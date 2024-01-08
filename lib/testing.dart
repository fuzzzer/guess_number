// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:guess_number/brain/base_models/base_models.dart';
import 'package:guess_number/providers/dataset_providers/models/models.dart';
import 'package:guess_number/providers/network_model_providers/repository/network_model_repository.dart';

import 'brain/logic/forward_propagation/forward_propagation.dart';
import 'providers/dataset_providers/repository/images_repository.dart';
import 'services/services.dart';

void main() async {
  await test();
}

//returns indexes of failed tests
Future<List<GuessFailure>> test() async {
  final normalizedMinstDataset = await ImagesRepository.getNormalizedMinstDataset(
    datasetType: DatasetType.testing,
  );

  assert(normalizedMinstDataset.images.isNotEmpty &&
      normalizedMinstDataset.images.length == normalizedMinstDataset.labels.length);

  NeuralNetwork neuralNetwork = await NetworkModelRepository.load();

  final stopwatch = Stopwatch()..start();

  List<GuessFailure> guessFailures = [];

  for (int i = 0; i < normalizedMinstDataset.images.length; i++) {
    final currentNormalizedImage = normalizedMinstDataset.images[i];
    final currentLabel = normalizedMinstDataset.labels[i];

    final forwardPropagationResult = forwardPropagation(
      currentNormalizedImage: currentNormalizedImage,
      neuralNetwork: neuralNetwork,
      currentLabel: currentLabel,
    );

    final currentGuess =
        findMaximumInMatrixColumn(forwardPropagationResult.forwardPropagatedNetwork.layers.last.activations);

    if (currentGuess != currentLabel) {
      guessFailures.add(GuessFailure(imageIndex: i, guess: currentGuess));
    }
  }

  final totalImagesCount = normalizedMinstDataset.images.length;

  print(
    'guessed total ${totalImagesCount - guessFailures.length} out of $totalImagesCount which is ${(totalImagesCount - guessFailures.length) / totalImagesCount * 100}% accurate',
  );

  print('elapsed: ${stopwatch.elapsed}');

  return guessFailures;
}

int findMaximumInMatrixColumn(Matrix column) {
  assert(column.isNotEmpty);

  double maxValue = 0;
  int maxValueIndex = -1;

  for (int i = 0; i < column.length; i++) {
    final currentElement = column[i][0];

    if (currentElement > maxValue) {
      maxValue = currentElement;
      maxValueIndex = i;
    }
  }

  return maxValueIndex;
}

class GuessFailure {
  final int imageIndex;
  final int guess;
  GuessFailure({
    required this.imageIndex,
    required this.guess,
  });
}
