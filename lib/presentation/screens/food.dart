import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart';
import 'package:diabestant/presentation/screens/food_details.dart';
import 'package:diabestant/presentation/screens/forms/food.dart';
import 'package:diabestant/presentation/widgets/bottom_nav.dart';
import 'package:diabestant/presentation/widgets/drawer.dart';
import 'package:flutter/material.dart';

class MealTrackerPage extends StatefulWidget {
  final BloodSugar? b;

  const MealTrackerPage({super.key, this.b});

  @override
  State<MealTrackerPage> createState() => _MealTrackerPageState();
}

class _MealTrackerPageState extends State<MealTrackerPage> {
  int _selectedIndex = 0;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: const Text('My Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What do you want to eat?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance.collection('foods').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No consumed items yet.'));
                  }

                  final filteredDocs = snapshot.data!.docs.where((doc) {
                    final data = doc.data();
                    return data['name']
                        .toString()
                        .toLowerCase()
                        .contains(searchQuery);
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return const Center(
                        child: Text('No matching meals found.'));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot<Map<String, dynamic>> document =
                          filteredDocs[index];
                      Map<String, dynamic>? data = document.data();
                      String itemName = data!['name'];
                      String sugarContent = data['sugar'].toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: CachedNetworkImage(
                            width: 50,
                            height: 100,
                            imageUrl: data['image'],
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) {
                              print(
                                  'Image failed to load: $url, Error: $error');
                              return const Icon(Icons.error);
                            },
                          ),
                          title: Text(itemName),
                          subtitle: Text('Sugar: ${sugarContent}g'),
                          onTap: () {
                            if (widget.b != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealDetailPage(
                                      imageUrl: data['image'],
                                      name: itemName,
                                      carbs: double.tryParse(
                                              data['carbohydrates']
                                                  .toString()) ??
                                          0.0,
                                      protein: double.tryParse(
                                              data['protein'].toString()) ??
                                          0.0,
                                      fat: double.tryParse(
                                              data['fats'].toString()) ??
                                          0.0,
                                      sugar: double.tryParse(
                                              data['sugar'].toString()) ??
                                          0.0,
                                      b: widget.b!),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealDetailPage(
                                    imageUrl: data['image'],
                                    name: itemName,
                                    carbs: double.tryParse(
                                            data['carbohydrates'].toString()) ??
                                        0.0,
                                    protein: double.tryParse(
                                            data['protein'].toString()) ??
                                        0.0,
                                    fat: double.tryParse(
                                            data['fats'].toString()) ??
                                        0.0,
                                    sugar: double.tryParse(
                                            data['sugar'].toString()) ??
                                        0.0,
                                  ),
                                ),
                              );
                            }
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodForm(
                                        food: data), // Pass the full food data
                                  ),
                                ).then((result) {
                                  if (result == 'updated') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Food updated successfully!')));
                                  }
                                });
                              } else if (value == 'Delete') {
                                FirebaseFirestore.instance
                                    .collection('foods')
                                    .doc(document.id)
                                    .delete();
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'Edit', 'Delete'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FoodForm()),
          ).then((result) {
            if (result == 'added') {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Food added successfully!')));
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
