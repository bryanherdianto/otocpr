import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_cpr/database.dart';
import 'package:auto_cpr/main.dart';
import 'package:auto_cpr/services/telemetry_repository.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App renders StartingScreen and attaches Drift database',
      (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(MyApp(database: db));
    await tester.pumpAndSettle();

    expect(find.text('OtoCPR'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(TelemetryRepository.instance.hasDatabase, isTrue);

    await TelemetryRepository.instance.resetForTesting();
    await db.close();
  });
}
