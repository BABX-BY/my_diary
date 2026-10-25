
class Diary {
  final int? id;
  final String title;
  final String content;
  final String date;
  final String mood;
  final String quote;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    this.quote = '',
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'date': date,
      'mood': mood,
      'quote': quote,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Diary.fromMap(Map<String, dynamic> map) {
    return Diary(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: map['date'],
      mood: map['mood'] ?? 'เฉยๆ',
      quote: map['quote'] ?? '',
    );
  }
}
