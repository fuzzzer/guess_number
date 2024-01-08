import '../../../core/typedefs.dart';

class NormalizedMinstDataset {
  final List<FlatNormalizedImage> images;
  final List<int> labels;

  NormalizedMinstDataset({
    required this.images,
    required this.labels,
  });
}
