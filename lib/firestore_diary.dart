import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'firestore_form_page.dart';

class FirestoreDiaryPage extends StatelessWidget {
  const FirestoreDiaryPage({super.key});

  Future<void> _editDiary(
    BuildContext context,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirestoreFormPage(existing: data),
      ),
    );
    if (result is Map<String, dynamic>) {
      await FirestoreService.update(
        docId,
        result['title'],
        result['content'],
        result['date'],
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String docId,
    String title,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบบันทึก “$title” ใช่ไหม?\nการลบนี้ไม่สามารถย้อนกลับได้'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD95C73),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('ลบจริง'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await FirestoreService.delete(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบบันทึกเรียบร้อยแล้ว')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึก Cloud (Firestore)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(), // ออกจากระบบ
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getMyDiaries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('โหลดบันทึกไม่สำเร็จ กรุณาลองใหม่'));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.cloud_queue_rounded, size: 72, color: Color(0xFFB7D2FB)),
                  SizedBox(height: 14),
                  Text('ยังไม่มีบันทึกบน Cloud', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('กดปุ่ม + เพื่อเพิ่มบันทึกแรก', style: TextStyle(color: Color(0xFF7B879C))),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id; // id ของ document (String)
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEAF3FF),
                    child: Icon(Icons.cloud_rounded, color: Color(0xFF75A9F8)),
                  ),
                  title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    '${data['date'] ?? ''} • ${data['content'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'แก้ไขบันทึก',
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF75A9F8)),
                        onPressed: () => _editDiary(context, docId, data),
                      ),
                      IconButton(
                        tooltip: 'ลบบันทึก',
                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFD95C73)),
                        onPressed: () => _confirmDelete(
                          context,
                          docId,
                          data['title']?.toString() ?? 'บันทึกนี้',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FirestoreFormPage()),
          );
          if (result is Map) {
            await FirestoreService.add(
              result['title'],
              result['content'],
              result['date'],
            );
            // ไม่ต้อง reload! StreamBuilder อัปเดตเอง
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
