import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/preference_manager.dart';
import '../../data/models/user_data.dart';
import 'macro_indicator.dart';

class DailyTracker extends StatefulWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const DailyTracker({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  State<DailyTracker> createState() => _DailyTrackerState();
}

class _DailyTrackerState extends State<DailyTracker> {
  UserData? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final prefManager = PreferenceManager(prefs);
    userData = prefManager.getUserData();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final targetCalories = userData?.estimatedCalories?.toDouble() ?? 2000.0;
    
    // --- สร้างตัวแปรเช็คว่ากินเกินเป้าหรือยัง ---
    final bool isOverLimit = widget.calories > targetCalories;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Daily Calorie Goal: ${userData?.estimatedCalories ?? 2000} kcal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 24), 

          // --- ส่วนแสดงผลตัวเลข ---
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department, 
                // ถ้าเกินเป้า ให้ไอคอนเป็นสีแดงด้วย (ถ้าอยากให้ไอคอนส้มตลอด ลบเงื่อนไขนี้ได้ครับ)
                color: isOverLimit ? Colors.red : Colors.orange, 
                size: 48, 
              ),
              SizedBox(height: 8),
              Text(
                '${widget.calories.toInt()}', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40, 
                  // --- เงื่อนไขเปลี่ยนสีตัวเลข ---
                  color: isOverLimit ? Colors.red : Colors.black87, 
                ),
              ),
              Text(
                'kcal consumed', 
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          // --- จบส่วนแสดงผลตัวเลข ---

          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              MacroIndicator(
                label: 'Protein',
                value: widget.protein,
                goal: (userData?.proteinGoal ?? 0).toDouble(),
                color: Colors.green,
              ),
              MacroIndicator(
                label: 'Fats',
                value: widget.fat,
                goal: (userData?.fatGoal ?? 0).toDouble(),
                color: Colors.orange,
              ),
              MacroIndicator(
                label: 'Carbs',
                value: widget.carbs,
                goal: (userData?.carbsGoal ?? 0).toDouble(),
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }
}