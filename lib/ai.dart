import 'package:flutter/material.dart';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';

class PredictionPage extends StatefulWidget {
  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pregnanciesController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _skinThicknessController =
      TextEditingController();
  final TextEditingController _insulinController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _diabetesPedigreeController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _result = '';
  bool _modelLoaded = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Download the model from Firebase
      final remoteModel = await FirebaseModelDownloader.instance.getModel(
        'diabetes_predition_model', // Replace with your model name
        FirebaseModelDownloadType.localModel,
      );

      // Load the model file
      final modelFilePath = remoteModel.file.path;

      setState(() {
        _modelLoaded = true;
        _isLoading = false; // Stop loading
      });
      print('Model loaded successfully from $modelFilePath');
    } catch (e) {
      print('Error loading model: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<List<T>> reshapeList<T>(List<T> list, int rows, int cols) {
    if (list.length != rows * cols) {
      throw ArgumentError('Invalid dimensions for reshape');
    }

    List<List<T>> reshaped = [];
    for (int i = 0; i < rows; i++) {
      reshaped.add(list.sublist(i * cols, (i + 1) * cols));
    }
    return reshaped;
  }

  Future<void> predict() async {
    if (!_modelLoaded) {
      print('Model is not loaded yet');
      return;
    }

    try {
      // Get input values from controllers
      List<double> inputValues = [
        double.parse(_pregnanciesController.text),
        double.parse(_glucoseController.text),
        double.parse(_bloodPressureController.text),
        double.parse(_skinThicknessController.text),
        double.parse(_insulinController.text),
        double.parse(_bmiController.text),
        double.parse(_diabetesPedigreeController.text),
        double.parse(_ageController.text),
      ];

      // Prepare the input for the model
      var input = [inputValues];
      var output = reshapeList(List.filled(1, 0.0), 1, 1);

      // Simulate a prediction logic for demonstration
      output[0][0] = inputValues.reduce((a, b) => a + b) > 20
          ? 1.0
          : 0.0; // Dummy logic for demonstration

      setState(() {
        _result =
            output[0][0] > 0.5 ? "Diabetes Positive" : "Diabetes Negative";
      });
    } catch (e) {
      print('Error during prediction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diabetes Prediction'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Loading model, please wait...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pregnanciesController,
                        decoration: InputDecoration(labelText: 'Pregnancies'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the number of pregnancies';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _glucoseController,
                        decoration: InputDecoration(labelText: 'Glucose Level'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the glucose level';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _bloodPressureController,
                        decoration:
                            InputDecoration(labelText: 'Blood Pressure'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the blood pressure';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _skinThicknessController,
                        decoration:
                            InputDecoration(labelText: 'Skin Thickness'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter skin thickness';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _insulinController,
                        decoration: InputDecoration(labelText: 'Insulin Level'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the insulin level';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _bmiController,
                        decoration: InputDecoration(labelText: 'BMI'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the BMI';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _diabetesPedigreeController,
                        decoration: InputDecoration(
                            labelText: 'Diabetes Pedigree Function'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter diabetes pedigree function';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the age';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _modelLoaded
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  predict();
                                }
                              }
                            : null, // Disable button until model is loaded
                        child: Text('Predict'),
                      ),
                      SizedBox(height: 20),
                      Text('Prediction: $_result'),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    // No need to close interpreter since we don't use TFLite directly
    super.dispose();
  }
}
