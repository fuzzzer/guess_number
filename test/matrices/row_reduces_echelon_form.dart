import 'dart:math' as math;
import 'package:guess_number/services/matrices/matrices.dart';
import 'package:test/test.dart';

void main() {
  group('MX Class Performance Tests', () {
    test('Row Reduce to Echelon Form - Large Matrix', () {
      int rows = 1500;
      int columns = 1000;

      Matrix largeMatrix =
          List.generate(rows, (i) => List.generate(columns, (j) => math.Random().nextInt(10000000).toDouble() / 100));

      Stopwatch stopwatch = Stopwatch()..start();
      final rowReducedMatrix = MX.rowReduceEchelonForm(largeMatrix);
      stopwatch.stop();

      print('Time taken for row-reduced echelon form on a $rows x $columns matrix: ${stopwatch.elapsed}');

      Future.delayed(Duration(seconds: 2), () {
        print(rowReducedMatrix);
      });
    });
  });
}
