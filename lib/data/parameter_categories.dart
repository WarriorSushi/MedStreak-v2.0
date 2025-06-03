import '../models/medical_models.dart';

/// Defines all available parameter categories in the application
class ParameterCategories {
  // Define category IDs as constants for consistent reference
  static const String electrolytesGases = 'electrolytes_gases';
  static const String cbc = 'cbc';
  static const String metabolic = 'metabolic';
  static const String liver = 'liver';
  static const String kidney = 'kidney';
  static const String cardiac = 'cardiac';
  static const String endocrine = 'endocrine';
  static const String toxicology = 'toxicology';
  static const String coagulation = 'coagulation';
  static const String inflammatory = 'inflammatory';
  
  // Map of category IDs to their display names
  static const Map<String, String> categoryNames = {
    electrolytesGases: 'Electrolytes & Blood Gases',
    cbc: 'Complete Blood Count',
    metabolic: 'Metabolic',
    liver: 'Liver Function',
    kidney: 'Kidney Function',
    cardiac: 'Cardiac Markers',
    endocrine: 'Endocrine',
    toxicology: 'Toxicology',
    coagulation: 'Coagulation',
    inflammatory: 'Inflammatory Markers',
  };
  
  // Get all available categories
  static List<Map<String, dynamic>> getAllCategories() {
    return categoryNames.entries.map((entry) => {
      'id': entry.key,
      'name': entry.value,
    }).toList();
  }
  
  // Get category name from ID
  static String getCategoryName(String categoryId) {
    return categoryNames[categoryId] ?? 'Unknown Category';
  }
}

/// Utility class to filter medical parameters by various criteria
class ParameterFilters {
  // Filter parameters by category
  static List<MedicalParameter> filterByCategory(List<MedicalParameter> parameters, String categoryId) {
    return parameters.where((param) => param.categoryID == categoryId).toList();
  }
  
  // Filter parameters by difficulty
  static List<MedicalParameter> filterByDifficulty(List<MedicalParameter> parameters, ParameterDifficulty difficulty) {
    return parameters.where((param) => param.difficulty == difficulty).toList();
  }
  
  // Filter parameters by whether they are Pro module parameters
  static List<MedicalParameter> filterByProStatus(List<MedicalParameter> parameters, bool isProOnly) {
    return parameters.where((param) => param.isProModuleParameter == isProOnly).toList();
  }
  
  // Get all parameters in a specified difficulty range (inclusive)
  static List<MedicalParameter> getParametersInDifficultyRange(
    List<MedicalParameter> parameters, 
    ParameterDifficulty minDifficulty, 
    ParameterDifficulty maxDifficulty
  ) {
    return parameters.where((param) => 
      param.difficulty.index >= minDifficulty.index && 
      param.difficulty.index <= maxDifficulty.index
    ).toList();
  }
  
  // Search parameters by name or explanation
  static List<MedicalParameter> searchParameters(List<MedicalParameter> parameters, String query) {
    final lowercaseQuery = query.toLowerCase();
    return parameters.where((param) => 
      param.name.toLowerCase().contains(lowercaseQuery) || 
      param.explanation.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Get count of parameters by category
  static Map<String, int> getParameterCountByCategory(List<MedicalParameter> parameters) {
    final Map<String, int> counts = {};
    for (final param in parameters) {
      counts[param.categoryID] = (counts[param.categoryID] ?? 0) + 1;
    }
    return counts;
  }
  
  // Get count of parameters by difficulty
  static Map<ParameterDifficulty, int> getParameterCountByDifficulty(List<MedicalParameter> parameters) {
    final Map<ParameterDifficulty, int> counts = {};
    for (final param in parameters) {
      counts[param.difficulty] = (counts[param.difficulty] ?? 0) + 1;
    }
    return counts;
  }
}
