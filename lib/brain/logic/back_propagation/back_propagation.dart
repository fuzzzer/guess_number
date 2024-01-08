import 'package:guess_number/brain/logic/back_propagation/models/back_propagated_network.dart';
import 'package:guess_number/services/functions/functions.dart';
import 'package:guess_number/services/services.dart';

import '../forward_propagation/models/forward_propagated_layer.dart';
import '../forward_propagation/models/forward_propagation_result.dart';
import 'models/back_propagated_layer.dart';
import 'models/back_propagation_result.dart';

export 'models/models.dart';

BackPropagationResult backPropagation({
  required ForwardPropagationResult forwardPropagationResult,
}) {
  final networkLayers = forwardPropagationResult.forwardPropagatedNetwork.layers;
  final actualResults = forwardPropagationResult.actualResults;

  final layerListOfCostByLayerZValuesDerivatives = getLayersListOfCostByLayerZValuesDerivatives(
    networkLayers: networkLayers,
    actualResults: actualResults,
  );

  final List<BackPropagatedLayer> backPropagatedLayers = [];

  final firstBackPropagatedLayer = BackPropagatedLayer(
    weigthAdjustments: calculateWeightAdjustments(
      costByLayerZValuesDerivatives: layerListOfCostByLayerZValuesDerivatives[0],
      previousLayerActivations: forwardPropagationResult.initialActivations,
    ),
    biasAdjustments: layerListOfCostByLayerZValuesDerivatives[0],
  );

  backPropagatedLayers.add(firstBackPropagatedLayer);

  for (int i = 1; i < networkLayers.length; i++) {
    final currentBackPropagatedLayer = BackPropagatedLayer(
      weigthAdjustments: calculateWeightAdjustments(
        costByLayerZValuesDerivatives: layerListOfCostByLayerZValuesDerivatives[i],
        previousLayerActivations: networkLayers[i - 1].activations,
      ),
      biasAdjustments: layerListOfCostByLayerZValuesDerivatives[i],
    );

    backPropagatedLayers.add(currentBackPropagatedLayer);
  }

  return BackPropagationResult(
    backPropagatedNetwork: BackPropagatedNetwork(
      layers: backPropagatedLayers,
    ),
  );
}

Matrix calculateWeightAdjustments({
  required Matrix costByLayerZValuesDerivatives,
  required Matrix previousLayerActivations,
}) {
  return List.generate(
    costByLayerZValuesDerivatives.length,
    (j) => List.generate(
      previousLayerActivations.length,
      (k) => costByLayerZValuesDerivatives[j][0] * previousLayerActivations[k][0],
    ),
  );
}

List<Matrix> getLayersListOfCostByLayerZValuesDerivatives({
  required List<ForwardPropagatedLayer> networkLayers,
  required Matrix actualResults,
}) {
  //layer by layer list that will be filled gradually, always inserting new computed derivatives column at the beggining
  final List<Matrix> costByLayerZValuesDerivativesList = [];

  final costByLastLayerActivationDerivatives = MX.elementWiseCombineAndTransform(
    networkLayers.last.activations,
    actualResults,
    (predicted, actual) => costDetivative(predicted, actual),
  );

  final lastLayerActivationByLastLayerZValuesDerivatives = MX.transformMatrix(
    networkLayers.last.zValues,
    (element) => activationDerivative(element),
  );

  final costByLastLayerZValuesDerivatives = MX.elementwiseProduct(
    costByLastLayerActivationDerivatives,
    lastLayerActivationByLastLayerZValuesDerivatives,
  );

  costByLayerZValuesDerivativesList.insert(0, costByLastLayerZValuesDerivatives);

  for (int i = networkLayers.length - 2; i >= 0; i--) {
    final previouslyIteratedLayerTransposedWeights = MX.transposeMatrix(networkLayers[i + 1].weights);
    final previouslyIteratedLayerDerivativesOfCostByZValues = costByLayerZValuesDerivativesList.first;

    final costByCurrentLayerActivationDerivatives = MX.multiply(
      previouslyIteratedLayerTransposedWeights,
      previouslyIteratedLayerDerivativesOfCostByZValues,
    );

    final currentLayerActivationByCurrentLayerZValuesDerivatives = MX.transformMatrix(
      networkLayers[i].zValues,
      (element) => activationDerivative(element),
    );

    final costByCurrentLayerZValuesDerivatives = MX.elementwiseProduct(
      costByCurrentLayerActivationDerivatives,
      currentLayerActivationByCurrentLayerZValuesDerivatives,
    );

    costByLayerZValuesDerivativesList.insert(0, costByCurrentLayerZValuesDerivatives);
  }

  return costByLayerZValuesDerivativesList;
}

// Matrix _calculateLayerActivationByLayerZValuesDerivatives(Matrix zValues) {
//   return MX.transformMatrix(
//     zValues,
//     (element) => activationDerivative(element),
//   );
// }
