class Task {
  final String? id; // SQL needs an ID for updates/deletes
  final String title;
  final DateTime deadline;
  bool isCompleted;
  final int depositAmount;
  String? proofLink; // Link to proof (e.g., Google Drive, URL)
  String? proofImageUrl; // URL to uploaded image
  DateTime? completedAt; // Timestamp when task was completed

  Task({
    this.id,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    this.depositAmount = 50,
    this.proofLink,
    this.proofImageUrl,
    this.completedAt,
  });

  // Convert a Task into a Map (for inserting into SQL)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'deadline': deadline.toIso8601String(), // Store Date as String
      'isCompleted': isCompleted ? 1 : 0,     // Store Bool as Int (1 or 0)
      'depositAmount': depositAmount,
      'proofLink': proofLink,
      'proofImageUrl': proofImageUrl,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Convert a Map into a Task (for reading from SQL)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      deadline: DateTime.parse(map['deadline']), // Convert String back to Date
      isCompleted: map['isCompleted'] == 1 || map['isCompleted'] == true,      // Convert Int/Bool back to Bool
      depositAmount: map['depositAmount'] ?? 50,
      proofLink: map['proofLink'],
      proofImageUrl: map['proofImageUrl'],
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
    );
  }
}