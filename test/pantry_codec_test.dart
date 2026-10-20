import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:menoo/local_storage/local_draft.dart';
import 'package:menoo/local_storage/pantry_codec.dart';
import 'package:menoo/models/pantry_location.dart';
import 'package:menoo/models/pantry_product_record.dart';
import 'package:menoo/models/pantry_values.dart';

PantryProductRecord product({
  String id = 'lot_1',
  num? quantity = 2.500000000000001,
  PantryUnit? unit = PantryUnit.kilogram,
  String unitLabel = 'kg',
  PantryLocation location = PantryLocation.pantry,
  String? date = '2028-02-29',
  ExpiryOrigin origin = ExpiryOrigin.userProvided,
  QuickCategory? category = QuickCategory.pastaRice,
  QuickStock? stock = QuickStock.some,
  Map<String, Object?> unknown = const {},
}) => PantryProductRecord(
  id: id,
  name: '  Lentilles / lentils  ',
  quantity: quantity,
  unit: unit,
  unitLabel: unitLabel,
  location: location,
  expiresOn: date,
  expiryOrigin: origin,
  source: 'manuel',
  foodId: 'lentille',
  declaredCategory: category,
  declaredStock: stock,
  unknownFields: unknown,
);

Map<String, Object?> document({DraftJourney owner = DraftJourney.solo}) =>
    PantryCodec.toMap(PantryPayload(journey: owner, items: [product()]));
Map<String, Object?> firstItem(Map<String, Object?> document) =>
    (document['items'] as List).first as Map<String, Object?>;
PantryPayload read(Map<String, Object?> map, {DraftJourney owner = DraftJourney.solo}) =>
    PantryCodec.fromMap(map, expectedJourney: owner);

LocalDraft legacy(
  DraftJourney owner, {
  List<Map<String, Object?>> pantry = const [],
  Map<String, Object?> answers = const {},
}) => LocalDraft(
  id: owner == DraftJourney.solo ? 'guest.solo' : 'guest.family',
  journey: owner,
  step: 1,
  management: DraftManagement.mixed,
  answers: answers,
  pantry: pantry,
  updatedAt: DateTime.utc(2026, 10, 20),
);

