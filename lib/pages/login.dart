import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibes_app/pages/homePage.dart';
import 'package:vibes_app/pages/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'BottomNavigationBar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Placeholder function for Google login (implement with Firebase or other service)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _loginWithGoogle() {
    // Integrate Google sign-in logic here
    print('Logging in with Google...');
  }

  // Placeholder function for user registration navigation
  void _goToRegister() {
    // Navigate to the registration page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Register(),
      ),
    );
    print('Navigating to Registration Page...');
  }
  //call after sucessful login
  void _goToHome(){

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) =>  BottomNavigationBarPage()), (route) => false);

  }
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void _login() async {
    print(emailController.text);
    try{
      final credentials = await _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      _goToHome();
    }on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center form vertically
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Login" Header
                const Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 50),

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
                      hintText: 'Enter your secure password',
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle login functionality here
                     _login();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueAccent, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Login with Google Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: _loginWithGoogle,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.redAccent, // Google button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.login, color: Colors.white), // Google icon placeholder
                    label: const Text(
                      'Login with Google',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Forgot Password and Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        // Navigate to forgot password page
                        print('Forgot Password Pressed');
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Text(
                      '|',
                      style: TextStyle(color: Colors.white),
                    ),
                    // Register Here
                    TextButton(
                      onPressed: _goToRegister,
                      child: const Text(
                        'Register Here',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
