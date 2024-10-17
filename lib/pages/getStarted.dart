import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vibes_app/pages/login.dart';

import 'BottomNavigationBar.dart';
import 'homePage.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
                "assets/images/bg.png",
                  fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => const Login(),
                      ),
                      );

                    },
                    child: Text('Get Started'),
                  style:  ElevatedButton.styleFrom(
                    // Change button size (minimum width and height)
                    minimumSize: Size(150, 50), // Width: 150, Height: 50
                    // Change padding inside the button
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    // Customize border radius
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 20px radius
                    ),
                    textStyle: TextStyle(
                      fontSize: 20,

                    ),
                  ),
                ),
              ),
            )
          ],
        ),
    );
  }
}
