import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_error.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: AppColors.cardBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildForgotPasswordCard()],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          SizedBox(height: 16),
          _buildDescription(),
          SizedBox(height: 32),
          _buildEmailField(),
          SizedBox(height: 32),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'Reset Password',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Enter the email associated with your account and we\'ll send an email with instructions to reset your password.',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary.withOpacity(0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email',
      hintText: 'Email',
      controller: _emailController,
    );
  }

  Widget _buildSendButton() {
    return CustomButton(
      text: 'Send Instructions',
      onPressed: _handleSendInstructions,
      isLoading: _isLoading,
    );
  }

  void _handleSendInstructions() async {
    if (_emailController.text.trim().isEmpty) {
      ErrorDialog.show(
        context,
        'Please enter your email address.',
        title: 'Email Required',
      );
      return;
    }

    if (!_isValidEmail(_emailController.text.trim())) {
      ErrorDialog.show(
        context,
        'Please enter a valid email address.',
        title: 'Invalid Email',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _sendOTPRequest(_emailController.text.trim());

      // Navigate to OTP verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VerifyOTPScreen(email: _emailController.text.trim()),
        ),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      ErrorDialog.show(context, _getErrorMessage(e.toString()), title: 'Error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Future<void> _sendOTPRequest(String email) async {
    print('Sending OTP request for email: $email');
    final String apiUrl = 'http://10.0.2.2:55553/otp/$email';
    print('API URL: $apiUrl');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    // FIXED: Print actual response details instead of the object
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('OTP sent successfully: ${responseData['message']}');
      // Handle successful response
    } else if (response.statusCode == 400) {
      print('400 Error - Response body: ${response.body}');
      throw Exception('Invalid email address');
    } else if (response.statusCode == 500) {
      print('500 Error - Response body: ${response.body}');
      throw Exception('Failed to send OTP email');
    } else {
      print('Unexpected status ${response.statusCode} - Response body: ${response.body}');
      throw Exception('❌Failed to send OTP. Please try again.');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid email address')) {
      return 'Invalid email address provided.';
    } else if (error.contains('Failed to send OTP email')) {
      return 'Failed to send OTP email. Please try again.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Failed to send reset instructions. Please try again.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
