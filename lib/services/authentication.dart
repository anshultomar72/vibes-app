import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AuthStatus{
    static const COMPLETE_PROFILE =1;
    static const INCOMPLETE_PROFILE =0;
}
class AuthService{

    Future<void> register({
        required String email,
        required String password,
        void Function()? onProcessing,
        void Function()? onProcessingDone,
        required void Function() onSuccess,
        void Function(String?)? onFailure,
    }) async {
        if (onProcessing != null) {
            onProcessing();
        }

        try {
            // Create user account
            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
            );

            // Get the user
            User? user = userCredential.user;

            if (user != null) {
                // Store user data in Firestore
                await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                    'email': email,
                });


                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('User_email', email);
                await prefs.setString('User_uid', user.uid);
                await prefs.setInt('profile_status', AuthStatus.INCOMPLETE_PROFILE);

                if (onProcessingDone != null) {
                    onProcessingDone();
                }
                onSuccess();
            } else {
                if (onFailure != null) {
                    onFailure('Failed to create user account.');
                }
            }
        } on FirebaseAuthException catch (e) {
            String errorMessage;
            if (e.code == 'email-already-in-use') {
                errorMessage = 'The account already exists for that email.';
            } else {
                errorMessage = e.message ?? 'An unknown error occurred.';
            }

            if (onFailure != null) {
                onFailure(errorMessage);
            }
        } catch (e) {
            if (onFailure != null) {
                onFailure(e.toString());
            }
        } finally {
            if (onProcessingDone != null) {
                onProcessingDone();
            }
        }
    }

    Future<void> completeProfile({
        required String phoneNumber,
        required String address,
        required String name,
        void Function()? onProcessing,
        void Function()? onProcessingDone,
        required void Function() onSuccess,
        void Function(String?)? onFailure,
    }) async {
        if (onProcessing != null) {
            onProcessing();
        }

        try {
            // Get the current user's UID from SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? uid = prefs.getString('User_uid');

            if (uid != null) {
                // Update user data in Firestore
                await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'phone': phoneNumber,
                    'address': address,
                    'name': name,
                });

                await prefs.setString('User_name', name);
                await prefs.setInt('profile_status', AuthStatus.COMPLETE_PROFILE);

                if (onProcessingDone != null) {
                    onProcessingDone();
                }
                onSuccess();
            } else {
                if (onFailure != null) {
                    onFailure('User UID not found in SharedPreferences.');
                }
            }
        } catch (e) {
            if (onFailure != null) {
                onFailure(e.toString());
            }
        } finally {
            if (onProcessingDone != null) {
                onProcessingDone();
            }
        }
    }
    Future<void> login({
        required String emailId,
        required String password,
        void Function()? onProcessing,
        void Function()? onProcessingDone,
        required void Function() onSuccess,
        void Function(String?)? onFailure,
    }) async {
        if (onProcessing != null) {
            onProcessing();
        }

        try {
            // Firebase authentication
            UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailId,
                password: password,
            );

            // Retrieve user info after successful login
            User? user = userCredential.user;
            if (user != null) {
                // Fetch user document from Firestore where document ID is user.uid
                DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                // Check if the document exists
                if (userDoc.exists) {
                    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

                    // Retrieve phone number and address from Firestore document
                    String? phoneNumber = userData['phone'];
                    String? address = userData['address'];
                    String name = userData['name'] ?? 'Unknown';

                    // Store data in SharedPreferences
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('User_email', emailId);
                    await prefs.setString('User_uid', user.uid);
                    await prefs.setString('User_name', name);
                    if (phoneNumber != null) {
                        await prefs.setString('User_phone', phoneNumber);
                    }
                    if (address != null) {
                        await prefs.setString('User_address', address);
                    }

                    // Check if phone number and address are present, set profile status
                    bool isProfileComplete = (phoneNumber != null && address != null);
                    if (isProfileComplete) {
                        await prefs.setInt('profile_status', AuthStatus.COMPLETE_PROFILE);
                    } else {
                        await prefs.setInt('profile_status', AuthStatus.INCOMPLETE_PROFILE);
                    }

                    // Call success callback after storing necessary information
                    if (onProcessingDone != null) {
                        onProcessingDone();
                    }
                    onSuccess();
                } else {
                    // User document not found in Firestore
                    if (onFailure != null) {
                        onFailure('User data not found.');
                    }
                }
            } else {
                // Handle case where the user is null (shouldn't happen if login is successful)
                if (onFailure != null) {
                    onFailure('User data is null after successful login');
                }
            }
        } on FirebaseAuthException catch (e) {
            // Handle Firebase specific errors (invalid email, wrong password, etc.)
            String errorMessage;
            if (e.code == 'user-not-found') {
                errorMessage = 'No user found for that email.';
            } else if (e.code == 'wrong-password') {
                errorMessage = 'Wrong password provided for that user.';
            } else {
                errorMessage = e.message ?? 'An unknown error occurred.';
            }

            if (onFailure != null) {
                onFailure(errorMessage);
            }
        } catch (e) {
            // General error handling for non-Firebase exceptions
            if (onFailure != null) {
                onFailure(e.toString());
            }
        } finally {
            if (onProcessingDone != null) {
                onProcessingDone();
            }
        }
    }

}