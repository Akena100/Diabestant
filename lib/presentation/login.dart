import 'dart:async';
import 'package:diabestant/presentation/screens/home_page.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_fire.dart';
import 'register.dart';

class Login extends StatefulWidget {
  static const String id = 'Login';
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final _ema = TextEditingController();
  final _pass = TextEditingController();
  bool _secureText = true;
  bool _isSubmitting = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  @override
  void dispose() {
    _ema.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(left: 10, right: 10),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30.0, bottom: 30),
                child: Center(
                  child: Image.asset('assets/logo-db.png', width: 170),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: _ema,
                cursorColor: Colors.blue.shade200,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon:
                      const Icon(Icons.email, size: 18, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter Email';
                  }
                  bool isValid = (EmailValidator.validate(value));
                  if (isValid == false) {
                    return 'Enter Valid Email Address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pass,
                cursorColor: Colors.blue.shade200,
                obscureText: _secureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon:
                      const Icon(Icons.lock, size: 18, color: Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: showHide,
                    icon: _secureText
                        ? const Icon(
                            Icons.visibility_off,
                            color: Colors.grey,
                            size: 20,
                          )
                        : const Icon(
                            Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter your Password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {},
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () {
                    _isSubmitting ? null : _signIn(context);
                  },
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Login',
                          style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, Register.id);
                  },
                  child: const Text('Don\'t have an account? ${'Sign Up'}',
                      style: TextStyle(color: Colors.blue)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  void _signIn(BuildContext context) async {
    String email = _ema.text;
    String pass = _pass.text;

    // Use Completer to handle the async operation
    Completer<void> completer = Completer<void>();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      _auth.signInWithEmailAndPassword(email, pass).then((User? user) {
        if (user != null) {
          if (kDebugMode) {
            print("User is there");
          }

          if (user.emailVerified) {
            // User is verified, navigate to dashboard
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(user: user)),
            );
          } else {
            // User is not verified, show a dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Email Verification Required'),
                  content: const Text(
                      'Please check your email and verify your account to login.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        completer.complete();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          if (kDebugMode) {
            print("Some error occurred");
          }
          completer.complete();
        }
      }).catchError((error) {
        if (kDebugMode) {
          print("Error signing in: $error");
        }
        completer.complete();
      });
      // Wait for the async operation to complete before continuing
      await completer.future;
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
