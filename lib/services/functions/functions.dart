import 'dart:math';

const h = 0.000000001;

const learningRate = 0.001;

double applyAdjustment({required double currentValue, required double adjustment}) {
  return currentValue - learningRate * adjustment;
}

double cost(double predicted, double actual) {
  return pow((predicted - actual), 2).toDouble();
}

double costDetivative(double predicted, double actual) {
  return 2 * (predicted - actual);
}

///relu: f(x)=max(0,x)
double relu(double x) {
  return max(0, x);
}

///the derivative is undefined at 0 but, since this is not continuous case we assign derivative at 0 manually
double reluDerivative(double x) {
  return x > 0 ? 1 : 0;
}

///sigmod f(x)=1/(1+e^(-x))
double sigmod(double x) {
  return 1 / (1 + exp(-x));
}

/// sigmoid f(x) derivative after simplification is f'(x)=f(x)*(1-f(x))
double sigmoidDerivative(double x) {
  return sigmod(x) * (1 - sigmod(x));
}

double activate(double x) {
  return sigmod(x);
}

double activationDerivative(double x) {
  return sigmoidDerivative(x);
}
