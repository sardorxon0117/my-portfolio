import 'package:flutter/foundation.dart';
import 'portfolio_repository.dart';
import '../models/site_content.dart';
import '../models/stat.dart';
import '../models/skill.dart';
import '../models/project.dart';
import '../models/social_link.dart';

/// Loads everything the public Home/Aloqa screens need in one pass —
/// mirrors app.js's loadData() fetching content/stats/skills/projects/social in parallel.
class AppData extends ChangeNotifier {
  final PortfolioRepository _repo;
  AppData(this._repo);

  bool loading = true;
  String? error;

  SiteContent content = SiteContent.empty();
  List<Stat> stats = [];
  List<Skill> skills = [];
  List<Project> featuredProjects = [];
  List<SocialLink> socialLinks = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.getContent(),
        _repo.getStats(),
        _repo.getSkills(),
        _repo.getFeaturedProjects(),
        _repo.getSocialLinks(),
      ]);
      content = results[0] as SiteContent;
      stats = results[1] as List<Stat>;
      skills = results[2] as List<Skill>;
      featuredProjects = results[3] as List<Project>;
      socialLinks = results[4] as List<SocialLink>;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}
