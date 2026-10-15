import 'dart:convert';

enum DraftJourney { solo, family }

enum DraftManagement { shopping, pantry, mixed }

/// Storage envelope, independent of widgets and future server calculations.
/// Unknown answer fields survive a round trip; future formats are never rewritten.
class LocalDraft {
  static const currentFormat = 1;
  final String id;
  final DraftJourney journey;
  final int step;
  final DraftManagement management;
  final String currency;
  final DateTime updatedAt;
  final String _answers;
  final String _pantry;

  LocalDraft({
    required this.id,
    required this.journey,
    required this.step,
    required this.management,
    required Map<String, Object?> answers,
    required List<Map<String, Object?>> pantry,
    this.currency = 'EUR',
    required this.updatedAt,
  }) : _answers = jsonEncode(answers),
       _pantry = jsonEncode(pantry) {
    if (id.isEmpty ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(currency) ||
        step < 1 ||
        step > (journey == DraftJourney.solo ? 11 : 9)) {
      throw const FormatException('Invalid draft envelope');
    }
  }

  Map<String, Object?> get answers => Map<String, Object?>.from(jsonDecode(_answers) as Map);
  List<Map<String, Object?>> get pantry =>
      (jsonDecode(_pantry) as List).map((item) => Map<String, Object?>.from(item as Map)).toList();

  String encode() => jsonEncode({
    'formatVersion': currentFormat,
    'id': id,
    'journey': journey.name,
    'step': step,
    'management': management.name,
    'currency': currency,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'syncState': 'localOnly',
    'answers': answers,
    'pantry': pantry,
  });

  factory LocalDraft.decode(String value) {
    final data = jsonDecode(value) as Map<String, dynamic>;
    if (data['formatVersion'] != currentFormat || data['syncState'] != 'localOnly') {
      throw const FormatException('Unsupported draft format');
    }
    return LocalDraft(
      id: data['id'] as String,
      journey: DraftJourney.values.byName(data['journey'] as String),
      step: data['step'] as int,
      management: DraftManagement.values.byName(data['management'] as String),
      currency: data['currency'] as String,
      updatedAt: DateTime.parse(data['updatedAt'] as String),
      answers: Map<String, Object?>.from(data['answers'] as Map),
      pantry: (data['pantry'] as List).map((e) => Map<String, Object?>.from(e as Map)).toList(),
    );
  }
}
