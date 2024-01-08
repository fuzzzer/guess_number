import '../data_sources/images_datasource.dart';
import '../models/models.dart';

class ImagesRepository {
  ///normalized minst dataset are greyscale values from 0 to 1 of the 28x28 pixel labeled handwritten numbers
  static Future<NormalizedMinstDataset> getNormalizedMinstDataset({
    DatasetType datasetType = DatasetType.training,
  }) async {
    final minstDataset = await ImagesDatasource.getMinstDataset(
      pathToDatasetsFolder: switch (datasetType) {
        DatasetType.training => '/Users/fuzzzer/programming/projects/tries/guess_number/materials/training',
        DatasetType.testing => '/Users/fuzzzer/programming/projects/tries/guess_number/materials/testing',
      },
    );

    return normalizeMinstDataset(minstDataset);
  }

  static NormalizedMinstDataset normalizeMinstDataset(MinstDataset dataset) {
    return NormalizedMinstDataset(
      images: dataset.images
          .map(
            (outer) => outer.map((inner) => inner / 255).toList(),
          )
          .toList(),
      labels: dataset.labels,
    );
  }
}
