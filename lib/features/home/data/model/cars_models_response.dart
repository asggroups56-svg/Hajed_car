import 'dart:convert';

import 'package:equatable/equatable.dart';

class CarsModelsResponse extends Equatable {
  final List<CarModel> cars;

  const CarsModelsResponse({required this.cars});

  factory CarsModelsResponse.fromJson(Map<String, dynamic> json) {
    dynamic rawData = json['Data'];
    // Some API gateways serialize the response more than once.
    while (rawData is String && rawData.isNotEmpty) {
      rawData = jsonDecode(rawData);
    }

    // The service currently spells the key "Parernt". Accept both that
    // response and the corrected spelling, as well as a direct list.
    dynamic rawParents = rawData;
    if (rawData is Map) {
      for (final entry in rawData.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key == 'parernt' || key == 'parent') {
          rawParents = entry.value;
          break;
        }
      }
    }
    final parents = rawParents is List ? rawParents : const [];

    return CarsModelsResponse(
      cars: parents
          .whereType<Map>()
          .map((item) => CarModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [cars];
}

class CarModel extends Equatable {
  final int groupCode;
  final String groupName;
  final String? groupEName;
  final int groupParent;
  final int groupLevel;
  final String picturePath;
  final List<CarModel> children;

  const CarModel({
    required this.groupCode,
    required this.groupName,
    this.groupEName,
    required this.groupParent,
    required this.groupLevel,
    required this.picturePath,
    this.children = const [],
  });

  static int _toInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  factory CarModel.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'] ?? json['CHILDREN'];
    return CarModel(
      groupCode: _toInt(json['GROUP_CODE'] ?? json['group_code']),
      groupName: (json['GROUP_NAME'] ?? json['group_name'] ?? '').toString(),
      groupEName: (json['GROUP_ENAME'] ?? json['group_ename'])?.toString(),
      groupParent: _toInt(
        json['GROUP_PARENT'] ??
            json['Child_GROUP_PARENT'] ??
            json['child_group_parent'],
      ),
      groupLevel: _toInt(json['GROUP_LEVEL'] ?? json['group_level']),
      picturePath: (json['PICTUREPATH'] ?? json['picturepath'] ?? '').toString(),
      children: rawChildren is List
          ? rawChildren
                .whereType<Map>()
                .map((item) => CarModel.fromJson(Map<String, dynamic>.from(item)))
                .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
    groupCode,
    groupName,
    groupEName,
    groupParent,
    groupLevel,
    picturePath,
    children,
  ];
}
