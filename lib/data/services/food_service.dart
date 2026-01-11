import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../models/food_item.dart';

class FoodService {
  final String _model = 'gemini-1.5-pro';

  // Load the API key from the environment
  String get _apiKey => dotenv.env['GOOGLE_AI_API_KEY'] ?? '';

  // Initialize Gemini in the constructor
  FoodService() {
    if (_apiKey.isEmpty) {
      throw Exception('Google AI API key not found in environment variables');
    }

    // Initialize the Gemini instance
    Gemini.init(apiKey: _apiKey);
  }
  Future<Either<String, FoodItem>> detectFoodAndCalories(File imageFile) async {
    try {
      if (!imageFile.existsSync()) {
        return Left('File not found: ${imageFile.path}');
      }

      final response = await Gemini.instance.textAndImage(
        text: 'Analyze this image and identify the food.'
            'Count how many pieces/servings of the food are visible in the image.'
            'Estimate calories, protein, carbs, and fat for a standard serving size,'
            'then MULTIPLY the values by the number of pieces detected.'
            'The "name" field MUST be written in Thai language only and include the quantity (number of pieces).'
            'The "calories", "protein", "carbs", and "fat" values MUST represent the TOTAL amount for all pieces combined.'
            'Return ONLY raw JSON.'
            'Do not use Markdown formatting.'
            'Do not use code blocks.'
            'Do not add any explanation.'
            'JSON Format:'
            '{"name":"ชื่ออาหารภาษาไทย (จำนวน X ชิ้น)","calories":0,"protein":0,"carbs":0,"fat":0}',
        images: [imageFile.readAsBytesSync()],
      );

      final output = response?.output;
      if (output == null || output.isEmpty) {
        return Left('No response output from Gemini API');
      }

      final match = RegExp(r'\{.*\}').firstMatch(output);
      if (match == null) {
        return Left('No valid JSON found in output: $output');
      }

      final foodData = jsonDecode(match.group(0)!);

      return Right(FoodItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: foodData['name'],
        calories: foodData['calories'].toDouble(),
        protein: foodData['protein'].toDouble(),
        carbs: foodData['carbs'].toDouble(),
        fat: foodData['fat'].toDouble(),
        quantity: 100.0,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      return Left('Failed to detect food: ${e.toString()}');
    }
  }
}
