import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

const apiKey = "AIzaSyAdFm2toPrEXa2r1VxVV827846ymXWm1QU";

class Show extends StatefulWidget {
  final BloodSugar bloodSugar;
  const Show({super.key, required this.bloodSugar});

  @override
  State<Show> createState() => _ShowState();
}

class _ShowState extends State<Show> {
  double bloodSugarLevel = 0.0;
  bool loading = false;
  String generatedText = ""; // To store the generated text
  String userId = ""; // To hold the user's ID
  String age = ""; // To hold user's age
  String name = "";
  String gender = "";
  String weight = "";
  String diabetesType = ""; // To hold user's diabetes type

  @override
  void initState() {
    bloodSugarLevel = widget.bloodSugar.beforeBloodSugar;
    fetchUserData();
    super.initState();
  }

  void fetchUserData() async {
    // Get current user ID
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      userId = currentUser.uid; // Get the current user's ID

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Assuming the user document has 'age' and 'diabetesType' fields
        setState(() {
          age = userDoc['age'] ?? ""; // Fetch age from Firestore
          diabetesType = userDoc['diabetesType'] ??
              ""; // Fetch diabetes type from Firestore
          name = userDoc['name'] ?? "";
          weight = userDoc['weight'] ?? "";
          gender = userDoc['gender'] ?? "";
        });
        generateTextFromStaticQuery();
      }
    }
  }

  // Create Gemini Instance
  final gemini = GoogleGemini(
    apiKey: apiKey,
  );

  void generateTextFromStaticQuery() {
    setState(() {
      loading = true;
    });

    // Predefined static query
    String query = "Consider yourself as an AI for a diabetes patient. "
        "For a $age-year-old $gender patient named $name, weighing $weight kg and with $diabetesType diabetes, analyze a blood sugar level of $bloodSugarLevel mmol/L taken before a meal. "
        "Take into account low, normal, and high blood sugar levels. "
        "Explain the significance of $name's blood sugar level, providing accurate recommendations (including specific food examples by name). "
        "Remember that the patient is using pills for treatment. "
        "Ensure the data is accurate to avoid misleading the patient. "
        "Respond as though you are talking directly to $name, and write the information in paragraphs. ";

    gemini.generateFromText(query).then((value) {
      setState(() {
        loading = false;
        generatedText = value.text ?? "No text generated"; // Update the text
      });
    }).onError((error, stackTrace) {
      setState(() {
        loading = false;
        generatedText = "Error: ${error.toString()}"; // Handle error
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: loading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/diabot.png'),
                            const CircularProgressIndicator(),
                            AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'DiabesBot Analyzing....',
                                  textStyle: const TextStyle(
                                    fontSize: 20.0,
                                  ),
                                  speed: const Duration(milliseconds: 50),
                                ),
                              ],
                              totalRepeatCount: 4,
                              pause: const Duration(milliseconds: 50),
                              displayFullTextOnTap: true,
                              stopPauseOnTap: true,
                            )
                          ],
                        ),
                      )
                    : Text(
                        generatedText,
                        style: const TextStyle(fontSize: 20),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final bloodSug = BloodSugar(
                        id: widget.bloodSugar.id,
                        userId: widget.bloodSugar.userId,
                        date: widget.bloodSugar.date,
                        status: widget.bloodSugar.status,
                        beforeBloodSugar: widget.bloodSugar.beforeBloodSugar,
                        afterBloodSugar: widget.bloodSugar.afterBloodSugar,
                        beforeTime: widget.bloodSugar.beforeTime,
                        afterTime: widget.bloodSugar.afterTime,
                        type: widget.bloodSugar.type,
                        beforeMealRecommendation: generatedText,
                        afterMealRecommendation:
                            widget.bloodSugar.afterMealRecommendation,
                      );

                      // Update the document in Firestore
                      await FirebaseFirestore.instance
                          .collection('bloodSugarLogs')
                          .doc(widget.bloodSugar.id)
                          .update(bloodSug.toJson());

                      Navigator.pop(context); // Navigate back after update
                    } catch (e) {
                      // Handle any errors that occur during update
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating data: $e')),
                      );
                    }
                  },
                  child: const Text("I Understand"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealTrackerPage(
                          b: widget.bloodSugar,
                        ),
                      ),
                    );
                  },
                  child: const Text("Check Out Food"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
