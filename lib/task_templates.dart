class TaskTemplates {
  // Category definitions with preset tasks
  static const Map<String, List<String>> templates = {
    '📚 Study': [
      'Math Practice',
      'Read Chapter',
      'Research Paper',
      'Review Notes',
      'Complete Assignment',
      'Study for Exam',
      'Watch Lecture',
      'Solve Problems',
    ],
    '🏋️ Health': [
      '30 Min Jog',
      'Drink 2L Water',
      'Meal Prep',
      'Gym Session',
      'Morning Workout',
      'Yoga Session',
      'No Sugar Today',
      '8 Hours Sleep',
    ],
    '🏠 Chores': [
      'Clean Room',
      'Laundry',
      'Wash Dishes',
      'Grocery Shopping',
      'Organize Desk',
      'Vacuum Floor',
      'Take Out Trash',
      'Water Plants',
    ],
    '💼 Work': [
      'Complete Project',
      'Team Meeting',
      'Review Documents',
      'Send Emails',
      'Update Report',
      'Client Call',
      'Code Review',
      'Plan Sprint',
    ],
    '🎯 Habits': [
      'Meditation',
      'Journal Entry',
      'Read 10 Pages',
      'Practice Skill',
      'Learn Language',
      'No Social Media',
      'Early Wake Up',
      'Gratitude List',
    ],
    '👥 Social': [
      'Call Family',
      'Meet Friend',
      'Date Night',
      'Group Activity',
      'Volunteer Work',
      'Networking Event',
      'Birthday Gift',
      'Thank You Note',
    ],
  };

  // Category colors for visual distinction
  static const Map<String, int> categoryColors = {
    '📚 Study': 0xFF4A90E2,      // Blue
    '🏋️ Health': 0xFF7A9D7A,     // Green
    '🏠 Chores': 0xFFD4A574,      // Amber
    '💼 Work': 0xFF9B7A4F,        // Brown
    '🎯 Habits': 0xFF9D4EDD,      // Purple
    '👥 Social': 0xFFE8B574,      // Orange
  };

  // Get all category names
  static List<String> get categories => templates.keys.toList();

  // Get tasks for a specific category
  static List<String> getTasksForCategory(String category) {
    return templates[category] ?? [];
  }

  // Get color for a category
  static int getColorForCategory(String category) {
    return categoryColors[category] ?? 0xFF9B7A4F;
  }
}

