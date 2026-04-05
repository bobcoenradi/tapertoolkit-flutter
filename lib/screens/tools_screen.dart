import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../models/taper_schedule_model.dart';
import '../services/firestore_service.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  // Calculator inputs
  final _startDoseCtrl = TextEditingController();
  final _targetDoseCtrl = TextEditingController(text: '0');
  double _primaryPercent = 10;
  bool _useHyperbolic = false;
  double _switchAtDose = 5;
  double _secondaryPercent = 5;
  int _intervalDays = 14;
  bool _crossTaper = false;

  List<TaperStep> _schedule = [];
  bool _scheduleVisible = false;

  // Chart data from Firestore
  List<Map<String, dynamic>> _doseLog = [];

  @override
  void initState() {
    super.initState();
    _loadDoseLog();
  }

  @override
  void dispose() {
    _startDoseCtrl.dispose();
    _targetDoseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoseLog() async {
    final log = await FirestoreService.fetchDoseLog();
    if (mounted) setState(() => _doseLog = log);
  }

  void _computeSchedule() {
    final startDose = double.tryParse(_startDoseCtrl.text);
    final targetDose = double.tryParse(_targetDoseCtrl.text) ?? 0;
    if (startDose == null || startDose <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid starting dose'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final params = TaperScheduleParams(
      startDose: startDose,
      targetDose: targetDose,
      primaryPercent: _primaryPercent,
      switchAtDose: _useHyperbolic ? _switchAtDose : null,
      secondaryPercent: _useHyperbolic ? _secondaryPercent : null,
      intervalDays: _intervalDays,
    );

    setState(() {
      _schedule = params.compute();
      _scheduleVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildProgressChart()),
            SliverToBoxAdapter(child: _buildCrossTaperToggle()),
            SliverToBoxAdapter(child: _buildQuote()),
            SliverToBoxAdapter(child: _buildCalculator()),
            if (_scheduleVisible) SliverToBoxAdapter(child: _buildScheduleTable()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildBeforeYouBegin()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Journey', style: AppTextStyles.h4(color: AppColors.primary)),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    final hasData = _doseLog.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Taper Progress', style: AppTextStyles.h3()),
                    Text('Your current trajectory towards stability.', style: AppTextStyles.body()),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Current\nDose', style: AppTextStyles.caption(), textAlign: TextAlign.right),
                    Text(
                      hasData ? '${(_doseLog.last['dose'] as num).toStringAsFixed(1)}mg' : '—',
                      style: AppTextStyles.h3(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: hasData
                  ? LineChart(_buildChartData())
                  : Center(child: Text('Log your first dose to see progress', style: AppTextStyles.body())),
            ),
            if (hasData)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('START', style: AppTextStyles.caption()),
                    Text('TODAY', style: AppTextStyles.caption()),
                    Text('TARGET', style: AppTextStyles.caption()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChartData() {
    final spots = _doseLog.asMap().entries.map((e) {
      final dose = (e.value['dose'] as num).toDouble();
      return FlSpot(e.key.toDouble(), dose);
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (s, p, bar, i) => FlDotCirclePainter(
              radius: 3,
              color: AppColors.primary,
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildCrossTaperToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cross Taper', style: AppTextStyles.h4()),
                  const SizedBox(height: 4),
                  Text(
                    'Switching medications safely with overlapping schedules. Consult your toolkit guide.',
                    style: AppTextStyles.body(),
                  ),
                ],
              ),
            ),
            Switch(
              value: _crossTaper,
              onChanged: (v) => setState(() => _crossTaper = v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuote() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Text(
          '"Your body is unique. It\'s okay to go slow. Stability is the priority over speed."',
          style: AppTextStyles.body(color: AppColors.textDark).copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildCalculator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Taper Calculator', style: AppTextStyles.h3()),
            const SizedBox(height: 4),
            Text('Calculate your reduction schedule', style: AppTextStyles.body()),
            const SizedBox(height: 20),

            Text('Starting Dose (mg)', style: AppTextStyles.label()),
            const SizedBox(height: 6),
            _inputRow(_startDoseCtrl, 'e.g. 20mg'),
            const SizedBox(height: 16),

            Text('Target Dose (mg)', style: AppTextStyles.label()),
            const SizedBox(height: 6),
            _inputRow(_targetDoseCtrl, '0'),
            const SizedBox(height: 16),

            Text('Reduction: ${_primaryPercent.round()}% per step', style: AppTextStyles.label()),
            Slider(
              value: _primaryPercent,
              min: 2,
              max: 25,
              divisions: 23,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _primaryPercent = v),
            ),

            Text('Interval: $_intervalDays days between steps', style: AppTextStyles.label()),
            Slider(
              value: _intervalDays.toDouble(),
              min: 7,
              max: 28,
              divisions: 21,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _intervalDays = v.round()),
            ),

            // Hyperbolic option
            Row(
              children: [
                Switch(value: _useHyperbolic, onChanged: (v) => setState(() => _useHyperbolic = v), activeColor: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('Switch to finer % below a threshold dose (hyperbolic)', style: AppTextStyles.body())),
              ],
            ),
            if (_useHyperbolic) ...[
              const SizedBox(height: 12),
              Text('Switch below: ${_switchAtDose.toStringAsFixed(1)}mg', style: AppTextStyles.label()),
              Slider(value: _switchAtDose, min: 1, max: 20, divisions: 38, activeColor: AppColors.primaryLight, onChanged: (v) => setState(() => _switchAtDose = v)),
              Text('Fine reduction: ${_secondaryPercent.round()}%', style: AppTextStyles.label()),
              Slider(value: _secondaryPercent, min: 1, max: 10, divisions: 9, activeColor: AppColors.primaryLight, onChanged: (v) => setState(() => _secondaryPercent = v)),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _computeSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Calculate Schedule', style: AppTextStyles.label(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.body(color: AppColors.textLight),
          border: InputBorder.none,
        ),
        style: AppTextStyles.body(color: AppColors.textDark),
      ),
    );
  }

  Widget _buildScheduleTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: AppDecorations.card(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Taper Schedule', style: AppTextStyles.h4()),
            const SizedBox(height: 8),
            Text('${_schedule.length} steps total', style: AppTextStyles.body()),
            const SizedBox(height: 12),
            // Header
            Row(
              children: [
                _th('Step', flex: 1),
                _th('Dose', flex: 2),
                _th('Reduction', flex: 2),
                _th('Day', flex: 2),
              ],
            ),
            const Divider(color: AppColors.border),
            ..._schedule.take(20).map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  _td('${step.stepNumber}', flex: 1),
                  _td('${step.dose}mg', flex: 2),
                  _td('-${step.reductionMg}mg (${step.reductionPercent.round()}%)', flex: 2),
                  _td('Day ${(step.stepNumber - 1) * _intervalDays + 1}', flex: 2),
                ],
              ),
            )),
            if (_schedule.length > 20)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('+ ${_schedule.length - 20} more steps…', style: AppTextStyles.body()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _th(String text, {required int flex}) => Expanded(flex: flex, child: Text(text, style: AppTextStyles.caption(color: AppColors.textLight).copyWith(letterSpacing: 0.5)));
  Widget _td(String text, {required int flex}) => Expanded(flex: flex, child: Text(text, style: AppTextStyles.body(color: AppColors.textDark)));

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Expanded(child: _ActionCard(icon: Icons.slow_motion_video_outlined, iconColor: AppColors.info, title: 'Slow Taper', subtitle: 'Extend intervals for smoother adjustment.')),
          const SizedBox(width: 12),
          Expanded(child: _ActionCard(icon: Icons.pause_circle_outline_rounded, iconColor: AppColors.warning, title: 'Hold Taper', subtitle: 'Maintain current dose to stabilise symptoms.')),
        ],
      ),
    );
  }

  Widget _buildBeforeYouBegin() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: AppDecorations.card(color: AppColors.primarySoft),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text('Before you begin, consider...', style: AppTextStyles.h3()),
              ],
            ),
            const SizedBox(height: 16),
            ...[
              ('The Support Network', 'Ensure a trusted friend or professional is aware of your schedule change today.'),
              ('Lifestyle Baseline', 'Maintaining consistent sleep and hydration patterns will help isolate taper effects.'),
              ('Symptom Journaling', 'Use the \'Journey\' tab daily to record even subtle shifts in your mood signature.'),
            ].map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 32, height: 2, color: AppColors.primary, margin: const EdgeInsets.only(bottom: 6)),
                  Text(item.$1, style: AppTextStyles.label(color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(item.$2, style: AppTextStyles.body()),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _ActionCard({required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.label(color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall()),
        ],
      ),
    );
  }
}
