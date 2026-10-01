import 'dart:math' as math;

import '../l10n/app_localizations.dart';
import '../l10n/formats.dart';

import 'package:flutter/material.dart' show ChangeNotifier, DateUtils, VoidCallback;

import '../models/pantry_location.dart';

export '../models/pantry_location.dart';

/// Valeurs alignées sur les types de la base (supabase/migrations/…_schema.sql).
enum HealthGoal { pertePoids, priseMasse, seche, maintien }

enum Sex { homme, femme }

enum ActivityLevel { sedentaire, modere, actif, tresActif }

enum MealType { petitDejeuner, dejeuner, diner }

enum ManagementMode { courses, reserves, mixte }

enum CookingLevel { debutant, intermediaire, confirme }


enum AppMode { solo, foyer }

/// Rôle d'un membre du foyer (enum `member_role` de la base).
enum MemberRole {
  adulte(14, 100, 1),
  enfant(4, 13, 0.65),
  bebe(0, 3, 0.3);

  const MemberRole(this.minAge, this.maxAge, this.portion);

  /// Libellé court (« Adulte »).
  String label(L l) => switch (this) {
    MemberRole.adulte => l.roleAdult,
    MemberRole.enfant => l.roleChild,
    MemberRole.bebe => l.roleBaby,
  };

  /// Libellé du groupe, avec la tranche d'âge (« Adultes (14 ans et plus) »).
  String groupLabel(L l) => switch (this) {
    MemberRole.adulte => l.roleAdultGroup,
    MemberRole.enfant => l.roleChildGroup,
    MemberRole.bebe => l.roleBabyGroup,
  };
  final int minAge;
  final int maxAge;

  /// Part d'une portion adulte (enfants : environ 60 à 70 %).
  final double portion;
}

/// Membre du foyer saisi pendant l'onboarding Foyer (enregistré à la création du compte).
class MemberDraft {
  MemberDraft({
    required this.id,
    required this.role,
    this.firstName = '',
    this.sex = Sex.homme,
    required this.age,
    this.heightCm,
    this.weightKg,
    this.goal = HealthGoal.maintien,
    this.activity = ActivityLevel.modere,
    Set<String>? allergens,
  }) : allergens = allergens ?? {};

  /// Identifiant local (la base attribuera un uuid).
  final int id;
  MemberRole role;
  String firstName;
  Sex sex;
  int age;
  int? heightCm;
  double? weightKg;
  HealthGoal goal;
  ActivityLevel activity;
  final Set<String> allergens;

  /// Membre par défaut pour un rôle (valeurs modifiables ensuite).
  factory MemberDraft.blank(int id, MemberRole role) => switch (role) {
    MemberRole.adulte => MemberDraft(id: id, role: role, age: 35, heightCm: 170, weightKg: 70),
    MemberRole.enfant => MemberDraft(
      id: id,
      role: role,
      age: 8,
      heightCm: 130,
      weightKg: 26,
      activity: ActivityLevel.actif,
    ),
    MemberRole.bebe => MemberDraft(id: id, role: role, age: 1),
  };

  String ageLabel(L l) => age == 0 ? l.roleAgeMonths : l.roleAgeYears(age);

  /// Copie de travail pour la fiche d'édition (validée par « Enregistrer »).
  MemberDraft copy() => MemberDraft(
    id: id,
    role: role,
    firstName: firstName,
    sex: sex,
    age: age,
    heightCm: heightCm,
    weightKg: weightKg,
    goal: goal,
    activity: activity,
    allergens: {...allergens},
  );
}

/// Coche ou décoche un élément d'un choix multiple.
extension SetToggle<T> on Set<T> {
  void toggle(T x) {
    if (!remove(x)) add(x);
  }
}

/// Un créneau de la grille des repas (jour 1 = lundi).
typedef MealSlot = (int day, MealType meal);

/// Produit ajouté à la réserve pendant l'onboarding (enregistré à la création du compte).
class PantryDraft {
  PantryDraft({
    required this.name,
    required this.quantity,
    required this.unitLabel,
    required this.location,
    this.expiresOn,
    this.source = 'manuel',
  });

  final String name;
  final double quantity;

  /// Unité telle que saisie (« pièce(s) », « g », « kg »…), convertie en g/ml/pièce à l'enregistrement.
  final String unitLabel;
  final PantryLocation location;
  final DateTime? expiresOn;
  final String source;

