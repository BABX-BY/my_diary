import 'package:flutter/material.dart';
import 'package:hello_flutter/api_service.dart';
import 'package:hello_flutter/screens/api_form_page.dart';

// ตัว Widget ของแท็บ "ออนไลน์" (เพิ่มเข้า BottomNavigationBar เหมือนแท็บอื่น)
class ApiDiaryPage extends StatefulWidget {
  const ApiDiaryPage({super.key});
  @override
  State<ApiDiaryPage> createState() => _ApiDiaryPageState();
}

class _ApiDiaryPageState extends State<ApiDiaryPage> {
  late Future<List<dynamic>>
  _diariesFuture; // รหัสอยู่ใน ApiService.baseUrl แล้ว

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  void _loadDiaries() {
    setState(() {
      _diariesFuture = ApiService.getDiaries(); // โหลดใหม่ (ได้เฉพาะของเรา)
    });
  }

  // เพิ่มแล้วโหลดใหม่ (แพตเทิร์นเดียวกับ SQLite สัปดาห์ 2!)
  Future<void> _addDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    try {
      await ApiService.createDiary(title, content, mood, date);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มบันทึกสำเร็จ'),
          ),
        );
      }

      _loadDiaries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มไม่สำเร็จ ตรวจสอบอินเทอร์เน็ต'),
          ),
        );
      }
    }
  }

  Future<void> _deleteDiary(String id) async {
    await ApiService.deleteDiary(id);
    _loadDiaries();
  }

  // แก้ไขแล้วโหลดใหม่
  Future<void> _updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    await ApiService.updateDiary(id, title, content, mood, date);
    _loadDiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บันทึกบน Cloud (REST API)')),
      body: FutureBuilder<List<dynamic>>(
        future: _diariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ผิดพลาด: ${snapshot.error}'));
          }
          final diaries = snapshot.data!;
          if (diaries.isEmpty) {
            return const Center(child: Text('ยังไม่มีบันทึก กดปุ่ม +'));
          }
          return ListView.builder(
            itemCount: diaries.length,
            itemBuilder: (context, i) {
              final obj = diaries[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(obj['title'] ?? ''),
                  subtitle: Text(
                    '${obj['mood'] ?? ''} • ${obj['date'] ?? ''} • ${obj['content'] ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min, // ให้ Row กว้างเท่าที่จำเป็น
                    children: [
                      // ── แก้ไข (Update) ──
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ApiFormPage(existing: obj),
                            ),
                          ); // ส่ง object เดิม
                          if (result is Map) {
                            await ApiService.updateDiary(
                              obj['id'],
                              result['title'],
                              result['content'],
                              result['mood'],
                              result['date'],
                            );
                            _loadDiaries();
                          }
                        },
                      ),
                      // ── ลบ (Delete) + ยืนยันก่อนลบ ──
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('ลบบันทึก?'),
                              content: Text(
                                'ต้องการลบ "${obj['title']}" ใช่ไหม',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('ยกเลิก'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'ลบ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ApiService.deleteDiary(obj['id']);
                            _loadDiaries(); // โหลดใหม่หลังลบ
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // ── ปุ่มเพิ่ม: เปิดฟอร์มโหมดเพิ่ม แล้วรับค่ากลับมา createDiary ──
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ApiFormPage()),
          );
          if (result is Map) {
            await _addDiary(
              result['title'],
              result['content'],
              result['mood'],
              result['date'],
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
