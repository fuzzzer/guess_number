import 'dart:math';

typedef Matrix = List<List<double>>;

//TODO write tests for each method
class MX {
  static void _swapRows(Matrix matrix, int row1, int row2) {
    List<double> temp = List.from(matrix[row1]);
    matrix[row1] = List.from(matrix[row2]);
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

  static Matrix copy(Matrix original) {
    return original.map((row) => List<double>.from(row)).toList();
  }

  static Matrix rowReduceEchelonForm(Matrix matrixP) {
    final matrix = MX.copy(matrixP);

    int rowCount = matrix.length;
    int columnCount = matrix[0].length;

    for (int pivotIndex = 0; pivotIndex < rowCount; pivotIndex++) {
      if (columnCount <= pivotIndex) {
        break; // No more columns to process
      }

      int nonNullRowIndex = pivotIndex;
      while (nonNullRowIndex < rowCount && matrix[nonNullRowIndex][pivotIndex] == 0) {
        nonNullRowIndex++;
      }

      if (nonNullRowIndex == rowCount) {
        // All entries in the current column are zero, move to the next column
        continue;
      }

      //Set non null row on pivot index
      _swapRows(matrix, pivotIndex, nonNullRowIndex);
      _scaleRow(matrix, pivotIndex, 1 / matrix[pivotIndex][pivotIndex]);

      // Eliminate other rows' entries in the current column
      for (int otherRow = 0; otherRow < rowCount; otherRow++) {
        if (otherRow != pivotIndex) {
          double factor = matrix[otherRow][pivotIndex];
          _rowOperation(matrix, otherRow, pivotIndex, -factor);
        }
      }
    }

    return matrix;
  }

  static Matrix identityMatrix(int rank) {
    return List.generate(rank, (i) => List<double>.generate(rank, (j) => i == j ? 1 : 0));
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
    return add(matrix1, multiplyByConstant(-1, matrix2));
  }

  static Matrix transposeMatrix(Matrix matrix) {
    return List.generate(matrix[0].length, (i) {
      return List.generate(matrix.length, (j) => matrix[j][i]);
    });
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

    double result = 1;

    Matrix upper = upperTriangularMatrix(matrix);
    for (int i = 0; i < upper.length; i++) {
      result = result * upper[i][i];
    }

    return result;
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

  static Matrix upperTriangularMatrix(Matrix matrix) {
    return List.generate(matrix.length, (i) {
      return List.generate(matrix[0].length, (j) {
        return i <= j ? matrix[i][j] : 0;
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
    int colCount = matrix[0].length;

    List<int> pivotColumns = [];
    List<int> nonPivotColumns = [];
    int matrixColumnSpaceRank = 0;

    int leadColumn = 0;

    for (int currentRow = 0; currentRow < rowCount; currentRow++) {
      if (colCount <= leadColumn) {
        break; // No more columns to process
      }

      int pivotRow = currentRow;
      while (pivotRow < rowCount && matrix[pivotRow][leadColumn] == 0) {
        pivotRow++;
      }

      if (pivotRow == rowCount) {
        // All entries in the current column are zero, move to the next column
        leadColumn++;
        continue;
      }

      _swapRows(matrix, currentRow, pivotRow);
      _scaleRow(matrix, currentRow, 1 / matrix[currentRow][leadColumn]);

      for (int otherRow = 0; otherRow < rowCount; otherRow++) {
        if (otherRow != currentRow) {
          double factor = matrix[otherRow][leadColumn];
          _rowOperation(matrix, otherRow, currentRow, -factor);
        }
      }

      //current row is our pivot ro
      pivotColumns.add(currentRow);
      matrixColumnSpaceRank++;

      leadColumn++;
    }

    for (int col = 0; col < colCount; col++) {
      if (!pivotColumns.contains(col)) {
        nonPivotColumns.add(col);
      }
    }

    return RowReductionResult(
      matrix: matrix,
      pivotColumns: pivotColumns,
      nonPivotColumns: nonPivotColumns,
      matrixColumnSpaceRank: matrixColumnSpaceRank,
    );
  }

  static Matrix nullSpaceBasisMatrix(Matrix matrix) {
    final rowReductionResult = extendedRowReduceEchelonForm(List.from(matrix));

    final Matrix rref = rowReductionResult.matrix;
    final List<int> pivotColumns = rowReductionResult.pivotColumns;
    final List<int> nonPivotColumns = rowReductionResult.nonPivotColumns;
    final int matrixColumnSpaceRank = rowReductionResult.matrixColumnSpaceRank;

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
  final int matrixColumnSpaceRank;

  RowReductionResult({
    required this.matrix,
    required this.pivotColumns,
    required this.nonPivotColumns,
    required this.matrixColumnSpaceRank,
  });
}
