import 'package:flutter/material.dart';

class FirestoreFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const FirestoreFormPage({super.key, this.existing});
  @override
  State<FirestoreFormPage> createState() => _FirestoreFormPageState();
}

class _FirestoreFormPageState extends State<FirestoreFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing['title']?.toString() ?? '';
      _contentController.text = existing['content']?.toString() ?? '';
      _selectedDate =
          DateTime.tryParse(existing['date']?.toString() ?? '') ??
          DateTime.now();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขบันทึก (Cloud)' : 'เพิ่มบันทึก (Cloud)'),
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
                    hintText: 'เช่น วันนี้เป็นวันที่ดี',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรอกชื่อเรื่อง' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'เนื้อหา',
                    hintText: 'เขียนเรื่องราว ความรู้สึก หรือสิ่งที่อยากจำ...',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'กรอกเนื้อหา' : null,
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
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, {
                          'title': _titleController.text.trim(),
                          'content': _contentController.text.trim(),
                          'date': _selectedDate.toString().substring(0, 10),
                        });
                      }
                    },
                    child: Text(_isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มบันทึก'),
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
