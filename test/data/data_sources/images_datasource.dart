import 'dart:io';
import 'package:guess_number/providers/dataset_providers/data_sources/images_datasource.dart';

import 'package:guess_number/testing.dart';

void printImage(List<int> image) {
  for (int i = 0; i < 28; i++) {
    for (int j = 0; j < 28; j++) {
      stdout.write(image[i * 28 + j] > 10 ? '*' : ' ');
    }
    stdout.writeln();
  }
}

void main() async {
  final minstData = await ImagesDatasource.getMinstDataset(
    pathToDatasetsFolder: '/Users/fuzzzer/programming/projects/tries/guess_number/materials/testing',
  );

  final guessFailures = await test();

  for (int i = 0; i < guessFailures.length; i++) {
    final currentFailure = guessFailures[i];

    print('--------------------------------------');
    print('predicted: ${currentFailure.guess}, was: ${minstData.labels[currentFailure.imageIndex]}');
    printImage(minstData.images[currentFailure.imageIndex]);
    print('--------------------------------------');
  }

  print('total fails: ${guessFailures.length}. ${guessFailures.length / minstData.images.length * 100}%');
}
