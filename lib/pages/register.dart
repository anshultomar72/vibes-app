import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homePage.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Placeholder function for Google registration (implement with Firebase or other service)
  void _registerWithGoogle() {
    print('Registering with Google...');
  }
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Placeholder function for navigating to the login page
  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // Assuming Login page is already created
      ),
    );
    print('Navigating to Login Page...');
  }
  void _register() async {
      try{
        final credentials = await _auth.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        print(credentials);

        _goToHome();
      }on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }


  }
  void _goToHome(){

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>  HomePage()), (route) => false);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/bg2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Form Elements
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center form vertically
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Register" Header
                  const SizedBox(height: 80),
                  const Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Name Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(

                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8), // Slightly transparent background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8), // Slightly transparent background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Email',
                        hintText: 'Enter valid email id',
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8), // Slightly transparent background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8), // Slightly transparent background
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Register Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle registration logic here
                        _register();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register with Google Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: _registerWithGoogle,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.redAccent, // Google button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.login, color: Colors.white), // Google icon placeholder
                      label: const Text(
                        'Register with Google',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Already have an account? Login Here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: _goToLogin,
                        child: const Text(
                          'Login Here',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
