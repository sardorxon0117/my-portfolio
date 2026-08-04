import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/portfolio_repository.dart';
import '../../core/app_data.dart';
import '../../models/stat.dart';
import '../widgets/locale_fields_editor.dart';
import '../admin_widgets.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key});

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  List<Stat>? _stats;
  int _newCounter = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stats = await context.read<PortfolioRepository>().getStats();
      if (mounted) setState(() => _stats = stats);
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  void _addNew() {
    _newCounter++;
    setState(() {
      _stats = [..._stats!, Stat(id: -_newCounter, orderIndex: _stats!.length, count: 0, label: const {})];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Statistika', style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 20)),
            ElevatedButton(onPressed: _addNew, child: const Text("+ Qo'shish")),
          ],
        ),
        const SizedBox(height: 16),
        ..._stats!.map((s) => _StatCard(
              key: ValueKey(s.id),
              stat: s,
              onDeleted: () {
                setState(() => _stats!.removeWhere((x) => x.id == s.id));
                context.read<AppData>().load();
              },
              onSaved: (saved) {
                setState(() {
                  final i = _stats!.indexWhere((x) => x.id == s.id);
                  _stats![i] = saved;
                });
                context.read<AppData>().load();
              },
            )),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final Stat stat;
  final VoidCallback onDeleted;
  final ValueChanged<Stat> onSaved;
  const _StatCard({super.key, required this.stat, required this.onDeleted, required this.onSaved});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  final _labelKey = GlobalKey<LocaleFieldsEditorState>();
  late final TextEditingController _countCtrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _countCtrl = TextEditingController(text: widget.stat.count.toString());
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = context.read<PortfolioRepository>();
    final count = int.tryParse(_countCtrl.text) ?? 0;
    final labelRaw = _labelKey.currentState!.getValues();
    final label = {for (final e in labelRaw.entries) e.key: e.value['label'] ?? ''};
    try {
      final saved = widget.stat.id > 0
          ? await repo.updateStat(widget.stat.id, count: count, label: label)
          : await repo.createStat(count: count, label: label, orderIndex: widget.stat.orderIndex);
      widget.onSaved(saved);
      if (mounted) showAdminToast(context, 'Saqlandi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (widget.stat.id <= 0) {
      widget.onDeleted();
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<PortfolioRepository>().deleteStat(widget.stat.id);
      widget.onDeleted();
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: widget.stat.id > 0 ? 'Statistika #${widget.stat.id}' : 'Yangi statistika',
      child: Column(
        children: [
          TextField(
            controller: _countCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Son (masalan: 20)'),
          ),
          const SizedBox(height: 12),
          LocaleFieldsEditor(
            key: _labelKey,
            initialValues: {for (final e in widget.stat.label.entries) e.key: {'label': e.value}},
            fields: const [LocaleFieldDef(key: 'label', label: 'Yorliq (masalan: Loyihalar)')],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _busy ? null : _save,
                  child: _busy ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Saqlash'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _busy ? null : _delete, child: const Text("O'chirish")),
            ],
          ),
        ],
      ),
    );
  }
}
