import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../../core/theme.dart';
import '../../core/portfolio_repository.dart';

const _maxVideoBytes = 150 * 1024 * 1024;

const Map<String, String> _mimeByExt = {
  'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png', 'webp': 'image/webp', 'gif': 'image/gif',
  'mp4': 'video/mp4', 'mov': 'video/quicktime', 'webm': 'video/webm', 'mkv': 'video/x-matroska',
};

/// Shared pick-and-upload core used by both UploadPicker (single-slot: banner,
/// logo, poster, about photo, skill icon) and the screenshots list manager
/// (append-only). Returns the public S3 URL, or null if cancelled/failed
/// (errors are surfaced via [onError]).
Future<String?> pickAndUploadFile(
  BuildContext context, {
  required PortfolioRepository repo,
  required String folder,
  required FileType fileType,
  required ValueChanged<String> onError,
}) async {
  final result = await FilePicker.platform.pickFiles(type: fileType);
  if (result == null || result.files.isEmpty || result.files.first.path == null) return null;
  final pf = result.files.first;

  if (fileType == FileType.video && pf.size > _maxVideoBytes) {
    onError("Video hajmi juda katta (maksimal 150MB). Tanlangan fayl: ${(pf.size / 1024 / 1024).toStringAsFixed(1)}MB");
    return null;
  }

  final ext = (pf.extension ?? '').toLowerCase();
  final contentType = _mimeByExt[ext] ?? (fileType == FileType.video ? 'video/mp4' : 'image/jpeg');

  try {
    final urls = await repo.getUploadUrl(filename: pf.name, contentType: contentType, folder: folder);
    final bytes = await File(pf.path!).readAsBytes();
    final res = await http.put(Uri.parse(urls['uploadUrl']!), headers: {'Content-Type': contentType}, body: bytes);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Yuklashda xatolik (${res.statusCode})');
    }
    return urls['publicUrl'];
  } catch (e) {
    onError(e.toString());
    return null;
  }
}

/// Mirrors admin.js's upload-zone + uploadImage(): pick a file, get a
/// presigned S3 URL from our API, PUT the bytes straight to S3.
class UploadPicker extends StatefulWidget {
  final String? initialUrl;
  final String folder;
  final FileType fileType;
  final ValueChanged<String?> onUploaded;
  final String label;
  final double previewSize;
  const UploadPicker({
    super.key,
    this.initialUrl,
    required this.folder,
    required this.fileType,
    required this.onUploaded,
    required this.label,
    this.previewSize = 84,
  });

  @override
  State<UploadPicker> createState() => _UploadPickerState();
}

class _UploadPickerState extends State<UploadPicker> {
  String? _url;
  bool _uploading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  @override
  void didUpdateWidget(covariant UploadPicker old) {
    super.didUpdateWidget(old);
    if (old.initialUrl != widget.initialUrl) _url = widget.initialUrl;
  }

  Future<void> _pick() async {
    final repo = context.read<PortfolioRepository>();
    setState(() { _uploading = true; _error = null; });
    final url = await pickAndUploadFile(
      context,
      repo: repo,
      folder: widget.folder,
      fileType: widget.fileType,
      onError: (msg) => _error = msg,
    );
    if (!mounted) return;
    setState(() {
      _uploading = false;
      if (url != null) _url = url;
    });
    if (url != null) widget.onUploaded(url);
  }

  void _clear() {
    setState(() => _url = null);
    widget.onUploaded(null);
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.fileType == FileType.video;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              width: widget.previewSize,
              height: widget.previewSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.brown200.withValues(alpha: 0.25),
                border: Border.all(color: AppColors.brown300.withValues(alpha: 0.4)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _url != null
                  ? (isVideo
                      ? const Icon(Icons.videocam_rounded, color: AppColors.accent)
                      : CachedNetworkImage(imageUrl: _url!, fit: BoxFit.cover))
                  : Icon(isVideo ? Icons.videocam_outlined : Icons.image_outlined, color: AppColors.accent),
            ),
            if (_uploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.black45),
                  child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(onPressed: _uploading ? null : _pick, child: const Text('Tanlash')),
                  if (_url != null) TextButton(onPressed: _uploading ? null : _clear, child: const Text("O'chirish")),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
