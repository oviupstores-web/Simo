import 'dart:async';

import 'package:flutter/foundation.dart';

import '../local_storage/draft_database.dart';
import '../local_storage/local_draft.dart';
import '../local_storage/pantry_codec.dart';
import '../local_storage/pantry_draft_section.dart';
import '../local_storage/pantry_form_checkpoint.dart';
import '../local_storage/draft_checkpoint_clock.dart';
import '../local_storage/family_draft_repository.dart';
import '../local_storage/solo_draft_repository.dart' show copySoloJson;
import 'onboarding_data.dart';

const familyStepNames = [
  'household',
  'members',
  'grid',
  'budget',
  'constraints',
  'management',
  'cuisines',
  'kitchen',
  'summary',
];

/// Family snapshots include only Family answers and its own pantry.
class FamilyDraftSession extends ChangeNotifier {
  FamilyDraftSession(this.data, this.repository, {DraftCheckpointClock? clock})
    : clock = clock ?? DraftCheckpointClock() {
    data.addListener(_changed);
  }
  DateTime? get updatedAt => _latest?.updatedAt;
  final DraftCheckpointClock clock;
  final OnboardingData data;
  final FamilyDraftRepository repository;
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
  PantryFormCheckpoint pantryForms = const PantryFormCheckpoint();
  String? pantryScreen;
  bool pantryFromSummary = false;

  void setManualForm(Map<String, Object?>? value, {bool persist = true}) {
    pantryForms = pantryForms.withManual(value);
    if (persist && _active && data.isFoyer) _capture();
  }

  void setQuickForm(Map<String, Object?>? value, {bool persist = true}) {
    pantryForms = pantryForms.withQuick(value);
    if (persist && _active && data.isFoyer) _capture();
  }

