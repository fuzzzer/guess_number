//Inner lists are rows of the matrix, so the rows are just lists containing multiple doubles and columns are List of Lists with only one element
typedef Matrix = List<List<double>>;

extension MatrixExtension on Matrix {
  Matrix transformEachMatrixElement(
    double Function(double element) transform,
  ) {
    for (int i = 0; i < length; i++) {
      for (int j = 0; j < this[i].length; j++) {
        this[i][j] = transform(this[i][j]);
      }
    }

    return this;
  }
}
