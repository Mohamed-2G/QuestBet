import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'game_state.dart';
import 'task_model.dart';
import 'theme.dart';
import 'focus_mode_screen.dart';
import 'dialogs.dart';
import 'add_task_screen.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFailedTasks();
    });
  }

  void _checkFailedTasks() {
    final gameState = context.read<GameState>();
    final failedTasks = gameState.getFailedTasks();
    
    if (failedTasks.isNotEmpty && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quest Failed',
                  style: GoogleFonts.poppins(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.primaryYellow, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Remember: Every quest failure is a lesson learned!',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed Quests:',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...failedTasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: AppTheme.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monetization_on, color: AppTheme.danger, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your gold deposit has been forfeited. Time to start a new quest!',
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'I Understand',
                style: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.yellowGlow,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  'Start New Quest!',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  List<Task> _getTodayTasks(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return tasks.where((task) {
      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      return !task.isCompleted && taskDate.isBefore(tomorrow) && !taskDate.isBefore(today);
    }).toList();
  }

  List<Task> _getLaterTasks(List<Task> tasks) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    
    return tasks.where((task) {
      final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
      return !task.isCompleted && !taskDate.isBefore(tomorrow);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final todayTasks = _getTodayTasks(gameState.tasks);
    final laterTasks = _getLaterTasks(gameState.tasks);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTheme.outlinedText(
                        text: 'QUESTS',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        textColor: Colors.white,
                        outlineColor: AppTheme.primaryYellow,
                        outlineWidth: 3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${gameState.tasks.where((t) => !t.isCompleted).length} active quests',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  // Gold Balance - QuestBet Style
                  AppTheme.yellowGradientContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: AppTheme.coinDisplay(amount: gameState.gold),
                  ),
                ],
              ),
            ),

            // Quest Quote Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppTheme.questContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryYellow.withOpacity(0.15),
                withYellowBorder: true,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppTheme.yellowGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppTheme.getRandomQuote(),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tasks List
            Expanded(
              child: gameState.tasks.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (todayTasks.isNotEmpty) ...[
                          _buildSectionHeader('Today', gameState),
                          const SizedBox(height: 12),
                          ...todayTasks.map((task) => _buildTaskCard(context, task)),
                          const SizedBox(height: 24),
                        ],
                        if (laterTasks.isNotEmpty) ...[
                          _buildSectionHeader('Later', gameState),
                          const SizedBox(height: 12),
                          ...laterTasks.map((task) => _buildTaskCard(context, task)),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.yellowGradient,
          shape: BoxShape.circle,
          boxShadow: AppTheme.yellowGlow,
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTaskScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: AppTheme.textPrimary, size: 28),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, GameState gameState) {
    final isToday = title == 'Today';
    final taskCount = isToday 
        ? _getTodayTasks(gameState.tasks).length 
        : _getLaterTasks(gameState.tasks).length;
    final completedCount = isToday
        ? _getTodayTasks(gameState.tasks).where((t) => t.isCompleted).length
        : _getLaterTasks(gameState.tasks).where((t) => t.isCompleted).length;
    final progress = taskCount > 0 ? completedCount / taskCount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.yellowGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isToday ? Icons.today : Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textPrimary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (taskCount > 0)
              Text(
                '$completedCount/$taskCount completed',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        if (taskCount > 0) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryYellow),
              minHeight: 8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Quests',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to start your first quest!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final isOverdue = task.deadline.isBefore(DateTime.now());
    final formattedDate = DateFormat('EEE, MMM d').format(task.deadline);
    final formattedTime = DateFormat('h:mm a').format(task.deadline);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppTheme.questContainer(
        borderRadius: 18,
        withYellowBorder: true,
        child: InkWell(
          onTap: () => _showTaskOptions(context, task),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: task.isCompleted 
                  ? Border.all(color: AppTheme.success.withOpacity(0.3), width: 1.5)
                  : isOverdue
                      ? Border.all(color: AppTheme.danger.withOpacity(0.3), width: 1.5)
                      : null,
            ),
            child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isOverdue ? AppTheme.danger : AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$formattedDate, $formattedTime',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isOverdue ? AppTheme.danger : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isOverdue
                            ? null
                            : AppTheme.yellowGradient,
                        color: isOverdue
                            ? AppTheme.danger.withOpacity(0.15)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isOverdue 
                              ? AppTheme.danger
                              : AppTheme.primaryYellow,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        isOverdue ? 'Overdue' : 'Active Quest',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isOverdue ? AppTheme.danger : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Checkbox(
                value: task.isCompleted,
                activeColor: AppTheme.success,
                onChanged: (bool? value) {
                  if (value == true && !task.isCompleted) {
                    _showProofDialog(context, task);
                  } else if (value == false && task.isCompleted) {
                    // Optionally allow unchecking (you can remove this if tasks can't be undone)
                    context.read<GameState>().uncompleteTask(task);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _showTaskOptions(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: AppTheme.success),
              title: Text(
                'Complete Quest',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showProofDialog(context, task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_circle, color: AppTheme.primaryYellow),
              title: Text(
                'Start Focus Mode',
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FocusModeScreen(
                      taskTitle: task.title,
                      deadline: task.deadline,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProofDialog(BuildContext context, Task task) {
    TaskDialogs.showProofDialog(context, task);
  }

  void _showAddTaskDialog(BuildContext context, GameState gameState) {
    TaskDialogs.showAddTaskDialog(context, gameState);
  }
}

