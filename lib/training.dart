import 'package:guess_number/brain/base_models/base_models.dart';
import 'package:guess_number/providers/network_model_providers/repository/network_model_repository.dart';
import 'package:guess_number/services/functions/functions.dart';

import 'brain/logic/back_propagation/back_propagation.dart';
import 'brain/logic/back_propagation/models/back_propagated_layer.dart';
import 'brain/logic/back_propagation/models/back_propagated_network.dart';
import 'brain/logic/forward_propagation/forward_propagation.dart';
import 'providers/dataset_providers/models/normalized_minst_dataset.dart';
import 'providers/dataset_providers/repository/images_repository.dart';
import 'services/matrices/mx.dart';

void main() async {
  await train();
}

Future<void> train() async {
  final normalizedMinstDataset = await ImagesRepository.getNormalizedMinstDataset();

  assert(normalizedMinstDataset.images.isNotEmpty &&
      normalizedMinstDataset.images.length == normalizedMinstDataset.labels.length);

  final normalizedMinstDatasetBatches = prepareDatasetBatches(
    fullDataset: normalizedMinstDataset,
    batchSize: 100,
  );

  NeuralNetwork neuralNetwork = await NetworkModelRepository.load();

  final stopwatch = Stopwatch()..start();

  const trainingIterations = 100;

  for (int k = 0; k < trainingIterations; k++) {
    for (int i = 0; i < normalizedMinstDatasetBatches.length; i++) {
      neuralNetwork = generateUpdatedNeuralNetworkFromBatch(
        currentNeuralNetwork: neuralNetwork,
        normalizedMinstDataset: normalizedMinstDatasetBatches[i],
      );
    }
  }

  await NetworkModelRepository.save(neuralNetwork: neuralNetwork);

  print('elapsed: ${stopwatch.elapsed}');
}

NeuralNetwork generateUpdatedNeuralNetworkFromBatch({
  required NeuralNetwork currentNeuralNetwork,
  required NormalizedMinstDataset normalizedMinstDataset,
}) {
  assert(normalizedMinstDataset.images.isNotEmpty);

  BackPropagatedNetwork? averageBackPropagatedNetwork;

  double avarageCost = 0;

  for (int i = 0; i < normalizedMinstDataset.images.length; i++) {
    final currentNormalizedImage = normalizedMinstDataset.images[i];
    final currentLabel = normalizedMinstDataset.labels[i];

    final forwardPropagationResult = forwardPropagation(
      currentNormalizedImage: currentNormalizedImage,
      neuralNetwork: currentNeuralNetwork,
      currentLabel: currentLabel,
    );

    final currentCost = MX.totalSum(forwardPropagationResult.costMatrix);

    avarageCost = takeAverage(
      currentAverage: avarageCost,
      newMember: currentCost,
      n: (i + 1),
    );

    final currentBackPropagationResult = backPropagation(
      forwardPropagationResult: forwardPropagationResult,
    );

    if (averageBackPropagatedNetwork == null) {
      averageBackPropagatedNetwork = currentBackPropagationResult.backPropagatedNetwork;
    } else {
      averageBackPropagatedNetwork = calculateNewAverageBackPropagationNetwork(
        oldAverage: averageBackPropagatedNetwork,
        newMemeber: currentBackPropagationResult.backPropagatedNetwork,
        n: i + 1,
      );
    }
  }

  print('batch average cost: $avarageCost');

  final updatedNeuralNetwork = updateNeuralNetworkBasedOnBackPropagation(
    currentNeuralNetwork: currentNeuralNetwork,
    backPropagatedNetwork: averageBackPropagatedNetwork!,
  );

  return updatedNeuralNetwork;
}

NeuralNetwork updateNeuralNetworkBasedOnBackPropagation({
  required NeuralNetwork currentNeuralNetwork,
  required BackPropagatedNetwork backPropagatedNetwork,
}) {
  final List<Layer> adjustedLayers = [];

  for (int i = 0; i < currentNeuralNetwork.layers.length; i++) {
    final currentLayer = currentNeuralNetwork.layers[i];
    final currentBackpropagatedLayer = backPropagatedNetwork.layers[i];

    final layerAdjustedWeights = MX.elementWiseCombineAndTransform(
      currentLayer.weights,
      currentBackpropagatedLayer.weigthAdjustments,
      (weight, adjustment) => applyAdjustment(
        currentValue: weight,
        adjustment: adjustment,
      ),
    );

    final layerAdjustedBiases = MX.elementWiseCombineAndTransform(
      currentLayer.biases,
      currentBackpropagatedLayer.biasAdjustments,
      (bias, adjustment) => applyAdjustment(
        currentValue: bias,
        adjustment: adjustment,
      ),
    );

    adjustedLayers.add(
      Layer(
        weights: layerAdjustedWeights,
        biases: layerAdjustedBiases,
      ),
    );
  }

  return NeuralNetwork(
    layers: adjustedLayers,
  );
}

//this will just average weight and bias adjustments
BackPropagatedNetwork calculateNewAverageBackPropagationNetwork({
  required BackPropagatedNetwork oldAverage,
  required BackPropagatedNetwork newMemeber,
  required int n,
}) {
  final List<BackPropagatedLayer> newAverageBackPropagatedLayers = [];

  for (int i = 0; i < oldAverage.layers.length; i++) {
    final currentAverageLayer = oldAverage.layers[i];
    final currentNewMemberLayer = newMemeber.layers[i];

    final currentLayerNewAverageWeightAdjustments = MX.elementWiseCombineAndTransform(
      currentAverageLayer.weigthAdjustments,
      currentNewMemberLayer.weigthAdjustments,
      (averageWeigthAdjustment, newWeightAdjustment) => takeAverage(
        currentAverage: averageWeigthAdjustment,
        newMember: newWeightAdjustment,
        n: n,
      ),
    );

    final currentLayerNewAverageBiasAdjustments = MX.elementWiseCombineAndTransform(
      currentAverageLayer.biasAdjustments,
      currentNewMemberLayer.biasAdjustments,
      (averageBiasAdjustment, newBiasAdjustment) => takeAverage(
        currentAverage: averageBiasAdjustment,
        newMember: newBiasAdjustment,
        n: n,
      ),
    );

    newAverageBackPropagatedLayers.add(
      BackPropagatedLayer(
        weigthAdjustments: currentLayerNewAverageWeightAdjustments,
        biasAdjustments: currentLayerNewAverageBiasAdjustments,
      ),
    );
  }

  return BackPropagatedNetwork(
    layers: newAverageBackPropagatedLayers,
  );
}

double takeAverage({
  required double currentAverage,
  required double newMember,
  required int n,
}) {
  return currentAverage + (newMember - currentAverage) / n;
}

List<NormalizedMinstDataset> prepareDatasetBatches({
  required NormalizedMinstDataset fullDataset,
  required int batchSize,
}) {
  final List<NormalizedMinstDataset> datasetBatches = [];
  final numberOfBatches = (fullDataset.images.length / batchSize).ceil();

  for (int i = 0; i < numberOfBatches; i++) {
    final start = i * batchSize;
    final end = (i + 1) * batchSize > fullDataset.images.length ? fullDataset.images.length : (i + 1) * batchSize;

    final batchImages = fullDataset.images.sublist(
      start,
      end,
    );

    final batchLabels = fullDataset.labels.sublist(
      start,
      end,
    );

    datasetBatches.add(
      NormalizedMinstDataset(
        images: batchImages,
        labels: batchLabels,
      ),
    );
  }

  return datasetBatches;
}
