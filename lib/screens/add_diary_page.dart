import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/diary.dart';

class AddDiaryPage extends StatefulWidget {
  const AddDiaryPage({super.key, this.existing});
  final Diary? existing; // รับข้อมูลเดิม (ถ้ามี)
  @override
  State<AddDiaryPage> createState() => _AddDiaryPageState();
}

class _AddDiaryPageState extends State<AddDiaryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'มีความสุข';
  final List<String> _moods = [
    'มีความสุข',
    'เฉยๆ',
    'เศร้า',
    'เหนื่อย',
    'ตื่นเต้น',
  ];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.title;
      _contentController.text = widget.existing!.content;
      if (_moods.contains(widget.existing!.mood)) {
        _selectedMood = widget.existing!.mood;
      }
      _selectedDate =
          DateTime.tryParse(widget.existing!.date) ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขบันทึก' : 'เขียนบันทึกใหม่'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อเรื่อง',
                    hintText: 'เช่น วันหยุดที่แสนดี',
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
                    hintText: 'วันนี้เกิดอะไรขึ้นบ้าง...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกเนื้อหา';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'อารมณ์วันนี้',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.mood),
                  ),
                  items: _moods.map((mood) {
                    return DropdownMenuItem(value: mood, child: Text(mood));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      //  เลือกค่าเลือกต้อง setState เอง
                      _selectedMood = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    'วันที่: ${_selectedDate.toString().substring(0, 10)}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () async {
                    final picked = await showDatePicker(
                      // เปิดปฏิทินให้เลือก
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020), // เลือกได้ตั้งแต่ปี 2020
                      lastDate: DateTime(2030), // ถึงปี 2030
                    );
                    if (picked != null) {
                      // ถ้าเลือก (ไม่กดยกเลิก)
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final diary = Diary(
                            id: widget.existing?.id,
                            title: _titleController.text.trim(),
                            content: _contentController.text.trim(),
                            date: _selectedDate.toString().substring(0, 10),
                            mood: _selectedMood,
                            quote: widget.existing?.quote ?? '',
                          );
                          if (widget.existing != null) {
                            await DatabaseHelper().update(diary);
                          } else {
                            await DatabaseHelper().insert(diary);
                          }
                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                        } catch (e, stackTrace) {
                          debugPrint('Save diary error: $e');
                          debugPrintStack(stackTrace: stackTrace);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                          );
                        }
                      }
                    },

                    child: const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
