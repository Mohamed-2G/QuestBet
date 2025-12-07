import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_state.dart';
import 'theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _globalSelectedMetric = 0; // 0 = Coins, 1 = Tasks
  int _groupSelectedMetric = 0; // 0 = Coins, 1 = Tasks

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeaderboards();
    });
  }

  void _loadLeaderboards() {
    final gameState = context.read<GameState>();
    gameState.loadGlobalCoinsLeaderboard();
    gameState.loadGlobalTasksLeaderboard();
    if (gameState.groupCode != null && gameState.groupCode!.isNotEmpty) {
      gameState.loadGroupCoinsLeaderboard();
      gameState.loadGroupTasksLeaderboard();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final currentUserId = gameState.username;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Leaderboard",
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryYellow,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryYellow,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Group'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Global Leaderboard
          _buildGlobalLeaderboard(context, gameState, currentUserId),
          // Group Leaderboard
          _buildGroupLeaderboard(context, gameState, currentUserId),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard(BuildContext context, GameState gameState, String? currentUserId) {
    return RefreshIndicator(
      onRefresh: () async {
        gameState.loadGlobalCoinsLeaderboard();
        gameState.loadGlobalTasksLeaderboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Metric Selector
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricChip(
                      'Most Coins',
                      Icons.monetization_on,
                      0,
                      true, // isGlobal
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricChip(
                      'Most Tasks',
                      Icons.check_circle,
                      1,
                      true, // isGlobal
                    ),
                  ),
                ],
              ),
            ),
            // Leaderboard List
            _globalSelectedMetric == 0
                ? _buildCoinsList(gameState.globalCoinsLeaderboard, currentUserId, false)
                : _buildTasksList(gameState.globalTasksLeaderboard, currentUserId, false),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupLeaderboard(BuildContext context, GameState gameState, String? currentUserId) {
    if (gameState.groupCode == null || gameState.groupCode!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Group Joined',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join a group to see group leaderboard',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        gameState.loadGroupCoinsLeaderboard();
        gameState.loadGroupTasksLeaderboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Group Name
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: AppTheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.group, color: AppTheme.primaryYellow),
                      const SizedBox(width: 12),
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
                    ],
                  ),
                ),
              ),
            ),
            // Metric Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricChip(
                      'Most Coins',
                      Icons.monetization_on,
                      0,
                      false, // isGlobal
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricChip(
                      'Most Tasks',
                      Icons.check_circle,
                      1,
                      false, // isGlobal
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Leaderboard List
            _groupSelectedMetric == 0
                ? _buildCoinsList(gameState.groupCoinsLeaderboard, currentUserId, true)
                : _buildTasksList(gameState.groupTasksLeaderboard, currentUserId, true),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, IconData icon, int index, bool isGlobal) {
    final isSelected = isGlobal ? _globalSelectedMetric == index : _groupSelectedMetric == index;
    return InkWell(
      onTap: () {
        setState(() {
          if (isGlobal) {
            _globalSelectedMetric = index;
          } else {
            _groupSelectedMetric = index;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryYellow.withOpacity(0.2) : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryYellow : AppTheme.textSecondary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryYellow : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? AppTheme.primaryYellow : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinsList(List<Map<String, dynamic>> players, String? currentUserId, bool isGroup) {
    if (players.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No data available',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
        itemCount: players.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final player = players[index];
        final isMe = player['username'] == currentUserId;
        final rank = index + 1;

          return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            border: isMe 
                ? Border.all(color: AppTheme.primaryYellow, width: 2)
                : null,
            ),
            child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: _buildLeaderboardAvatar(
                photoUrl: player['photoUrl'] as String?,
                avatarAsset: player['avatarAsset'] as String?,
                username: player['username'] as String? ?? 'U',
                rank: rank,
                highlight: isMe,
              ),
              title: Text(
              player['username'] ?? 'Unknown',
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
                  "${player['gold'] ?? 0} G",
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksList(List<Map<String, dynamic>> players, String? currentUserId, bool isGroup) {
    if (players.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No data available',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final player = players[index];
        final isMe = player['username'] == currentUserId;
        final rank = index + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: isMe 
                ? Border.all(color: AppTheme.primaryYellow, width: 2)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: _buildLeaderboardAvatar(
              photoUrl: player['photoUrl'] as String?,
              avatarAsset: player['avatarAsset'] as String?,
              username: player['username'] as String? ?? 'U',
              rank: rank,
              highlight: isMe,
            ),
            title: Text(
              player['username'] ?? 'Unknown',
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: isMe ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.success,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  "${player['completedTasks'] ?? 0}",
                  style: GoogleFonts.inter(
                    color: AppTheme.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              ),
            ),
          );
        },
    );
  }

  Widget _buildLeaderboardAvatar({
    required String? photoUrl,
    required String? avatarAsset,
    required String username,
    required int rank,
    required bool highlight,
  }) {
    final double container = 46;
    final double photoSize = 30;
    final double ringSize = 44;
    return SizedBox(
      width: container,
      height: container,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: photoSize,
              height: photoSize,
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _initialsBubble(username, highlight),
                    )
                  : _initialsBubble(username, highlight),
            ),
          ),
          if (avatarAsset != null && avatarAsset.isNotEmpty)
            IgnorePointer(
              child: Image.asset(
                avatarAsset,
                width: ringSize,
                height: ringSize,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: highlight ? AppTheme.primaryYellow : AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: highlight ? Colors.black.withOpacity(0.2) : AppTheme.textSecondary.withOpacity(0.2)),
              ),
              child: Text(
                '#$rank',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: highlight ? Colors.black : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _initialsBubble(String username, bool highlight) {
    final String letter = (username.isNotEmpty ? username[0] : 'U').toUpperCase();
    return Container(
      color: highlight ? AppTheme.primaryYellow.withOpacity(0.15) : AppTheme.textSecondary.withOpacity(0.15),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          color: highlight ? AppTheme.primaryYellow : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