void main() {
  test('full exact round trip, including IDs, whitespace and all fields', () {
    final input = document();
    final encoded = jsonEncode(input);
    final output = PantryCodec.decode(encoded, expectedJourney: DraftJourney.solo);
    expect(PantryCodec.encode(output), encoded);
    expect(output.items.single.id, 'lot_1');
    expect(output.items.single.quantity, 2.500000000000001);
    expect(output.items.single.name, '  Lentilles / lentils  ');
    expect(output.items.single.declaredCategory, QuickCategory.pastaRice);
    expect(output.items.single.declaredStock, QuickStock.some);
    expect(output.items.single.foodId, 'lentille');
    expect(output.items.single.source, 'manuel');
  });
  test('secure product identities allocated once, never during decoding', () {
    final ids = List.generate(1000, (_) => createPantryProductId());
    expect(ids.toSet(), hasLength(1000));
    expect(ids.every((id) => RegExp(r'^pr_[0-9a-f]{32}$').hasMatch(id)), isTrue);
    final encoded = PantryCodec.encode(
      PantryPayload(
        journey: DraftJourney.solo,
        items: [product(id: ids.first)],
      ),
    );
    for (var i = 0; i < 5; i++) {
      expect(PantryCodec.decode(encoded, expectedJourney: DraftJourney.solo).items.single.id, ids.first);
    }
  });
  test('same name and contents retain two distinct lots and original order', () {
    final value = PantryPayload(
      journey: DraftJourney.family,
      items: [
        product(id: 'second'),
        product(id: 'first'),
      ],
    );
    final result = PantryCodec.decode(PantryCodec.encode(value), expectedJourney: DraftJourney.family);
    expect(result.items.map((p) => p.id), ['second', 'first']);
    expect(result.items.map((p) => p.name).toSet(), hasLength(1));
    expect(result.items, hasLength(2));
  });
  test('empty current payload is explicit and distinct from an unreadable one', () {
    final payload = PantryPayload(journey: DraftJourney.family, items: []);
    expect(PantryCodec.decode(PantryCodec.encode(payload), expectedJourney: DraftJourney.family).items, isEmpty);
  });
  test('manual record retains absent category and stock with an arbitrary raw unit', () {
    final payload = PantryPayload(
      journey: DraftJourney.solo,
      items: [product(unit: null, unitLabel: 'jar (custom)', category: null, stock: null)],
    );
    final restored = PantryCodec.decode(PantryCodec.encode(payload), expectedJourney: DraftJourney.solo).items.single;
    expect(restored.unit, isNull);
    expect(restored.unitLabel, 'jar (custom)');
    expect(restored.declaredCategory, isNull);
    expect(restored.declaredStock, isNull);
  });
  for (final stock in QuickStock.values) {
    test('qualitative ${stock.name} stays exact', () {
      final payload = PantryPayload(
        journey: DraftJourney.solo,
        items: [product(stock: stock)],
      );
      expect(
        PantryCodec.decode(PantryCodec.encode(payload), expectedJourney: DraftJourney.solo).items.single.declaredStock,
        stock,
      );
    });
  }
  test('duplicate stable identities are rejected rather than merged', () {
    final map = document();
    (map['items'] as List).add({...firstItem(map)});
    expect(() => read(map), throwsFormatException);
    expect(() => PantryPayload(journey: DraftJourney.solo, items: [product(), product()]), throwsFormatException);
  });
  for (final quantity in <num?>[null, 0, 0.0, -0.0, 1, 1.125, 9007199254740993]) {
    test('quantity $quantity retains exact representation without conversion', () {
      final item = PantryCodec.decode(
        PantryCodec.encode(
          PantryPayload(
            journey: DraftJourney.solo,
            items: [product(quantity: quantity)],
          ),
        ),
        expectedJourney: DraftJourney.solo,
      ).items.single;
      expect(item.quantity, quantity);
      if (quantity != null) expect(item.quantity.runtimeType, quantity.runtimeType);
    });
  }
  for (final unit in PantryUnit.values) {
    test('unit ${unit.id} is not normalized to another unit', () {
      final item = PantryCodec.decode(
        PantryCodec.encode(
          PantryPayload(
            journey: DraftJourney.solo,
            items: [product(unit: unit, unitLabel: 'original-label')],
          ),
        ),
        expectedJourney: DraftJourney.solo,
      ).items.single;
      expect(item.unit, unit);
      expect(item.unitLabel, 'original-label');
      expect(item.quantity, 2.500000000000001);
    });
  }
  test('null canonical unit stays null even if its raw label is recognized', () {
    final value = PantryPayload(
      journey: DraftJourney.solo,
      items: [product(quantity: null, unit: null, unitLabel: 'kg')],
    );
    final item = PantryCodec.decode(PantryCodec.encode(value), expectedJourney: DraftJourney.solo).items.single;
    expect(item.unit, isNull);
    expect(item.unitLabel, 'kg');
    expect(item.quantity, isNull);
  });
  for (final location in PantryLocation.values) {
    test('stable location ${location.dbValue}', () {
      final value = PantryPayload(
        journey: DraftJourney.solo,
        items: [product(location: location)],
      );
      expect(firstItem(PantryCodec.toMap(value))['location'], location.dbValue);
      expect(
        PantryCodec.decode(PantryCodec.encode(value), expectedJourney: DraftJourney.solo).items.single.location,
        location,
      );
    });
  }
  for (final category in QuickCategory.values) {
    test('quick category ${category.id} preserved independently of label', () {
      final value = PantryPayload(
        journey: DraftJourney.solo,
        items: [product(category: category)],
      );
      expect(firstItem(PantryCodec.toMap(value))['declaredCategory'], category.id);
      expect(
        PantryCodec.decode(PantryCodec.encode(value), expectedJourney: DraftJourney.solo).items.single.declaredCategory,
        category,
      );
    });
  }
  for (final origin in ExpiryOrigin.values) {
    for (final date in ['2026-03-29', '2026-10-25', '2028-02-29', '1999-12-31']) {
      test('civil $date and ${origin.name} preserved without timezone shift', () {
        final value = PantryPayload(
          journey: DraftJourney.solo,
          items: [product(date: date, origin: origin)],
        );
        final result = PantryCodec.decode(PantryCodec.encode(value), expectedJourney: DraftJourney.solo).items.single;
        expect(result.expiresOn, date);
        expect(result.expiryOrigin, origin);
      });
    }
  }
  test('qualitative stock has no invented quantity, unit or expiry', () {
    final map = document();
    firstItem(map).addAll({
      'quantity': null,
      'unit': null,
      'unitLabel': '',
      'expiresOn': null,
      'expiryOrigin': 'unknown',
      'foodId': null,
      'source': 'verification_rapide',
    });
    expect(PantryCodec.toMap(read(map)), map);
  });
  for (final owner in DraftJourney.values) {
    test('${owner.name} explicit ownership and same-owner legacy empty compatibility', () {
      final map = document(owner: owner);
      expect(read(map, owner: owner).journey, owner);
      final draft = legacy(
        owner,
        answers: {
          'unknownAnswers': {
            'nested': [1, 'keep'],
          },
        },
      );
      final before = draft.encode();
      expect(PantryCodec.readLegacyDraft(draft, expectedJourney: owner).items, isEmpty);
      expect(draft.encode(), before);
      final other = owner == DraftJourney.solo ? DraftJourney.family : DraftJourney.solo;
      expect(() => read(map, owner: other), throwsFormatException);
      expect(() => PantryCodec.readLegacyDraft(draft, expectedJourney: other), throwsFormatException);
    });
  }
  test('wrong draft ID rejected even with correct journey', () {
    expect(() => read(document()..['draftId'] = 'guest.family'), throwsFormatException);
  });
  test('unversioned nonempty history is refused and remains byte-for-byte intact', () {
    final draft = legacy(
      DraftJourney.solo,
      pantry: [
        {
          'product': 'lentils',
          'quantity': 2.5,
          'unit': 'kg',
          'location': 'cupboard',
          'date': '2026-11-02',
          'dateSource': 'manual',
          'future': 'keep',
        },
      ],
    );
    final before = draft.encode();
    expect(() => PantryCodec.readLegacyDraft(draft, expectedJourney: DraftJourney.solo), throwsFormatException);
    expect(draft.encode(), before);
  });
  test('legacy helper never treats versioned or future metadata as empty legacy', () {
    for (final version in [1, 2, null, '1']) {
      final draft = legacy(DraftJourney.family, answers: {'pantryPayloadVersion': version});
      final before = draft.encode();
      expect(() => PantryCodec.readLegacyDraft(draft, expectedJourney: DraftJourney.family), throwsFormatException);
      expect(draft.encode(), before);
    }
  });
  test('unknown compatible fields survive deeply without aliasing input or output', () {
    final input = document();
    input['future'] = {
      'list': [
        1,
        null,
        {'ok': true},
      ],
    };
    firstItem(input)['futureLot'] = {
      'weights': [1.125, 2],
    };
    final expected = jsonEncode(input);
    final result = read(input);
    (input['future'] as Map)['list'] = [];
    (firstItem(input)['futureLot'] as Map)['weights'] = <num>[];
    expect(jsonDecode(PantryCodec.encode(result)), jsonDecode(expected));
    expect(() => result.items.clear(), throwsUnsupportedError);
    expect(() => (result.unknownFields['future'] as Map).clear(), throwsUnsupportedError);
    expect(() => (result.items.single.unknownFields['futureLot'] as Map).clear(), throwsUnsupportedError);
  });
  test('reserved fields cannot be shadowed by extension fields', () {
    expect(
      () => PantryCodec.encode(
        PantryPayload(journey: DraftJourney.solo, items: [], unknownFields: {'journey': 'family'}),
      ),
      throwsFormatException,
    );
    expect(
      () => PantryCodec.encode(
        PantryPayload(
          journey: DraftJourney.solo,
          items: [
            product(unknown: {'id': 'other'}),
          ],
        ),
      ),
      throwsFormatException,
    );
  });
  test('malformed JSON diagnostics do not contain the personal payload', () {
    try {
      PantryCodec.decode('{"personal":"private_value",', expectedJourney: DraftJourney.solo);
      fail('corrupt JSON accepted');
    } on FormatException catch (error) {
      expect(error.source, isNull);
      expect(error.toString(), isNot(contains('private_value')));
    }
  });
  for (final invalid in ['{', 'null', '[]', '42', '"invalid"']) {
    test('corrupt document $invalid is refused', () {
      expect(() => PantryCodec.decode(invalid, expectedJourney: DraftJourney.solo), throwsFormatException);
    });
  }
  for (final version in [null, 0, 2, -1, '1', 1.0, true]) {
    test('unsupported or mistyped version $version refused unchanged', () {
      final value = document()..['pantryVersion'] = version;
      final before = jsonEncode(value);
      expect(() => read(value), throwsFormatException);
      expect(jsonEncode(value), before);
    });
  }
  final invalidFields = <String, List<Object?>>{
    'id': [null, '', 'bad id', 1],
    'name': [null, '', '   ', 2],
    'quantity': ['2.5', true, -1, double.nan, double.infinity],
    'unit': ['kg', 'unknown', 2],
    'unitLabel': [null, 3],
    'location': [null, 'cupboard', 'unknown', 2],
    'expiresOn': ['2027-02-29', '2026-02-30', '2026-13-01', '0000-01-01', '2026-03-29T00:00:00Z', '2026-1-01', 3],
    'expiryOrigin': [null, 'manual', 'future'],
    'source': [null, '', 3],
    'foodId': ['', 3],
    'declaredCategory': ['future', 3],
    'declaredStock': ['future', 3],
  };
  for (final entry in invalidFields.entries) {
    for (final value in entry.value) {
      test('invalid ${entry.key} $value refuses the entire document', () {
        final input = document();
        final bad = {...firstItem(input), 'id': 'lot_2', entry.key: value};
        (input['items'] as List).add(bad);
        expect(() => read(input), throwsFormatException);
        expect((input['items'] as List).length, 2);
      });
    }
  }
  for (final invalid in [
    null,
    true,
    {},
    'not_a_list',
    [null],
    [1],
    [[]],
  ]) {
    test('invalid item collection $invalid cannot become an empty pantry', () {
      final input = document()..['items'] = invalid;
      expect(() => read(input), throwsFormatException);
    });
  }
  test('missing required field is not guessed; null expiry cannot claim a date origin', () {
    final missing = document();
    firstItem(missing).remove('quantity');
    expect(() => read(missing), throwsFormatException);
    for (final origin in [ExpiryOrigin.estimated, ExpiryOrigin.userProvided]) {
      final input = document();
      firstItem(input).addAll({'expiresOn': null, 'expiryOrigin': origin.name});
      expect(() => read(input), throwsFormatException);
    }
  });
  test('non-JSON extension data never becomes a partial valid record', () {
    expect(() => product(unknown: {'notJson': DateTime(2026)}), throwsFormatException);
    expect(() => read(document()..['future'] = double.nan), throwsFormatException);
  });
}
