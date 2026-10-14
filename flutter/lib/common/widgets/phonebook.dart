import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hbb/models/phonebook_model.dart';

import '../../common.dart';
import '../../models/platform_model.dart';

class PhonebookView extends StatefulWidget {
  const PhonebookView({Key? key}) : super(key: key);

  @override
  State<PhonebookView> createState() => _PhonebookViewState();
}

class _PhonebookViewState extends State<PhonebookView> {
  List<PhonebookEntry> _entries = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final json = await bind.mainPhonebookList();
    if (!mounted) return;
    setState(() => _entries = decodePhonebook(json));
  }

  Future<void> _edit([PhonebookEntry? e]) async {
    final id = TextEditingController(text: e?.id ?? '');
    final alias = TextEditingController(text: e?.alias ?? '');
    final group = TextEditingController(text: e?.group ?? '');
    final note = TextEditingController(text: e?.note ?? '');
    final pw = TextEditingController(text: e?.password ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate(e == null ? 'Add machine' : 'Edit machine')),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: id,
                enabled: e == null,
                decoration: InputDecoration(labelText: translate('ID'))),
            TextField(
                controller: pw,
                obscureText: true,
                decoration: InputDecoration(labelText: translate('Password'))),
            TextField(
                controller: alias,
                decoration: InputDecoration(labelText: translate('Alias'))),
            TextField(
                controller: group,
                decoration: InputDecoration(labelText: translate('Group'))),
            TextField(
                controller: note,
                decoration: InputDecoration(labelText: translate('Note'))),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(translate('Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(translate('OK'))),
        ],
      ),
    );
    if (ok != true || id.text.trim().isEmpty) return;
    await bind.mainPhonebookSave(
        entry: jsonEncode(PhonebookEntry(
                id: id.text,
                password: pw.text,
                alias: alias.text.trim(),
                group: group.text.trim(),
                note: note.text.trim())
            .toJson()));
    _reload();
  }

  Future<void> _import() async {
    final text = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('Import machines')),
        content: SizedBox(
          width: 480,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(translate('phonebook_import_tip')),
            TextField(controller: text, minLines: 8, maxLines: 12),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(translate('Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(translate('Import machines'))),
        ],
      ),
    );
    if (ok != true) return;
    final entries = parsePhonebookLines(text.text);
    final n = await bind.mainPhonebookImport(
        data: jsonEncode(entries.map((e) => e.toJson()).toList()));
    showToast(n < 0 ? translate('Failed') : '$n');
    _reload();
  }

  Future<void> _remove(PhonebookEntry e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('Delete')),
        content: Text(e.title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(translate('Cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(translate('OK'))),
        ],
      ),
    );
    if (ok != true) return;
    await bind.mainPhonebookRemove(id: e.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final shown = _entries.where((e) => e.matches(_query)).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: translate('Search'),
                  isDense: true),
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (v) {
                final id = v.replaceAll(' ', '');
                if (_entries.every((e) => !e.matches(v)) && id.isNotEmpty) {
                  connect(context, id);
                }
              },
            ),
          ),
          IconButton(
              tooltip: translate('Add machine'),
              onPressed: _edit,
              icon: const Icon(Icons.add)),
          IconButton(
              tooltip: translate('Import machines'),
              onPressed: _import,
              icon: const Icon(Icons.upload_file)),
        ]),
      ),
      Expanded(
        child: shown.isEmpty
            ? Center(child: Text(translate('Empty')))
            : ListView.builder(
                itemCount: shown.length,
                itemBuilder: (ctx, i) => _row(ctx, shown[i]),
              ),
      ),
    ]);
  }

  Widget _row(BuildContext context, PhonebookEntry e) {
    final sub = [
      if (e.alias.isNotEmpty) e.id,
      if (e.group.isNotEmpty) e.group,
      if (e.note.isNotEmpty) e.note,
    ].join('  ·  ');
    return ListTile(
      dense: true,
      title: Text(e.title),
      subtitle: sub.isEmpty ? null : Text(sub),
      onTap: () => connect(context, e.id, password: e.password),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
            tooltip: translate('Transfer file'),
            icon: const Icon(Icons.folder_open),
            onPressed: () => connect(context, e.id,
                isFileTransfer: true, password: e.password)),
        IconButton(
            tooltip: translate('Edit'),
            icon: const Icon(Icons.edit),
            onPressed: () => _edit(e)),
        IconButton(
            tooltip: translate('Delete'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _remove(e)),
      ]),
    );
  }
}
