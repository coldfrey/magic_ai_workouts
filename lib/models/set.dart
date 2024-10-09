import 'package:json_annotation/json_annotation.dart';

part 'set.g.dart';

@JsonSerializable()
class Set {
  final double weight;
  final int repetitions;

  Set({
    required this.weight,
    required this.repetitions,
  });

  factory Set.fromJson(Map<String, dynamic> json) => _$SetFromJson(json);

  Map<String, dynamic> toJson() => _$SetToJson(this);

  Set copyWith({
    double? weight,
    int? repetitions,
  }) {
    return Set(
      weight: weight ?? this.weight,
      repetitions: repetitions ?? this.repetitions,
    );
  }
}
