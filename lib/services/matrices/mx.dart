import 'dart:math';

import 'matrix.dart';

class MX {
  static Matrix copy(Matrix original) {
    return original.map((row) => List<double>.from(row)).toList();
  }

  static Matrix listToColumn(List<double> list) {
    return List.generate(
      list.length,
      (index) => [list[index]],
    );
  }

  static Matrix listToRow(List<double> list) {
    return [list];
  }

  static double totalSum(Matrix matrix) {
    return matrix.fold(
      0,
      (previousValue, row) => previousValue + row.fold<double>(0, (previousValue, element) => previousValue + element),
    );
  }

  static Matrix transformMatrix(
    Matrix matrix,
    double Function(double element) transform,
  ) {
    return List.generate(
      matrix.length,
      (i) => List.generate(
        matrix[i].length,
        (j) => transform(
          matrix[i][j],
        ),
      ),
    );
  }

  static Matrix elementWiseCombineAndTransform(
    Matrix matrix1,
    Matrix matrix2,
    double Function(double firstMatrixElement, double secondMatrixElement) transform,
  ) {
    assert(matrix1.length == matrix2.length);
    assert(matrix1[0].length == matrix2[0].length);

    return List.generate(
      matrix1.length,
      (i) => List.generate(
        matrix1[i].length,
        (j) => transform(
          matrix1[i][j],
          matrix2[i][j],
        ),
      ),
    );
  }

  static Matrix elementwiseProduct(Matrix column1, Matrix column2) {
    assert(column1.length == column2.length);

    for (int i = 0; i < column1.length; i++) {}

    return List.generate(
      column1.length,
      (i) {
        return [column1[i][0] * column2[i][0]];
      },
    );
  }

