import 'dart:convert';

class ModelMetadata {
  final int modelVersion;
  ModelMetadata({
    required this.modelVersion,
  });

  ModelMetadata copyWith({
    int? modelVersion,
  }) {
    return ModelMetadata(
      modelVersion: modelVersion ?? this.modelVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'modelVersion': modelVersion,
    };
  }

  factory ModelMetadata.fromMap(Map<String, dynamic> map) {
    return ModelMetadata(
      modelVersion: map['modelVersion'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ModelMetadata.fromJson(String source) => ModelMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'ModelMetadata(modelVersion: $modelVersion)';

  @override
  bool operator ==(covariant ModelMetadata other) {
    if (identical(this, other)) return true;

    return other.modelVersion == modelVersion;
  }

  @override
  int get hashCode => modelVersion.hashCode;
}
