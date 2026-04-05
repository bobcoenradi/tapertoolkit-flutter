/// A single step in a computed taper schedule.
class TaperStep {
  final int stepNumber;
  final double dose;
  final double reductionPercent;
  final double reductionMg;

  const TaperStep({
    required this.stepNumber,
    required this.dose,
    required this.reductionPercent,
    required this.reductionMg,
  });
}

/// All the parameters the user provides to compute a schedule.
class TaperScheduleParams {
  final double startDose;
  final double targetDose;     // usually 0
  final String reductionType;  // 'fixed_percent', 'hyperbolic', 'custom'
  final double primaryPercent; // e.g. 10
  final double? switchAtDose;  // switch to finer % below this dose (hyperbolic)
  final double? secondaryPercent; // e.g. 5 below switchAtDose
  final int intervalDays;      // days between each step

  const TaperScheduleParams({
    required this.startDose,
    this.targetDose = 0,
    this.reductionType = 'fixed_percent',
    this.primaryPercent = 10,
    this.switchAtDose,
    this.secondaryPercent,
    this.intervalDays = 14,
  });

  List<TaperStep> compute() {
    final steps = <TaperStep>[];
    double dose = startDose;
    int stepNum = 0;

    while (dose > targetDose + 0.01) {
      stepNum++;
      final pct = (switchAtDose != null && dose <= switchAtDose! && secondaryPercent != null)
          ? secondaryPercent!
          : primaryPercent;

      final reduction = dose * (pct / 100);
      final nextDose = (dose - reduction).clamp(targetDose, double.infinity);

      steps.add(TaperStep(
        stepNumber: stepNum,
        dose: dose,
        reductionPercent: pct,
        reductionMg: _round(reduction),
      ));

      dose = _round(nextDose);

      // Safety: never more than 200 steps
      if (stepNum >= 200) break;
    }

    // Add final 0 step if target is 0
    if (targetDose == 0 && steps.isNotEmpty) {
      final last = steps.last;
      steps.add(TaperStep(
        stepNumber: stepNum + 1,
        dose: 0,
        reductionPercent: last.reductionPercent,
        reductionMg: last.dose,
      ));
    }

    return steps;
  }

  static double _round(double v) => (v * 100).round() / 100;
}
