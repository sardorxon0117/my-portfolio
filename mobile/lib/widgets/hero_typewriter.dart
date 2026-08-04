import 'dart:async';
import 'package:flutter/material.dart';

/// Mirrors app.js's startHeroTypewriter: cycles through comma-separated
/// phrases with a type/pause/delete/pause loop. A single phrase (no comma)
/// just renders statically, same as the web fallback.
class HeroTypewriter extends StatefulWidget {
  final String rawText; // may contain comma-separated phrases
  final TextStyle? style;
  const HeroTypewriter({super.key, required this.rawText, this.style});

  @override
  State<HeroTypewriter> createState() => _HeroTypewriterState();
}

class _HeroTypewriterState extends State<HeroTypewriter> {
  static const _typeMs = 75;
  static const _deleteMs = 40;
  static const _pauseFullMs = 1700;
  static const _pauseEmptyMs = 350;

  late List<String> _phrases;
  int _phraseIndex = 0;
  int _charIndex = 0;
  bool _deleting = false;
  Timer? _timer;
  String _shown = '';

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant HeroTypewriter old) {
    super.didUpdateWidget(old);
    if (old.rawText != widget.rawText) _setup();
  }

  void _setup() {
    _timer?.cancel();
    _phrases = widget.rawText.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    _phraseIndex = 0;
    _charIndex = 0;
    _deleting = false;
    if (_phrases.isEmpty) {
      setState(() => _shown = '');
      return;
    }
    if (_phrases.length == 1) {
      setState(() => _shown = _phrases.first);
      return;
    }
    setState(() => _shown = '');
    _timer = Timer(const Duration(milliseconds: _typeMs), _tick);
  }

  void _tick() {
    if (!mounted || _phrases.isEmpty) return;
    final current = _phrases[_phraseIndex];
    if (!_deleting) {
      _charIndex++;
      setState(() => _shown = current.substring(0, _charIndex));
      if (_charIndex == current.length) {
        _timer = Timer(const Duration(milliseconds: _pauseFullMs), () {
          _deleting = true;
          _tick();
        });
        return;
      }
      _timer = Timer(const Duration(milliseconds: _typeMs), _tick);
    } else {
      _charIndex--;
      setState(() => _shown = current.substring(0, _charIndex));
      if (_charIndex == 0) {
        _deleting = false;
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
        _timer = Timer(const Duration(milliseconds: _pauseEmptyMs), _tick);
        return;
      }
      _timer = Timer(const Duration(milliseconds: _deleteMs), _tick);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: _shown, style: widget.style),
        if (_phrases.length > 1) TextSpan(text: '|', style: widget.style),
      ]),
    );
  }
}
