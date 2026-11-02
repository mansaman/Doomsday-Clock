class LifeExpectancyPredictor {
  /// Predicts life expectancy based on lifestyle factors.
  /// Base: 78 years (global average), adjusted by habits.
  static int predict({
    required int age,
    required bool smoker,
    required bool exercisesRegularly,
    required bool healthyDiet,
    required bool managesStress,
    String gender = 'unknown',
  }) {
    double base = 78.0;

    // Gender adjustment (statistical averages)
    if (gender == 'male') base -= 4;
    if (gender == 'female') base += 4;

    // Smoking: -10 years
    if (smoker) base -= 10;

    // Exercise: +5 years (if regular)
    if (exercisesRegularly) base += 5;

    // Healthy diet: +3 years
    if (healthyDiet) base += 3;

    // Stress management: +2 years
    if (managesStress) base += 2;

    // Age adjustment: older people have already survived riskier years
    if (age > 40) base += 1;
    if (age > 60) base += 2;

    // Clamp between 50 and 105
    return base.round().clamp(50, 105);
  }
}
