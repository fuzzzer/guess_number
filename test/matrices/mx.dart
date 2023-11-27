import 'package:guess_number/matrices/mx.dart';
import 'package:test/test.dart';

void main() {
  group('MX Class Tests', () {
    test('Row Reduce to Echelon Form - Zero Matrix', () {
      Matrix matrix = [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
      ];

      Matrix result = MX.rowReduceEchelonForm(matrix);

      // Assert the result is a zero matrix in canonical form
      expect(result, [
        [0, 0, 0],
        [0, 0, 0],
        [0, 0, 0],
      ]);
    });

    test('Row Reduce to Echelon Form - Identity Matrix', () {
      Matrix matrix = MX.identityMatrix(3);

      Matrix result = MX.rowReduceEchelonForm(matrix);

      // Assert the result is still an identity matrix in canonical form
      expect(result, [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
      ]);
    });

    test('Row Reduce to Echelon Form - Random Matrix', () {
      Matrix matrix = [
        [2, 3, 1],
        [4, 5, 6],
        [7, 8, 9],
      ];

      Matrix result = MX.rowReduceEchelonForm(matrix);

      expect(result, [
        [1, 0, 0],
        [0, 1, 0],
        [0, 0, 1],
      ]);
    });

    test('Row Reduce to Echelon Form - Large Matrix', () {
      Matrix matrix = List.generate(5, (i) => List.generate(5, (j) => i == j ? 1.0 : 0.0));

      Matrix result = MX.rowReduceEchelonForm(matrix);

      // Assert the result is still an identity matrix in canonical form
      expect(result, [
        [1, 0, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 0, 1, 0],
        [0, 0, 0, 0, 1],
      ]);
    });

    test('Row Reduce to Echelon Form - Rectangular Matrix', () {
      Matrix matrix = [
        [1, 2, 3],
        [4, 5, 6],
      ];

      Matrix result = MX.rowReduceEchelonForm(matrix);

      // Assert the result is in canonical form
      expect(result, [
        [1, 0, -1],
        [0, 1, 2],
      ]);
    });

    test('Matrix Multiplication', () {
      Matrix matrix1 = [
        [1, 2],
        [3, 4],
      ];

      Matrix matrix2 = [
        [5, 6],
        [7, 8],
      ];

      Matrix result = MX.multiply(matrix1, matrix2);

      // Assert the result of matrix multiplication
      expect(result, [
        [19, 22],
        [43, 50],
      ]);
    });

    test('Matrix Inversion', () {
      Matrix matrix = [
        [4, 7],
        [2, 6],
      ];

      Matrix? result = MX.inverse(matrix);

      // Assert the result of matrix inversion
      expect(result, [
        [0.6, -0.7],
        [-0.2, 0.4],
      ]);
    });

    test('Projection Matrix', () {
      Matrix matrix = [
        [1, 2],
        [3, 4],
      ];

      Matrix projectionMatrix = MX.projectionMatrix(matrix);

      // Assert the result of projection matrix
      expect(projectionMatrix, [
        [0.2, 0.4],
        [0.4, 0.8],
      ]);
    });

    test('Projection of Matrix', () {
      Matrix matrixToProjectOn = [
        [1, 0],
        [0, 1],
      ];

      Matrix toBeProjected = [
        [2, 3],
        [4, 5],
      ];

      Matrix result = MX.projection(matrixToProjectOn, toBeProjected);

      // Assert the result of matrix projection
      expect(result, [
        [2, 3],
        [4, 5],
      ]);
    });

    test('Error Matrix', () {
      Matrix matrixToProjectOn = [
        [1, 0],
        [0, 1],
      ];

      Matrix toBeProjected = [
        [2, 3],
        [4, 5],
      ];

      Matrix result = MX.error(matrixToProjectOn, toBeProjected);

      // Assert the result of error matrix
      expect(result, [
        [0, 0],
        [0, 0],
      ]);
    });
  });
}
