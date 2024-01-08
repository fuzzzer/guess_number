import 'dart:io';
import 'dart:typed_data';

import '../../../core/typedefs.dart';
import '../models/minst_dataset.dart';

class ImagesDatasource {
  static Future<MinstDataset> getMinstDataset({required String pathToDatasetsFolder}) async {
    final imagePath = '$pathToDatasetsFolder/t10k-images-idx3-ubyte';
    final labelPath = '$pathToDatasetsFolder/t10k-labels-idx1-ubyte';

    // Read image file
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    final imageBuffer = ByteData.sublistView(imageBytes);

    // Read label file
    final labelFile = File(labelPath);
    final labelBytes = await labelFile.readAsBytes();
    final labelBuffer = ByteData.sublistView(labelBytes);

    // Parse headers
    final magicNumberImages = imageBuffer.getUint32(0);
    final numberOfImages = imageBuffer.getUint32(4);
    final numberOfRows = imageBuffer.getUint32(8);
    final numberOfColumns = imageBuffer.getUint32(12);

    final magicNumberLabels = labelBuffer.getUint32(0);
    final numberOfItems = labelBuffer.getUint32(4);

    // Check if files are valid
    assert(magicNumberImages == 2051);
    assert(magicNumberLabels == 2049);
    assert(numberOfImages == numberOfItems);

    List<FlatImage> allImages = [];
    List<int> allLabels = [];

    for (int i = 0; i < numberOfImages; i++) {
      List<int> image = [];
      for (int j = 0; j < numberOfRows * numberOfColumns; j++) {
        image.add(imageBuffer.getUint8(16 + i * numberOfRows * numberOfColumns + j));
      }
      allImages.add(image);

      int label = labelBuffer.getUint8(8 + i);
      allLabels.add(label);
    }

    return MinstDataset(
      images: allImages,
      labels: allLabels,
    );
  }
}
