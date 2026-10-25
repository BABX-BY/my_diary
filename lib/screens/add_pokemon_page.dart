import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../api_service.dart';

class AddPokemonPage extends StatefulWidget {
  const AddPokemonPage({super.key, this.existing});
  final Pokedek? existing; // รับข้อมูลเดิม (ถ้ามี)
  @override
  State<AddPokemonPage> createState() => _AddPokemonPageState();
}

class _AddPokemonPageState extends State<AddPokemonPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleController.text = widget.existing!.name;

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อโปเกมอน',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณากรอกชื่อโปเกมอน';
                  }
                  return null; // null = ผ่าน
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 1, // ช่องเนื้อหาสูง 5 บรรทัด
                decoration: const InputDecoration(
                  labelText: 'โน็ต/ชื่อเล่นที่ใช้เรียก',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'โน็ต/ชื่อเล่นที่ใช้เรียก';
                  }
                  return null;
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
                        final pokedek = Pokedek(
                          id: widget.existing?.id,
                          name: _titleController.text.trim(),
                          date: _selectedDate.toString().substring(0, 10),
                          note: _contentController.text.trim(),
                        );
                        if (widget.existing != null) {
                          await DatabaseHelper().updatePokemon(pokedek);
                        } else {
                          await DatabaseHelper().insertPokemon(pokedek);
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
    );
  }
}
