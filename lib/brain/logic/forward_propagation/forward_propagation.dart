import 'package:guess_number/services/services.dart';

import '../functions/functions.dart';
import '../../base_models/neural_network.dart';
import 'models/models.dart';

export 'models/models.dart';

//ZValues are same as weighted and biased sums

ForwardPropagationResult forwardPropagation({
  required List<double> currentNormalizedImage,
  required NeuralNetwork neuralNetwork,
  required int currentLabel,
}) {
  final initialActivations = MX.listToColumn(currentNormalizedImage);

  final firstLayer = (neuralNetwork.layers[0]);
  final firstWeightedSum = MX.multiply(firstLayer.weights, initialActivations);
  final firstZValues = MX.add(firstWeightedSum, firstLayer.biases);
  final firstActivations = MX.transformMatrix(firstZValues, (element) => activate(element));

  final List<ForwardPropagatedLayer> forwardPropagatedLayers = [
    ForwardPropagatedLayer(
      weights: firstLayer.weights,
      biases: firstLayer.biases,
      zValues: firstZValues,
      activations: firstActivations,
    ),
  ];

  for (int i = 1; i < neuralNetwork.layers.length; i++) {
    final currentLayer = (neuralNetwork.layers[i]);
    final currentWeightedSum = MX.multiply(currentLayer.weights, forwardPropagatedLayers.last.activations);
    final currentZValues = MX.add(currentWeightedSum, currentLayer.biases);
    final currentActivations = MX.transformMatrix(currentZValues, (element) => activate(element));

    forwardPropagatedLayers.add(
      ForwardPropagatedLayer(
        weights: currentLayer.weights,
        biases: currentLayer.biases,
        zValues: currentZValues,
        activations: currentActivations,
      ),
    );
  }

  final predictedResults = forwardPropagatedLayers.last.activations;
  final actualResults = MX.listToColumn(
    List.generate(
      predictedResults.length,
      (index) => index == currentLabel ? 1 : 0,
    ),
  );

  final costMatrix = MX.elementWiseCombineAndTransform(
    predictedResults,
    actualResults,
    (predicted, actual) => cost(predicted, actual),
  );

  return ForwardPropagationResult(
    initialActivations: initialActivations,
    costMatrix: costMatrix,
    actualResults: actualResults,
    forwardPropagatedNetwork: ForwardPropagatedNetwork(
      layers: forwardPropagatedLayers,
    ),
  );
}
