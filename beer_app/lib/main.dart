import 'package:flutter/material.dart';
import 'BeerListPage.dart';
import 'GeneratePage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ひとり酒',
      debugShowCheckedModeBanner: false, // ← デバッグバナー非表示でスッキリ
      theme: ThemeData(
        fontFamily: 'Georgia',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal.shade200,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100], // ← 全体の背景も統一感UP
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal.shade100,
          titleTextStyle: const TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      home: const MyHomePage(title: 'ひとり酒'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BeerListPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GeneratePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '静かに味わう、ひとりの時間。\nひとくちが、記憶になる夜がある。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BeerListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 背景白
                foregroundColor: Colors.teal,  // 文字色
                side: const BorderSide(color: Colors.teal), // 枠線
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 四角形にする
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.local_drink, size: 28), // ← ビールアイコン
                  SizedBox(height: 4),
                  Text(
                    'ビールのうんちくを選ぶ',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GeneratePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 背景白
                foregroundColor: Colors.teal,  // 文字色
                side: const BorderSide(color: Colors.teal), // 枠線
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // 四角形にする
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search, size: 28),
                  SizedBox(height: 4),
                  Text(
                    'お酒のうんちくを探す',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '選ぶ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: '探す',
          ),        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