  int? get daysLeft {
    if (expiresOn == null) return null;
    final today = DateUtils.dateOnly(DateTime.now());
    return DateUtils.dateOnly(expiresOn!).difference(today).inDays;
  }
}

/// Réponses de l'onboarding (Solo ou Foyer), en mémoire jusqu'à la création du compte (jalon 6).
class OnboardingData extends ChangeNotifier {
  // Mode choisi sur path_choice
  AppMode mode = AppMode.solo;
  bool get isFoyer => mode == AppMode.foyer;

  // Foyer, étapes 1-2 — composition et profils (famille Martin de SPEC §9 par défaut)
  final List<MemberDraft> members = [
    MemberDraft(
      id: 1,
      role: MemberRole.adulte,
      firstName: 'Thomas',
      age: 38,
      heightCm: 182,
      weightKg: 84,
      activity: ActivityLevel.actif,
    ),
    MemberDraft(
      id: 2,
      role: MemberRole.adulte,
      firstName: 'Sarah',
      sex: Sex.femme,
      age: 35,
      heightCm: 168,
      weightKg: 62,
    ),
    MemberDraft(
      id: 3,
      role: MemberRole.enfant,
      firstName: 'Lucas',
      age: 9,
      heightCm: 134,
      weightKg: 29,
      activity: ActivityLevel.actif,
    ),
    MemberDraft(
      id: 4,
      role: MemberRole.enfant,
      firstName: 'Emma',
      sex: Sex.femme,
      age: 6,
      heightCm: 116,
      weightKg: 21,
      activity: ActivityLevel.actif,
      allergens: {'fruits_a_coque'},
    ),
  ];
  int _nextMemberId = 5;

  // Foyer, étape 8 — qui cuisine le plus souvent (null = à tour de rôle)
  int? mainCookId = 1;

  /// Vrai dès que l'utilisateur a choisi son budget lui-même (on ne le recalcule plus).
  bool budgetEdited = false;

  // Étape 1 — objectif
  HealthGoal goal = HealthGoal.pertePoids;
  // Étape 2 — profil
  Sex sex = Sex.homme;
  int age = 32;
  int heightCm = 180;
  double weightKg = 75;
  // Étape 2 (suite) — poids visé et rythme (retours jalon 4 ; rien pour « maintien »)
  double? targetWeightKg;
  double weeklyRateKg = 0.5;
  // Étape 3 — activité
  ActivityLevel activity = ActivityLevel.modere;
  // Étape 4 — balance (optionnelle)
  bool wantsScale = false;
  // Étape 5 — grille des repas (par défaut : déjeuners et dîners)
  final Set<MealSlot> slots = {...soloDefaultSlots};
  // Étape 6 — budget hebdomadaire en euros (SPEC §6 : Solo ≈ 65 €)
  int budgetEuros = 65;
  // Étape 7 — mode de gestion
  ManagementMode management = ManagementMode.mixte;
  // Étape 8 — contraintes
  final Set<String> diets = {};
  final Set<String> allergens = {};
  final List<String> excludedFoods = [];
  // Étape 9 — types de cuisine appréciés (vide = toutes)
  final Set<String> cuisinePreferences = {};
  // Étape 9 — Ma cuisine
  CookingLevel cookingLevel = CookingLevel.intermediaire;
  int weekdayMinutes = 30;
  int weekendMinutes = 45;
  final Set<String> equipment = {'four', 'plaques', 'micro_ondes'};
  // Détour Réserve
  final List<PantryDraft> pantry = [];

  /// Notifie les écrans après une modification.
  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  // --- Mode et foyer -------------------------------------------------

  /// Choix du mode sur path_choice : valeurs de départ propres à chaque parcours
  /// (SPEC §6 : Solo ≈ 65 € ; Foyer ≈ 30 € × adultes + 20 € × enfants).
  void startMode(AppMode m) {
    if (mode == m) return;
    update(() {
      mode = m;
      budgetEdited = false;
      slots
        ..clear()
        ..addAll(m == AppMode.foyer ? foyerDefaultSlots : soloDefaultSlots);
      budgetEuros = m == AppMode.foyer ? recommendedBudget : 65;
    });
  }

  static final soloDefaultSlots = {
    for (var d = 1; d <= 7; d++) ...{(d, MealType.dejeuner), (d, MealType.diner)},
  };

