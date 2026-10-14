import 'package:flutter_hbb/models/phonebook_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parsePhonebookLines reads id, password, alias, group', () {
    final r = parsePhonebookLines(
        '123 456 789, secret, Front desk, Office\n\nnot an id\n987654321;pw2');
    expect(r.length, 2);
    expect(r[0].id, '123456789');
    expect(r[0].password, 'secret');
    expect(r[0].alias, 'Front desk');
    expect(r[0].group, 'Office');
    expect(r[1].id, '987654321');
    expect(r[1].alias, '');
  });

  test('matches searches id, alias, group and note', () {
    const e = PhonebookEntry(id: '123456789', alias: 'Accounts PC', group: 'HQ');
    expect(e.matches('accounts'), isTrue);
    expect(e.matches('hq'), isTrue);
    expect(e.matches('nope'), isFalse);
    expect(e.title, 'Accounts PC');
  });
}
