import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/onboarding/onboarding_data.dart';

void main() {
  late OnboardingData data;
  setUp(() => data = OnboardingData()..startMode(AppMode.foyer));
  tearDown(() => data.dispose());

  test('B01: un membre sans prénom porte son rôle et son numéro', () {
    data.setCount(MemberRole.adulte, 3);
    expect(data.displayName(data.members.lastWhere((m) => m.role == MemberRole.adulte)), 'Adulte 3');
  });

  for (final role in [MemberRole.enfant, MemberRole.bebe]) {
    test('B02: le cuisinier devenu ${role.name} revient à tour de rôle', () {
      final member = MemberDraft.blank(data.members.first.id, role)..firstName = data.members.first.firstName;
      expect(data.saveMember(member), isNull);
      expect(data.mainCookId, isNull);
    });
  }

  test('B02: un cuisinier restant adulte conserve son attribution', () {
    final member = data.members.first.copy()..firstName = 'Alex';
    data.saveMember(member);
    expect(data.mainCookId, member.id);
  });

  for (final role in MemberRole.values) {
    test('B03: ajout refusé au maximum ${role.name}, données intactes', () {
      data.setCount(role, OnboardingData.maxPerRole[role]!);
      final before = [...data.members];
      final budget = data.budgetEuros;
      data.saveMember(data.newMember(role));
      expect(data.members, orderedEquals(before));
      expect(data.budgetEuros, budget);
    });
  }

  test('B03: changement de rôle refusé quand le rôle cible est complet', () {
    data.setCount(MemberRole.enfant, OnboardingData.maxPerRole[MemberRole.enfant]!);
    final before = [...data.members];
    data.saveMember(data.members.first.copy()..role = MemberRole.enfant);
    expect(data.members, orderedEquals(before));
    expect(data.mainCookId, before.first.id);
  });

  test('B03: impossible de supprimer le dernier adulte dans le modèle', () {
    data.setCount(MemberRole.adulte, 1);
    final adult = data.members.firstWhere((m) => m.role == MemberRole.adulte);
    data.removeMember(adult);
    expect(data.members, contains(adult));
    expect(data.count(MemberRole.adulte), 1);
  });

  test('B03: impossible de transformer le dernier adulte', () {
    data.setCount(MemberRole.adulte, 1);
    final before = [...data.members];
    data.saveMember(data.members.first.copy()..role = MemberRole.enfant);
    expect(data.members, orderedEquals(before));
  });

  test('B03: compteur excessif refusé sans réduction silencieuse', () {
    final before = [...data.members];
    data.setCount(MemberRole.adulte, 9);
    expect(data.members, orderedEquals(before));
  });

  test('identifiants, allergies, exclusions et budget personnalisé conservés', () {
    data.allergens.add('lait');
    data.excludedFoods.add('Tofu');
    data.budgetEdited = true;
    data.budgetEuros = 123;
    final member = data.members.last.copy()..firstName = 'Em';
    final ids = data.members.map((m) => m.id).toSet();
    final allergies = {...data.allAllergens};
    data.saveMember(member);
    expect(data.members.map((m) => m.id).toSet(), ids);
    expect(data.allAllergens, allergies);
    expect(member.allergens, {'fruits_a_coque'});
    expect(data.excludedFoods, ['Tofu']);
    expect(data.budgetEuros, 123);
  });

  for (final locale in ['fr', 'en', 'de']) {
    test('B01: noms et allergies traduits en $locale sans changer les codes', () {
      final l = lookupL(Locale(locale));
      data.setCount(MemberRole.adulte, 3);
      final member = data.members.lastWhere((m) => m.role == MemberRole.adulte);
      member.allergens.add('soja');
      data.allergens.add('lait');
      data.excludedFoods.add('Tofu');
      final ids = data.members.map((m) => m.id).toList();
      expect(data.displayName(member, l), '${l.roleAdult} 3');
      expect(data.displayName(data.members.first, l), 'Thomas');
      expect(data.memberAllergenNames(l)['soja'], ['${l.roleAdult} 3']);
      expect(data.allAllergens, {'lait', 'soja', 'fruits_a_coque'});
      expect(data.members.map((m) => m.id), ids);
      expect(data.excludedFoods, ['Tofu']);
    });
  }

  test('B03: refus sans notification, budget, cuisinier ni données modifiés', () {
    data.setCount(MemberRole.adulte, 1);
    var notifications = 0;
    data.addListener(() => notifications++);
    final before = [...data.members];
    final budget = data.budgetEuros;
    final cook = data.mainCookId;
    expect(data.setCount(MemberRole.adulte, 0), isNotNull);
    expect(data.removeMember(data.members.first), isNotNull);
    expect(data.saveMember(data.members.first.copy()..role = MemberRole.bebe), isNotNull);
    expect(data.members, orderedEquals(before));
    expect(data.budgetEuros, budget);
    expect(data.mainCookId, cook);
    expect(notifications, 0);
  });

  test('B03: suppression vérifie le rôle enregistré et non celui du brouillon', () {
    data.setCount(MemberRole.adulte, 1);
    final draft = data.members.first.copy()..role = MemberRole.enfant;
    expect(data.canRemove(draft), isFalse);
    expect(data.removeMember(draft), isNotNull);
    expect(data.count(MemberRole.adulte), 1);
  });

  test('B02: annuler un brouillon conserve le cuisinier et les allergies', () {
    final original = data.members.first;
    final draft = original.copy()..role = MemberRole.bebe;
    draft.allergens.add('soja');
    expect(data.mainCookId, original.id);
    expect(original.role, MemberRole.adulte);
    expect(original.allergens, isEmpty);
  });

  test('B03: édition à effectif maximal autorisée sans ajouter de membre', () {
    data.setCount(MemberRole.adulte, 8);
    final draft = data.members.first.copy()..firstName = 'Alex';
    expect(data.saveMember(draft), isNull);
    expect(data.count(MemberRole.adulte), 8);
    expect(data.members.first.firstName, 'Alex');
  });

  for (final locale in ['fr', 'en', 'de']) {
    test('B03: retirer un enfant inexistant donne le bon message en $locale', () {
      final l = lookupL(Locale(locale));
      data.setCount(MemberRole.enfant, 0);
      final error = data.setCount(MemberRole.enfant, -1);
      expect(error, isNotNull);
      expect(error!.message(l), l.householdRoleMinimumError(0, l.roleChild));
      expect(error.message(l), isNot(l.householdLastAdultError));
      expect(data.count(MemberRole.enfant), 0);
    });
  }
}
