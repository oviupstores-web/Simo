import 'dart:math' as math;

import '../l10n/app_localizations.dart';
import '../l10n/formats.dart';

import 'package:flutter/material.dart' show ChangeNotifier, DateUtils, Locale, VoidCallback;

import '../models/pantry_location.dart';
import '../models/numeric_safety.dart';

export '../models/pantry_location.dart';

/// Valeurs alignées sur les types de la base (supabase/migrations/…_schema.sql).
enum HealthGoal { pertePoids, priseMasse, seche, maintien }

enum Sex { homme, femme }

enum ActivityLevel { sedentaire, modere, actif, tresActif }

enum MealType { petitDejeuner, dejeuner, diner }

enum ManagementMode { courses, reserves, mixte }

enum CookingLevel { debutant, intermediaire, confirme }

enum AppMode { solo, foyer }

/// Refus de composition : aucune réponse existante n'est modifiée.
class HouseholdLimitViolation {
  const HouseholdLimitViolation(this.role, {required this.minimum, required this.limit}) : _numericMessage = null;

  const HouseholdLimitViolation.numeric(this.role, this._numericMessage) : minimum = false, limit = 0;

  final MemberRole role;
  final bool minimum;
  final int limit;
  final String Function(L)? _numericMessage;

  String message(L l) => _numericMessage != null
      ? _numericMessage(l)
      : minimum
      ? role == MemberRole.adulte
            ? l.householdLastAdultError
            : l.householdRoleMinimumError(limit, role.label(l))
      : l.householdRoleLimitError(limit, role.label(l));
}

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
    MemberDraft(id: 2, role: MemberRole.adulte, firstName: 'Sarah', age: 35, heightCm: 168, weightKg: 62),
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

  /// Limites provisoires de composition, conservées pour la phase 1.
  static const maxPerRole = {MemberRole.adulte: 8, MemberRole.enfant: 8, MemberRole.bebe: 4};
  static const minPerRole = {MemberRole.adulte: 1, MemberRole.enfant: 0, MemberRole.bebe: 0};

  int count(MemberRole role) => members.where((m) => m.role == role).length;

  HouseholdLimitViolation? _validateCounts(Map<MemberRole, int> counts) {
    for (final role in MemberRole.values) {
      if (counts[role]! < minPerRole[role]!) {
        return HouseholdLimitViolation(role, minimum: true, limit: minPerRole[role]!);
      }
      if (counts[role]! > maxPerRole[role]!) {
        return HouseholdLimitViolation(role, minimum: false, limit: maxPerRole[role]!);
      }
    }
    return null;
  }

  /// Vérifie un ajout ou un changement de rôle avant de toucher au foyer.
  HouseholdLimitViolation? validateMember(MemberDraft member) {
    final counts = {for (final role in MemberRole.values) role: count(role)};
    final original = members.where((m) => m.id == member.id).firstOrNull;
    if (original != null) counts[original.role] = counts[original.role]! - 1;
    counts[member.role] = counts[member.role]! + 1;
    return _validateCounts(counts);
  }

  /// Ajoute ou retire des membres d'un rôle (on retire toujours le dernier ajouté).
  HouseholdLimitViolation? setCount(MemberRole role, int n) {
    final error = _validateCounts({for (final r in MemberRole.values) r: r == role ? n : count(r)});
    if (error != null) return error;
    final target = n;
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
    return null;
  }

  MemberDraft newMember(MemberRole role) => MemberDraft.blank(_nextMemberId++, role);

  /// Ajoute (ou remplace) un membre après sa fiche d'édition.
  HouseholdLimitViolation? saveMember(MemberDraft m) {
    final error = validateMember(m);
    if (error != null) return error;
    final numericError = memberInputViolation(m);
    if (numericError != null) return numericError;
    update(() {
      final i = members.indexWhere((x) => x.id == m.id);
      i < 0 ? members.add(m) : members[i] = m;
      if (mainCookId == m.id && m.role != MemberRole.adulte) mainCookId = null;
      members.sort((a, b) => a.role.index.compareTo(b.role.index));
      _refreshBudget();
    });
    return null;
  }

  bool canRemove(MemberDraft m) {
    final original = members.where((x) => x.id == m.id).firstOrNull;
    return original != null && count(original.role) > minPerRole[original.role]!;
  }

  HouseholdLimitViolation? removeMember(MemberDraft m) {
    final original = members.where((x) => x.id == m.id).firstOrNull;
    if (original == null) return null;
    final error = _validateCounts({
      for (final role in MemberRole.values) role: count(role) - (role == original.role ? 1 : 0),
    });
    if (error != null) return error;
    update(() {
      members.removeWhere((x) => x.id == m.id);
      if (mainCookId == m.id) mainCookId = null;
      _refreshBudget();
    });
    return null;
  }

  /// Nom affiché (prénom, ou « Adulte 2 » tant qu'il n'est pas renseigné).
  String displayName(MemberDraft m, [L? l]) {
    if (m.firstName.trim().isNotEmpty) return m.firstName.trim();
    final same = members.where((x) => x.role == m.role).toList();
    final i = same.indexWhere((x) => x.id == m.id);
    final label = m.role.label(l ?? lookupL(const Locale('fr')));
    return '$label ${i < 0 ? same.length + 1 : i + 1}';
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
  Map<String, List<String>> get memberAllergens => memberAllergenNames(lookupL(const Locale('fr')));

  /// Noms traduits pour l'affichage ; les codes d'allergènes restent identiques.
  Map<String, List<String>> memberAllergenNames(L l) {
    final map = <String, List<String>>{};
    for (final m in members) {
      for (final a in m.allergens) {
        (map[a] ??= []).add(displayName(m, l));
      }
    }
    return map;
  }

  /// Allergènes exclus pour tout le foyer (partagés + profils).
  Set<String> get allAllergens => isFoyer ? {...allergens, ...memberAllergens.keys} : allergens;

  // --- Poids cible ---------------------------------------------------

  /// Environ 7 700 kcal par kilo de masse corporelle.
  static const kcalPerKg = 7700;

  /// Repère d'IMC adulte utilisé par la règle produit actuelle.
  /// Réservé au parcours Individuel adulte ; ce n'est pas un diagnostic.
  static const minBmi = 18.5;

  /// Perte maximale tolérée par semaine.
  static const maxLossPerWeek = 1.0;

  static const minAge = 18;
  static const maxAge = 100;
  static const minHeightCm = 120;
  static const maxHeightCm = 230;
  static const minWeightKg = 35.0;

  /// Borne de saisie provisoire du produit, pas une limite médicale universelle
  /// ni une preuve de validité de l'équation pour tous les profils admis.
  static const maxWeightKg = 250.0;

  /// Plafond provisoire validé par Simo pour la cible, sans changer l'IMC minimal.
  static const maxTargetWeightKg = 250.0;

  /// Limite technique des entiers exactement représentables par un double.
  static const maxExactInteger = NumericSafety.maxExactInteger;

  static bool inRange(num? value, num min, num max) => value != null && value.isFinite && value >= min && value <= max;

  static String? profileInputError(L l, {required int? age, required int? heightCm, required double? weightKg}) {
    if (!inRange(age, minAge, maxAge)) return l.profileAgeError;
    if (!inRange(heightCm, minHeightCm, maxHeightCm)) return l.profileHeightError;
    if (!inRange(weightKg, minWeightKg, maxWeightKg)) return l.profileWeightError;
    return null;
  }

  static HouseholdLimitViolation? memberInputViolation(MemberDraft m) {
    final r = m.role;
    if (!inRange(m.age, r.minAge, r.maxAge)) {
      return HouseholdLimitViolation.numeric(
        r,
        (l) => r == MemberRole.bebe
            ? l.memberBabyAgeError
            : l.memberAgeRangeError(r.label(l).toLowerCase(), r.minAge, r.maxAge),
      );
    }
    if (r == MemberRole.bebe) {
      // Les mensurations sont facultatives ; une valeur fournie reste finie et positive.
      if (m.heightCm != null && (m.heightCm! <= 0 || m.heightCm! > maxExactInteger)) {
        return HouseholdLimitViolation.numeric(r, (l) => l.numericValueUnavailable);
      }
      if (m.weightKg != null && (!m.weightKg!.isFinite || m.weightKg! <= 0 || m.weightKg! > maxExactInteger)) {
        return HouseholdLimitViolation.numeric(r, (l) => l.numericValueUnavailable);
      }
      return null;
    }
    final (hMin, hMax, wMin, wMax) = r == MemberRole.adulte ? (120, 230, 35, 250) : (80, 190, 12, 100);
    if (!inRange(m.heightCm, hMin, hMax)) {
      return HouseholdLimitViolation.numeric(r, (l) => l.memberHeightError(hMin, hMax));
    }
    if (!inRange(m.weightKg, wMin, wMax)) {
      return HouseholdLimitViolation.numeric(r, (l) => l.memberWeightError(wMin, wMax));
    }
    return null;
  }

  bool get isEligibleForIndividual => !isFoyer && inRange(age, minAge, maxAge);

  bool get hasValidProfile =>
      isEligibleForIndividual &&
      inRange(age, minAge, maxAge) &&
      inRange(heightCm, minHeightCm, maxHeightCm) &&
      inRange(weightKg, minWeightKg, maxWeightKg);

  static int? _safeRound(double value) => NumericSafety.round(value);

  bool get needsTarget => !isFoyer && goal != HealthGoal.maintien;

  /// Rythmes proposés selon l'objectif (sèche : déficit modéré fixe pour préserver le muscle).
  List<double> get rateOptions => switch (goal) {
    HealthGoal.pertePoids => const [0.25, 0.5, 0.75],
    HealthGoal.priseMasse => const [0.25, 0.5],
    HealthGoal.seche => const [0.5],
    HealthGoal.maintien => const [],
  };

  /// Un rythme incompatible avec l'objectif doit être choisi explicitement à nouveau.
  double? get effectiveRate {
    if (isFoyer) return null;
    if (!weeklyRateKg.isFinite || weeklyRateKg < 0 || weeklyRateKg > maxLossPerWeek) return null;
    final options = rateOptions;
    if (options.isEmpty) return 0;
    if (weeklyRateKg == 0) return null;
    if (options.contains(weeklyRateKg)) return math.min(weeklyRateKg, maxLossPerWeek);
    return null;
  }

  /// Cible minimale selon la règle produit d'IMC adulte 18,5, arrondie au dixième.
  /// Cette opération mathématique ne valide pas la pertinence clinique de la cible.
  static double? minHealthyWeight(int heightCm) {
    if (heightCm <= 0) return null;
    final value = minBmi * math.pow(heightCm / 100, 2) * 10;
    if (!value.isFinite || value > maxExactInteger) return null;
    return value.ceil() / 10;
  }

  static double? bmi(double weightKg, int heightCm) {
    if (!weightKg.isFinite || weightKg <= 0 || heightCm <= 0) return null;
    final result = weightKg / math.pow(heightCm / 100, 2);
    return result.isFinite && result > 0 ? result : null;
  }

  /// Message d'erreur si le poids visé n'est pas acceptable (null si tout va bien).
  String? targetError(
    L l,
    Formats fmt, {
    required double? target,
    required double current,
    required int heightCm,
    int? profileAge,
  }) {
    if (isFoyer) return l.numericProjectionUnavailable;
    if (!inRange(profileAge ?? age, minAge, maxAge)) return l.profileAgeError;
    if (!inRange(current, minWeightKg, maxWeightKg)) return l.profileWeightError;
    if (!inRange(heightCm, minHeightCm, maxHeightCm)) return l.profileHeightError;
    if (target != null && (!target.isFinite || target <= 0)) return l.numericValueUnavailable;
    if (target != null && target > maxTargetWeightKg) return l.targetErrorMaximum(fmt.weight(l, maxTargetWeightKg));
    if (!needsTarget) return null;
    if (target == null) return l.targetErrorMissing;
    if (effectiveRate == null) return l.numericRateError;
    final losing = goal != HealthGoal.priseMasse;
    if (losing && target >= current) {
      return l.targetErrorLosing(fmt.weight(l, current));
    }
    if (!losing && target <= current) {
      return l.targetErrorGaining(fmt.weight(l, current));
    }
    final min = minHealthyWeight(heightCm);
    if (min == null) return l.numericProjectionUnavailable;
    if (target < min) {
      final index = bmi(target, heightCm);
      if (index == null) return l.numericValueUnavailable;
      final b = fmt.number(index, decimals: 1);
      return l.targetErrorTooLow(b, fmt.height(l, heightCm.toDouble()), fmt.weight(l, min));
    }
    return null;
  }

  /// Nombre de semaines pour atteindre le poids visé au rythme choisi.
  int? weeksToTarget({double? target, double? current, int? heightCm, int? profileAge}) {
    if (isFoyer || !inRange(profileAge ?? age, minAge, maxAge)) return null;
    final t = target ?? targetWeightKg;
    final c = current ?? weightKg;
    final rate = effectiveRate;
    final projectionHeight = heightCm ?? this.heightCm;
    if (!needsTarget ||
        t == null ||
        rate == null ||
        rate <= 0 ||
        !inRange(c, minWeightKg, maxWeightKg) ||
        !inRange(projectionHeight, minHeightCm, maxHeightCm) ||
        !t.isFinite ||
        t <= 0 ||
        t > maxTargetWeightKg) {
      return null;
    }
    final min = minHealthyWeight(projectionHeight);
    if (min == null || t < min || (goal == HealthGoal.priseMasse ? t <= c : t >= c)) return null;
    final weeks = (t - c).abs() / rate;
    return weeks.isFinite && weeks <= maxExactInteger ? weeks.ceil() : null;
  }

  /// Date estimée d'atteinte du poids visé.
  DateTime? targetDate({double? target, double? current, int? heightCm, int? profileAge}) {
    final w = weeksToTarget(target: target, current: current, heightCm: heightCm, profileAge: profileAge);
    if (w == null) return null;
    final today = DateUtils.dateOnly(DateTime.now());
    final micros = BigInt.from(w) * BigInt.from(7) * BigInt.from(Duration.microsecondsPerDay);
    final epoch = BigInt.from(today.microsecondsSinceEpoch) + micros;
    // Capacités réelles de Duration (int64) et DateTime : aucun plafond métier en années.
    if (micros > BigInt.parse('9223372036854775807') || epoch.abs() > BigInt.parse('8640000000000000000')) return null;
    try {
      return today.add(Duration(microseconds: micros.toInt()));
    } on ArgumentError {
      return null;
    }
  }

  static String formatKg(double v) => !v.isFinite || v.abs() > maxExactInteger
      ? v.toString()
      : v == v.roundToDouble()
      ? '${v.round()}'
      : v.toStringAsFixed(1).replaceAll('.', ',');

  static String formatRate(double r) => r.toString().replaceAll('.', ',');

  // --- Calculs -------------------------------------------------------

  int get plannedMeals => slots.length;

  /// Coût moyen disponible par repas planifié.
  double get budgetPerMeal => plannedMeals == 0 ? 0 : budgetEuros / plannedMeals;

  /// Besoin calorique journalier : Mifflin-St Jeor × activité, puis écart lié au rythme
  /// visé (0,5 kg/semaine ≈ 550 kcal/jour), jamais sous le métabolisme de base ni sous
  /// 1 500 kcal (homme) / 1 200 kcal (femme).
  int? get dailyKcal {
    final rate = effectiveRate;
    if (!hasValidProfile || rate == null) return null;
    final bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + (sex == Sex.homme ? 5 : -161);
    const factor = {
      ActivityLevel.sedentaire: 1.2,
      ActivityLevel.modere: 1.45,
      ActivityLevel.actif: 1.65,
      ActivityLevel.tresActif: 1.85,
    };
    final dailyDelta = rate * kcalPerKg / 7;
    final delta = switch (goal) {
      HealthGoal.pertePoids || HealthGoal.seche => -dailyDelta,
      HealthGoal.priseMasse => dailyDelta,
      HealthGoal.maintien => 0.0,
    };
    final floor = math.max(bmr, sex == Sex.homme ? 1500.0 : 1200.0);
    final kcal = math.max(bmr * factor[activity]! + delta, floor);
    final rounded = _safeRound(kcal / 10);
    return rounded == null || rounded <= 0 || rounded > maxExactInteger ~/ 10 ? null : rounded * 10;
  }

  /// Protéines : g/kg selon l'objectif ; lipides : 25 % des kcal ; glucides : le reste.
  ({int protein, int carbs, int fat})? get macros {
    final calories = dailyKcal;
    if (calories == null) return null;
    const perKg = {
      HealthGoal.pertePoids: 1.8,
      HealthGoal.priseMasse: 1.8,
      HealthGoal.seche: 2.0,
      HealthGoal.maintien: 1.6,
    };
    final protein = _safeRound(weightKg * perKg[goal]!);
    final fat = _safeRound(calories * 0.25 / 9);
    if (protein == null || fat == null) return null;
    final carbs = _safeRound((calories - protein * 4 - fat * 9) / 4);
    if (carbs == null || protein < 0 || fat < 0 || carbs < 0) return null;
    return (protein: protein, carbs: carbs, fat: fat);
  }
}
