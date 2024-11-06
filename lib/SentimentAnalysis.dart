import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';

class SentimentAnalysis {
  final String _baseUrl;

  SentimentAnalysis(this._baseUrl);

  Future<double> checkComment(String commentText) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': commentText}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['sentiment'];
    } else {
      throw Exception('Failed to check comment');
    }
  }
}