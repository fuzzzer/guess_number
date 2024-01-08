import '../../../../services/services.dart';

class ForwardPropagatedLayer {
  final Matrix weights;
  final Matrix biases;

  ///Equals Weighted and biased sums of previous layer activations
  final Matrix zValues;
  final Matrix activations;

  ForwardPropagatedLayer({
    required this.weights,
    required this.biases,
    required this.zValues,
    required this.activations,
  });

  @override
  String toString() {
    return 'ForwardPropagatedLayer(weights: $weights, biases: $biases, zValues: $zValues, activations: $activations)';
  }
}
