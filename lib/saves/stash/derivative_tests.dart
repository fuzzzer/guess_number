import 'dart:math';

//derivatives
void main() {
  double h = 0.00001;

  //factors
  double a = 5;
  double b = 2;

  double x = 70;

  double y = a * pow(x, b);

  double nudgedy = a * pow(x + h, b);

  final dyxd = (nudgedy - y) / h;

  print(dyxd);
}
