import '../models/medical_models.dart';

class UnitConverter {
  // Converts a GameQuestion to a different unit system
  static GameQuestion convertQuestion(GameQuestion question, UnitSystem targetSystem) {
    // If already in target system, return the same question
    if (question.unitData.unitType == targetSystem) {
      return question;
    }
    
    // Try to get unit data for the target system
    final targetUnitData = question.parameter.getUnitData(
      targetSystem, 
      question.sexContext
    );
    
    // If no matching unit data is found, return original question
    if (targetUnitData == null) {
      return question;
    }
    
    // Convert the value to the target unit system
    double convertedValue;
    
    // If converting from SI to conventional or vice versa
    if (question.unitData.conversionFactorToPrimarySI != null && 
        targetUnitData.conversionFactorToPrimarySI != null) {
      // Convert to SI first (if not already in SI)
      final siValue = question.unitData.unitType == UnitSystem.si 
          ? question.value 
          : question.value * question.unitData.conversionFactorToPrimarySI!;
      
      // Then convert from SI to target (if target is not SI)
      convertedValue = targetSystem == UnitSystem.si 
          ? siValue 
          : siValue / targetUnitData.conversionFactorToPrimarySI!;
    } else {
      // If we don't have conversion factors, just use the same value
      // This is a fallback but might not be scientifically accurate
      convertedValue = question.value;
    }
    
    // Format the converted value to the appropriate precision
    String displayValue = _formatValue(convertedValue, targetUnitData.precision);
    
    // Create new GameQuestion with converted values
    return GameQuestion(
      parameter: question.parameter,
      value: convertedValue,
      unitData: targetUnitData,
      sexContext: question.sexContext,
      correctAnswer: question.correctAnswer,
      displayValue: displayValue,
    );
  }
  
  // Helper method to format a value according to precision
  static String _formatValue(double value, int precision) {
    if (precision == 0) {
      return value.round().toString();
    } else {
      return value.toStringAsFixed(precision);
    }
  }
}
