import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/app_data.dart';
import '../../core/portfolio_repository.dart';
import '../widgets/locale_fields_editor.dart';
import '../widgets/upload_picker.dart';
import '../admin_widgets.dart';

class ContentTab extends StatefulWidget {
  const ContentTab({super.key});

  @override
  State<ContentTab> createState() => _ContentTabState();
}

class _ContentTabState extends State<ContentTab> {
  final _heroKey = GlobalKey<LocaleFieldsEditorState>();
  final _aboutKey = GlobalKey<LocaleFieldsEditorState>();
  final _marqueeKey = GlobalKey<LocaleFieldsEditorState>();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _pendingAboutPhoto;

  @override
  void initState() {
    super.initState();
    final content = context.read<AppData>().content;
    _emailCtrl.text = (content.contact['email'] ?? '').toString();
    _phoneCtrl.text = (content.contact['phone'] ?? '').toString();
    _pendingAboutPhoto = content.about['photo_url'] as String?;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveHero() async {
    final repo = context.read<PortfolioRepository>();
    try {
      await repo.saveContent('hero', _heroKey.currentState!.getValues());
      if (!mounted) return;
      context.read<AppData>().load();
      showAdminToast(context, 'Hero saqlandi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _saveAbout() async {
    final repo = context.read<PortfolioRepository>();
    final values = _aboutKey.currentState!.getValues();
    final payload = {
      for (final locale in values.keys) locale: {...values[locale]!},
    };
    // photo_url isn't per-locale — attach it at the top level like the web admin does.
    try {
      await repo.saveContent('about', {...payload, 'photo_url': _pendingAboutPhoto});
      if (!mounted) return;
      context.read<AppData>().load();
      showAdminToast(context, 'Saqlandi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _saveContact() async {
    final repo = context.read<PortfolioRepository>();
    try {
      await repo.saveContent('contact', {'email': _emailCtrl.text.trim(), 'phone': _phoneCtrl.text.trim()});
      if (!mounted) return;
      context.read<AppData>().load();
      showAdminToast(context, 'Saqlandi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _saveMarquee() async {
    final repo = context.read<PortfolioRepository>();
    final raw = _marqueeKey.currentState!.getValues();
    // marquee is stored as {locale: [items...]} directly — not nested under an 'items' key.
    final payload = {
      for (final locale in raw.keys) locale: (raw[locale]!['items'] ?? '').split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
    };
    try {
      await repo.saveContent('marquee', payload);
      if (!mounted) return;
      context.read<AppData>().load();
      showAdminToast(context, 'Saqlandi.');
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = context.read<AppData>().content;
    // marquee is stored as {locale: [items...]} directly — not nested under an 'items' key.
    final marqueeInitial = {
      for (final entry in content.marquee.entries) entry.key: {'items': (entry.value as List?)?.join(', ') ?? ''},
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminCard(
          title: 'Hero (bosh banner)',
          child: Column(
            children: [
              LocaleFieldsEditor(
                key: _heroKey,
                initialValues: content.hero,
                fields: const [
                  LocaleFieldDef(key: 'eyebrow', label: 'Kichik sarlavha'),
                  LocaleFieldDef(key: 'name', label: 'Ism-familiya'),
                  LocaleFieldDef(key: 'role', label: "Kasb (bir nechta bo'lsa vergul bilan)"),
                  LocaleFieldDef(key: 'text', label: 'Tavsif matni', multiline: true),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveHero, child: const Text('Saqlash'))),
            ],
          ),
        ),
        AdminCard(
          title: 'Men haqimda',
          child: Column(
            children: [
              UploadPicker(
                initialUrl: _pendingAboutPhoto,
                folder: 'about',
                fileType: FileType.image,
                label: 'Rasm',
                onUploaded: (url) => setState(() => _pendingAboutPhoto = url),
              ),
              const SizedBox(height: 12),
              LocaleFieldsEditor(
                key: _aboutKey,
                initialValues: content.about,
                fields: const [
                  LocaleFieldDef(key: 'paragraph1', label: '1-paragraf', multiline: true),
                  LocaleFieldDef(key: 'paragraph2', label: '2-paragraf', multiline: true),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveAbout, child: const Text('Saqlash'))),
            ],
          ),
        ),
        AdminCard(
          title: "Bog'lanish ma'lumotlari",
          child: Column(
            children: [
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 10),
              TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Telefon')),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveContact, child: const Text('Saqlash'))),
            ],
          ),
        ),
        AdminCard(
          title: "Marquee lenta (o'tib turadigan matnlar)",
          child: Column(
            children: [
              LocaleFieldsEditor(
                key: _marqueeKey,
                initialValues: marqueeInitial,
                fields: const [LocaleFieldDef(key: 'items', label: 'Iboralar (vergul bilan)')],
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveMarquee, child: const Text('Saqlash'))),
            ],
          ),
        ),
      ],
    );
  }
}
