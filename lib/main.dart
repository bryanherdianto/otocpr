import 'dart:async';
import 'package:flutter/material.dart';
import 'database.dart';
import 'screens/starting_screen.dart';
import 'screens/main_scaffold.dart';
import 'services/telemetry_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  await TelemetryRepository.instance.attachDatabase(database);
  runApp(MyApp(database: database));
}

class MyApp extends StatefulWidget {
  final AppDatabase? database;
  const MyApp({super.key, this.database});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    final db = widget.database;
    if (db != null) {
      unawaited(TelemetryRepository.instance.attachDatabase(db));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OtoCPR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: Builder(
        builder: (context) => StartingScreen(
          onGetStarted: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScaffold(),
              ),
            );
          },
        ),
      ),
    );
  }
}
