import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toko_roti/main.dart'; // Sesuaikan dengan nama paket di pubspec.yaml

void main() {
  testWidgets('Toko Roti App displays roti list', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(TokoRotiApp());

    // Verify that the app bar title is displayed.
    expect(find.text('Toko Roti Online'), findsOneWidget);

    // Verify that at least one roti item is displayed (misalnya nama roti pertama).
    expect(find.text('Roti Tawar'), findsOneWidget); // Sesuaikan dengan data roti Anda

    // Tambahkan tes tambahan jika perlu, misalnya tap pada item.
    await tester.tap(find.text('Roti Tawar'));
    await tester.pump();
    expect(find.text('Roti Tawar dibeli!'), findsOneWidget); // Cek notifikasi snackbar
  });
}