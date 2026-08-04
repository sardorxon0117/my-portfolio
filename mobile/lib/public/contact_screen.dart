import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/i18n.dart';
import '../core/theme.dart';
import '../core/app_data.dart';
import '../core/portfolio_repository.dart';

const Map<String, IconData> _socialIcons = {
  'telegram': Icons.send_rounded,
  'telegram_channel': Icons.campaign_rounded,
  'github': Icons.code_rounded,
  'facebook': Icons.facebook_rounded,
  'instagram': Icons.camera_alt_rounded,
};

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _sending = false;
  String? _status;

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _send(LocaleProvider locale) async {
    if ([_nameCtrl.text, _emailCtrl.text, _subjectCtrl.text, _messageCtrl.text].any((s) => s.trim().isEmpty)) {
      setState(() => _status = "Barcha maydonlar to'ldirilishi shart.");
      return;
    }
    setState(() { _sending = true; _status = null; });
    try {
      await context.read<PortfolioRepository>().submitMessage(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            subject: _subjectCtrl.text.trim(),
            message: _messageCtrl.text.trim(),
          );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
      setState(() => _status = 'Yuborildi ✓');
    } catch (e) {
      setState(() => _status = e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final appData = context.watch<AppData>();
    final contact = appData.content.contact;

    return Scaffold(
      appBar: AppBar(title: Text(locale.t('contact_heading'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (contact['email'] != null)
            _ContactRow(icon: Icons.email_rounded, label: locale.t('email_label'), value: contact['email'], onTap: () => _openUrl('mailto:${contact['email']}')),
          if (contact['phone'] != null)
            _ContactRow(icon: Icons.phone_rounded, label: locale.t('phone_label'), value: contact['phone'], onTap: () => _openUrl('tel:${contact['phone']}')),
          if (appData.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(locale.t('social_label'), style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: appData.socialLinks.where((s) => s.url.isNotEmpty).map((s) {
                return ActionChip(
                  avatar: Icon(_socialIcons[s.platform] ?? Icons.link_rounded, size: 16),
                  label: Text(locale.t('social_${s.platform}') != 'social_${s.platform}' ? locale.t('social_${s.platform}') : s.platform),
                  onPressed: () => _openUrl(s.url),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 28),
          Text(locale.t('form_message'), style: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 14),
          TextField(controller: _nameCtrl, decoration: InputDecoration(hintText: locale.t('form_name'))),
          const SizedBox(height: 10),
          TextField(controller: _emailCtrl, decoration: InputDecoration(hintText: locale.t('form_email')), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 10),
          TextField(controller: _subjectCtrl, decoration: InputDecoration(hintText: locale.t('form_subject'))),
          const SizedBox(height: 10),
          TextField(controller: _messageCtrl, decoration: InputDecoration(hintText: locale.t('form_message')), maxLines: 4),
          const SizedBox(height: 14),
          if (_status != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_status!, style: const TextStyle(color: AppColors.accent))),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sending ? null : () => _send(locale),
              child: _sending
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(locale.t('form_submit')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  const _ContactRow({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: AppColors.brown200.withValues(alpha: 0.3), child: Icon(icon, color: AppColors.accent, size: 18)),
      title: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
