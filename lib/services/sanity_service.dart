import 'dart:convert';
import 'package:http/http.dart' as http;

class SanityService {
  static const _projectId = 'hx8jof68';
  static const _dataset = 'production';
  static const _apiVersion = 'v2021-10-21';

  static Uri _queryUrl(String groq) {
    final encoded = Uri.encodeComponent(groq);
    return Uri.parse(
      'https://$_projectId.apicdn.sanity.io/$_apiVersion/data/query/$_dataset?query=$encoded',
    );
  }

  static Future<List<dynamic>> _fetch(String groq) async {
    final response = await http.get(_queryUrl(groq));
    if (response.statusCode != 200) {
      throw Exception('Sanity query failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    final result = data['result'];
    if (result == null) return [];
    if (result is List) return result;
    return [result];
  }

  // ─── Articles (Library) ───────────────────────────────────────────────────

  static Future<List<SanityArticle>> fetchArticles({int limit = 20}) async {
    final groq = '''
      *[_type == "article"] | order(_createdAt desc) [0...$limit] {
        _id, title, excerpt, category, readTime, publishedAt,
        "imageUrl": coverImage.asset->url,
        "slug": slug.current,
        body
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityArticle.fromJson(e)).toList();
  }

  static Future<SanityArticle?> fetchArticleBySlug(String slug) async {
    final groq = '''
      *[_type == "article" && slug.current == "$slug"][0] {
        _id, title, excerpt, category, readTime, publishedAt,
        "imageUrl": coverImage.asset->url,
        "slug": slug.current,
        body
      }
    ''';
    final results = await _fetch(groq);
    if (results.isEmpty) return null;
    return SanityArticle.fromJson(results.first);
  }

  // ─── News / Social feed ───────────────────────────────────────────────────

  static Future<List<SanityNewsItem>> fetchNews({int limit = 20}) async {
    final groq = '''
      *[_type == "newsItem"] | order(publishedAt desc) [0...$limit] {
        _id, title, excerpt, tag, publishedAt,
        "imageUrl": coverImage.asset->url,
        "slug": slug.current,
        body
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityNewsItem.fromJson(e)).toList();
  }

  // ─── Glossary ─────────────────────────────────────────────────────────────

  static Future<List<SanityGlossaryTerm>> fetchGlossary() async {
    const groq = '''
      *[_type == "glossaryTerm"] | order(term asc) {
        _id, term, definition
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityGlossaryTerm.fromJson(e)).toList();
  }

  // ─── FAQs ─────────────────────────────────────────────────────────────────

  static Future<List<SanityFaq>> fetchFaqs() async {
    const groq = '''
      *[_type == "faq"] | order(order asc) {
        _id, question, answer, category
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityFaq.fromJson(e)).toList();
  }

  // ─── Daily Tips ───────────────────────────────────────────────────────────

  static Future<List<SanityTip>> fetchDailyTips() async {
    const groq = '''
      *[_type == "dailyTip"] | order(order asc) {
        _id, tip, icon
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityTip.fromJson(e)).toList();
  }

  // ─── Checklist ────────────────────────────────────────────────────────────

  static Future<List<SanityChecklistItem>> fetchChecklist() async {
    const groq = '''
      *[_type == "checklistItem"] | order(order asc) {
        _id, title, description, category
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityChecklistItem.fromJson(e)).toList();
  }

  // ─── Topics (community categories) ───────────────────────────────────────

  static Future<List<SanityTopic>> fetchTopics() async {
    const groq = '''
      *[_type == "communityTopic"] | order(order asc) {
        _id, title, description, icon
      }
    ''';
    final results = await _fetch(groq);
    return results.map((e) => SanityTopic.fromJson(e)).toList();
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class SanityArticle {
  final String id;
  final String title;
  final String excerpt;
  final String category;
  final String readTime;
  final String? publishedAt;
  final String? imageUrl;
  final String slug;
  final dynamic body; // Portable Text blocks

  const SanityArticle({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.readTime,
    this.publishedAt,
    this.imageUrl,
    required this.slug,
    this.body,
  });

  factory SanityArticle.fromJson(Map<String, dynamic> j) => SanityArticle(
        id: j['_id'] ?? '',
        title: j['title'] ?? '',
        excerpt: j['excerpt'] ?? '',
        category: j['category'] ?? '',
        readTime: j['readTime'] ?? '5 MIN READ',
        publishedAt: j['publishedAt'],
        imageUrl: j['imageUrl'],
        slug: j['slug'] ?? '',
        body: j['body'],
      );
}

class SanityNewsItem {
  final String id;
  final String title;
  final String excerpt;
  final String tag;
  final String? publishedAt;
  final String? imageUrl;
  final String slug;
  final dynamic body;

  const SanityNewsItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.tag,
    this.publishedAt,
    this.imageUrl,
    required this.slug,
    this.body,
  });

  factory SanityNewsItem.fromJson(Map<String, dynamic> j) => SanityNewsItem(
        id: j['_id'] ?? '',
        title: j['title'] ?? '',
        excerpt: j['excerpt'] ?? '',
        tag: j['tag'] ?? 'NEWS',
        publishedAt: j['publishedAt'],
        imageUrl: j['imageUrl'],
        slug: j['slug'] ?? '',
        body: j['body'],
      );
}

class SanityGlossaryTerm {
  final String id;
  final String term;
  final String definition;

  const SanityGlossaryTerm({required this.id, required this.term, required this.definition});

  factory SanityGlossaryTerm.fromJson(Map<String, dynamic> j) => SanityGlossaryTerm(
        id: j['_id'] ?? '',
        term: j['term'] ?? '',
        definition: j['definition'] ?? '',
      );
}

class SanityFaq {
  final String id;
  final String question;
  final String answer;
  final String? category;

  const SanityFaq({required this.id, required this.question, required this.answer, this.category});

  factory SanityFaq.fromJson(Map<String, dynamic> j) => SanityFaq(
        id: j['_id'] ?? '',
        question: j['question'] ?? '',
        answer: j['answer'] ?? '',
        category: j['category'],
      );
}

class SanityTip {
  final String id;
  final String tip;
  final String? icon;

  const SanityTip({required this.id, required this.tip, this.icon});

  factory SanityTip.fromJson(Map<String, dynamic> j) =>
      SanityTip(id: j['_id'] ?? '', tip: j['tip'] ?? '', icon: j['icon']);
}

class SanityChecklistItem {
  final String id;
  final String title;
  final String? description;
  final String? category;

  const SanityChecklistItem({required this.id, required this.title, this.description, this.category});

  factory SanityChecklistItem.fromJson(Map<String, dynamic> j) => SanityChecklistItem(
        id: j['_id'] ?? '',
        title: j['title'] ?? '',
        description: j['description'],
        category: j['category'],
      );
}

class SanityTopic {
  final String id;
  final String title;
  final String description;
  final String? icon;

  const SanityTopic({required this.id, required this.title, required this.description, this.icon});

  factory SanityTopic.fromJson(Map<String, dynamic> j) => SanityTopic(
        id: j['_id'] ?? '',
        title: j['title'] ?? '',
        description: j['description'] ?? '',
        icon: j['icon'],
      );
}
