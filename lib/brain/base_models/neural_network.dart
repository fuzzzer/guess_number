import 'dart:convert';

import 'layer.dart';

class NeuralNetwork {
  final List<Layer> layers;

  NeuralNetwork({
    required this.layers,
  });

  @override
  String toString() => 'NeuralNetwork(layers: $layers)';

  Map<String, dynamic> toMap(NeuralNetwork neuralNetwork) {
    return {
      'layers': neuralNetwork.layers
          .map((layer) => {
                'layerWeights': layer.weights,
                'biases': layer.biases,
              })
          .toList(),
    };
  }

  factory NeuralNetwork.fromMap(Map<String, dynamic> json) {
    var layers = (json['layers'] as List).map((layerJson) {
      return Layer(
        weights: (layerJson['layerWeights'] as List).map((e) => List<double>.from(e)).toList(),
        // layerWeights: (layerJson['layerWeights'] as List).cast<List<double>>(),
        biases: (layerJson['biases'] as List).map((e) => List<double>.from(e)).toList(),
        // biases: (layerJson['biases'] as List).map((e) => List<double>.from(e)).toList(),
      );
    }).toList();

    return NeuralNetwork(layers: layers);
  }

  String toJson() => json.encode(toMap(this));

  factory NeuralNetwork.fromJson(String source) => NeuralNetwork.fromMap(json.decode(source) as Map<String, dynamic>);
}
