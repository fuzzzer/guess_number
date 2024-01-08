import 'dart:async';
import 'dart:io';

import '../../../brain/base_models/base_models.dart';
import '../models/model_metadata.dart';

class NetworkModelRepository {
  static Completer<void> _savingCompleter = Completer<void>();
  static bool _isSaving = false;

  static final String _modelsFolderPath = '/Users/fuzzzer/programming/projects/tries/guess_number/materials/models';
  static final String _metadataFilePath = '$_modelsFolderPath/metadata.json';

  static String _getCurrentModelFilePath({required int version}) {
    final fileName = 'model_v$version.json';
    return '$_modelsFolderPath/$fileName';
  }

  static Future<ModelMetadata> _getModelMetadata() async {
    String modelsMetadataJsonString = await File(_metadataFilePath).readAsString();
    final modelMetadata = ModelMetadata.fromJson(modelsMetadataJsonString);

    return modelMetadata;
  }

  static Future<void> _setModelMetadata({required ModelMetadata modelMetadata}) async {
    final modelMetadataJson = modelMetadata.toJson();
    await File(_metadataFilePath).writeAsString(modelMetadataJson);
  }

  //returns new version
  static Future<int> _bumpModelMetadataVersion() async {
    final currentModelMetadata = (await _getModelMetadata());
    final newModelVersion = currentModelMetadata.modelVersion + 1;
    final newModelMetadata = currentModelMetadata.copyWith(modelVersion: newModelVersion);

    _setModelMetadata(modelMetadata: newModelMetadata);

    return newModelVersion;
  }

  static Future<void> save({
    required NeuralNetwork neuralNetwork,
  }) async {
    _isSaving = true;
    _savingCompleter = Completer<void>();

    final currentModelFilePath = _getCurrentModelFilePath(
      version: await _bumpModelMetadataVersion(),
    );

    final jsonString = neuralNetwork.toJson();
    await File(currentModelFilePath).writeAsString(jsonString);

    _isSaving = false;
    _savingCompleter.complete();
  }

  static Future<NeuralNetwork> load() async {
    if (_isSaving) {
      await _savingCompleter.future;
    }

    final currentModelFilePath = _getCurrentModelFilePath(
      version: (await _getModelMetadata()).modelVersion,
    );

    String jsonString = await File(currentModelFilePath).readAsString();
    final neuralNetwork = NeuralNetwork.fromJson(jsonString);

    return neuralNetwork;
  }
}