  /// Foyer : tous les dîners + les déjeuners du week-end (repas pris en famille).
  static final foyerDefaultSlots = {
    for (var d = 1; d <= 7; d++) (d, MealType.diner),
    (6, MealType.dejeuner),
    (7, MealType.dejeuner),
  };

  /// Limites de composition du foyer.
  static const maxPerRole = {MemberRole.adulte: 8, MemberRole.enfant: 8, MemberRole.bebe: 4};
  static const minPerRole = {MemberRole.adulte: 1, MemberRole.enfant: 0, MemberRole.bebe: 0};

  int count(MemberRole role) => members.where((m) => m.role == role).length;

  /// Ajoute ou retire des membres d'un rôle (on retire toujours le dernier ajouté).
  void setCount(MemberRole role, int n) {
    final target = n.clamp(minPerRole[role]!, maxPerRole[role]!);
    update(() {
      while (count(role) < target) {
        members.add(MemberDraft.blank(_nextMemberId++, role));
      }
      while (count(role) > target) {
        final last = members.lastWhere((m) => m.role == role);
        members.remove(last);
        if (mainCookId == last.id) mainCookId = null;
      }
      _refreshBudget();
    });
  }

  MemberDraft newMember(MemberRole role) => MemberDraft.blank(_nextMemberId++, role);

  /// Ajoute (ou remplace) un membre après sa fiche d'édition.
  void saveMember(MemberDraft m) => update(() {
    final i = members.indexWhere((x) => x.id == m.id);
    i < 0 ? members.add(m) : members[i] = m;
    members.sort((a, b) => a.role.index.compareTo(b.role.index));
    _refreshBudget();
  });

  bool canRemove(MemberDraft m) => count(m.role) > minPerRole[m.role]!;

  void removeMember(MemberDraft m) => update(() {
    members.removeWhere((x) => x.id == m.id);
    if (mainCookId == m.id) mainCookId = null;
    _refreshBudget();
  });

  /// Nom affiché (prénom, ou « Adulte 2 » tant qu'il n'est pas renseigné).
  String displayName(MemberDraft m) {
    if (m.firstName.trim().isNotEmpty) return m.firstName.trim();
    final same = members.where((x) => x.role == m.role).toList();
    final i = same.indexWhere((x) => x.id == m.id);
    return '${m.role.label} ${i < 0 ? same.length + 1 : i + 1}';
  }

  int get peopleCount => isFoyer ? members.length : 1;

  /// Budget conseillé (SPEC §6), arrondi à 5 € ; 25 € par bébé (décision Simo).
  int get recommendedBudget {
    final raw = 30 * count(MemberRole.adulte) + 20 * count(MemberRole.enfant) + 25 * count(MemberRole.bebe);
    return ((raw / 5).round() * 5).clamp(20, 350);
  }

  void _refreshBudget() {
    if (isFoyer && !budgetEdited) budgetEuros = recommendedBudget;
  }

  /// Portions servies sur la semaine (une par personne et par repas planifié).
  int get weeklyPortions => plannedMeals * peopleCount;

  double get budgetPerPortion => weeklyPortions == 0 ? 0 : budgetEuros / weeklyPortions;

  /// Allergènes déclarés dans les profils : code → prénoms concernés.
  Map<String, List<String>> get memberAllergens {
    final map = <String, List<String>>{};
    for (final m in members) {
      for (final a in m.allergens) {
        (map[a] ??= []).add(displayName(m));
      }
    }
    return map;
  }

  /// Allergènes exclus pour tout le foyer (partagés + profils).
  Set<String> get allAllergens => isFoyer ? {...allergens, ...memberAllergens.keys} : allergens;

  // --- Poids cible ---------------------------------------------------

  /// Environ 7 700 kcal par kilo de masse corporelle.
  static const kcalPerKg = 7700;

  /// Seuil d'insuffisance pondérale (OMS).
  static const minBmi = 18.5;

  /// Perte maximale tolérée par semaine.
  static const maxLossPerWeek = 1.0;

  bool get needsTarget => goal != HealthGoal.maintien;

  /// Rythmes proposés selon l'objectif (sèche : déficit modéré fixe pour préserver le muscle).
  List<double> get rateOptions => switch (goal) {
    HealthGoal.pertePoids => const [0.25, 0.5, 0.75],
    HealthGoal.priseMasse => const [0.25, 0.5],
    HealthGoal.seche => const [0.5],
    HealthGoal.maintien => const [],
  };

