import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String _uuid ="";
  String _userName = "User";
  String _email = "";
  String _phone = "";
  String _profileImageUrl = "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png";
  List<String> _addresses = [];
  bool _isLoading = false;

  // Getters
  String get userName => _userName;
  String get user_uuid => _uuid;
  String get email => _email;
  String get phone => _phone;
  String get profileImageUrl => _profileImageUrl;
  List<String> get addresses => _addresses;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load user addresses from Firebase
  Future<void> fetchAddresses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('users')
          .doc(_uuid)
          .get();

      if (snapshot.exists && snapshot.data()!.containsKey('addresses')) {
        _addresses = List<String>.from(snapshot.data()!['addresses'] ?? []);
      } else {
        _addresses = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add new address
  Future<void> addAddress(String address) async {
    try {
      _isLoading = true;
      notifyListeners();

      _addresses.add(address);

      await _firestore
          .collection('users')
          .doc(_uuid)
          .update({'addresses': _addresses});

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update existing address
  Future<void> updateAddress(int index, String newAddress) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (index >= 0 && index < _addresses.length) {
        _addresses[index] = newAddress;

        await _firestore
            .collection('users')
            .doc(_uuid)
            .update({'addresses': _addresses});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete address
  Future<void> deleteAddress(int index) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (index >= 0 && index < _addresses.length) {
        _addresses.removeAt(index);

        await _firestore
            .collection('users')
            .doc(_uuid)
            .update({'addresses': _addresses});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  // Load user details from SharedPreferences
  Future<void> fetchUserDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('User_name') ?? "User";
    _uuid = prefs.getString('User_uid') ?? "";
    _email = prefs.getString('User_email') ?? "";
    _phone = prefs.getString('User_phone') ?? "";
    _profileImageUrl = prefs.getString('profile_url') ??
        "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png";

    notifyListeners(); // Notify all consumers of the change
  }

  // Update user details in SharedPreferences and notify listeners
  Future<void> updateUserDetails(String name, String phone, String profileUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('User_name', name);
    await prefs.setString('User_phone', phone);
    await prefs.setString('profile_url', profileUrl);

    // Update local variables
    _userName = name;
    _phone = phone;
    _profileImageUrl = profileUrl;

    notifyListeners();
  }
}
