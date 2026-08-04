import 'api_client.dart';
import '../models/project.dart';
import '../models/skill.dart';
import '../models/stat.dart';
import '../models/review.dart';
import '../models/message.dart';
import '../models/social_link.dart';
import '../models/site_content.dart';

/// Typed wrapper around ApiClient — one method per endpoint in server/routes/*.js.
class PortfolioRepository {
  final ApiClient _api;
  PortfolioRepository(this._api);

  // ===== Public reads =====
  Future<SiteContent> getContent() async => SiteContent.fromJson(await _api.get('/content'));

  Future<List<Stat>> getStats() async => (await _api.get('/stats') as List).map((e) => Stat.fromJson(e)).toList();

  Future<List<Skill>> getSkills() async => (await _api.get('/skills') as List).map((e) => Skill.fromJson(e)).toList();

  Future<List<Project>> getProjects() async => (await _api.get('/projects') as List).map((e) => Project.fromJson(e)).toList();

  Future<List<Project>> getFeaturedProjects() async =>
      (await _api.get('/projects/featured') as List).map((e) => Project.fromJson(e)).toList();

  Future<Project> getProject(String slug) async => Project.fromJson(await _api.get('/projects/${Uri.encodeComponent(slug)}'));

  Future<List<SocialLink>> getSocialLinks() async =>
      (await _api.get('/social-links') as List).map((e) => SocialLink.fromJson(e)).toList();

  Future<Map<String, dynamic>> getReviews(String slug) async =>
      Map<String, dynamic>.from(await _api.get('/projects/${Uri.encodeComponent(slug)}/reviews'));

  // ===== Public writes =====
  Future<void> submitReview(String slug, {required String name, required int rating, required String comment}) =>
      _api.post('/projects/${Uri.encodeComponent(slug)}/reviews', body: {'name': name, 'rating': rating, 'comment': comment});

  Future<void> submitMessage({required String name, required String email, required String subject, required String message}) =>
      _api.post('/messages', body: {'name': name, 'email': email, 'subject': subject, 'message': message});

  Future<void> trackView(String slug) => _api.post('/projects/${Uri.encodeComponent(slug)}/view');

  // ===== Admin auth =====
  Future<String> login(String username, String password) async {
    final res = await _api.post('/auth/login', body: {'username': username, 'password': password});
    return res['token'] as String;
  }

  Future<bool> checkAuth() async {
    try {
      await _api.get('/auth/me');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ===== Admin: content =====
  Future<void> saveContent(String section, Map<String, dynamic> data) => _api.put('/admin/content/$section', body: data);

  // ===== Admin: stats =====
  Future<Stat> createStat({required int count, required Map<String, dynamic> label, int orderIndex = 0}) async =>
      Stat.fromJson(await _api.post('/admin/stats', body: {'count': count, 'label': label, 'order_index': orderIndex}));
  Future<Stat> updateStat(int id, {required int count, required Map<String, dynamic> label}) async =>
      Stat.fromJson(await _api.put('/admin/stats/$id', body: {'count': count, 'label': label}));
  Future<void> deleteStat(int id) => _api.delete('/admin/stats/$id');

  // ===== Admin: skills =====
  Future<Skill> createSkill({String? imageUrl, required int percent, required Map<String, dynamic> name, int orderIndex = 0}) async =>
      Skill.fromJson(await _api.post('/admin/skills', body: {'image_url': imageUrl, 'percent': percent, 'name': name, 'order_index': orderIndex}));
  Future<Skill> updateSkill(int id, {String? imageUrl, required int percent, required Map<String, dynamic> name}) async =>
      Skill.fromJson(await _api.put('/admin/skills/$id', body: {'image_url': imageUrl, 'percent': percent, 'name': name}));
  Future<void> deleteSkill(int id) => _api.delete('/admin/skills/$id');

  // ===== Admin: projects =====
  Future<Project> createProject(Map<String, dynamic> payload) async => Project.fromJson(await _api.post('/admin/projects', body: payload));
  Future<Project> updateProject(int id, Map<String, dynamic> payload) async => Project.fromJson(await _api.put('/admin/projects/$id', body: payload));
  Future<void> setFeatured(int id, {required bool featured, int featuredOrder = 0}) =>
      _api.put('/admin/projects/$id/feature', body: {'featured': featured, 'featured_order': featuredOrder});
  Future<void> deleteProject(int id) => _api.delete('/admin/projects/$id');

  // ===== Admin: social links =====
  Future<void> saveSocialLink(String platform, String url) => _api.put('/admin/social-links/$platform', body: {'url': url});

  // ===== Admin: reviews =====
  Future<List<Review>> getAllReviews() async => (await _api.get('/admin/reviews') as List).map((e) => Review.fromJson(e)).toList();
  Future<void> replyToReview(int id, String reply) => _api.put('/admin/reviews/$id/reply', body: {'reply': reply});
  Future<void> deleteReview(int id) => _api.delete('/admin/reviews/$id');

  // ===== Admin: messages =====
  Future<List<ContactMessage>> getAllMessages() async =>
      (await _api.get('/admin/messages') as List).map((e) => ContactMessage.fromJson(e)).toList();
  Future<void> markMessageRead(int id) => _api.put('/admin/messages/$id/read');
  Future<void> deleteMessage(int id) => _api.delete('/admin/messages/$id');

  // ===== Admin: presigned upload =====
  Future<Map<String, String>> getUploadUrl({required String filename, required String contentType, required String folder}) async {
    final res = await _api.post('/admin/upload-url', body: {'filename': filename, 'contentType': contentType, 'folder': folder});
    return {'uploadUrl': res['uploadUrl'] as String, 'publicUrl': res['publicUrl'] as String};
  }
}