  /// Rythme réellement appliqué (ramené à une valeur permise si l'objectif a changé).
  double get effectiveRate {
    final options = rateOptions;
    if (options.isEmpty) return 0;
    if (options.contains(weeklyRateKg)) return math.min(weeklyRateKg, maxLossPerWeek);
    return options.contains(0.5) ? 0.5 : options.first;
  }

  /// Poids minimal conseillé pour une taille donnée (IMC 18,5), arrondi au dixième supérieur.
  static double minHealthyWeight(int heightCm) => (minBmi * math.pow(heightCm / 100, 2) * 10).ceil() / 10;

  static double bmi(double weightKg, int heightCm) => weightKg / math.pow(heightCm / 100, 2);

  /// Message d'erreur si le poids visé n'est pas acceptable (null si tout va bien).
  String? targetError(L l, Formats fmt, {required double? target, required double current, required int heightCm}) {
    if (!needsTarget) return null;
    if (target == null) return l.targetErrorMissing;
    final losing = goal != HealthGoal.priseMasse;
    if (losing && target >= current) {
      return l.targetErrorLosing(fmt.weight(l, current));
    }
    if (!losing && target <= current) {
      return l.targetErrorGaining(fmt.weight(l, current));
    }
    final min = minHealthyWeight(heightCm);
    if (target < min) {
      final b = bmi(target, heightCm).toStringAsFixed(1).replaceAll('.', ',');
      return l.targetErrorTooLow(b, fmt.height(l, heightCm.toDouble()), fmt.weight(l, min));
    }
    return null;
  }

  /// Nombre de semaines pour atteindre le poids visé au rythme choisi.
  int? weeksToTarget({double? target, double? current}) {
    final t = target ?? targetWeightKg;
    final c = current ?? weightKg;
    if (!needsTarget || t == null || effectiveRate == 0) return null;
    return ((t - c).abs() / effectiveRate).ceil();
  }

  /// Date estimée d'atteinte du poids visé.
  DateTime? targetDate({double? target, double? current}) {
    final w = weeksToTarget(target: target, current: current);
    return w == null ? null : DateUtils.dateOnly(DateTime.now()).add(Duration(days: w * 7));
  }

  static String formatKg(double v) =>
      v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1).replaceAll('.', ',');

  static String formatRate(double r) => r.toString().replaceAll('.', ',');

  // --- Calculs -------------------------------------------------------

  int get plannedMeals => slots.length;

  /// Coût moyen disponible par repas planifié.
  double get budgetPerMeal => plannedMeals == 0 ? 0 : budgetEuros / plannedMeals;

  /// Besoin calorique journalier : Mifflin-St Jeor × activité, puis écart lié au rythme
  /// visé (0,5 kg/semaine ≈ 550 kcal/jour), jamais sous le métabolisme de base ni sous
  /// 1 500 kcal (homme) / 1 200 kcal (femme).
  int get dailyKcal {
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + (sex == Sex.homme ? 5 : -161);
    const factor = {
      ActivityLevel.sedentaire: 1.2,
      ActivityLevel.modere: 1.45,
      ActivityLevel.actif: 1.65,
      ActivityLevel.tresActif: 1.85,
    };
    final dailyDelta = effectiveRate * kcalPerKg / 7;
    final delta = switch (goal) {
      HealthGoal.pertePoids || HealthGoal.seche => -dailyDelta,
      HealthGoal.priseMasse => dailyDelta,
      HealthGoal.maintien => 0.0,
    };
    final floor = math.max(bmr, sex == Sex.homme ? 1500.0 : 1200.0);
    final kcal = math.max(bmr * factor[activity]! + delta, floor);
    return (kcal / 10).round() * 10;
  }

  /// Protéines : g/kg selon l'objectif ; lipides : 25 % des kcal ; glucides : le reste.
  ({int protein, int carbs, int fat}) get macros {
    const perKg = {
      HealthGoal.pertePoids: 1.8,
      HealthGoal.priseMasse: 1.8,
      HealthGoal.seche: 2.0,
      HealthGoal.maintien: 1.6,
    };
    final protein = (weightKg * perKg[goal]!).round();
    final fat = (dailyKcal * 0.25 / 9).round();
    final carbs = ((dailyKcal - protein * 4 - fat * 9) / 4).round();
    return (protein: protein, carbs: carbs, fat: fat);
  }
}
