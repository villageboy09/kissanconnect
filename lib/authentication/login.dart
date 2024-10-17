// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _userIdController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String userId = _userIdController.text.trim();

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: userData,
        );
      } else {
        setState(() {
          _errorMessage = "User ID not found.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error logging in: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.leaf_arrow_circlepath, size: 100, color: CupertinoColors.activeGreen),
              const SizedBox(height: 20),
              const Text(
                'Farmer App',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              CupertinoTextField(
                controller: _userIdController,
                placeholder: 'User ID',
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(CupertinoIcons.person, color: CupertinoColors.systemGrey),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                ),
              const SizedBox(height: 20),
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}