  bool matrixEquals(Matrix matrix1, Matrix matrix2) {
    for (int i = 0; i < matrix1.length; i++) {
      for (int j = 0; j < matrix1[i].length; j++) {
        if (matrix1[i][j] != matrix2[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  static Matrix identityMatrix(int rank) {
    return List.generate(rank, (i) => List<double>.generate(rank, (j) => i == j ? 1 : 0));
  }

  static Matrix emptyMatrix(int rows, int columns) {
    return List.generate(rows, (i) => List<double>.generate(columns, (j) => 0));
  }

  static Matrix multiplyTwo(Matrix matrix1, Matrix matrix2) {
    if (matrix1[0].length != matrix2.length) {
      throw Exception('Can not multiply matrices');
    }

    return List.generate(matrix1.length, (i) {
      return List.generate(matrix2[0].length, (k) {
        double sum = 0;
        for (int j = 0; j < matrix1[0].length; j++) {
          sum = sum + matrix1[i][j] * matrix2[j][k];
        }
        return sum;
      });
    });
  }

  static Matrix multiply(Matrix a, Matrix b) {
    return multiplyTwo(a, b);
  }

  static Matrix multiplyByConstant(double K, Matrix matrix) {
    return List.generate(matrix.length, (i) {
      return List.generate(matrix[0].length, (j) => matrix[i][j] * K);
    });
  }

  static Matrix addTwo(Matrix matrix1, Matrix matrix2) {
    if (matrix1.length != matrix2.length || matrix1[0].length != matrix2[0].length) {
      throw Exception('Can not add');
    }

    return List.generate(matrix1.length, (i) {
      return List.generate(matrix1[0].length, (j) => matrix1[i][j] + matrix2[i][j]);
    });
  }

  static Matrix add(Matrix matrix1, Matrix matrix2) {
    return addTwo(matrix1, matrix2);
  }

  static Matrix subtract(Matrix matrix1, Matrix matrix2) {
    if (matrix1.length != matrix2.length || matrix1[0].length != matrix2[0].length) {
      throw Exception('Can not subtract');
    }

    return List.generate(matrix1.length, (i) {
      return List.generate(matrix1[0].length, (j) => matrix1[i][j] - matrix2[i][j]);
    });
  }

  static Matrix transposeMatrix(Matrix matrix) {
    return List.generate(matrix[0].length, (i) {
      return List.generate(matrix.length, (j) => matrix[j][i]);
    });
  }

  static void _swapRows(Matrix matrix, int row1, int row2) {
    List<double> temp = List.from(matrix[row1]);
    matrix[row1] = matrix[row2];
    matrix[row2] = temp;
  }

  static void _scaleRow(Matrix matrix, int row, double scalar) {
    matrix[row] = matrix[row].map((element) => element * scalar).toList();
  }

  static void _rowOperation(Matrix matrix, int targetRow, int sourceRow, double scalar) {
    for (int i = 0; i < matrix[targetRow].length; i++) {
      matrix[targetRow][i] = matrix[targetRow][i] + scalar * matrix[sourceRow][i];
    }
  }

  static Matrix rowReduceEchelonForm(Matrix matrixP) {
    final matrix = MX.copy(matrixP);

    int rowCount = matrix.length;
    int columnCount = matrix[0].length;

    for (int pivotIndex = 0; pivotIndex < rowCount && pivotIndex < columnCount; pivotIndex++) {
      int nonNullRowIndex = pivotIndex;
      while (nonNullRowIndex < rowCount && matrix[nonNullRowIndex][pivotIndex] == 0) {
        nonNullRowIndex++;
      }

      if (nonNullRowIndex == rowCount) {
        // All entries in the current column are zero, move to the next column
        continue;
      }

      _swapRows(matrix, pivotIndex, nonNullRowIndex);

      final leadingDiagonalValue = matrix[pivotIndex][pivotIndex];

      _scaleRow(matrix, pivotIndex, 1 / leadingDiagonalValue);

      // Eliminate other row entries in the current pivot column
      for (int otherRowIndex = 0; otherRowIndex < rowCount; otherRowIndex++) {
        if (otherRowIndex != pivotIndex) {
          double factor = matrix[otherRowIndex][pivotIndex];
          _rowOperation(matrix, otherRowIndex, pivotIndex, -factor);
        }
      }
    }

    return matrix;
  }

  static Matrix? inverse(Matrix matrix) {
    if (matrix.length != matrix[0].length) throw Exception('Can not inverse');

    Matrix augmentedMatrix = List.from(matrix);
    int rowCount = augmentedMatrix.length;
    int colCount = augmentedMatrix[0].length;

    // Augment the matrix with an identity matrix
    for (int i = 0; i < rowCount; i++) {
      augmentedMatrix[i].addAll(List.filled(rowCount, 0));
      augmentedMatrix[i][colCount + i] = 1;
    }

    // Apply row reduction to get the augmented matrix in row-echelon form
    Matrix rowEchelonForm = rowReduceEchelonForm(augmentedMatrix);

    // Extract the inverse (right half of the augmented matrix)
    Matrix inverseMatrix = rowEchelonForm.map((row) => row.sublist(colCount, colCount * 2)).toList();

    // Check if the original matrix was full rank
    int matrixColumnSpaceRank =
        rowEchelonForm.fold(0, (rank, row) => rank + (row.sublist(0, colCount).any((element) => element != 0) ? 1 : 0));

    if (matrixColumnSpaceRank == rowCount) {
      return inverseMatrix;
    } else {
      return null;
    }
  }

  static Matrix inverseFromCofactors(Matrix matrix) {
    if (matrix.length != matrix[0].length) throw Exception('Can not inverse');
    if (matrix.length == 1) {}

    Matrix cofactoredMatrix = cofactorMatrix(matrix);
    Matrix transposedCofactorMatrix = transposeMatrix(cofactoredMatrix);
    Matrix diagonal = multiply(matrix, transposedCofactorMatrix);
    double determinant = diagonal[0][0];
    return multiplyByConstant(1 / determinant, transposedCofactorMatrix);
  }

  static double determinant(Matrix matrix) {
    if (matrix.length != matrix[0].length) return 0;

    final rowReductionResult = extendedRowReduceEchelonForm(matrix);

    return rowReductionResult.determinant;
  }

  static double factorialDeterminant(Matrix matrix) {
    if (matrix.length != matrix[0].length) return 0;
    int N = matrix.length;
    List<List<int>> allCombinationOfEntries = findAllCombinations(N);
    double result = 0;
    for (int i = 0; i < allCombinationOfEntries.length; i++) {
      double mult = 1;
      for (int j = 0; j < allCombinationOfEntries[i].length; j++) {
        int column = allCombinationOfEntries[i][j];
        mult = mult * matrix[j][column];
      }
      if (isOddCombination(allCombinationOfEntries[i])) mult = mult * (-1);
      result = result + mult;
    }
    return result;
  }

  static List<List<int>> findAllCombinations(int N) {
    List<int> matrix = List.generate(N, (index) => index);
    List<List<int>> result = [];

    void generate(int n, List<int> matrix) {
      if (n == 1) {
        result.add(List.from(matrix));
        return;
      }
      for (int i = 0; i < n - 1; i++) {
        generate(n - 1, matrix);
        if (n % 2 == 0) {
          int temp = matrix[i];
          matrix[i] = matrix[n - 1];
          matrix[n - 1] = temp;
        } else {
          int temp = matrix[0];
          matrix[0] = matrix[n - 1];
          matrix[n - 1] = temp;
        }
      }
      generate(n - 1, matrix);
    }

    generate(N, matrix);
    return result;
  }

  static Matrix cofactorMatrix(Matrix matrix) {
    if (matrix.length < 2) throw Exception('Can not find cofactor matrix with less size than 2');
    if (matrix.length != matrix[0].length) throw Exception('Can not find cofactor matrix for non square matrices');

    return List.generate(matrix.length, (i) {
      return List.generate(matrix[0].length, (j) {
        Matrix subMatrix = createSubMatrix(matrix, i, j);
        return pow(-1, i + j) * determinant(subMatrix);
      });
    });
  }

  static Matrix createSubMatrix(Matrix matrix, int rowToRemove, int colToRemove) {
    return List.generate(matrix.length - 1, (i) {
      return List.generate(matrix[0].length - 1, (j) {
        int rowIndex = i < rowToRemove ? i : i + 1;
        int colIndex = j < colToRemove ? j : j + 1;
        return matrix[rowIndex][colIndex];
      });
    });
  }

  static bool isOddCombination(List<int> list) {
    int parity = 0;
    for (int i = 0; i < list.length; i++) {
      for (int j = i + 1; j < list.length; j++) {
        if (list[i] > list[j]) parity++;
      }
    }
    return parity % 2 == 1;
  }

  static RowReductionResult extendedRowReduceEchelonForm(Matrix matrixP) {
    final matrix = MX.copy(matrixP);

    int rowCount = matrix.length;
    int columnCount = matrix[0].length;

    List<int> pivotColumns = [];
    List<int> nonPivotColumns = [];

    double determinantScale = 1;

    for (int pivotIndex = 0; pivotIndex < rowCount && pivotIndex < columnCount; pivotIndex++) {
      // non null row should be found since all pivots should be non null
      int nonNullRowIndex = pivotIndex;
      while (nonNullRowIndex < rowCount && matrix[nonNullRowIndex][pivotIndex] == 0) {
        nonNullRowIndex++;
      }

      if (nonNullRowIndex == rowCount) {
        // All entries in the current column are zero, move to the next column, and mark column as non pivot
        nonPivotColumns.add(pivotIndex);
        continue;
      }

      //Set non null row on pivot index
      _swapRows(matrix, pivotIndex, nonNullRowIndex);

      final leadingDiagonalValue = matrix[pivotIndex][pivotIndex];

      //If matrix is square and all columns are pivot, RREF matrix will be same as identity matrix. Swapping rows has no influence on determinant, but scaling a row scales a determinant by equal ratio. In this case scaling row by (1 / leadingDiagonalValue) scales the determinant by (1 / leadingDiagonalValue). So save leadingDiagonalValue and we know what was the initial determinant since we know how much we scaled it.
      determinantScale *= leadingDiagonalValue;

      _scaleRow(matrix, pivotIndex, 1 / leadingDiagonalValue);

      // Eliminate other rows' entries in the current pivot column
      for (int otherRowIndex = 0; otherRowIndex < rowCount; otherRowIndex++) {
        if (otherRowIndex != pivotIndex) {
          double factor = matrix[otherRowIndex][pivotIndex];
          _rowOperation(matrix, otherRowIndex, pivotIndex, -factor);
        }
      }

      pivotColumns.add(pivotIndex);
    }

    return RowReductionResult(
      matrix: matrix,
      pivotColumns: pivotColumns,
      nonPivotColumns: nonPivotColumns,
      determinant: determinantScale,
    );
  }

  static Matrix nullSpaceBasisMatrix(Matrix matrix) {
    final rowReductionResult = extendedRowReduceEchelonForm(List.from(matrix));

    final Matrix rref = rowReductionResult.matrix;
    final List<int> pivotColumns = rowReductionResult.pivotColumns;
    final List<int> nonPivotColumns = rowReductionResult.nonPivotColumns;
    final int matrixColumnSpaceRank = pivotColumns.length;

    final int nullSpaceDimension = rref[0].length;
    final int nullSpaceRank = nullSpaceDimension - matrixColumnSpaceRank;

    if (nullSpaceDimension == nullSpaceRank) return identityMatrix(nullSpaceRank);
    if (nullSpaceRank == 0) {
      return [
        [0.0]
      ];
    }

    final Matrix nullSpaceMatrix = List.generate(nullSpaceDimension, (i) => List<double>.filled(nullSpaceRank, 0));

    for (int j = 0; j < nullSpaceRank; j++) {
      final int currentNPC = nonPivotColumns[j]; // currentNonPivotColumn
      nullSpaceMatrix[currentNPC][j] = 1;

      for (int i = 0; i < pivotColumns.length && pivotColumns[i] < currentNPC; i++) {
        nullSpaceMatrix[pivotColumns[i]][j] = -rref[i][currentNPC];
      }
    }

    return nullSpaceMatrix;
  }

  static Matrix projectionMatrix(Matrix matrix) {
    Matrix A = List.from(matrix);
    RowReductionResult rowReductionResult = extendedRowReduceEchelonForm(A);
    A = removeColumns(A, rowReductionResult.nonPivotColumns);
    Matrix transposedA = transposeMatrix(A);
    Matrix? inverseOfAAndtransposedA = inverse(multiply(transposedA, A));

    if (inverseOfAAndtransposedA == null) {
      throw Exception('The inverse of the transposed matrix A does not exist. '
          'This may be due to A not having full column rank or numerical instability.');
    }

    Matrix P = multiply(multiply(A, inverseOfAAndtransposedA), transposedA);
    return P;
  }

  static Matrix removeColumns(Matrix matrix, List<int> columnsList) {
    Matrix result = List.generate(matrix.length, (i) => List<double>.filled(matrix[0].length - columnsList.length, 0));
    int columnsRemoved = 0;

    for (int j = 0; j < matrix[0].length; j++) {
      if (!columnsList.contains(j)) {
        for (int i = 0; i < matrix.length; i++) {
          result[i][j - columnsRemoved] = matrix[i][j];
        }
      } else {
        columnsRemoved++;
      }
    }

    return result;
  }

  static Matrix projection(Matrix matrixToProjectOn, Matrix toBeProjected) {
    if (matrixToProjectOn.length != toBeProjected.length) throw Exception('Matrices should have same number of rows');

    Matrix P = projectionMatrix(extendedRowReduceEchelonForm(matrixToProjectOn).matrix);

    Matrix result = multiply(P, toBeProjected);
    return result;
  }

  static Matrix error(Matrix matrixToProjectOn, Matrix toBeProjected) {
    Matrix P = projectionMatrix(matrixToProjectOn);

    Matrix result = subtract(toBeProjected, multiply(P, toBeProjected));
    return result;
  }
}

class RowReductionResult {
  final Matrix matrix;
  final List<int> pivotColumns;
  final List<int> nonPivotColumns;
  final double determinant;

  RowReductionResult({
    required this.matrix,
    required this.pivotColumns,
    required this.nonPivotColumns,
    required this.determinant,
  });
}
