import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildRegisterCard()],
        ),
      ),
    );
  }

  Widget _buildRegisterCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            SizedBox(height: 20),
            _buildSurnameField(),
            SizedBox(height: 20),
            _buildEmailField(),
            SizedBox(height: 20),
            _buildPasswordField(),
            SizedBox(height: 20),
            _buildConfirmPasswordField(),
            SizedBox(height: 32),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomTextField(
      label: 'Name',
      hintText: 'Enter your first name',
      controller: _nameController,
    );
  }

  Widget _buildSurnameField() {
    return CustomTextField(
      label: 'Surname',
      hintText: 'Enter your last name',
      controller: _surnameController,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email',
      hintText: 'Enter your email address',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Password',
      hintText: 'Enter your password',
      controller: _passwordController,
      isPassword: true,
      showPasswordToggle: true,
    );
  }

  Widget _buildConfirmPasswordField() {
    return CustomTextField(
      label: 'Confirm Password',
      hintText: 'Confirm your password',
      controller: _confirmPasswordController,
      isPassword: true,
      showPasswordToggle: true,
    );
  }

  Widget _buildRegisterButton() {
    return CustomButton(
      text: 'Register',
      onPressed: _isLoading ? null : _handleRegister,
      isLoading: _isLoading,
    );
  }

  void _handleRegister() async {
    // Validate all fields are filled
    if (!_validateFields()) {
      return;
    }

    // Validate passwords match
    if (!_validatePasswordsMatch()) {
      return;
    }

    // Validate email format
    if (!_validateEmail()) {
      return;
    }

    // Validate password strength
    if (!_validatePasswordStrength()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      String uid = userCredential.user!.uid;

      // Store additional user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'permissions': ['read', 'write'],
        'name': _nameController.text.trim(),
        'surname': _surnameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Update user profile with display name
      await userCredential.user!.updateDisplayName(
        '${_nameController.text.trim()} ${_surnameController.text.trim()}',
      );

      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorDialog.show(
          context,
          _getErrorMessage(e.toString()),
          title: 'Registration Error',
        );
        print("🚀🚀 " + e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateFields() {
    if (_nameController.text.trim().isEmpty ||
        _surnameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ErrorDialog.show(
        context,
        "Please fill in all fields",
        title: 'Validation Error',
      );
      return false;
    }
    return true;
  }

  bool _validatePasswordsMatch() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ErrorDialog.show(
        context,
        "Passwords do not match",
        title: 'Validation Error',
      );
      return false;
    }
    return true;
  }

  bool _validateEmail() {
    String email = _emailController.text.trim();
    bool emailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);

    if (!emailValid) {
      ErrorDialog.show(
        context,
        "Please enter a valid email address",
        title: 'Validation Error',
      );
      return false;
    }
    return true;
  }

  bool _validatePasswordStrength() {
    String password = _passwordController.text;

    if (password.length < 6) {
      ErrorDialog.show(
        context,
        "Password must be at least 6 characters long",
        title: 'Validation Error',
      );
      return false;
    }

    // Optional: Add more password strength requirements
    // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
    //   ErrorDialog.show(
    //     context,
    //     "Password must contain at least one uppercase letter, one lowercase letter, and one number",
    //     title: 'Validation Error',
    //   );
    //   return false;
    // }

    return true;
  }

  String _getErrorMessage(String error) {
    if (error.contains('weak-password')) {
      return 'The password provided is too weak.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists for this email address.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many requests. Please try again later.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return 'Registration failed. Please try again.';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
