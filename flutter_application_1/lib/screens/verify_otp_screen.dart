import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../utils/app_colors.dart';
import '../utils/app_error.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_new_password_screen.dart'; // Import the new screen

class VerifyOTPScreen extends StatefulWidget {
  final String email;

  const VerifyOTPScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
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
          children: [_buildOTPCard()],
        ),
      ),
    );
  }

  Widget _buildOTPCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitle(),
          SizedBox(height: 16),
          _buildDescription(),
          SizedBox(height: 32),
          _buildOTPFields(),
          SizedBox(height: 24),
          _buildEmailInfo(),
          SizedBox(height: 32),
          _buildVerifyButton(),
          SizedBox(height: 20),
          _buildResendSection(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Verify OTP',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Enter the 6-digit code sent to email',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) => _buildOTPField(index)),
    );
  }

  Widget _buildOTPField(int index) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _controllers[index].text.isNotEmpty
              ? AppColors.accent
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
            }
          } else {
            if (index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          }
          setState(() {});
        },
        onTap: () {
          _controllers[index].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[index].text.length),
          );
        },
      ),
    );
  }

  Widget _buildEmailInfo() {
    return Text(
      'We have sent a password recovery\ninstructions to your email.',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary.withOpacity(0.6),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildVerifyButton() {
    return CustomButton(
      text: 'Verify OTP',
      onPressed: _handleVerifyOTP,
      isLoading: _isLoading,
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          'Resend available: ${_canResend ? 'Now' : '${_resendCountdown}s'}',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _canResend ? _handleResendOTP : null,
          child: Text(
            'Resend OTP',
            style: TextStyle(
              fontSize: 14,
              color: _canResend ? AppColors.accent : Colors.grey,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _handleVerifyOTP() async {
    String otp = _controllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ErrorDialog.show(
        context,
        'Please enter all 6 digits.',
        title: 'Incomplete OTP',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _verifyOTPRequest(otp);

      // Navigate to Create New Password screen instead of showing success dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateNewPasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      ErrorDialog.show(
        context,
        _getErrorMessage(e.toString()),
        title: 'Verification Failed',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleResendOTP() async {
    setState(() {
      _isLoading = true;
      _canResend = false;
      _resendCountdown = 60;
    });

    try {
      await _sendOTPRequest(widget.email);

      // Clear existing OTP fields
      for (var controller in _controllers) {
        controller.clear();
      }

      // Focus on first field
      _focusNodes[0].requestFocus();

      // Restart timer
      _startResendTimer();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP resent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ErrorDialog.show(
        context,
        'Failed to resend OTP. Please try again.',
        title: 'Resend Failed',
      );
      setState(() {
        _canResend = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOTPRequest(String otp) async {
    // Replace with your actual server IP/domain
    final String apiUrl = 'http://10.0.2.2:55553/verify/$otp';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('OTP verified successfully: ${responseData['message']}');
    } else if (response.statusCode == 400) {
      throw Exception('Invalid OTP');
    } else {
      throw Exception('Failed to verify OTP. Please try again.');
    }
  }

  Future<void> _sendOTPRequest(String email) async {
    // Replace with your actual server IP/domain
    final String apiUrl = 'http://192.168.1.100:8080/otp/$email';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('OTP sent successfully: ${responseData['message']}');
    } else {
      throw Exception('Failed to resend OTP');
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid OTP')) {
      return 'Invalid OTP code. Please check and try again.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Failed to verify OTP. Please try again.';
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
