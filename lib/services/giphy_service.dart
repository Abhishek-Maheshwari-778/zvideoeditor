import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GiphyItem {
  final String id;
  final String title;
  final String previewUrl;
  final String originalUrl;
  final int width;
  final int height;
  final bool isSticker;

  const GiphyItem({
    required this.id,
    required this.title,
    required this.previewUrl,
    required this.originalUrl,
    required this.width,
    required this.height,
    this.isSticker = false,
  });

  factory GiphyItem.fromJson(Map<String, dynamic> json, {bool isSticker = false}) {
    final images = json['images'] as Map<String, dynamic>? ?? {};
    final preview = images['fixed_height_small'] as Map<String, dynamic>? ?? {};
    final original = images['original'] as Map<String, dynamic>? ?? {};

    return GiphyItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'GIF',
      previewUrl: preview['url'] as String? ?? original['url'] as String? ?? '',
      originalUrl: original['url'] as String? ?? '',
      width: int.tryParse(original['width']?.toString() ?? '300') ?? 300,
      height: int.tryParse(original['height']?.toString() ?? '300') ?? 300,
      isSticker: isSticker,
    );
  }
}

class GiphyService {
  // Public public beta / demo key for open client apps
  static const String _defaultApiKey = 'sXpGFDGZs0Dv1mmNFvYaGU42wKX0Pqvd';

  /// Searches GIPHY for animated GIFs or transparent Stickers
  static Future<List<GiphyItem>> search({
    required String query,
    bool stickersOnly = false,
    int limit = 24,
    int offset = 0,
  }) async {
    final endpoint = stickersOnly ? 'stickers/search' : 'gifs/search';
    final url = Uri.parse(
      'https://api.giphy.com/v1/$endpoint?api_key=$_defaultApiKey&q=${Uri.encodeComponent(query)}&limit=$limit&offset=$offset&rating=g',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((item) => GiphyItem.fromJson(item as Map<String, dynamic>, isSticker: stickersOnly)).toList();
      }
    } catch (e) {
      debugPrint('[GiphyService] Error fetching: $e');
    }

    return [];
  }

  /// Gets trending GIFs or Stickers
  static Future<List<GiphyItem>> getTrending({
    bool stickersOnly = false,
    int limit = 24,
  }) async {
    final endpoint = stickersOnly ? 'stickers/trending' : 'gifs/trending';
    final url = Uri.parse(
      'https://api.giphy.com/v1/$endpoint?api_key=$_defaultApiKey&limit=$limit&rating=g',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>? ?? [];
        return list.map((item) => GiphyItem.fromJson(item as Map<String, dynamic>, isSticker: stickersOnly)).toList();
      }
    } catch (e) {
      debugPrint('[GiphyService] Error fetching trending: $e');
    }

    return [];
  }
}