  Future<void> initialize() async {
    if (_loaded) return;
    try {
      final draft = await repository.load();
      if (draft != null) {
        if (draft.id != FamilyDraftRepository.id || draft.journey != DraftJourney.family) {
          throw const DraftStorageException('family_identity_invalid');
        }
        final restoredPantry = PantryDraftSection.restore(PantryDraftSection.read(draft));
        final answer = draft.answers;
        final forms = PantryFormCheckpoint.read(answer['pantryForms']);
        final savedPantryScreen = answer['pantryScreen'];
        if (savedPantryScreen != null && !const ['hub', 'manual', 'quick'].contains(savedPantryScreen)) {
          throw const FormatException('family_pantry_route_invalid');
        }
        final savedFromSummary = answer['pantryFromSummary'] ?? false;
        if (savedFromSummary is! bool) throw const FormatException('family_pantry_context_invalid');
        if (answer['familyPayloadVersion'] != 1) throw const FormatException('family_format_unknown');
        final stack = (answer['routeStack'] as List).map((e) => Map<String, Object?>.from(e as Map)).toList();
        for (final route in stack) {
          if ((!familyStepNames.contains(route['step']) && route['step'] != 'memberEdit') ||
              route['editing'] is! bool) {
            throw const FormatException('family_route_invalid');
          }
        }
        final completed = (answer['completedSteps'] as List).cast<String>();
        if (completed.any((step) => !familyStepNames.contains(step))) {
          throw const FormatException('family_step_invalid');
        }
        final inputs = Map<String, String>.from(answer['rawInputs'] as Map);
        final values = Map<String, Object?>.from(answer['acceptedAnswers'] as Map);
        final resume = answer['resumeRequested'] as bool;
        final edits = <int, Map<String, Object?>>{
          for (final e in (answer['memberEdits'] as Map).entries)
            int.parse(e.key as String): Map<String, Object?>.from(e.value as Map),
        };
        for (final route in stack.where((r) => r['step'] == 'memberEdit')) {
          final edit = edits[route['memberId']];
          if (edit == null || edit['isNew'] != route['isNew']) throw const FormatException('family_edit_route_invalid');
        }
        final numbered = stack.where((r) => familyStepNames.contains(r['step'])).toList();
        if (resume && stack.isEmpty) throw const FormatException('family_route_missing');
        if (savedPantryScreen != null && (!resume || numbered.isEmpty || numbered.last['step'] != 'management')) {
          throw const FormatException('family_pantry_checkpoint_invalid');
        }
        if (stack.isNotEmpty &&
            (numbered.isEmpty || familyStepNames.indexOf(numbered.last['step'] as String) + 1 != draft.step)) {
          throw const FormatException('family_checkpoint_mismatch');
        }
        final decoded = OnboardingData();
        try {
          decoded.restoreFamilyAnswers(values, inputs, edits);
        } finally {
          decoded.dispose();
        }
        data.restorePantry(AppMode.foyer, restoredPantry);
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
        pantryForms = forms;
        pantryScreen = savedPantryScreen as String?;
        pantryFromSummary = savedFromSummary;
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
    if (!_loaded || !data.isFoyer) return false;
    _restoring = true;
    try {
      if (_latest == null) {
        final fresh = OnboardingData()
          ..startMode(AppMode.foyer)
          ..initializeBudgetCurrency('EUR');
        try {
          data.restoreFamilyAnswers(fresh.exportFamilyAnswers(), {}, {});
        } finally {
          fresh.dispose();
        }
      } else {
        final answers = _latest!.answers;
        data.restoreFamilyAnswers(
          Map<String, Object?>.from(answers['acceptedAnswers'] as Map),
          Map<String, String>.from(answers['rawInputs'] as Map),
          {
            for (final e in (answers['memberEdits'] as Map).entries)
              int.parse(e.key as String): Map<String, Object?>.from(e.value as Map),
          },
        );
      }
      data.restorePantry(
        AppMode.foyer,
        _latest == null ? [] : PantryDraftSection.restore(PantryDraftSection.read(_latest!)),
      );
      return true;
    } catch (_) {
      errorStage = 'load';
      _loaded = false;
      notifyListeners();
      return false;
    } finally {
      _restoring = false;
    }
  }

  void checkpoint(
    List<Map<String, Object?>> routes, {
    required bool visibleFamily,
    required bool pantryDetour,
    String? pantrySubscreen,
    bool fromSummary = false,
  }) {
    if (!_loaded || _closed || !data.isFoyer) return;
    _active = visibleFamily || pantryDetour;
    if (routes.isNotEmpty) {
      routeStack
        ..clear()
        ..addAll(routes);
      final numbered = routes.where((r) => familyStepNames.contains(r['step'])).toList();
      if (numbered.isNotEmpty) currentStep = familyStepNames.indexOf(numbered.last['step'] as String) + 1;
    }
    resumeRequested = visibleFamily || pantryDetour;
    pantryScreen = pantryDetour ? (pantrySubscreen ?? 'hub') : null;
    pantryFromSummary = pantryDetour && fromSummary;
    if (_active) {
      _capture();
    } else {
      _captureMetadataOnly();
    }
  }

  void markCompleted(String step) {
    if (!_active || !data.isFoyer) return;
    completedSteps.add(step);
    _capture();
  }

  void _changed() {
    if (_restoring || !_loaded || _closed) return;
    if (!data.isFoyer) {
      _active = false;
    } else if (_active) {
      _capture();
    }
  }

  Map<String, Object?> get _metadata => {
    'familyPayloadVersion': 1,
    'resumeRequested': resumeRequested,
    'routeStack': routeStack,
    'completedSteps': completedSteps.toList(),
    'calculationStatus': 'localProvisional',
    'pantryScreen': pantryScreen,
    'pantryFromSummary': pantryFromSummary,
  };

  void _capture() {
    try {
      if (data.budgetCurrencyCode == null && !data.budgetCurrencyUnknown) data.initializeBudgetCurrency('EUR');
      final pantry = PantryDraftSection.capture(DraftJourney.family, data.pantry, _latest);
      final answers = copySoloJson({
        ...?_latest?.answers,
        ..._metadata,
        'pantryPayloadVersion': PantryCodec.version,
        'pantryForms': pantryForms.toJson(),
        'acceptedAnswers': {
          if (_latest != null) ...Map<String, Object?>.from(_latest!.answers['acceptedAnswers'] as Map),
          ...data.exportFamilyAnswers(),
        },
        'rawInputs': data.familyInputs,
        'memberEdits': {for (final e in data.familyMemberEdits.entries) e.key.toString(): e.value},
      });
      _enqueue(
        LocalDraft(
          id: FamilyDraftRepository.id,
          journey: DraftJourney.family,
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
