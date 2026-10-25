import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class Quote {
  final String text;
  final String author;
  final String source;

  Quote({required this.text, required this.author, this.source = ''});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] ?? json['text'] ?? '',
      author: json['author'] ?? 'คติประจำใจ',
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'quote': text, 'author': author, 'source': source};
  }
}

class Pokedek {
  final int? id;
  final String name;
  final dynamic height;
  final dynamic weight;
  final String type;
  final String image;
  final String note;
  final String date;

  Pokedek({
    this.id,
    required this.name,
    this.height = '0',
    this.weight = '0',
    this.type = 'ไม่ทราบ',
    this.image = '',
    this.note = '',
    this.date = '',
  });

  // แปลง JSON (Map) → Pokedek (จาก PokeAPI)
  factory Pokedek.fromJson(Map<String, dynamic> json) {
    String typeName = 'ไม่ทราบ';
    if (json['types'] != null &&
        json['types'] is List &&
        (json['types'] as List).isNotEmpty) {
      typeName = json['types'][0]['type']?['name'] ?? 'ไม่ทราบ';
    }

    String imageUrl = json['sprites']?['front_default'] ?? '';

    return Pokedek(
      name: json['name'] ?? '',
      height: json['height']?.toString() ?? '0',
      weight: json['weight']?.toString() ?? '0',
      type: typeName,
      image: imageUrl,
      note: 'โปเกมอนสุ่ม',
      date: DateTime.now().toString().substring(0, 10),
    );
  }

  // แปลง Map → Pokedek (จาก SQLite)
  factory Pokedek.fromMap(Map<String, dynamic> map) {
    return Pokedek(
      id: map['id'],
      name: map['name'] ?? '',
      height: map['height'] ?? '0',
      weight: map['weight'] ?? '0',
      type: map['type'] ?? '',
      image: map['image'] ?? '',
      note: map['note'] ?? '',
      date: map['date'] ?? '',
    );
  }

  // แปลง Pokedek → Map (ลง SQLite)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'height': height.toString(),
      'weight': weight.toString(),
      'type': type,
      'image': image,
      'note': note,
      'date': date,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'height': height,
      'weight': weight,
      'type': type,
      'image': image,
      'note': note,
      'date': date,
    };
  }
}

class ApiService {
  static Future<Quote> fetchQuote() async {
    try {
      final url = Uri.parse('https://dummyjson.com/quotes/random');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data);
      } else {
        throw Exception('เซิร์ฟเวอร์ตอบผิดพลาด (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    }
  }

  static Future<Pokedek> fetchPokemon() async {
    try {
      final id = Random().nextInt(151) + 1;
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$id');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // if (response.statusCode == 200) {
      //   jsonDecode(response.body);
      //   final random = Random();
      //   return _thaiQuotes[random.nextInt(_thaiQuotes.length)];
      // } else {
      //   throw Exception('เซิร์ฟเวอร์ตอบผิดพลาด (${response.statusCode})');
      // }

      if (response.statusCode == 200) {
        // 200 = สำเร็จ
        final data = jsonDecode(response.body); // แปลง JSON → Map
        return Pokedek.fromJson(data);
      } else {
        throw Exception('โหลดโปเกมอนไม่สำเร็จ (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('เชื่อมต่อไม่ได้ ตรวจสอบอินเทอร์เน็ต');
    }
  }

  static const String studentId = '67011211113'; // << ใส่รหัสของคุณ
  static const String baseUrl =
      'https://thipwimon.comsciproject.net/mydiary/api.php/$studentId'; // << กล่องข้อมูลของเราโดยเฉพาะ

  // CREATE — เพิ่มบันทึก (POST)
  static Future<void> createDiary(
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'}, // บอกว่าส่ง JSON
      body: jsonEncode({
        // แปลง Map → JSON string
        'title': title,
        'content': content,
        'mood': mood,
        'date': date,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('เพิ่มไม่สำเร็จ (${response.statusCode})');
    }
  }

  // READ — ดึงข้อมูลบันทึกทั้งหมด (GET)
  static Future<List<dynamic>> getDiaries() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> all = jsonDecode(response.body);
      return all; // ได้เฉพาะกล่องของเรา ไม่ต้องกรอง
    }
    throw Exception('โหลดไม่สำเร็จ');
  }

  // UPDATE — แก้ไขบันทึก (PUT)
  static Future<void> updateDiary(
    String id,
    String title,
    String content,
    String mood,
    String date,
  ) async {
    final url = Uri.parse('$baseUrl/$id'); // ระบุ id ที่จะแก้
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content,
        'mood': mood,
        'date': date,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('แก้ไขไม่สำเร็จ');
    }
  }

  // DELETE — ลบบันทึก
  static Future<void> deleteDiary(String id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('ลบไม่สำเร็จ');
    }
  }
}
