import 'back_propagated_network.dart';

class BackPropagationResult {
  final BackPropagatedNetwork backPropagatedNetwork;

  BackPropagationResult({
    required this.backPropagatedNetwork,
  });

  @override
  String toString() => 'BackPropagationResult(backPropagatedNetwork: $backPropagatedNetwork)';
}
