import 'package:flutter/material.dart';

import '../screens/entry/path_choice_screen.dart';
import '../screens/onboarding/cover_household_screen.dart';
import '../screens/onboarding/member_profiles_screen.dart';
import 'onboarding_data.dart';
import 'onboarding_flow.dart';
import 'family_draft_session.dart';
import 'solo_draft_navigation.dart' show pantryDetourRoute;

const familyRoutePrefix = 'onboarding.family.step.';
const familyMemberRoute = 'onboarding.family.member';

class FamilyDraftRouteObserver extends NavigatorObserver {
  FamilyDraftRouteObserver(this.session);
  final FamilyDraftSession session;
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
    if (replaying || !session.data.isFoyer) return;
    final pages = _routes.whereType<PageRoute>().toList();
    final top = pages.lastOrNull;
    final visible =
        top?.settings.name == familyMemberRoute || (top?.settings.name?.startsWith(familyRoutePrefix) ?? false);
    if (_bootstrapping && pages.length <= 1 && !visible) return;
    session.checkpoint(
      [
        for (final route in pages)
          if (route.settings.name?.startsWith(familyRoutePrefix) ?? false)
            {
              'step': route.settings.name!.substring(familyRoutePrefix.length),
              'editing': route.settings.arguments == true,
            }
          else if (route.settings.name == familyMemberRoute)
            {'step': 'memberEdit', 'editing': false, ...Map<String, Object?>.from(route.settings.arguments as Map)},
      ],
      visibleFamily: visible,
      pantryDetour: pages.any((r) => r.settings.name == pantryDetourRoute),
    );
  }

  void finishReplay() {
    replaying = false;
    _bootstrapping = false;
    _checkpoint();
  }
}

void resumeFamilyRoutes(
  BuildContext context,
  FamilyDraftSession session,
  FamilyDraftRouteObserver observer, {
  bool includeEntry = true,
}) {
  final stack = session.routeStack.map((r) => Map<String, Object?>.from(r)).toList();
  observer.replaying = true;
  final nav = Navigator.of(context);
  void restore(Widget screen, {String? name, Object? arguments}) => nav.push(
    _RestoredFamilyRoute(
      settings: RouteSettings(name: name, arguments: arguments),
      builder: (_) => screen,
    ),
  );
  if (includeEntry) {
    restore(const PathChoiceScreen());
    restore(const CoverHouseholdScreen());
  }
  for (final item in stack) {
    if (item['step'] == 'memberEdit') {
      final edit = session.data.familyMemberEdits[item['memberId']]!;
      restore(
        MemberEditScreen(
          member: MemberDraft.fromDraftJson(Map<String, Object?>.from(edit['member'] as Map)),
          isNew: edit['isNew'] as bool,
        ),
        name: familyMemberRoute,
        arguments: {'memberId': item['memberId'], 'isNew': item['isNew']},
      );
    } else {
      final step = OnbStep.values.byName(item['step'] as String);
      restore(OnboardingFlow.screenFor(step), name: '$familyRoutePrefix${step.name}', arguments: item['editing']);
    }
  }
  observer.finishReplay();
}

class _RestoredFamilyRoute extends MaterialPageRoute<void> {
  _RestoredFamilyRoute({required super.builder, super.settings});
  @override
  AnimationController createAnimationController() => super.createAnimationController()..value = 1;
}
