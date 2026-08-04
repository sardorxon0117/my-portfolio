import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/portfolio_repository.dart';
import '../../core/theme.dart';
import '../../models/message.dart';
import '../admin_widgets.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  List<ContactMessage>? _messages;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final messages = await context.read<PortfolioRepository>().getAllMessages();
      if (mounted) setState(() => _messages = messages);
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _markRead(ContactMessage m) async {
    if (m.isRead) return;
    try {
      await context.read<PortfolioRepository>().markMessageRead(m.id);
      setState(() {
        final i = _messages!.indexWhere((x) => x.id == m.id);
        _messages![i] = ContactMessage(id: m.id, name: m.name, email: m.email, subject: m.subject, message: m.message, isRead: true, createdAt: m.createdAt);
      });
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _delete(ContactMessage m) async {
    try {
      await context.read<PortfolioRepository>().deleteMessage(m.id);
      setState(() => _messages!.removeWhere((x) => x.id == m.id));
    } catch (e) {
      if (mounted) showAdminToast(context, e.toString(), isError: true);
    }
  }

  Future<void> _reply(ContactMessage m) async {
    final uri = Uri(scheme: 'mailto', path: m.email, queryParameters: {'subject': 'Re: ${m.subject}'});
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    if (_messages == null) return const Center(child: CircularProgressIndicator());
    if (_messages!.isEmpty) return const Center(child: Text("Hozircha xabarlar yo'q."));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages!.length,
      itemBuilder: (context, i) {
        final m = _messages![i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: m.isRead ? BorderSide.none : const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          child: InkWell(
            onTap: () => _markRead(m),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                      if (!m.isRead) const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.circle, size: 8, color: AppColors.accent)),
                    ],
                  ),
                  Text(m.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(m.subject, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(m.message),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(onPressed: () => _reply(m), child: const Text('Javob yozish')),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => _delete(m)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
