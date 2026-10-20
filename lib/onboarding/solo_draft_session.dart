import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local_storage/draft_database.dart';
import '../local_storage/local_draft.dart';
import '../local_storage/pantry_codec.dart';
import '../local_storage/pantry_draft_section.dart';
import '../local_storage/draft_checkpoint_clock.dart';
import '../local_storage/solo_draft_repository.dart';
import 'onboarding_data.dart';

const soloStepNames = [
  'goal',
  'profile',
  'activity',
  'scale',
  'grid',
  'budget',
  'management',
  'constraints',
  'cuisines',
  'kitchen',
  'summary',
];

/// Persists Solo answers and its pantry; owns no Family fields or calculations.
class SoloDraftSession extends ChangeNotifier {
  SoloDraftSession(this.data, this.repository, {this.familyEnabled = false, DraftCheckpointClock? clock})
    : clock = clock ?? DraftCheckpointClock() {
    data.addListener(_changed);
  }
  final bool familyEnabled;
  final DraftCheckpointClock clock;
  DateTime? get updatedAt => _latest?.updatedAt;
  final OnboardingData data;
  final SoloDraftRepository repository;
  LocalDraft? _latest;
  LocalDraft? _pending;
  Future<void>? _writing;
  bool _loaded = false;
  bool _active = false;
  bool _restoring = false;
  bool _closed = false;
  Future<void>? _closing;
  String? errorStage;
  bool resumeRequested = false;
  final List<Map<String, Object?>> routeStack = [];
  final Set<String> completedSteps = {};
  int currentStep = 1;

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final draft = await repository.load();
      if (draft != null) {
        if (draft.id != SoloDraftRepository.soloId || draft.journey != DraftJourney.solo) {
          throw const DraftStorageException('solo_identity_invalid');
        }
        final restoredPantry = PantryDraftSection.restore(PantryDraftSection.read(draft));
        final answer = draft.answers;
        if (answer['soloPayloadVersion'] != 1) throw const FormatException('solo_format_unknown');
        final stack = (answer['routeStack'] as List).map((e) => Map<String, Object?>.from(e as Map)).toList();
        for (final route in stack) {
          if (!soloStepNames.contains(route['step']) || route['editing'] is! bool) {
            throw const FormatException('solo_route_invalid');
          }
        }
        final completed = (answer['completedSteps'] as List).cast<String>();
        if (completed.any((step) => !soloStepNames.contains(step))) throw const FormatException('solo_step_invalid');
        final inputs = Map<String, String>.from(answer['rawInputs'] as Map);
        final values = Map<String, Object?>.from(answer['acceptedAnswers'] as Map);
        final resume = answer['resumeRequested'] as bool;
        if (resume && stack.isEmpty) throw const FormatException('solo_route_missing');
        if (stack.isNotEmpty && soloStepNames.indexOf(stack.last['step'] as String) + 1 != draft.step) {
          throw const FormatException('solo_checkpoint_mismatch');
        }
        _restoring = true;
        try {
          if (resume && !familyEnabled) {
            data.restoreSoloAnswers(values, inputs);
          } else {
            final decoded = OnboardingData();
            try {
              decoded.restoreSoloAnswers(values, inputs);
            } finally {
              decoded.dispose();
            }
          }
        } finally {
          _restoring = false;
        }
        data.restorePantry(AppMode.solo, restoredPantry);
        _latest = draft;
        clock.observe(draft.updatedAt);
        currentStep = draft.step;
        routeStack
          ..clear()
          ..addAll(stack);
        completedSteps
          ..clear()
          ..addAll(completed);
        resumeRequested = resume;
      }
      _loaded = true;
      errorStage = null;
    } catch (_) {
      // Failed reads never turn into writes of defaults over an existing draft.
      errorStage = 'load';
    }
    notifyListeners();
  }

  Future<bool> enter() async {
    await initialize();
    if (!_loaded || data.isFoyer) return false;
    if (_latest == null && familyEnabled) {
      final fresh = OnboardingData()..initializeBudgetCurrency('EUR');
      try {
        data.restoreSoloAnswers(fresh.exportSoloAnswers(), {});
      } finally {
        fresh.dispose();
      }
    }
    if (_latest != null) {
      _restoring = true;
      try {
        data.restoreSoloAnswers(
          Map<String, Object?>.from(_latest!.answers['acceptedAnswers'] as Map),
          Map<String, String>.from(_latest!.answers['rawInputs'] as Map),
        );
      } finally {
        _restoring = false;
      }
    }
    data.restorePantry(
      AppMode.solo,
      _latest == null ? [] : PantryDraftSection.restore(PantryDraftSection.read(_latest!)),
    );
    return true;
  }

  void checkpoint(List<Map<String, Object?>> routes, {required bool visibleSolo, required bool pantryDetour}) {
    if (!_loaded || _closed || data.isFoyer) return;
    _active = visibleSolo || pantryDetour;
    if (routes.isNotEmpty) {
      routeStack
        ..clear()
        ..addAll(routes);
      currentStep = soloStepNames.indexOf(routes.last['step'] as String) + 1;
    }
    resumeRequested = visibleSolo || pantryDetour;
    if (_active) {
      _capture();
    } else {
      _captureMetadataOnly();
    }
  }

  void markCompleted(String step) {
    if (!_active || data.isFoyer) return;
    completedSteps.add(step);
    _capture();
  }

  void _changed() {
    if (_restoring || !_loaded || _closed) return;
    if (data.isFoyer) {
      _active = false;
      if (familyEnabled) return;
      resumeRequested = false;
      _captureMetadataOnly();
    } else if (_active) {
      _capture();
    }
  }

  Map<String, Object?> get _metadata => {
    'soloPayloadVersion': 1,
    'resumeRequested': resumeRequested,
    'routeStack': routeStack,
    'completedSteps': completedSteps.toList(),
    'calculationStatus': 'localProvisional',
  };

  void _capture() {
    try {
      if (data.budgetCurrencyCode == null && !data.budgetCurrencyUnknown) data.initializeBudgetCurrency('EUR');
      final pantry = PantryDraftSection.capture(DraftJourney.solo, data.pantry, _latest);
      final answers = copySoloJson({
        ...?_latest?.answers,
        ..._metadata,
        'pantryPayloadVersion': PantryCodec.version,
        'acceptedAnswers': {
          if (_latest != null) ...Map<String, Object?>.from(_latest!.answers['acceptedAnswers'] as Map),
          ...data.exportSoloAnswers(),
        },
        'rawInputs': data.soloInputs,
      });
      _enqueue(
        LocalDraft(
          id: SoloDraftRepository.soloId,
          journey: DraftJourney.solo,
          step: currentStep,
          management: switch (data.management) {
            ManagementMode.courses => DraftManagement.shopping,
            ManagementMode.reserves => DraftManagement.pantry,
            ManagementMode.mixte => DraftManagement.mixed,
          },
          currency: data.budgetCurrencyCode ?? (data.budgetCurrencyUnknown ? 'XXX' : 'EUR'),
          updatedAt: clock.next(),
          answers: answers,
          pantry: [PantryCodec.toMap(pantry)],
        ),
      );
    } catch (_) {
      errorStage = 'save';
      notifyListeners();
    }
  }

  void _captureMetadataOnly() {
    final previous = _latest;
    if (previous == null) return;
    _enqueue(
      LocalDraft(
        id: previous.id,
        journey: previous.journey,
        step: currentStep,
        management: previous.management,
        currency: previous.currency,
        updatedAt: clock.next(),
        answers: copySoloJson({...previous.answers, ..._metadata}),
        pantry: previous.pantry,
      ),
    );
  }

  void _enqueue(LocalDraft draft) {
    _latest = draft;
    _pending = draft;
    _startWriting();
  }

  void _startWriting() {
    if (_writing != null) return;
    // Start on a microtask so the field is set even if a synchronous adapter fails.
    _writing = Future<void>.microtask(_drain).whenComplete(() {
      _writing = null;
      if (_pending != null && errorStage != 'save') _startWriting();
    });
  }

  Future<void> _drain() async {
    while (_pending != null) {
      final writing = _pending!;
      _pending = null;
      try {
        await repository.save(writing);
        final hadError = errorStage != null;
        errorStage = null;
        if (hadError) notifyListeners();
      } catch (_) {
        _pending ??= writing;
        errorStage = 'save';
        notifyListeners();
        return;
      }
    }
  }

  Future<bool> flush() async {
    if (!_loaded) return false;
    if (_writing == null && _pending != null) _startWriting();
    await _writing;
    return _pending == null && errorStage == null;
  }

  Future<void> close() => _closing ??= _close();
  Future<void> _close() async {
    if (_closed) return;
    _closed = true;
    data.removeListener(_changed);
    await flush();
    await repository.close();
  }
}
