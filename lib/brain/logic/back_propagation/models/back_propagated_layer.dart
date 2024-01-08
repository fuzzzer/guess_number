import '../../../../services/services.dart';

//use applyAdjustment() method to apply backpropagated layer adjustments
class BackPropagatedLayer {
  final Matrix weigthAdjustments;
  final Matrix biasAdjustments;

  BackPropagatedLayer({
    required this.weigthAdjustments,
    required this.biasAdjustments,
  });

  @override
  String toString() {
    return 'BackPropagatedLayer(weigthAdjustments: $weigthAdjustments, biasAdjustments: $biasAdjustments)';
  }
}
