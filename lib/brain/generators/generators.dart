import 'dart:math';

import 'package:guess_number/services/services.dart';

import '../../providers/dataset_providers/repository/images_repository.dart';
import '../../providers/network_model_providers/repository/network_model_repository.dart';
import '../base_models/base_models.dart';

final rgen = Random();

//The uniform distribution has the following properties: The mean of the distribution is μ = (a + b) / 2. The variance of the distribution is σ2 = (b – a)2 / 12, normi
///in this case: a=-100 b=100 so sigma over uniform interval (-100, 100) is 57

const _a = -100;
const _b = 100;
const _sigma = 57.0;

double generateWeigth() {
  return (rgen.nextInt(_b - _a) + _a) / _sigma;
}

const _biasMin = -1;
const _biasMax = 1;

double generateBias() {
  return _biasMin + (rgen.nextDouble()) * (_biasMax - _biasMin);
}

//Neuron is just one row in layer matrix
List<double> generateNeuron({
  required int inputLength,
}) {
  final weights = List<double>.generate(
    inputLength,
    (index) => generateWeigth(),
    growable: false,
  );

  return weights;
}

Matrix generateLayerWeightsMatrix({
  required int inputLength,
  required int outputLength,
}) {
  return Matrix.generate(
    outputLength,
    (index) => generateNeuron(inputLength: inputLength),
  );
}

Matrix generateLayerBiasesColumn({
  required int layerOutputLength,
}) {
  return Matrix.generate(
    layerOutputLength,
    //column is just list of one element lists
    (index) => [generateBias()],
  );
}

NeuralNetwork generatNeuralNetwork({
  required int firstInputLayerLength,
  required List<int> neuronCountsInLayers,
}) {
  assert(neuronCountsInLayers.isNotEmpty);

  final firstLayerNeuronsCount = neuronCountsInLayers[0];

  final firstLayer = Layer(
    weights: generateLayerWeightsMatrix(
      inputLength: firstInputLayerLength,
      outputLength: firstLayerNeuronsCount,
    ),
    biases: generateLayerBiasesColumn(layerOutputLength: firstLayerNeuronsCount),
  );

  final List<Layer> layers = [firstLayer];

  //starting from second element
  for (int i = 1; i < neuronCountsInLayers.length; i++) {
    final previousLayerNeuronsCount = neuronCountsInLayers[i - 1];
    final currentLayerNeuronsCount = neuronCountsInLayers[i];

    layers.add(
      Layer(
        weights: generateLayerWeightsMatrix(
          inputLength: previousLayerNeuronsCount,
          outputLength: currentLayerNeuronsCount,
        ),
        biases: generateLayerBiasesColumn(layerOutputLength: currentLayerNeuronsCount),
      ),
    );
  }

  return NeuralNetwork(layers: layers);
}

//run only once for initial model generation, so model_v1 will be just randomly generated model
void main() async {
  final normalizedMinstDataset = await ImagesRepository.getNormalizedMinstDataset();

  assert(normalizedMinstDataset.images.isNotEmpty &&
      normalizedMinstDataset.images.length == normalizedMinstDataset.labels.length);

  final firstInputLayerLength = normalizedMinstDataset.images[0].length;

  final neuralNetwork = generatNeuralNetwork(
    firstInputLayerLength: firstInputLayerLength,
    //This will be network model, final layer count being the end result
    neuronCountsInLayers: [13, 13, 10],
  );

  final saveingStopwatch = Stopwatch()..start();

  await NetworkModelRepository.save(neuralNetwork: neuralNetwork);

  print('Time needed to save: ${saveingStopwatch.elapsed}');

  final loadingStopwatch = Stopwatch()..start();

  await NetworkModelRepository.load();

  print('Time needed to load: ${loadingStopwatch.elapsed}');
}
