import '../models/medical_models.dart';
import 'all_medical_parameters.dart';
import 'parameter_categories.dart';

/// Manages the medical parameters throughout the application
/// Provides methods to access, filter, and organize parameters
class ParameterManager {
  // Singleton instance
  static final ParameterManager _instance = ParameterManager._internal();
  
  // Factory constructor
  factory ParameterManager() => _instance;
  
  // Internal constructor
  ParameterManager._internal();
  
  // Cache of parameters by category
  final Map<String, List<MedicalParameter>> _parametersByCategory = {};
  
  // Cache of parameters by difficulty
  final Map<ParameterDifficulty, List<MedicalParameter>> _parametersByDifficulty = {};
  
  // Initialize cache
  void initialize() {
    // Clear existing caches
    _parametersByCategory.clear();
    _parametersByDifficulty.clear();
    
    // Populate category cache
    for (final categoryId in ParameterCategories.categoryNames.keys) {
      _parametersByCategory[categoryId] = allMedicalParameters
          .where((param) => param.categoryID == categoryId)
          .toList();
    }
    
    // Populate difficulty cache
    for (final difficulty in ParameterDifficulty.values) {
      _parametersByDifficulty[difficulty] = allMedicalParameters
          .where((param) => param.difficulty == difficulty)
          .toList();
    }
  }
  
  // Get all parameters
  List<MedicalParameter> getAllParameters() {
    return allMedicalParameters;
  }
  
  // Get parameters by category
  List<MedicalParameter> getParametersByCategory(String categoryId) {
    if (_parametersByCategory.isEmpty) {
      initialize();
    }
    return _parametersByCategory[categoryId] ?? [];
  }
  
  // Get parameters by difficulty
  List<MedicalParameter> getParametersByDifficulty(ParameterDifficulty difficulty) {
    if (_parametersByDifficulty.isEmpty) {
      initialize();
    }
    return _parametersByDifficulty[difficulty] ?? [];
  }
  
  // Get parameters for a specific difficulty level and category
  List<MedicalParameter> getParametersByCategoryAndDifficulty(
      String categoryId, ParameterDifficulty difficulty) {
    return getParametersByCategory(categoryId)
        .where((param) => param.difficulty == difficulty)
        .toList();
  }
  
  // Get parameters suitable for a user's current level
  List<MedicalParameter> getParametersForUserLevel(
      int questionsAnswered, String preferredCategory) {
    // Determine appropriate difficulty based on questions answered
    ParameterDifficulty targetDifficulty;
    if (questionsAnswered < 20) {
      targetDifficulty = ParameterDifficulty.easy;
    } else if (questionsAnswered < 50) {
      targetDifficulty = ParameterDifficulty.medium;
    } else {
      targetDifficulty = ParameterDifficulty.hard;
    }
    
    // If user has a preferred category, prioritize that
    if (preferredCategory.isNotEmpty) {
      final categoryParams = getParametersByCategoryAndDifficulty(
          preferredCategory, targetDifficulty);
      
      // If we have enough parameters in the preferred category, use those
      if (categoryParams.length >= 10) {
        return categoryParams;
      }
    }
    
    // Otherwise, return all parameters at the target difficulty
    return getParametersByDifficulty(targetDifficulty);
  }
  
  // Get parameters by specific criteria
  List<MedicalParameter> getParametersByCriteria({
    String? categoryId,
    ParameterDifficulty? difficulty,
    bool? isProParameter,
    String? searchTerm,
  }) {
    // Start with all parameters
    List<MedicalParameter> filteredParameters = getAllParameters();
    
    // Apply category filter if specified
    if (categoryId != null) {
      filteredParameters = filteredParameters
          .where((param) => param.categoryID == categoryId)
          .toList();
    }
    
    // Apply difficulty filter if specified
    if (difficulty != null) {
      filteredParameters = filteredParameters
          .where((param) => param.difficulty == difficulty)
          .toList();
    }
    
    // Apply pro parameter filter if specified
    if (isProParameter != null) {
      filteredParameters = filteredParameters
          .where((param) => param.isProModuleParameter == isProParameter)
          .toList();
    }
    
    // Apply search term filter if specified
    if (searchTerm != null && searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      filteredParameters = filteredParameters
          .where((param) =>
              param.name.toLowerCase().contains(term) ||
              param.explanation.toLowerCase().contains(term))
          .toList();
    }
    
    return filteredParameters;
  }
  
  // Get parameter statistics
  Map<String, dynamic> getParameterStatistics() {
    if (_parametersByCategory.isEmpty || _parametersByDifficulty.isEmpty) {
      initialize();
    }
    
    final Map<String, int> countByCategory = {};
    final Map<ParameterDifficulty, int> countByDifficulty = {};
    int totalParameters = allMedicalParameters.length;
    int proParameters = 0;
    
    // Count parameters by category
    for (final entry in _parametersByCategory.entries) {
      countByCategory[entry.key] = entry.value.length;
    }
    
    // Count parameters by difficulty
    for (final entry in _parametersByDifficulty.entries) {
      countByDifficulty[entry.key] = entry.value.length;
    }
    
    // Count pro parameters
    proParameters = allMedicalParameters
        .where((param) => param.isProModuleParameter == true)
        .length;
    
    return {
      'totalParameters': totalParameters,
      'proParameters': proParameters,
      'byCategory': countByCategory,
      'byDifficulty': countByDifficulty,
    };
  }
}
