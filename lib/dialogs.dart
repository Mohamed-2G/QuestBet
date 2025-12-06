import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'game_state.dart';
import 'task_model.dart';
import 'theme.dart';
import 'task_templates.dart';

class TaskDialogs {
  static void showAddTaskDialog(BuildContext context, GameState gameState) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController depositController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return _AddTaskDialogContent(
          titleController: titleController,
          depositController: depositController,
          initialDate: selectedDate,
          initialTime: selectedTime,
          gameState: gameState,
        );
      },
    );
  }

  static void showProofDialog(BuildContext context, Task task) {
    final ImagePicker _imagePicker = ImagePicker();
    TextEditingController linkController = TextEditingController();
    File? selectedImageFile;
    PlatformFile? selectedFile;
    String proofType = 'link'; // 'link', 'camera', 'gallery', 'file'

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surface,
              title: AppTheme.outlinedText(
                text: "COMPLETE QUEST",
                fontSize: 20,
                fontWeight: FontWeight.w800,
                textColor: Colors.white,
                outlineColor: AppTheme.primaryYellow,
                outlineWidth: 2,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Provide Quest Proof:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Proof Type Selection
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildProofTypeChip(
                          context,
                          'Link',
                          Icons.link,
                          proofType == 'link',
                          () => setState(() {
                            proofType = 'link';
                            selectedImageFile = null;
                            selectedFile = null;
                          }),
                        ),
                        _buildProofTypeChip(
                          context,
                          'Camera',
                          Icons.camera_alt,
                          proofType == 'camera',
                          () async {
                            final XFile? image = await _imagePicker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              setState(() {
                                proofType = 'camera';
                                selectedImageFile = File(image.path);
                                selectedFile = null;
                                linkController.clear();
                              });
                            }
                          },
                        ),
                        _buildProofTypeChip(
                          context,
                          'Gallery',
                          Icons.photo_library,
                          proofType == 'gallery',
                          () async {
                            final XFile? image = await _imagePicker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              setState(() {
                                proofType = 'gallery';
                                selectedImageFile = File(image.path);
                                selectedFile = null;
                                linkController.clear();
                              });
                            }
                          },
                        ),
                        _buildProofTypeChip(
                          context,
                          'File',
                          Icons.attach_file,
                          proofType == 'file',
                          () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.any,
                            );
                            if (result != null && result.files.single.path != null) {
                              setState(() {
                                proofType = 'file';
                                selectedFile = result.files.single;
                                selectedImageFile = null;
                                linkController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Show selected image preview
                    if (selectedImageFile != null) ...[
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryYellow,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            selectedImageFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Upload this image to imgur.com or imgbb.com and paste the URL below:",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Show selected file name
                    if (selectedFile != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: AppTheme.yellowGradient,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_file,
                                color: AppTheme.textPrimary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedFile!.name,
                                style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Upload this file to Google Drive, Dropbox, etc. and paste the link below:",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Link/URL input field
                    TextField(
                      controller: linkController,
                      style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: proofType == 'link'
                            ? "Paste proof link (e.g., Google Drive, Dropbox)"
                            : proofType == 'file'
                                ? "Paste file link after uploading"
                                : "Paste image URL after uploading to imgur/imgbb",
                        hintStyle: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.yellowGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            proofType == 'link' ? Icons.link : Icons.image,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      autofocus: proofType == 'link',
                    ),
                    
                    const SizedBox(height: 8),
                    Text(
                      proofType == 'link'
                          ? "Tip: Share a Google Drive/Dropbox link"
                          : proofType == 'file'
                              ? "Tip: Upload file to cloud storage and share the link"
                              : "Tip: Upload image to imgur.com or imgbb.com and paste URL",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.successGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.successGlow,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                    String? proofLink;
                    String? proofImageUrl;

                    if (proofType == 'link') {
                      proofLink = linkController.text.trim();
                      if (proofLink?.isEmpty ?? true) proofLink = null;
                    } else if (proofType == 'file') {
                      proofLink = linkController.text.trim();
                      if (proofLink?.isEmpty ?? true) proofLink = null;
                    } else {
                      // Camera or Gallery
                      proofImageUrl = linkController.text.trim();
                      if (proofImageUrl?.isEmpty ?? true) proofImageUrl = null;
                    }

                    context.read<GameState>().completeTask(
                      task,
                      proofLink: proofLink,
                      proofImageUrl: proofImageUrl,
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.celebration, color: Colors.white, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "🎉 Quest Complete!",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    "You earned +80 Gold!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppTheme.success,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                    child: Text(
                      "COMPLETE QUEST",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildProofTypeChip(
    BuildContext context,
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
                        gradient: selected ? AppTheme.yellowGradient : null,
                        color: selected ? null : AppTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryYellow
                              : AppTheme.primaryYellow.withOpacity(0.3),
                          width: selected ? 2.5 : 1.5,
                        ),
                        boxShadow: selected ? AppTheme.yellowGlow : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: selected
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: GoogleFonts.poppins(
                              color: selected
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}

class _AddTaskDialogContent extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController depositController;
  final DateTime initialDate;
  final TimeOfDay initialTime;
  final GameState gameState;

  const _AddTaskDialogContent({
    required this.titleController,
    required this.depositController,
    required this.initialDate,
    required this.initialTime,
    required this.gameState,
  });

  @override
  State<_AddTaskDialogContent> createState() => _AddTaskDialogContentState();
}

class _AddTaskDialogContentState extends State<_AddTaskDialogContent> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    // Get tasks for selected category
    final categoryTasks = selectedCategory != null
        ? TaskTemplates.getTasksForCategory(selectedCategory!)
        : <String>[];

    return AlertDialog(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: AppTheme.outlinedText(
                text: "NEW QUEST",
                fontSize: 20,
                fontWeight: FontWeight.w800,
                textColor: Colors.white,
                outlineColor: AppTheme.primaryYellow,
                outlineWidth: 2,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection Tabs
                    Text(
                      "Quest Category",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: TaskTemplates.categories.length,
                        itemBuilder: (context, index) {
                          final category = TaskTemplates.categories[index];
                          final isSelected = selectedCategory == category;
                          final categoryColor = Color(TaskTemplates.getColorForCategory(category));

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedCategory = null;
                                  } else {
                                    selectedCategory = category;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? AppTheme.yellowGradient : null,
                                  color: isSelected ? null : AppTheme.backgroundSecondary,
                                  borderRadius: BorderRadius.circular(20),
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
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
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
                    if (selectedCategory != null && categoryTasks.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categoryTasks.map((task) {
                          final categoryColor = Color(
                            TaskTemplates.getColorForCategory(selectedCategory!),
                          );

                          return InkWell(
                            onTap: () {
                              widget.titleController.text = task;
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: widget.titleController.text == task
                                    ? AppTheme.yellowGradient
                                    : null,
                                color: widget.titleController.text == task
                                    ? null
                                    : categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.titleController.text == task
                                      ? AppTheme.primaryYellow
                                      : categoryColor.withOpacity(0.4),
                                  width: widget.titleController.text == task ? 2.5 : 1.5,
                                ),
                                boxShadow: widget.titleController.text == task
                                    ? AppTheme.yellowGlow
                                    : null,
                              ),
                              child: Text(
                                task,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: widget.titleController.text == task
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: widget.titleController.text == task
                                      ? AppTheme.textPrimary
                                      : categoryColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Divider(color: Colors.grey.shade200),
                    const SizedBox(height: 16),

                    // Custom Quest Title Field
                    Text(
                      "Or Type Your Own Quest",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: widget.titleController,
                      style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: "Task Title",
                        labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.yellowGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      autofocus: false,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: widget.depositController,
                      style: GoogleFonts.poppins(color: AppTheme.textPrimary),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Gold Deposit (optional)",
                        labelStyle: GoogleFonts.poppins(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.yellowGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.monetization_on,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Deadline: ${DateFormat('MMM d, y').format(selectedDate)} at ${selectedTime.format(context)}",
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppTheme.yellowGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppTheme.primaryYellow,
                                  onPrimary: AppTheme.background,
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
                            selectedDate = pickedDate;
                          });
                          final TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: AppTheme.primaryYellow,
                                    onPrimary: AppTheme.background,
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
                              selectedTime = pickedTime;
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.yellowGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.yellowGlow,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      if (widget.titleController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please enter a quest title"),
                            backgroundColor: AppTheme.danger,
                          ),
                        );
                        return;
                      }

                      int deposit = 0;
                      if (widget.depositController.text.trim().isNotEmpty) {
                        deposit = int.tryParse(widget.depositController.text.trim()) ?? 0;
                      }

                      final deadline = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      widget.gameState.addTask(
                        widget.titleController.text.trim(),
                        deadline,
                        depositAmount: deposit,
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ Quest created!"),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    },
                    child: AppTheme.outlinedText(
                      text: "CREATE QUEST",
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      textColor: Colors.white,
                      outlineColor: AppTheme.textPrimary,
                      outlineWidth: 1.5,
                    ),
                  ),
                ),
              ],
            );
  }
}

