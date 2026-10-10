import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'database.dart';
import 'screens/starting_screen.dart';
import 'screens/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final AppDatabase? database;
  const MyApp({super.key, this.database});

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

class MyHomePage extends StatefulWidget {
  final AppDatabase? database;
  const MyHomePage({super.key, this.database});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AppDatabase _db;
  late final bool _isOwnedDb;

  @override
  void initState() {
    super.initState();
    if (widget.database != null) {
      _db = widget.database!;
      _isOwnedDb = false;
    } else {
      _db = AppDatabase();
      _isOwnedDb = true;
    }
  }

  @override
  void dispose() {
    if (_isOwnedDb) {
      _db.close();
    }
    super.dispose();
  }

  Future<void> _addItem() async {
    final count = await _db.select(_db.testItems).get();
    await _db.into(_db.testItems).insert(
          TestItemsCompanion.insert(
            content: 'Data Test #${count.length + 1}',
          ),
        );
  }

  Future<void> _clearAll() async {
    await _db.delete(_db.testItems).go();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift Database Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Semua Data',
            onPressed: _clearAll,
          ),
        ],
      ),
      body: StreamBuilder<List<TestItem>>(
        stream: _db.select(_db.testItems).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: AppColors.cyan, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Koneksi Database Berhasil!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Belum ada data. Tekan tombol + untuk menambah test data.'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${item.id}')),
                title: Text(item.content),
                subtitle: Text('Dibuat: ${item.createdAt}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Tambah Data',
        child: const Icon(Icons.add),
      ),
    );
  }
}
