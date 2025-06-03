import 'package:flutter/material.dart';
import 'parameter_categories.dart';

/// Parameter category data model for UI rendering
class ParameterCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ParameterCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// List of parameter categories with UI properties
final List<ParameterCategory> parameterCategories = [
  ParameterCategory(
    id: ParameterCategories.electrolytesGases,
    name: ParameterCategories.getCategoryName(ParameterCategories.electrolytesGases),
    icon: Icons.bolt_outlined,
    color: Colors.blue,
  ),
  ParameterCategory(
    id: ParameterCategories.cbc,
    name: ParameterCategories.getCategoryName(ParameterCategories.cbc),
    icon: Icons.bloodtype_outlined,
    color: Colors.red,
  ),
  ParameterCategory(
    id: ParameterCategories.metabolic,
    name: ParameterCategories.getCategoryName(ParameterCategories.metabolic),
    icon: Icons.science_outlined,
    color: Colors.purple,
  ),
  ParameterCategory(
    id: ParameterCategories.liver,
    name: ParameterCategories.getCategoryName(ParameterCategories.liver),
    icon: Icons.filter_alt_outlined,
    color: Colors.amber,
  ),
  ParameterCategory(
    id: ParameterCategories.kidney,
    name: ParameterCategories.getCategoryName(ParameterCategories.kidney),
    icon: Icons.water_drop_outlined,
    color: Colors.teal,
  ),
  ParameterCategory(
    id: ParameterCategories.cardiac,
    name: ParameterCategories.getCategoryName(ParameterCategories.cardiac),
    icon: Icons.favorite_outline,
    color: Colors.pinkAccent,
  ),
  ParameterCategory(
    id: ParameterCategories.endocrine,
    name: ParameterCategories.getCategoryName(ParameterCategories.endocrine),
    icon: Icons.medication_outlined,
    color: Colors.greenAccent,
  ),
  ParameterCategory(
    id: ParameterCategories.toxicology,
    name: ParameterCategories.getCategoryName(ParameterCategories.toxicology),
    icon: Icons.warning_amber_outlined,
    color: Colors.orange,
  ),
  ParameterCategory(
    id: ParameterCategories.coagulation,
    name: ParameterCategories.getCategoryName(ParameterCategories.coagulation),
    icon: Icons.water_outlined,
    color: Colors.deepPurpleAccent,
  ),
  ParameterCategory(
    id: ParameterCategories.inflammatory,
    name: ParameterCategories.getCategoryName(ParameterCategories.inflammatory),
    icon: Icons.whatshot_outlined,
    color: Colors.redAccent,
  ),
];
