import '../../../core/typedefs.dart';

class MinstDataset {
  final List<FlatImage> images;
  final List<int> labels;

  MinstDataset({
    required this.images,
    required this.labels,
  });
}
