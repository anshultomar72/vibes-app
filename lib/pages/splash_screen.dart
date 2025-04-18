import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibes_app/pages/getStarted.dart';
import '../services/authentication.dart';
import 'BottomNavigationBar.dart';
import 'completeProfile.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _redirect();  // Call redirection here for better timing
  }

  Future<void> _redirect() async {
    // redirects user to corresponding pages depending on Sign-In status
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    AuthService authService = AuthService();

    int signInStatus = await authService.checkSignInStatus();
    if (!mounted) {
      return;
    }


    else if (signInStatus==AuthStatus.NOT_SIGNED_IN) {
      debugPrint(prefs.getKeys().toString());
      Navigator.of(context).pushReplacement(

          MaterialPageRoute(builder: (BuildContext context)=>const GetStarted())
      );
    }
    else if(signInStatus==AuthStatus.INCOMPLETE_PROFILE){
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context)=>const CompleteProfilePage())
      );
    }
    else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context)=>const BottomNavigationBarPage())
      );
    }

    await Future.delayed(const Duration(seconds: 10));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/vibes_logo.png',
                  width: constraints.maxWidth * 0.25,
                ),
                const SizedBox(height: 20),
                CircularProgressIndicator(color: Colors.orange.shade600),
              ],
            ),
          );
        },
      ),
    );
  }
}