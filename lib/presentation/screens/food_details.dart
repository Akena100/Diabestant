import 'package:diabestant/model/blood_sugar.dart';
import 'package:diabestant/presentation/widgets/show3.dart';
import 'package:diabestant/presentation/widgets/show31.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealDetailPage extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double carbs;

  final double protein;
  final double fat;
  final double sugar;
  final BloodSugar? b;

  const MealDetailPage({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.sugar,
    this.b,
  });

  @override
  Widget build(BuildContext context) {
    String x = '';
    final goal = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              const SizedBox(height: 16),
              const ListTile(
                title:
                    Text('Nutritional facts', style: TextStyle(fontSize: 20)),
                trailing: Text('per 100g'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text('Carbs'),
                          trailing: Text('${carbs}g'),
                        ),
                        LinearProgressIndicator(
                          value: carbs / 100,
                          color: Colors.green,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: const Text('Glucose'),
                          trailing: Text('${sugar}g'),
                        ),
                        LinearProgressIndicator(
                          value: sugar / 100,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          title: const Text('Proteins'),
                          trailing: Text('${protein}g'),
                        ),
                        LinearProgressIndicator(
                          value: protein / 100,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        ListTile(
                          title: const Text('Fat'),
                          trailing: Text('${fat}g'),
                        ),
                        LinearProgressIndicator(
                          value: protein / 100,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              // Buttons for additional actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('Ingredients'),
                    onPressed: () {
                      if (b != null) {
                        _showAppropriateDialog(b!, context,
                            qn: 'Ingredients for $name (Please talk only about ingredients)');
                      } else {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text('Sugar Goal'),
                                content: TextField(
                                  controller: goal,
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        x = goal.text;
                                        Navigator.pop(context);
                                        _showAppropriateDialog2(context,
                                            qn: 'Ingredients $name for Sugar Goal $x (Please talk only about ingredients)');
                                      },
                                      child: const Text('Submit'))
                                ],
                              );
                            }));
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.kitchen),
                    label: const Text('Cooking Instruction'),
                    onPressed: () {
                      if (b != null) {
                        // Handle Cooking Instruction action
                        _showAppropriateDialog(b!, context,
                            qn: 'Cooking Instruction for $name (Please talk only about cooking instructions)');
                      } else {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text('Sugar Goal'),
                                content: TextField(
                                  controller: goal,
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        x = goal.text;
                                        Navigator.pop(context);
                                        _showAppropriateDialog2(context,
                                            qn: 'Cooking Instruction for $name for Sugar Goal $x (Please talk only about cooking instructions)');
                                      },
                                      child: const Text('Submit'))
                                ],
                              );
                            }));
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lightbulb),
                    label: const Text('Tips & Tricks'),
                    onPressed: () {
                      if (b != null) {
                        // Handle Tips & Tricks action
                        _showAppropriateDialog(b!, context,
                            qn: 'Tips & Tricks for cooking and choosing $name');
                      } else {
                        showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text('Sugar Goal'),
                                content: TextField(
                                  controller: goal,
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () {
                                        x = goal.text;
                                        Navigator.pop(context);
                                        _showAppropriateDialog2(context,
                                            qn: 'Tips and Tricks on $name for Sugar Goal $x');
                                      },
                                      child: const Text('Submit'))
                                ],
                              );
                            }));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAppropriateDialog(BloodSugar? b, BuildContext context,
      {required String qn}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: Center(
                  child: Image.asset(
                'assets/diabot.png',
                height: 150,
                width: 100,
              )),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Show3(bloodSugar: b, qn: qn)));
        });
  }

  void _showAppropriateDialog2(BuildContext context, {required String qn}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
              title: Center(
                  child: Image.asset(
                'assets/diabot.png',
                height: 150,
                width: 100,
              )),
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Show31(qn: qn)));
        });
  }
}
