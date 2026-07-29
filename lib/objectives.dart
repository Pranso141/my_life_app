import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ObjectivesScreen extends StatefulWidget {
  const ObjectivesScreen({super.key});
  @override
  State<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends State<ObjectivesScreen> {
  static const _storageKey = 'objectives_table_v2';

  List<String> _columns = ['Sem 5', 'Sem 6', 'Sem 7', 'Sem 8'];
  // Each row: list of cells, one per column. Cell = {text, checked}
  List<List<Map<String, dynamic>>> _rows = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _columns = (data['columns'] as List).cast<String>();
      _rows = (data['rows'] as List)
          .map<List<Map<String, dynamic>>>((row) => (row as List).map((c) => Map<String, dynamic>.from(c)).toList())
          .toList();
    } else {
      _rows = [
        for (int i = 0; i < 3; i++) [for (final _ in _columns) {'text': '', 'checked': false}]
      ];
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode({'columns': _columns, 'rows': _rows}));
  }

  void _addColumn() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Column'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Column name'), autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _columns.add(name);
                  for (final row in _rows) {
                    row.add({'text': '', 'checked': false});
                  }
                });
                _save();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeColumn(int colIndex) {
    setState(() {
      _columns.removeAt(colIndex);
      for (final row in _rows) {
        row.removeAt(colIndex);
      }
    });
    _save();
  }

  void _addRow() {
    setState(() => _rows.add([for (final _ in _columns) {'text': '', 'checked': false}]));
    _save();
  }

  void _removeRow(int rowIndex) {
    setState(() => _rows.removeAt(rowIndex));
    _save();
  }

  void _editCellText(int rowIndex, int colIndex) {
    final ctrl = TextEditingController(text: _rows[rowIndex][colIndex]['text'] as String);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Goal'),
        content: TextField(controller: ctrl, autofocus: true, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() => _rows[rowIndex][colIndex]['text'] = ctrl.text.trim());
              _save();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleCheck(int rowIndex, int colIndex) {
    setState(() {
      _rows[rowIndex][colIndex]['checked'] = !(_rows[rowIndex][colIndex]['checked'] as bool);
    });
    _save();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder.all(color: Colors.grey.shade700, width: 0.5),
            children: [
              TableRow(children: [
                _headerCell(''),
                for (int c = 0; c < _columns.length; c++)
                  _headerCell(_columns[c], onDelete: () => _removeColumn(c)),
              ]),
              for (int r = 0; r < _rows.length; r++)
                TableRow(children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _removeRow(r)),
                  ),
                  for (int c = 0; c < _columns.length; c++) _dataCell(r, c),
                ]),
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(heroTag: 'addCol', onPressed: _addColumn, tooltip: 'Add column', child: const Icon(Icons.view_column)),
          const SizedBox(width: 12),
          FloatingActionButton(heroTag: 'addRow', onPressed: _addRow, tooltip: 'Add row', child: const Icon(Icons.add)),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {VoidCallback? onDelete}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (onDelete != null) IconButton(icon: const Icon(Icons.close, size: 14), onPressed: onDelete),
      ]),
    );
  }

  Widget _dataCell(int r, int c) {
    final cell = _rows[r][c];
    final checked = cell['checked'] as bool;
    final text = cell['text'] as String;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Checkbox(value: checked, onChanged: (_) => _toggleCheck(r, c)),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: InkWell(
            onTap: () => _editCellText(r, c),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                text.isEmpty ? '(tap to edit)' : text,
                style: TextStyle(
                  color: text.isEmpty ? Colors.grey : (checked ? Colors.grey : null),
                  decoration: checked ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
