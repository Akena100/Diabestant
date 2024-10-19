import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart';
import 'package:diabestant/presentation/screens/food.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

const apiKey = "AIzaSyAdFm2toPrEXa2r1VxVV827846ymXWm1QU";

class Show2 extends StatefulWidget {
  final BloodSugar bloodSugar;
  const Show2({super.key, required BloodSugar this.bloodSugar});

  @override
  State<Show2> createState() => _ShowState();
}

class _ShowState extends State<Show2> {
  double bloodSugarLevel = 0.0;
  double bloodSugarLevel2 = 0.0;

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
    bloodSugarLevel2 = widget.bloodSugar.afterBloodSugar;

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
          // Call to generate text after fetching user data
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
        "For a $age-year-old $gender patient named $name, weighing $weight kg and with $diabetesType diabete"
        "Analyze the blood sugar level of $bloodSugarLevel2 mmol/L recorded after a meal. "
        "Explain the meaning of this level after eating. "
        "Compare it to a previous reading of $bloodSugarLevel mmol/L taken before the meal. "
        "Provide any relevant recommendations (including specific food examples) "
        "and additional information to help the patient. "
        "Remember that the patient is using pills for treatment. "
        "Ensure the data is accurate to avoid misleading the patient. "
        "\n"
        "Blood sugar (glucose) levels vary based on factors like age, time of measurement (before or after meals), and diabetes management goals. Here are typical ranges for diabetes patients based on age:"
        "\n"
        "General Guidelines for Blood Sugar Levels (in mmol/L)"
        "\n"
        "For Adults (Including Age 50 and Above):"
        "1. After Meals (1-2 hours post-meal):"
        "- Low: Below 4 mmol/L (Hypoglycemia)"
        "- Normal: Below 10.0 mmol/L"
        "- High: Above 10.0 mmol/L"
        "\n"
        "For Older Adults (60+ years):"
        "1. After Meals (1-2 hours post-meal):"
        "- Low: Below 4 mmol/L (Hypoglycemia)"
        "- Normal: Below 10.0 mmol/L"
        "- High: Above 10.0 mmol/L"
        "\n"
        "Additional Considerations:"
        "- If the reading of $bloodSugarLevel2 mmol/L is above the normal range, it may indicate poor blood sugar control, which could necessitate adjustments in diet or medication."
        "- Specific food examples can include whole grains, lean proteins, and non-starchy vegetables to help manage blood sugar levels."
        "\n"
        "Just imagine you are talking to the actual patient (Use the person's name: $name)."
        "Be precise and straight to the point";

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
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: loading
                  ? Center(
                      child: Column(
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
                      ), // Show loading indicator
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
                      beforeMealRecommendation:
                          widget.bloodSugar.beforeMealRecommendation,
                      afterMealRecommendation: generatedText);
                  await FirebaseFirestore.instance
                      .collection('bloodSugarLogs')
                      .doc(widget.bloodSugar.id)
                      .update(bloodSug.toJson());
                  Navigator.pop(context);
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
                              )));
                },
                child: const Text("Check Out Food"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
