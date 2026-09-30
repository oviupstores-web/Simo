import 'package:flutter/material.dart';

/// Ouvre un écran avec la transition du thème (glissement + fondu).
Future<T?> push<T>(BuildContext context, Widget screen) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

/// Message discret en bas d'écran (fond encre, coins arrondis).
void showMenooMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
