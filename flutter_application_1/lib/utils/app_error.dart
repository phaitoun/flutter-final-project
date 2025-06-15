import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String message;
  final String title;

  const ErrorDialog({Key? key, required this.message, this.title = 'Error'})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 24),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'OK',
            style: TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Static method to show the dialog easily
  static void show(BuildContext context, String message, {String? title}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(message: message, title: title ?? 'Error');
      },
    );
  }
}
