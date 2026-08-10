import 'package:flutter/material.dart';

/// Drawer section grouping for the MeMy sidebar IA.
enum SidebarSectionId { account, primary, lifeAreas, connections, trustHelp }

/// How a sidebar destination should be presented.
enum SidebarAvailability { available, demo, planned, unavailable }

/// A single navigable (or planned) item in the MeMy sidebar drawer.
class SidebarDestination {
  const SidebarDestination({
    required this.id,
    required this.label,
    required this.icon,
    required this.section,
    required this.availability,
    required this.semanticLabel,
    required this.keyName,
    this.routePath,
    this.shellTabIndex,
    this.badgeLabel,
  });

  final String id;
  final String label;
  final IconData icon;
  final String? routePath;
  final int? shellTabIndex;
  final SidebarSectionId section;
  final SidebarAvailability availability;
  final String? badgeLabel;
  final String semanticLabel;
  final String keyName;

  bool get isShellTab => shellTabIndex != null;

  bool get isPlanned => availability == SidebarAvailability.planned;
}
