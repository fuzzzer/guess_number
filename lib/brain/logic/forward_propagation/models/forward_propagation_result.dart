// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:guess_number/services/services.dart';

import 'forward_propagated_network.dart';

class ForwardPropagationResult {
  final Matrix initialActivations;
  final Matrix costMatrix;
  final Matrix actualResults;
  final ForwardPropagatedNetwork forwardPropagatedNetwork;

  ForwardPropagationResult({
    required this.initialActivations,
    required this.costMatrix,
    required this.actualResults,
    required this.forwardPropagatedNetwork,
  });

  @override
  String toString() {
    return 'ForwardPropagationResult(initialActivations: $initialActivations, costMatrix: $costMatrix, actualResults: $actualResults, forwardPropagatedNetwork: $forwardPropagatedNetwork)';
  }
}
