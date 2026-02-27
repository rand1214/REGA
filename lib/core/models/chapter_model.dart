import 'package:flutter/material.dart';

class ChapterModel {
  final int id;
  final int chapterNumber;
  final String titleKurdish;
  final String? titleEnglish;
  final String? description;
  final String colorHex;
  final bool isFree;
  final int orderIndex;
  final String? iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChapterModel({
    required this.id,
    required this.chapterNumber,
    required this.titleKurdish,
    this.titleEnglish,
    this.description,
    required this.colorHex,
    required this.isFree,
    required this.orderIndex,
    this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert hex color string to Color object
  Color get color {
    final hexColor = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  // Factory constructor to create from JSON
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as int,
      chapterNumber: json['chapter_number'] as int,
      titleKurdish: json['title_kurdish'] as String,
      titleEnglish: json['title_english'] as String?,
      description: json['description'] as String?,
      colorHex: json['color_hex'] as String,
      isFree: json['is_free'] as bool,
      orderIndex: json['order_index'] as int,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'title_kurdish': titleKurdish,
      'title_english': titleEnglish,
      'description': description,
      'color_hex': colorHex,
      'is_free': isFree,
      'order_index': orderIndex,
      'icon_url': iconUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Copy with method for updating fields
  ChapterModel copyWith({
    int? id,
    int? chapterNumber,
    String? titleKurdish,
    String? titleEnglish,
    String? description,
    String? colorHex,
    bool? isFree,
    int? orderIndex,
    String? iconUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      titleKurdish: titleKurdish ?? this.titleKurdish,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      isFree: isFree ?? this.isFree,
      orderIndex: orderIndex ?? this.orderIndex,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChapterModel(id: $id, chapterNumber: $chapterNumber, titleKurdish: $titleKurdish, isFree: $isFree)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChapterModel &&
        other.id == id &&
        other.chapterNumber == chapterNumber &&
        other.titleKurdish == titleKurdish &&
        other.colorHex == colorHex;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        chapterNumber.hashCode ^
        titleKurdish.hashCode ^
        colorHex.hashCode;
  }
}
