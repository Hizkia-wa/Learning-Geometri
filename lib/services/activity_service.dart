import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ActivityItem {
  final String title;
  final String subtitle;
  final String type;
  final DateTime createdAt;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      title: json['title'],
      subtitle: json['subtitle'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ActivityService {
  static const String _storageKey = 'learning_activity';

  static Future<void> addActivity({
    required String title,
    required String subtitle,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final activities = await getActivities();

    activities.insert(
      0,
      ActivityItem(
        title: title,
        subtitle: subtitle,
        type: type,
        createdAt: DateTime.now(),
      ),
    );

    if (activities.length > 20) {
      activities.removeRange(20, activities.length);
    }

    final encoded = activities
        .map((activity) => jsonEncode(activity.toJson()))
        .toList();

    await prefs.setStringList(_storageKey, encoded);
  }

  static Future<List<ActivityItem>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getStringList(_storageKey);

    if (stored == null || stored.isEmpty) {
      return [];
    }

    return stored
        .map(
          (item) => ActivityItem.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  static Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}