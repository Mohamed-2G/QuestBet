import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_state.dart';
import 'theme.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Groups'),
        backgroundColor: AppTheme.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create Group Section
            if (gameState.groupCode == null || gameState.groupCode!.isEmpty)
              Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Group',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create a new accountability group and share the code with your friends',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Group'),
                          onPressed: () => _showCreateGroupDialog(context, gameState),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Group',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You are already in a group. Leave your current group to create a new one.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Group'),
                          onPressed: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Join Group Section
            if (gameState.groupCode == null || gameState.groupCode!.isEmpty)
              Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join Existing Group',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter a group code to join your accountability partners',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        style: GoogleFonts.inter(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'e.g., ABC123',
                          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: AppTheme.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.group, color: AppTheme.primaryYellow),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_codeController.text.trim().isNotEmpty) {
                              final error = await gameState.joinGroup(_codeController.text.trim());
                              if (error != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: AppTheme.danger,
                                  ),
                                );
                              } else if (mounted) {
                                _codeController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Successfully joined group!'),
                                    backgroundColor: AppTheme.success,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Join Group'),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join Existing Group',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You are already in a group. Leave your current group to join another one.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _codeController,
                        enabled: false,
                        style: GoogleFonts.inter(color: AppTheme.textSecondary),
                        decoration: InputDecoration(
                          hintText: 'e.g., ABC123',
                          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: AppTheme.background.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.group, color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: null,
                          child: const Text('Join Group'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Current Group
            if (gameState.groupCode != null && gameState.groupCode!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gameState.groupName ?? 'Group',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${gameState.groupCode}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await gameState.leaveGroup();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Left group'),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Leave',
                      style: GoogleFonts.inter(color: AppTheme.danger),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Group Members
              if (gameState.groupMembers.isNotEmpty)
                ...gameState.groupMembers.map((member) {
                  final isMe = member['username'] == gameState.username;
                  return Card(
                    color: AppTheme.surface,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                        child: Text(
                          (member['username'] as String)[0].toUpperCase(),
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        member['username'],
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: AppTheme.primaryYellow,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${member['gold']} G',
                            style: GoogleFonts.inter(
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ] else
              Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No group joined',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join a group to see your accountability partners',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, GameState gameState) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Create New Group',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a name for your group',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g., Study Squad, Work Team',
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.group, color: AppTheme.primaryYellow),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              'A unique code will be generated automatically',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a group name'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
                return;
              }

              final error = await gameState.createGroup(nameController.text.trim());
              if (error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              } else if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Group "${gameState.groupName}" created! Code: ${gameState.groupCode}',
                    ),
                    backgroundColor: AppTheme.success,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow),
            child: Text(
              'Create',
              style: GoogleFonts.inter(color: AppTheme.background),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}

