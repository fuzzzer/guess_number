import 'package:guess_number/services/services.dart';

import '../../../services/functions/functions.dart';
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

  //TODO make changes for this to work on any number of layers
  final firstLayer = (neuralNetwork.layers[0]);
  final firstWeightedSum = MX.multiply(firstLayer.weights, initialActivations);
  final firstZValues = MX.add(firstWeightedSum, firstLayer.biases);
  final firstActivations = MX.transformMatrix(firstZValues, (element) => activate(element));

  final secondLayer = (neuralNetwork.layers[1]);
  final secondWeightedSum = MX.multiply(secondLayer.weights, firstActivations);
  final secondZValues = MX.add(secondWeightedSum, secondLayer.biases);
  final secondActivations = MX.transformMatrix(secondZValues, (element) => activate(element));

  final thirdLayer = (neuralNetwork.layers[2]);
  final thirdWeightedSum = MX.multiply(thirdLayer.weights, secondActivations);
  final thirdZValues = MX.add(thirdWeightedSum, thirdLayer.biases);
  final thirdActivations = MX.transformMatrix(thirdZValues, (element) => activate(element));

  final predictedResults = thirdActivations;
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
      layers: [
        ForwardPropagatedLayer(
          weights: firstLayer.weights,
          biases: firstLayer.biases,
          zValues: firstZValues,
          activations: firstActivations,
        ),
        ForwardPropagatedLayer(
          weights: secondLayer.weights,
          biases: secondLayer.biases,
          zValues: secondZValues,
          activations: secondActivations,
        ),
        ForwardPropagatedLayer(
          weights: thirdLayer.weights,
          biases: thirdLayer.biases,
          zValues: thirdZValues,
          activations: thirdActivations,
        ),
      ],
    ),
  );
}
