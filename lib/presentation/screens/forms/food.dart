import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class FoodForm extends StatefulWidget {
  final Map<String, dynamic>? food;

  const FoodForm({Key? key, this.food}) : super(key: key);

  @override
  _FoodFormState createState() => _FoodFormState();
}

class _FoodFormState extends State<FoodForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _fatsController = TextEditingController();
  final _sugarController = TextEditingController();
  String? _imageUrl;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();

    if (widget.food != null) {
      _nameController.text = widget.food!['name'] ?? '';
      _categoryController.text = widget.food!['category'] ?? '';
      _servingSizeController.text =
          widget.food!['servingSize']?.toString() ?? '';
      _caloriesController.text = widget.food!['calories']?.toString() ?? '';
      _proteinController.text = widget.food!['protein']?.toString() ?? '';
      _carbohydratesController.text =
          widget.food!['carbohydrates']?.toString() ?? '';
      _fatsController.text = widget.food!['fats']?.toString() ?? '';
      _sugarController.text = widget.food!['sugar']?.toString() ?? '';
      _imageUrl = widget.food!['image'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydratesController.dispose();
    _fatsController.dispose();
    _sugarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  double _parseDouble(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl = _imageUrl;

        if (_imageFile != null) {
          String fileName = const Uuid().v4();
          final storageRef =
              FirebaseStorage.instance.ref().child('foods/$fileName');
          if (kIsWeb) {
            await storageRef.putData(await _imageFile!.readAsBytes());
          } else {
            await storageRef.putFile(File(_imageFile!.path));
          }
          imageUrl = await storageRef.getDownloadURL();
        }

        Map<String, dynamic> food = {
          'id': widget.food?['id'] ?? const Uuid().v4(),
          'name': _nameController.text,
          'category': _categoryController.text,
          'servingSize': _parseDouble(_servingSizeController.text),
          'calories': _parseDouble(_caloriesController.text),
          'protein': _parseDouble(_proteinController.text),
          'carbohydrates': _parseDouble(_carbohydratesController.text),
          'fats': _parseDouble(_fatsController.text),
          'sugar': _parseDouble(_sugarController.text),
          'image': imageUrl ?? '',
        };

        if (widget.food == null) {
          await FirebaseFirestore.instance.collection('foods').add(food);
        } else {
          await FirebaseFirestore.instance
              .collection('foods')
              .doc(widget.food!['id'])
              .update(food);
        }

        Navigator.pop(context, widget.food == null ? 'added' : 'updated');
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Form'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _imageFile != null
                    ? Image.file(File(_imageFile!.path),
                        height: 150, width: 150)
                    : (_imageUrl != null
                        ? Image.network(_imageUrl!, height: 150, width: 150)
                        : const Icon(Icons.image, size: 100)),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Pick Image'),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _servingSizeController,
                decoration: const InputDecoration(
                  labelText: 'Serving Size',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the serving size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the calories';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _proteinController,
                decoration: const InputDecoration(
                  labelText: 'Protein (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the protein amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _carbohydratesController,
                decoration: const InputDecoration(
                  labelText: 'Carbohydrates (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the carbohydrate amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _fatsController,
                decoration: const InputDecoration(
                  labelText: 'Fats (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the fat amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _sugarController,
                decoration: const InputDecoration(
                  labelText: 'Sugar (g)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the sugar amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.food == null ? 'Add Food' : 'Update Food'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
