import 'package:flutter/material.dart';
import 'package:hello_flutter/firestore_diary.dart';
import 'diary_list_page.dart';
import 'about_page.dart';
import 'pokedek_list_page.dart';
import 'api_diaty_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DiaryListPage(),
    const AboutPage(),
    const PokedekListPage(),
    const ApiDiaryPage(),
    const FirestoreDiaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFFF39BC5).withValues(alpha: 0.18),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book_rounded, color: Color(0xFF75A9F8)),
              label: 'บันทึก',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: Color(0xFF75A9F8),
              ),
              label: 'เกี่ยวกับ',
            ),
            NavigationDestination(
              icon: Icon(Icons.catching_pokemon_rounded),
              selectedIcon: Icon(
                Icons.catching_pokemon_rounded,
                color: Color(0xFF75A9F8),
              ),
              label: 'โปเกเดกซ์',
            ),
            NavigationDestination(
              icon: Icon(Icons.linear_scale_rounded),
              selectedIcon: Icon(
                Icons.linear_scale_rounded,
                color: Color(0xFF75A9F8),
              ),
              label: 'ออนไลน์',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud_outlined),
              selectedIcon: Icon(Icons.cloud_rounded, color: Color(0xFF75A9F8)),
              label: 'Cloud',
            ),
          ],
        ),
      ),
    );
  }
}
