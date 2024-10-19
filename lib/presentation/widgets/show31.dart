import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

const apiKey = "AIzaSyAdFm2toPrEXa2r1VxVV827846ymXWm1QU";

class Show31 extends StatefulWidget {
  final String qn;
  Show31({super.key, required this.qn});

  @override
  State<Show31> createState() => _ShowState();
}

class _ShowState extends State<Show31> {
  double bloodSugarLevel = 0.0; // Initialize blood sugar level
  double bloodSugarLevel2 = 0.0; // Initialize blood sugar level
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
    super.initState();
    fetchUserData(); // Fetch user data when widget initializes
    fetchLastBloodSugarReading(); // Fetch the last blood sugar reading
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
          diabetesType = userDoc['diabetesType'] ?? ""; // Fetch diabetes type
          name = userDoc['name'] ?? "";
          weight = userDoc['weight'] ?? "";
          gender = userDoc['gender'] ?? "";
        });
        generateTextFromStaticQuery();
      }
    }
  }

  void fetchLastBloodSugarReading() async {
    setState(() {
      loading = true;
    });

    try {
      // Fetch the last blood sugar reading for the current user
      QuerySnapshot bloodSugarSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('bloodSugarLogs')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (bloodSugarSnapshot.docs.isNotEmpty) {
        // Get the first (most recent) document
        DocumentSnapshot lastReadingDoc = bloodSugarSnapshot.docs.first;
        BloodSugar lastReading =
            BloodSugar.fromJson(lastReadingDoc.data() as Map<String, dynamic>);

        setState(() {
          bloodSugarLevel = lastReading.afterBloodSugar;
          bloodSugarLevel2 = lastReading.beforeBloodSugar;
          // Initialize the blood sugar level
          loading = false;
        });
      } else {
        setState(() {
          generatedText = "No blood sugar readings found.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        generatedText = "Error fetching blood sugar reading: $e";
        loading = false;
      });
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
    String query = "Consider yourself as an AI diabetes patient Nutrition. "
        "Recommend ${widget.qn}"
        "For a $age-year-old $gender patient named $name, weighing $weight kg and with $diabetesType diabetes,"
        "The last recorded sugar levels are $bloodSugarLevel2 mmol/L before last meal, $bloodSugarLevel mmol/L after last meal you can reflect on this where necessary"
        "Respond as though you are talking directly to $name, and write the information in paragraphs. "
        "Don't go off topic only talk about ${widget.qn}"
        "Be precise and straight to the point and give only answers related to the patient and their condition at that point.";

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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Ok Got It"),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
