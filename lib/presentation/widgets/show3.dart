import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diabestant/model/blood_sugar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/google_gemini.dart';

const apiKey = "AIzaSyAdFm2toPrEXa2r1VxVV827846ymXWm1QU";

class Show3 extends StatefulWidget {
  BloodSugar? bloodSugar;
  final String qn;
  Show3({super.key, this.bloodSugar, required this.qn});

  @override
  State<Show3> createState() => _ShowState();
}

class _ShowState extends State<Show3> {
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
    bloodSugarLevel = widget.bloodSugar!.beforeBloodSugar;

    fetchUserData();
    super.initState();
  }

  text() {
    if (widget.bloodSugar!.afterBloodSugar == 0.0 &&
        widget.bloodSugar!.beforeBloodSugar == 0.0) {
      return '';
    } else if (widget.bloodSugar!.afterBloodSugar == 0.0) {
      return 'for a patient of $bloodSugarLevel before meal';
    } else {
      return 'for a patient of $bloodSugarLevel before meal and ${widget.bloodSugar!.afterBloodSugar} after meal';
    }
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
    String query = "Consider yourself as an AI diabetes patient Nutrition. "
        "Recommend ${widget.qn} $text"
        "For a $age-year-old $gender patient named $name, weighing $weight kg and with $diabetesType diabetes,"
        "Respond as though you are talking directly to $name, and write the information in paragraphs. "
        "Dont go off topic only talk about ${widget.qn}"
        "Be precise and straight to the point and give only answers related to the paient and his codition at that point";

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
