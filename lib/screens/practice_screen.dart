import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parameter_categories_ui.dart';
import '../utils/theme.dart';
import '../notifiers/user_profile_notifier.dart';
import '../widgets/card_container.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final settings = userProfile.settings;
    // Get selected categories or use all if none selected
    final Map<String, bool> enabledCategories = settings.enabledCategories;
    final selectedCategories = enabledCategories.isEmpty 
        ? parameterCategories.map((c) => c.id).toSet()
        : enabledCategories.entries.where((e) => e.value == true).map((e) => e.key).toSet();
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Practice Mode',
          style: TextStyle(
            color: AppTheme.textBright,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textBright),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/menu'),
        ),
        actions: [
          // Category selection button
          IconButton(
            icon: const Icon(Icons.category, color: Colors.green),
            onPressed: () => _showCategorySelector(context, ref, selectedCategories),
            tooltip: 'Select Categories',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main game area
          const CardContainer(),
          
          // Practice mode indicator
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.school,
                      color: Colors.green,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'PRACTICE MODE',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Navigation buttons at the bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back to menu button
                _buildCircleButton(
                  Icons.home,
                  AppTheme.primaryNeon,
                  () => Navigator.of(context).pushReplacementNamed('/menu'),
                ),
                
                // Start normal game mode
                _buildPlayButton(context, ref),
                
                // Settings button
                _buildCircleButton(
                  Icons.settings,
                  AppTheme.secondaryNeon,
                  () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceDark,
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Navigate to the game screen with practice mode disabled
        Navigator.of(context).pushNamed(
          '/game',
          arguments: {'mode': 'normal'},
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.primaryNeon.withOpacity(0.6),
              AppTheme.primaryNeon.withOpacity(0.2),
            ],
            center: Alignment.center,
            radius: 0.8,
          ),
          border: Border.all(
            color: AppTheme.primaryNeon,
            width: 3,
          ),
          boxShadow: AppTheme.neonShadow(AppTheme.primaryNeon),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: AppTheme.textBright,
          size: 40,
        ),
      ),
    );
  }

  void _showCategorySelector(BuildContext context, WidgetRef ref, Set<String> selectedCategories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CategorySelectorSheet(
        selectedCategories: selectedCategories,
        onCategoriesChanged: (newCategories) {
          // Update user settings with new categories
          final notifier = ref.read(userProfileProvider.notifier);
          // Create a map of all parameter categories set to false initially
          Map<String, bool> updatedCategories = {};
          // Use parameter category UI objects which we have access to
          for (var category in parameterCategories) {
            updatedCategories[category.id] = false;
          }
          for (final categoryId in newCategories) {
            updatedCategories[categoryId] = true;
          }
          // Get current settings and update with new category map
          final currentSettings = ref.read(userProfileProvider).settings;
          notifier.updateSettings(
            currentSettings.copyWith(enabledCategories: updatedCategories),
          );
        },
      ),
    );
  }
}

class CategorySelectorSheet extends StatefulWidget {
  final Set<String> selectedCategories;
  final Function(Set<String>) onCategoriesChanged;

  const CategorySelectorSheet({
    Key? key,
    required this.selectedCategories,
    required this.onCategoriesChanged,
  }) : super(key: key);

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  late Set<String> _selectedCategories;
  
  @override
  void initState() {
    super.initState();
    _selectedCategories = Set.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SELECT CATEGORIES',
                style: TextStyle(
                  color: AppTheme.primaryNeon,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose which parameter categories to practice:',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ...parameterCategories.map((category) => _buildCategoryCheckbox(category)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategories = {};
                  });
                },
                child: const Text(
                  'CLEAR ALL',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCategories = parameterCategories.map((c) => c.id).toSet();
                  });
                },
                child: const Text(
                  'SELECT ALL',
                  style: TextStyle(
                    color: AppTheme.primaryNeon,
                  ),
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: () {
                widget.onCategoriesChanged(_selectedCategories);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNeon,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'APPLY',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCheckbox(ParameterCategory category) {
    final isSelected = _selectedCategories.contains(category.id);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(category.id);
          } else {
            _selectedCategories.add(category.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withOpacity(0.2) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? category.color : category.color.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              category.icon,
              color: isSelected ? category.color : category.color.withOpacity(0.5),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? AppTheme.textBright : AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedCategories.add(category.id);
                  } else {
                    _selectedCategories.remove(category.id);
                  }
                });
              },
              activeColor: category.color,
              checkColor: Colors.black,
              side: BorderSide(color: category.color.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
