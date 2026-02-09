import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/app_theme.dart';
import '../../services/recovery_service.dart';
import '../../services/haptic_service.dart';
import '../../models/injury_model.dart';
import 'log_injury_modal.dart';
import 'package:google_fonts/google_fonts.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final RecoveryService _recoveryService = RecoveryService();
  RecoveryStatus? _status;
  List<Injury> _injuries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final status = await _recoveryService.getRecoveryStatus();
    final injuries = await _recoveryService.getActiveInjuries();
    
    if (mounted) {
      setState(() {
        _status = status;
        _injuries = injuries;
        _isLoading = false;
      });
    }
  }

  void _showLogInjuryModal() {
    HapticService().selection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogInjuryModal(onSaved: _fetchData),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLogInjuryModal,
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
        label: const Text("Log Issue"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReadinessCard(),
            const SizedBox(height: 32),
            Text("ACTIVE ISSUES", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildInjuriesList(),
            const SizedBox(height: 32),
            if (_injuries.isNotEmpty) _buildRehabSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadinessCard() {
    int score = _status?.score ?? 100;
    Color color = score > 80 ? AppTheme.successColor : (score > 40 ? AppTheme.primaryColor : AppTheme.accentColor);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("READINESS", style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text("${score}%", style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              Icon(Icons.health_and_safety, size: 48, color: color.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            _status?.status ?? "Prime",
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (_status?.breakdown != null && _status!.breakdown.isNotEmpty)
            ..._status!.breakdown.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.arrow_right, color: AppTheme.textSecondary, size: 16),
                  Text(e, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            )),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildInjuriesList() {
    if (_injuries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: const Center(
          child: Text(
            "No active injuries. Stay hard!", 
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: _injuries.map((injury) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  injury.bodyPart.toUpperCase(), 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Pain: ${injury.painLevel}/10", 
                    style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${injury.severity} ${injury.injuryType} - ${injury.status}",
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildRehabSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("RECOMMENDED THERAPY", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.secondaryColor.withOpacity(0.2), AppTheme.backgroundColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.accessibility_new, color: AppTheme.secondaryColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mobility & Activation",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Targeted relief for ${_injuries.map((i) => i.bodyPart).join(', ')}",
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: const Text("START"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
