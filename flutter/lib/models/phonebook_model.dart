import 'dart:convert';

class PhonebookEntry {
  final String id;
  final String alias;
  final String group;
  final String note;
  final String password;

  const PhonebookEntry({
    required this.id,
    this.alias = '',
    this.group = '',
    this.note = '',
    this.password = '',
  });

  factory PhonebookEntry.fromJson(Map<String, dynamic> j) => PhonebookEntry(
        id: j['id'] ?? '',
        alias: j['alias'] ?? '',
        group: j['group'] ?? '',
        note: j['note'] ?? '',
        password: j['password'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'alias': alias,
        'group': group,
        'note': note,
        'password': password,
      };

  String get title => alias.isEmpty ? id : alias;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [id, alias, group, note].any((s) => s.toLowerCase().contains(q));
  }
}

List<PhonebookEntry> decodePhonebook(String json) {
  try {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PhonebookEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Parses pasted notes, one machine per line: `id, password, alias, group`.
/// Separators may be comma, semicolon or tab. Spaces inside an id are ignored,
/// so `123 456 789` works. Lines without a numeric-looking id are skipped.
List<PhonebookEntry> parsePhonebookLines(String text) {
  final out = <PhonebookEntry>[];
  for (final line in text.split('\n')) {
    final parts = line.split(RegExp(r'[,;\t]')).map((s) => s.trim()).toList();
    if (parts.isEmpty) continue;
    final id = parts[0].replaceAll(' ', '');
    if (!RegExp(r'^[0-9A-Za-z_.@:-]{6,}$').hasMatch(id)) continue;
    String at(int i) => i < parts.length ? parts[i] : '';
    out.add(PhonebookEntry(
        id: id, password: at(1), alias: at(2), group: at(3)));
  }
  return out;
}
