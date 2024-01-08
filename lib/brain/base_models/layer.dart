import '../../services/services.dart';

class Layer {
  final Matrix weights;
  final Matrix biases;

  Layer({
    required this.weights,
    required this.biases,
  });

  @override
  String toString() => 'Layer(weights: $weights, biases: $biases)';
}
