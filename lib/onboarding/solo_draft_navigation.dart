import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../navigation.dart';
import '../screens/entry/path_choice_screen.dart';
import '../screens/onboarding/cover_solo_screen.dart';
import '../screens/pantry/pantry_add_manual_screen.dart';
import '../screens/pantry/pantry_quick_check_screen.dart';
import 'onboarding_flow.dart';
import 'solo_draft_session.dart';
import 'family_draft_session.dart';
import 'family_draft_navigation.dart';
import 'onboarding_data.dart';

const soloRoutePrefix = 'onboarding.step.';
const pantryDetourRoute = 'onboarding.pantry';
const pantryManualRoute = 'onboarding.pantry.manual';
const pantryQuickRoute = 'onboarding.pantry.quick';

class SoloDraftRouteObserver extends NavigatorObserver {
  SoloDraftRouteObserver(this.session);
  final SoloDraftSession session;
  final List<Route<dynamic>> _routes = [];
  bool replaying = false;
  bool _bootstrapping = true;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
    _checkpoint();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _checkpoint();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _checkpoint();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = _routes.indexOf(oldRoute!);
    if (index >= 0 && newRoute != null) _routes[index] = newRoute;
    _checkpoint();
  }

  void _checkpoint() {
    if (replaying || session.data.isFoyer) return;
    final pages = _routes.whereType<PageRoute>().toList();
    final top = pages.lastOrNull;
    if (_bootstrapping && pages.length <= 1 && !(top?.settings.name?.startsWith(soloRoutePrefix) ?? false)) return;
    final names = pages.map((r) => r.settings.name);
    final hub = pages.where((r) => r.settings.name == pantryDetourRoute).lastOrNull;
    final pantrySubscreen = top?.settings.name == pantryManualRoute
        ? 'manual'
        : top?.settings.name == pantryQuickRoute
        ? 'quick'
        : 'hub';
    session.checkpoint(
      [
        for (final route in pages)
          if (route.settings.name?.startsWith(soloRoutePrefix) ?? false)
            {
              'step': route.settings.name!.substring(soloRoutePrefix.length),
              'editing': route.settings.arguments == true,
            },
      ],
      visibleSolo: top?.settings.name?.startsWith(soloRoutePrefix) ?? false,
      pantryDetour: names.contains(pantryDetourRoute),
      pantrySubscreen: pantrySubscreen,
      fromSummary: hub?.settings.arguments == true,
    );
  }

  void finishReplay() {
    replaying = false;
    _bootstrapping = false;
    _checkpoint();
  }
}

/// Mounted underneath the existing splash, only after storage initialization.
class SoloDraftResumeHost extends StatefulWidget {
  const SoloDraftResumeHost({
    super.key,
    required this.session,
    required this.observer,
    required this.startupDone,
    required this.child,
    this.family,
    this.familyObserver,
  });
  final SoloDraftSession session;
  final SoloDraftRouteObserver observer;
  final FamilyDraftSession? family;
  final FamilyDraftRouteObserver? familyObserver;
  final Widget child;
  final ValueNotifier<bool> startupDone;
  @override
  State<SoloDraftResumeHost> createState() => _SoloDraftResumeHostState();
}

class _SoloDraftResumeHostState extends State<SoloDraftResumeHost> {
  String? _shownError;
  @override
  void initState() {
    super.initState();
    widget.session.addListener(_error);
    widget.family?.addListener(_error);
    widget.startupDone.addListener(_resume);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _error();
      _resume();
    });
  }

  bool _resumed = false;
  void _resume() {
    if (!widget.startupDone.value || _resumed) return;
    _error();
    _resumed = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final family = widget.family;
      final familyIsLatest =
          family?.resumeRequested == true &&
          (!widget.session.resumeRequested ||
              widget.session.updatedAt == null ||
              !family!.updatedAt!.isBefore(widget.session.updatedAt!));
      if (familyIsLatest && family!.resumeRequested && widget.familyObserver != null) {
        widget.session.data.update(() => widget.session.data.mode = AppMode.foyer);
        if (await family.enter() && mounted) {
          resumeFamilyRoutes(context, family, widget.familyObserver!);
        }
        widget.observer.finishReplay();
      } else if (!familyIsLatest && widget.session.resumeRequested) {
        if (widget.session.familyEnabled && !await widget.session.enter()) return;
        if (!mounted) return;
        resumeSoloRoutes(context, widget.session, widget.observer);
      } else {
        widget.observer.finishReplay();
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void _error() {
    final stage = widget.family?.errorStage ?? widget.session.errorStage;
    if (!widget.startupDone.value && stage != null) return;
    if (stage == null) {
      _shownError = null;
      return;
    }
    if (_shownError == stage) return;
    _shownError = stage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = L.of(context);
      showMenooMessage(context, stage == 'load' ? l.soloDraftLoadError : l.soloDraftSaveError);
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  void dispose() {
    widget.session.removeListener(_error);
    widget.family?.removeListener(_error);
    widget.startupDone.removeListener(_resume);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

void resumeSoloRoutes(
  BuildContext context,
  SoloDraftSession session,
  SoloDraftRouteObserver observer, {
  bool includeEntry = true,
}) {
  final stack = session.routeStack.map((e) => Map<String, Object?>.from(e)).toList();
  observer.replaying = true;
  final nav = Navigator.of(context);
  void restore(Widget screen, {String? name, bool editing = false}) => nav.push(
    _RestoredSoloRoute(
      settings: RouteSettings(name: name, arguments: editing),
      builder: (_) => screen,
    ),
  );
  if (includeEntry) {
    restore(const PathChoiceScreen());
    restore(const CoverSoloScreen());
  }
  for (final item in stack) {
    final step = OnbStep.values.byName(item['step'] as String);
    restore(OnboardingFlow.screenFor(step), name: '$soloRoutePrefix${step.name}', editing: item['editing'] as bool);
  }
  if (session.pantryScreen != null) {
    restore(
      OnboardingFlow.restoredPantryHub(context, session.pantryFromSummary),
      name: pantryDetourRoute,
      editing: session.pantryFromSummary,
    );
    if (session.pantryScreen == 'manual') restore(const PantryAddManualScreen(), name: pantryManualRoute);
    if (session.pantryScreen == 'quick') restore(const PantryQuickCheckScreen(), name: pantryQuickRoute);
  }
  observer.finishReplay();
}

/// Replay instantly; subsequent back gestures retain the original theme transition.
class _RestoredSoloRoute extends MaterialPageRoute<void> {
  _RestoredSoloRoute({required super.builder, super.settings});
  @override
  AnimationController createAnimationController() => super.createAnimationController()..value = 1;
}
