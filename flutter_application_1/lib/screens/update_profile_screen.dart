// lib/screens/update_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class UpdateProfileScreen extends StatefulWidget {
  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  User? currentUser;
  File? _selectedImage;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            _firstNameController.text = userData['firstName'] ?? '';
            _lastNameController.text = userData['lastName'] ?? '';
            _profileImageUrl = userData['profileImageUrl'];
          });
        } else {
          String displayName = currentUser!.displayName ?? '';
          List<String> nameParts = displayName.split(' ');
          setState(() {
            _firstNameController.text = nameParts.isNotEmpty
                ? nameParts[0]
                : '';
            _lastNameController.text = nameParts.length > 1
                ? nameParts.sublist(1).join(' ')
                : '';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar('Error picking image: $e', Colors.red);
    }
  }

  Future<String?> _saveImageLocally() async {
    if (_selectedImage == null) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${currentUser!.uid}.jpg';
      final String newPath = path.join(directory.path, fileName);
      final File newImage = await _selectedImage!.copy(newPath);
      return newImage.path;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.trim().isEmpty) {
      _showSnackBar('First name is required', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _profileImageUrl;

      if (_selectedImage != null) {
        imageUrl = await _saveImageLocally();
        if (imageUrl == null) {
          _showSnackBar('Failed to save image', Colors.red);
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      String fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
              .trim();
      await currentUser!.updateDisplayName(fullName);

      // Update Firestore
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': currentUser!.email,
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnackBar('Profile updated successfully!', Colors.green);
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Error updating profile: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Color(0xFFD4A574), width: 3),
          color: Colors.grey[100],
        ),
        child: _selectedImage != null
            ? ClipOval(
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                ),
              )
            : _profileImageUrl != null
            ? ClipOval(
                child: Image.file(
                  File(_profileImageUrl!),
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey[600],
                    );
                  },
                ),
              )
            : Icon(Icons.person, size: 60, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Color(0xFFD4A574)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFD4A574), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Update Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildProfileImage(),
            SizedBox(height: 8),
            Text(
              'Tap to change photo',
              style: TextStyle(
                color: Color(0xFFD4A574),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 40),
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline,
              required: true,
            ),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD4A574),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'Update Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
