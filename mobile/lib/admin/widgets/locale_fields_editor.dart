import 'package:flutter/material.dart';
import '../../core/i18n.dart';

class LocaleFieldDef {
  final String key;
  final String label;
  final bool multiline;
  const LocaleFieldDef({required this.key, required this.label, this.multiline = false});
}

/// Mirrors admin.js's langTabGroup()/wireLangTabs()/readLangTabGroup(): a
/// language-tabbed set of text inputs for JSONB fields keyed {uz, uz_cyr, en, ru}.
class LocaleFieldsEditor extends StatefulWidget {
  final List<LocaleFieldDef> fields;
  final Map<String, dynamic> initialValues;
  const LocaleFieldsEditor({super.key, required this.fields, required this.initialValues});

  @override
  State<LocaleFieldsEditor> createState() => LocaleFieldsEditorState();
}

class LocaleFieldsEditorState extends State<LocaleFieldsEditor> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Map<String, TextEditingController>> _controllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: supportedLocales.length, vsync: this);
    for (final locale in supportedLocales) {
      _controllers[locale] = {};
      final localeValues = Map<String, dynamic>.from(widget.initialValues[locale] ?? {});
      for (final field in widget.fields) {
        _controllers[locale]![field.key] = TextEditingController(text: localeValues[field.key]?.toString() ?? '');
      }
    }
  }

  /// Returns {uz: {key: text}, uz_cyr: {...}, en: {...}, ru: {...}} — same shape the API expects.
  Map<String, Map<String, String>> getValues() {
    return {
      for (final locale in supportedLocales)
        locale: {for (final field in widget.fields) field.key: _controllers[locale]![field.key]!.text},
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final m in _controllers.values) {
      for (final c in m.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  double get _panelHeight =>
      widget.fields.fold(0.0, (sum, f) => sum + (f.multiline ? 132 : 76));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: supportedLocales.map((l) => Tab(text: localeShortLabels[l])).toList(),
        ),
        SizedBox(
          height: _panelHeight,
          child: TabBarView(
            controller: _tabController,
            children: supportedLocales.map((locale) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: widget.fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextField(
                        controller: _controllers[locale]![field.key],
                        maxLines: field.multiline ? 4 : 1,
                        decoration: InputDecoration(labelText: field.label),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
