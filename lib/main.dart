import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

// ==========================================
// MODEL
// ==========================================
class Diary {
  final String title;
  final String content;
  final String date;
  Diary({required this.title, required this.content, required this.date});
}

// ข้อมูลตัวอย่าง 5 อัน
final List<Diary> diaries = [
  Diary(
    title: 'วันแรกของการเรียน Flutter',
    content: 'วันนี้ได้เริ่มเขียนแอปตัวแรก รู้สึกตื่นเต้นมาก',
    date: '1 ก.ย. 2568',
  ),
  Diary(
    title: 'เข้าใจ Widget แล้ว',
    content: 'ทุกอย่างใน Flutter คือ Widget เหมือนต่อเลโก้',
    date: '2 ก.ย. 2568',
  ),
  Diary(
    title: 'ทำ ListView สำเร็จ',
    content: 'วันนี้ทำรายการเลื่อนได้ ภูมิใจจัง',
    date: '5 มิ.ย. 2568',
  ),
  Diary(
    title: 'ลองทำ Navigation',
    content: 'เรียนรู้การสลับหน้าจอด้วย Navigator ได้แล้ว',
    date: '6 ก.ย. 2568',
  ),
  Diary(
    title: 'เริ่มเข้าใจ State',
    content: 'setState ทำให้หน้าจอวาดใหม่ได้ เข้าใจแล้ว!',
    date: '7 ก.ย. 2568',
  ),
];

// ==========================================
// MAIN APP
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDiary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // สี Indigo สไตล์โมเดิร์น
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(
          0xFFF8FAFC,
        ), // พื้นหลังสีเทาอมฟ้าอ่อนๆ
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1E293B)),
        ),
      ),
      home: const MainPage(),
    );
  }
}

// ==========================================
// MAIN PAGE (NAVIGATION)
// ==========================================
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [const DiaryListPage(), const AboutPage()];

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
              color: Colors.black.withOpacity(0.05),
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
          indicatorColor: const Color(0xFF6366F1).withOpacity(0.15),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.book_outlined),
              selectedIcon: Icon(Icons.book_rounded, color: Color(0xFF6366F1)),
              label: 'บันทึก',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: Color(0xFF6366F1),
              ),
              label: 'เกี่ยวกับ',
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DIARY LIST PAGE
// ==========================================
class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});
  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  // ย้าย List ข้อมูลมาไว้ตรงนี้ (นอก build)
  final List<Diary> diaries = [
    Diary(
      title: 'วันแรกของการเรียน Flutter',
      content: 'เริ่มเขียนแอปตัวแรก',
      date: '1 มิ.ย. 2568',
    ),
    Diary(
      title: 'เข้าใจ Widget แล้ว',
      content: 'ทุกอย่างคือ Widget',
      date: '3 มิ.ย. 2568',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Color> iconColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกของฉัน')),
      body: ListView.builder(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 100,
          left: 16,
          right: 16,
        ),
        itemCount: diaries.length,
        itemBuilder: (context, i) {
          final color = iconColors[i % iconColors.length];
          final diary = diaries[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DiaryDetailPage(diary: diary, color: color),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'icon_${diary.title}',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: color,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              diary.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${diary.date} • ${diary.content}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCBD5E1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('ฟีเจอร์เพิ่มบันทึก มาสัปดาห์หน้า!'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: const Color(0xFF1E293B),
            ),
          );
        },
        icon: const Icon(Icons.edit_rounded),
        label: const Text(
          'เขียนบันทึก',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
    );
  }
}

// ==========================================
// DIARY DETAIL PAGE
// ==========================================
class DiaryDetailPage extends StatelessWidget {
  final Diary diary;
  final Color color;

  const DiaryDetailPage({super.key, required this.diary, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'icon_${diary.title}',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.auto_stories_rounded, color: color, size: 32),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              diary.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    diary.date,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: Color(0xFFE2E8F0), thickness: 1.5),
            ),
            Text(
              diary.content,
              style: const TextStyle(
                fontSize: 17,
                height: 1.8,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ABOUT PAGE
// ==========================================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เกี่ยวกับนักพัฒนา')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'นายธีระวัฒน์ สีปัดขน',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'รหัสนิสิต: 67011211113',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.book_rounded,
                      'แอปพลิเคชัน',
                      'MyDiary (สมุดบันทึก)',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),
                    _buildInfoRow(
                      Icons.school_rounded,
                      'สาขาวิชา',
                      'วิทยาการคอมพิวเตอร์\nมหาวิทยาลัยมหาสารคาม',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),
                    _buildInfoRow(Icons.code_rounded, 'เวอร์ชัน', '1.0.0'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key});
  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>(); // กุญแจคุมฟอร์ม
  final _titleController = TextEditingController(); // อ่านค่าช่องชื่อเรื่อง
  final _contentController = TextEditingController(); // อ่านค่าช่องเนื้อหา

  @override
  void dispose() {
    _titleController.dispose(); // คืนทรัพยากรตอนปิดหน้า
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เขียนบันทึกใหม่')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อเรื่อง',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อเรื่อง';
                  }
                  return null; // null = ผ่าน
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5, // ช่องเนื้อหาสูง 5 บรรทัด
                decoration: const InputDecoration(
                  labelText: 'เนื้อหา',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกเนื้อหา';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // ขั้นถัดไปจะเติมโค้ดบันทึกตรงนี้
                  },
                  child: const Text('บันทึก'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
