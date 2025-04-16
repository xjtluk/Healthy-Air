// lib/widgets/feedback_dialog.dart
import 'package:flutter/material.dart';

class FeedbackDialog extends StatefulWidget {
  final Function(String) onSubmit;
  
  const FeedbackDialog({
    Key? key,
    required this.onSubmit,
  }) : super(key: key);
  
  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;
  
  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
  
  void _handleSubmit() {
    final feedback = _feedbackController.text.trim();
    
    if (feedback.isEmpty) {
      setState(() {
        _errorText = 'Please enter your feedback';
      });
      return;
    }
    
    if (feedback.length < 10) {
      setState(() {
        _errorText = 'Feedback is too short';
      });
      return;
    }
    
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    
    widget.onSubmit(feedback);
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Feedback'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please share your thoughts, suggestions, or report any issues you\'ve encountered with the app.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              hintText: 'Enter your feedback',
              border: const OutlineInputBorder(),
              errorText: _errorText,
            ),
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}