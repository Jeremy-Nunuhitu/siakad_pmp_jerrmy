import 'package:flutter/material.dart';

void showAppMessage(BuildContext context, String? message) {
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String rupiahSafe(String value) => value.trim();
