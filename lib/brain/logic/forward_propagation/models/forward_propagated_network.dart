import 'forward_propagated_layer.dart';

class ForwardPropagatedNetwork {
  final List<ForwardPropagatedLayer> layers;

  ForwardPropagatedNetwork({
    required this.layers,
  });

  @override
  String toString() => 'ForwardPropagatedNetwork(layers: $layers)';
}
