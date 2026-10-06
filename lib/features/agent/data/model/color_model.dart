import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ColorModel extends Equatable {
  final int code;
  final String name;
  final String? enName;

  const ColorModel({
    required this.code,
    required this.name,
    this.enName,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) {
    int getCode() {
      final val = json['COLOR_CODE'] ??
          json['COLORCODE'] ??
          json['color_code'] ??
          json['colorCode'] ??
          json['CODE'] ??
          json['Code'] ??
          json['code'] ??
          json['ID'] ??
          json['Id'] ??
          json['id'];
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    String getName() {
      final val = json['COLOR_NAME'] ??
          json['COLORNAME'] ??
          json['color_name'] ??
          json['colorName'] ??
          json['NAME'] ??
          json['Name'] ??
          json['name'] ??
          json['DESCA'] ??
          json['DESC'] ??
          json['desc'];
      return val?.toString().trim() ?? '';
    }

    String? getEnName() {
      final val = json['COLOR_ENAME'] ??
          json['COLORENAME'] ??
          json['color_ename'] ??
          json['colorEName'] ??
          json['ENAME'] ??
          json['EName'] ??
          json['ename'] ??
          json['DESCE'];
      return val?.toString().trim();
    }

    return ColorModel(
      code: getCode(),
      name: getName(),
      enName: getEnName(),
    );
  }

  static List<ColorModel> listFromResponse(dynamic data) {
    if (data == null) return [];

    dynamic parsedData = data;
    if (parsedData is String) {
      try {
        final decoded = jsonDecode(parsedData);
        parsedData = decoded;
      } catch (_) {
        return [];
      }
    }

    if (parsedData is Map<String, dynamic> && parsedData.containsKey('Data')) {
      parsedData = parsedData['Data'];
    }

    if (parsedData is! List) return [];

    return parsedData
        .whereType<Map<String, dynamic>>()
        .map((item) => ColorModel.fromJson(item))
        .where((item) => item.code != 0 || item.name.isNotEmpty)
        .toList();
  }

  Color get displayColor {
    final lower = name.trim().toLowerCase();
    if (lower.contains('أبيض') ||
        lower.contains('ابيض') ||
        lower.contains('white') ||
        lower.contains('لؤلؤي') ||
        lower.contains('صدفي')) {
      return Colors.white;
    } else if (lower.contains('أسود') ||
        lower.contains('اسود') ||
        lower.contains('black') ||
        lower.contains('ليلي') ||
        lower.contains('فحم')) {
      return const Color(0xFF1A1A1A);
    } else if (lower.contains('فضي') || lower.contains('silver')) {
      return const Color(0xFFC0C0C0);
    } else if (lower.contains('رمادي') ||
        lower.contains('رصاصي') ||
        lower.contains('grey') ||
        lower.contains('gray') ||
        lower.contains('اسمنتي') ||
        lower.contains('معدني')) {
      return Colors.grey.shade600;
    } else if (lower.contains('أحمر') ||
        lower.contains('احمر') ||
        lower.contains('red') ||
        lower.contains('عنابي') ||
        lower.contains('خمري') ||
        lower.contains('كرزي') ||
        lower.contains('دم الغزال')) {
      return const Color(0xFFC62828);
    } else if (lower.contains('أزرق') ||
        lower.contains('ازرق') ||
        lower.contains('blue') ||
        lower.contains('كحلي') ||
        lower.contains('سماوي') ||
        lower.contains('نيلي') ||
        lower.contains('بحري')) {
      return const Color(0xFF1565C0);
    } else if (lower.contains('بيج') ||
        lower.contains('beige') ||
        lower.contains('رملي') ||
        lower.contains('صحراوي') ||
        lower.contains('عاجي')) {
      return const Color(0xFFE0D7C6);
    } else if (lower.contains('بني') ||
        lower.contains('brown') ||
        lower.contains('برونزي') ||
        lower.contains('موخا') ||
        lower.contains('شوكولا') ||
        lower.contains('هافان')) {
      return const Color(0xFF6D4C41);
    } else if (lower.contains('أخضر') ||
        lower.contains('اخضر') ||
        lower.contains('green') ||
        lower.contains('زيتي') ||
        lower.contains('عسكري')) {
      return const Color(0xFF2E7D32);
    } else if (lower.contains('ذهبي') ||
        lower.contains('gold') ||
        lower.contains('أصفر') ||
        lower.contains('اصفر') ||
        lower.contains('شامبين')) {
      return const Color(0xFFFFD54F);
    } else if (lower.contains('برتقالي') || lower.contains('orange') || lower.contains('نحاسي')) {
      return const Color(0xFFE65100);
    }
    return Colors.blueGrey;
  }

  @override
  List<Object?> get props => [code, name, enName];
}
