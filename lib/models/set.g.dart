// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Set _$SetFromJson(Map<String, dynamic> json) => Set(
      weight: (json['weight'] as num).toDouble(),
      repetitions: (json['repetitions'] as num).toInt(),
    );

Map<String, dynamic> _$SetToJson(Set instance) => <String, dynamic>{
      'weight': instance.weight,
      'repetitions': instance.repetitions,
    };
