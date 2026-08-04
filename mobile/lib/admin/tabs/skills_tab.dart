import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/portfolio_repository.dart';
import '../../core/app_data.dart';
import '../../models/skill.dart';
import '../widgets/locale_fields_editor.dart';
import '../widgets/upload_picker.dart';
import '../admin_widgets.dart';

class SkillsTab extends StatefulWidget {
  const SkillsTab({super.key});

  @override
  State<SkillsTab> createState() => _SkillsTabState();
}

class _SkillsTabState extends State<SkillsTab> {
  List<Skill>? _skills;
  int _newCounter = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final skills = await context.read<PortfolioRepository>().getSkills();
      if (mounted) setState(() => _skills = skills);
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  void _addNew() {
    _newCounter++;
    setState(() {
      _skills = [..._skills!, Skill(id: -_newCounter, orderIndex: _skills!.length, percent: 50, name: const {})];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_skills == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Ko'nikmalar", style: TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 20)),
            ElevatedButton(onPressed: _addNew, child: const Text("+ Qo'shish")),
          ],
        ),
        const SizedBox(height: 16),
        ..._skills!.map((s) => _SkillCard(
              key: ValueKey(s.id),
              skill: s,
              onDeleted: () {
                setState(() => _skills!.removeWhere((x) => x.id == s.id));
                context.read<AppData>().load();
              },
              onSaved: (saved) {
                setState(() {
                  final i = _skills!.indexWhere((x) => x.id == s.id);
                  _skills![i] = saved;
                });
                context.read<AppData>().load();
              },
            )),
      ],
    );
  }
}

class _SkillCard extends StatefulWidget {
  final Skill skill;
  final VoidCallback onDeleted;
  final ValueChanged<Skill> onSaved;
  const _SkillCard({super.key, required this.skill, required this.onDeleted, required this.onSaved});

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> {
  final _nameKey = GlobalKey<LocaleFieldsEditorState>();
  late final TextEditingController _percentCtrl;
  String? _imageUrl;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _percentCtrl = TextEditingController(text: widget.skill.percent.toString());
    _imageUrl = widget.skill.imageUrl;
  }

  @override
  void dispose() {
    _percentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final repo = context.read<PortfolioRepository>();
    final percent = (int.tryParse(_percentCtrl.text) ?? 0).clamp(0, 100);
    final nameRaw = _nameKey.currentState!.getValues();
    final name = {for (final e in nameRaw.entries) e.key: e.value['name'] ?? ''};
    try {
      final saved = widget.skill.id > 0
          ? await repo.updateSkill(widget.skill.id, imageUrl: _imageUrl, percent: percent, name: name)
          : await repo.createSkill(imageUrl: _imageUrl, percent: percent, name: name, orderIndex: widget.skill.orderIndex);
      widget.onSaved(saved);
      if (mounted) showAdminToast(context, 'Saqlandi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (widget.skill.id <= 0) {
      widget.onDeleted();
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<PortfolioRepository>().deleteSkill(widget.skill.id);
      widget.onDeleted();
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      title: widget.skill.id > 0 ? "Ko'nikma #${widget.skill.id}" : "Yangi ko'nikma",
      child: Column(
        children: [
          UploadPicker(
            initialUrl: _imageUrl,
            folder: 'skills',
            fileType: FileType.image,
            label: 'Rasm/ikon',
            onUploaded: (url) => setState(() => _imageUrl = url),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _percentCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Foiz (0-100)'),
          ),
          const SizedBox(height: 12),
          LocaleFieldsEditor(
            key: _nameKey,
            initialValues: {for (final e in widget.skill.name.entries) e.key: {'name': e.value}},
            fields: const [LocaleFieldDef(key: 'name', label: 'Nomi')],
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
