import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart' as profile_model;
import '../models/medical_models.dart';
import '../services/storage_service.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, profile_model.UserProfile>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<profile_model.UserProfile> {
  UserProfileNotifier() : super(profile_model.UserProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final medicalProfile = await StorageService.loadUserProfile();
    // Convert from medical_models.UserProfile to user_profile.UserProfile
    state = _convertFromMedicalProfile(medicalProfile);
  }
  
  // Helper method to convert from medical_models.UserProfile to user_profile.UserProfile
  profile_model.UserProfile _convertFromMedicalProfile(UserProfile medicalProfile) {
    return profile_model.UserProfile(
      hasCompletedOnboarding: medicalProfile.hasCompletedOnboarding,
      settings: profile_model.UserSettings(
        unitSystem: medicalProfile.settings.unitSystem == UnitSystem.si ? 
            profile_model.UnitSystem.si : profile_model.UnitSystem.conventional,
        sexContext: _convertSexContext(medicalProfile.settings.preferredSexContext),
        difficulty: _convertDifficulty(medicalProfile.settings.difficulty),
        soundEnabled: medicalProfile.settings.soundEnabled,
        autoMode: medicalProfile.settings.autoMode,
        enabledCategories: Map<String, bool>.fromEntries(
          medicalProfile.settings.enabledCategories.map(
            (category) => MapEntry(category, true)
          )
        ),
      ),
    );
  }
  
  // Helper method to convert from medical_models.UserProfile to user_profile.UserProfile
  UserProfile _convertToMedicalProfile(profile_model.UserProfile userProfile) {
    return UserProfile(
      highestStreak: 0, // Default values
      currentStreak: 0,
      hasCompletedOnboarding: userProfile.hasCompletedOnboarding,
      questionsAnswered: {},
      categoryProgress: {},
      lastPlayed: null,
      settings: GameSettings(
        unitSystem: userProfile.settings.unitSystem == profile_model.UnitSystem.si ?
            UnitSystem.si : UnitSystem.conventional,
        difficulty: _convertToParameterDifficulty(userProfile.settings.difficulty),
        preferredSexContext: _convertToMedicalSexContext(userProfile.settings.sexContext),
        soundEnabled: userProfile.settings.soundEnabled,
        autoMode: userProfile.settings.autoMode,
        enabledCategories: userProfile.settings.enabledCategories.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toSet(),
        practiceMode: false, // Default value
        preferredUnitSystem: userProfile.settings.unitSystem == profile_model.UnitSystem.si ?
            UnitSystem.si : UnitSystem.conventional,
      ),
    );
  }
  
  // Helper method to convert SexContext
  profile_model.SexContext _convertSexContext(SexContext sexContext) {
    switch (sexContext) {
      case SexContext.male:
        return profile_model.SexContext.male;
      case SexContext.female:
        return profile_model.SexContext.female;
      default:
        return profile_model.SexContext.general;
    }
  }
  
  SexContext _convertToMedicalSexContext(profile_model.SexContext sexContext) {
    switch (sexContext) {
      case profile_model.SexContext.male:
        return SexContext.male;
      case profile_model.SexContext.female:
        return SexContext.female;
      default:
        return SexContext.general;
    }
  }
  
  // Helper method to convert Difficulty
  profile_model.Difficulty _convertDifficulty(ParameterDifficulty difficulty) {
    switch (difficulty) {
      case ParameterDifficulty.easy:
        return profile_model.Difficulty.easy;
      case ParameterDifficulty.medium:
        return profile_model.Difficulty.medium;
      case ParameterDifficulty.hard:
        return profile_model.Difficulty.hard;
      default:
        return profile_model.Difficulty.medium;
    }
  }
  
  ParameterDifficulty _convertToParameterDifficulty(profile_model.Difficulty difficulty) {
    switch (difficulty) {
      case profile_model.Difficulty.easy:
        return ParameterDifficulty.easy;
      case profile_model.Difficulty.medium:
        return ParameterDifficulty.medium;
      case profile_model.Difficulty.hard:
        return ParameterDifficulty.hard;
    }
  }

  Future<void> saveProfile() async {
    // Convert from user_profile.UserProfile to medical_models.UserProfile before saving
    final medicalProfile = _convertToMedicalProfile(state);
    await StorageService.saveUserProfile(medicalProfile);
  }

  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
    saveProfile();
  }

  void updateSettings(profile_model.UserSettings settings) {
    state = state.copyWith(settings: settings);
    saveProfile();
  }

  void toggleCategoryEnabled(String categoryId, bool enabled) {
    final updatedCategories = Map<String, bool>.from(state.settings.enabledCategories);
    updatedCategories[categoryId] = enabled;
    
    final updatedSettings = state.settings.copyWith(
      enabledCategories: updatedCategories,
    );
    
    state = state.copyWith(settings: updatedSettings);
    saveProfile();
  }

  void resetProgress() {
    state = profile_model.UserProfile(
      hasCompletedOnboarding: state.hasCompletedOnboarding,
      settings: state.settings,
    );
    saveProfile();
  }

  void resetAllData() {
    state = profile_model.UserProfile();
    saveProfile();
  }
}
