import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:menoo/l10n/app_localizations.dart';
import 'package:menoo/l10n/formats.dart';

void main() {
  setUpAll(initializeDateFormatting);

  test('Unités : métriques partout, impériales aux États-Unis', () {
    expect(Formats(const Locale('fr', 'FR')).units, UnitSystem.metric);
    expect(Formats(const Locale('en', 'GB')).units, UnitSystem.metric);
    expect(Formats(const Locale('en', 'US')).units, UnitSystem.imperial);
  });

  test('Devise selon le pays', () {
    expect(Formats(const Locale('fr', 'FR')).currency, 'EUR');
    expect(Formats(const Locale('de', 'DE')).currency, 'EUR');
    expect(Formats(const Locale('en', 'US')).currency, 'USD');
    expect(Formats(const Locale('ar', 'MA')).currency, 'MAD');
    // Une langue sans pays retombe sur l'euro (marché de lancement).
    expect(Formats(const Locale('es')).currency, 'EUR');
  });

  test('Conversions : le nombre change avec le système d\'unités', () async {
    final fr = await L.delegate.load(const Locale('fr'));
    final metric = Formats(const Locale('fr', 'FR'));
    final imperial = Formats(const Locale('en', 'US'));

    expect(metric.weight(fr, 75), contains('75'));
    expect(imperial.weight(fr, 75), contains('165')); // 75 kg ≈ 165,3 lb
    expect(metric.height(fr, 180), contains('180'));
    expect(imperial.height(fr, 180), '5 ft 11 in');
    // Le séparateur décimal suit le pays du format, pas la langue des libellés.
    expect(imperial.mass(fr, 100), contains('3.5')); // 100 g ≈ 3.5 oz
  });

  test('Prix : les centimes de la base deviennent un montant lisible', () {
    // Espaces insécables selon la locale : on vérifie les chiffres et le symbole.
    final fr = Formats(const Locale('fr', 'FR')).price(6550);
    expect(fr, contains('65,50'));
    expect(fr, contains('€'));
    expect(Formats(const Locale('fr', 'FR')).priceRounded(6500), contains('65'));
    expect(Formats(const Locale('en', 'US')).price(6550), contains('65.50'));
  });
}
