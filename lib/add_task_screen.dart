import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'game_state.dart';
import 'theme.dart';
import 'task_templates.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedCategory;
  IconData? _selectedIcon;
  String? _customTaskName;

  // Icon options for tasks
  final List<IconData> _iconOptions = [
    Icons.work,
    Icons.school,
    Icons.fitness_center,
    Icons.home,
    Icons.shopping_cart,
    Icons.book,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.computer,
    Icons.phone,
    Icons.restaurant,
    Icons.local_gas_station,
    Icons.medical_services,
    Icons.directions_car,
    Icons.pets,
    Icons.favorite,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  void _createTask() {
    final gameState = context.read<GameState>();
    
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a task title"),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    int deposit = 0;
    if (_depositController.text.trim().isNotEmpty) {
      deposit = int.tryParse(_depositController.text.trim()) ?? 0;
    }

    final deadline = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    gameState.addTask(
      _titleController.text.trim(),
      deadline,
      depositAmount: deposit,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Task created!"),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryTasks = _selectedCategory != null
        ? TaskTemplates.getTasksForCategory(_selectedCategory!)
        : <String>[];

    // Map category names to colors
    final Map<String, Color> categoryColors = {
      'Study': Colors.blue.shade700,
      'Health': Colors.green.shade700,
      'Chores': Colors.amber.shade700,
      'Work': AppTheme.yellowDark,
      'Habits': Colors.purple.shade700,
      'Social': Colors.orange.shade700,
    };

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppTheme.outlinedText(
          text: "NEW QUEST",
          fontSize: 24,
          fontWeight: FontWeight.w800,
          textColor: Colors.white,
          outlineColor: AppTheme.primaryYellow,
          outlineWidth: 2.5,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual Quest Creation Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.yellowGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Create Your Quest",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Enter quest details manually",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Quest Title Field
            TextField(
              controller: _titleController,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: "Quest Title",
                labelStyle: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.primaryYellow.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2.5,
                  ),
                ),
                prefixIcon: _selectedIcon != null
                    ? Icon(_selectedIcon, color: AppTheme.primaryYellow)
                    : const Icon(Icons.edit, color: AppTheme.primaryYellow),
              ),
              autofocus: false,
            ),
            const SizedBox(height: 16),

            // Icon Selection
            Text(
              "Choose Quest Icon (Optional)",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _iconOptions.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = isSelected ? null : icon;
                    });
                  },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.yellowGradient : null,
                        color: isSelected
                            ? null
                            : AppTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryYellow
                              : AppTheme.primaryYellow.withOpacity(0.3),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected ? AppTheme.yellowGlow : null,
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Gold Deposit Field
            TextField(
              controller: _depositController,
              style: GoogleFonts.poppins(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Gold Deposit (optional)",
                labelStyle: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.primaryYellow.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryYellow,
                    width: 2.5,
                  ),
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.yellowGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Deadline Selection
            AppTheme.questContainer(
              padding: const EdgeInsets.all(16),
              withYellowBorder: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quest Deadline",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${DateFormat('MMM d, y').format(_selectedDate)} at ${_selectedTime.format(context)}",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.yellowGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: AppTheme.textPrimary,
                      ),
                      onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: AppTheme.darkTheme.copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppTheme.primaryYellow,
                                onPrimary: Colors.white,
                                surface: AppTheme.surface,
                                onSurface: AppTheme.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                          builder: (context, child) {
                            return Theme(
                              data: AppTheme.darkTheme.copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppTheme.primaryYellow,
                                  onPrimary: Colors.white,
                                  surface: AppTheme.surface,
                                  onSurface: AppTheme.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          setState(() {
                            _selectedTime = pickedTime;
                          });
                        }
                      }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Divider
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 32),

            // Quick Pick Templates Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.yellowGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Quick Pick Quests",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Select from premade quests",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Category Selection
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: TaskTemplates.categories.length,
                itemBuilder: (context, index) {
                  final category = TaskTemplates.categories[index];
                  final isSelected = _selectedCategory == category;
                  final categoryColor = categoryColors[category] ?? AppTheme.primaryYellow;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = isSelected ? null : category;
                          _customTaskName = null;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.yellowGradient : null,
                            color: isSelected
                                ? null
                                : AppTheme.backgroundSecondary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryYellow
                                  : AppTheme.primaryYellow.withOpacity(0.3),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: isSelected ? AppTheme.yellowGlow : null,
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ),
                  );
                },
              ),
            ),

            // Task Chips for Selected Category
            if (_selectedCategory != null && categoryTasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categoryTasks.map((task) {
                  final categoryColor = categoryColors[_selectedCategory!] ?? AppTheme.primaryYellow;
                  final isSelected = _customTaskName == task;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _customTaskName = task;
                        _titleController.text = task;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.yellowGradient : null,
                        color: isSelected
                            ? null
                            : categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryYellow
                              : categoryColor.withOpacity(0.4),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected ? AppTheme.yellowGlow : null,
                      ),
                      child: Text(
                        task,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? AppTheme.textPrimary : categoryColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 40),

            // Create Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.yellowGlow,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _createTask,
                child: AppTheme.outlinedText(
                  text: "CREATE QUEST",
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textColor: Colors.white,
                  outlineColor: AppTheme.textPrimary,
                  outlineWidth: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

