import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/portfolio_repository.dart';
import '../../core/app_data.dart';
import '../admin_widgets.dart';

const Map<String, String> _socialLabels = {
  'telegram': 'Telegram',
  'telegram_channel': 'Telegram kanal',
  'github': 'GitHub',
  'facebook': 'Facebook',
  'instagram': 'Instagram',
};

class SocialTab extends StatefulWidget {
  const SocialTab({super.key});

  @override
  State<SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<SocialTab> {
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _saving = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    for (final platform in _socialLabels.keys) {
      _controllers[platform] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    try {
      final links = await context.read<PortfolioRepository>().getSocialLinks();
      for (final l in links) {
        _controllers[l.platform]?.text = l.url;
      }
      if (mounted) setState(() => _loaded = true);
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(String platform) async {
    setState(() => _saving.add(platform));
    try {
      await context.read<PortfolioRepository>().saveSocialLink(platform, _controllers[platform]!.text.trim());
      if (mounted) {
        context.read<AppData>().load();
        showAdminToast(context, 'Saqlandi.');
      }
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving.remove(platform));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in _socialLabels.entries)
          AdminCard(
            title: entry.value,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controllers[entry.key], decoration: const InputDecoration(labelText: 'URL'))),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saving.contains(entry.key) ? null : () => _save(entry.key),
                  child: _saving.contains(entry.key)
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Saqlash'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
