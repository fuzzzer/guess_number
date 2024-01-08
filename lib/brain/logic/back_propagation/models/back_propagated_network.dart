import 'back_propagated_layer.dart';

class BackPropagatedNetwork {
  final List<BackPropagatedLayer> layers;

  BackPropagatedNetwork({
    required this.layers,
  });

  @override
  String toString() => 'BackPropagatedNetwork(layers: $layers)';
}
