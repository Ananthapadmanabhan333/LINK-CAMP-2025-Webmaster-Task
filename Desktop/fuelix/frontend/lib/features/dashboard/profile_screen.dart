import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _bodyFatController = TextEditingController(); // Optional
  
  String _selectedGoal = 'Maintenance';
  String _activityLevel = 'Moderate';
  
  double _calories = 2500; // Default
  
  void _calculateMacros() {
    double weight = double.tryParse(_weightController.text) ?? 70;
    double height = double.tryParse(_heightController.text) ?? 175;
    int age = int.tryParse(_ageController.text) ?? 25;
    
    // Mifflin-St Jeor Equation (Male default for MVP)
    double bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    
    double multiplier = 1.2;
    if (_activityLevel == 'active') multiplier = 1.55;
    if (_activityLevel == 'athlete') multiplier = 1.9;
    
    double tdee = bmr * multiplier;
    
    if (_selectedGoal == 'Fat Loss') tdee -= 500;
    if (_selectedGoal == 'Muscle Gain') tdee += 300;
    
    setState(() {
      _calories = tdee;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Physical Stats"),
            Row(
              children: [
                Expanded(child: _buildInput("Height (cm)", _heightController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInput("Weight (kg)", _weightController)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildInput("Age", _ageController)),
                const SizedBox(width: 16),
                Expanded(child: _buildInput("Body Fat %", _bodyFatController)),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildSectionHeader("Goals & Lifestyle"),
            _buildDropdown("Goal", ["Fat Loss", "Maintenance", "Muscle Gain"], _selectedGoal, (val) {
              setState(() => _selectedGoal = val!);
            }),
            const SizedBox(height: 16),
            _buildDropdown("Activity Level", ["Sedentary", "Moderate", "Active", "Athlete"], _activityLevel, (val) {
              setState(() => _activityLevel = val!);
            }),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _calculateMacros,
                child: const Text("CALCULATE TARGETS"),
              ),
            ),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor),
              ),
              child: Column(
                children: [
                  const Text("Daily Calorie Target", style: TextStyle(color: Colors.grey)),
                  Text(
                    "${_calories.toStringAsFixed(0)} kcal",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      dropdownColor: AppTheme.surfaceColor,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: onChanged,
    );
  }
}
