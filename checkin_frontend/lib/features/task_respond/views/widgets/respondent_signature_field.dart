import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/user/user_profile.dart';

class RespondentSignatureField extends StatelessWidget {
  final UserProfile? auth;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const RespondentSignatureField({
    super.key,
    required this.auth,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (auth == null) {
      return TextField(
        controller: controller,
        maxLength: 25,
        decoration: const InputDecoration(
          labelText: "Your name / signature",
          hintText: "Sign yourself here",
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.person),
        ),
        inputFormatters: [LengthLimitingTextInputFormatter(50)],
        onChanged: (_) => onChanged(),
      );
    }

    return Card(
      color: Colors.blue.withAlpha(25),
      child: ListTile(
        leading: const Icon(Icons.verified_user, color: Colors.blue),
        title: Text("Signed as: ${auth!.name}"),
        subtitle: Text(auth!.email),
      ),
    );
  }
}