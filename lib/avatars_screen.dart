import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'game_state.dart';
import 'theme.dart';

class AvatarsScreen extends StatelessWidget {
  const AvatarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final completedCount = gameState.completedTasksCount;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Avatars',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppTheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppTheme.primaryYellow),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount completed tasks',
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (gameState.avatarAsset != null && gameState.avatarAsset!.isNotEmpty)
                      Text(
                        'Equipped',
                        style: GoogleFonts.inter(
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: GameState.avatarThresholds.length,
              itemBuilder: (context, index) {
                final threshold = GameState.avatarThresholds[index];
                final asset = 'assets/avatars/avatar_${threshold}.png';
                final unlocked = gameState.completedTasksCount >= threshold;
                final equipped = gameState.avatarAsset == asset;
                return GestureDetector(
                  onTap: unlocked
                      ? () async {
                          final String? err = await gameState.setAvatarAsset(
                            equipped ? null : asset,
                          );
                          if (err != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: AppTheme.danger),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(equipped ? 'Avatar unequipped' : 'Avatar equipped!'),
                                backgroundColor: equipped ? AppTheme.textSecondary : AppTheme.success,
                              ),
                            );
                          }
                        }
                      : null,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: equipped
                                ? AppTheme.primaryYellow
                                : AppTheme.textSecondary.withOpacity(0.2),
                            width: equipped ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            asset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: AppTheme.surface,
                              alignment: Alignment.center,
                              child: Icon(Icons.person, color: AppTheme.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      if (equipped)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.black),
                          ),
                        ),
                      if (!unlocked)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, color: Colors.white),
                              const SizedBox(height: 6),
                              Text(
                                '$threshold',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            if (gameState.avatarAsset != null && gameState.avatarAsset!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final err = await gameState.setAvatarAsset(null);
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err), backgroundColor: AppTheme.danger),
                      );
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Avatar unequipped'), backgroundColor: AppTheme.textSecondary),
                      );
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textSecondary),
                  label: Text('Remove avatar', style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


