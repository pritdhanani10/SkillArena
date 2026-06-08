import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/services/app_state.dart';

class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _globalUsers = [
    {'name': 'Sneha_32', 'xp': 2450, 'coins': 840, 'avatar': '🌸', 'rank': 1},
    {'name': 'Alex_Dev', 'xp': 2100, 'coins': 690, 'avatar': '⚡', 'rank': 2},
    {'name': 'CodeMaster', 'xp': 1950, 'coins': 520, 'avatar': '🚀', 'rank': 3},
    {'name': 'Rahul_K', 'xp': 1200, 'coins': 350, 'avatar': '🥋', 'rank': 4},
    {'name': 'Amit_Raj', 'xp': 950, 'coins': 280, 'avatar': '🦁', 'rank': 5},
  ];

  final List<Map<String, dynamic>> _countryUsers = [
    {'name': 'Sneha_32', 'xp': 2450, 'coins': 840, 'avatar': '🌸', 'rank': 1},
    {'name': 'CodeMaster', 'xp': 1950, 'coins': 520, 'avatar': '🚀', 'rank': 2},
    {'name': 'Rahul_K', 'xp': 1200, 'coins': 350, 'avatar': '🥋', 'rank': 3},
  ];

  final List<Map<String, dynamic>> _friendUsers = [
    {'name': 'Sneha_32', 'xp': 2450, 'coins': 840, 'avatar': '🌸', 'rank': 1},
    {'name': 'Rahul_K', 'xp': 1200, 'coins': 350, 'avatar': '🥋', 'rank': 2},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    // Dynamically inject player into lists based on their current XP
    final playerMap = {
      'name': '${appState.username} (You)',
      'xp': appState.xp,
      'coins': appState.coins,
      'avatar': '🎓',
      'isPlayer': true,
    };

    final globalList = List<Map<String, dynamic>>.from(_globalUsers)..add(playerMap);
    globalList.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
    
    final countryList = List<Map<String, dynamic>>.from(_countryUsers)..add(playerMap);
    countryList.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));

    final friendsList = List<Map<String, dynamic>>.from(_friendUsers)..add(playerMap);
    friendsList.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));

    return Scaffold(
      appBar: AppBar(
        title: const Text("🏆 Leaderboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: "Global"),
            Tab(text: "Country"),
            Tab(text: "Friends"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(globalList),
          _buildLeaderboardList(countryList),
          _buildLeaderboardList(friendsList),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> users) {
    // Top 3 Podium Displays
    final hasPodium = users.length >= 3;
    final podiumUsers = hasPodium ? users.sublist(0, 3) : <Map<String, dynamic>>[];
    final remainingUsers = hasPodium ? users.sublist(3) : users;

    return Column(
      children: [
        if (hasPodium) ...[
          const SizedBox(height: 16),
          _buildPodiumGraphic(podiumUsers),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: remainingUsers.length,
              itemBuilder: (context, index) {
                final user = remainingUsers[index];
                final isPlayer = user['isPlayer'] == true;
                
                // calculate ranks index + 4 because 1-3 are in podium
                final rank = hasPodium ? index + 4 : index + 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isPlayer ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPlayer ? AppColors.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "#$rank",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      Text(user['avatar'], style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          user['name'],
                          style: TextStyle(
                            fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("${user['xp']} XP", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          Text("${user['coins']} Coins", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumGraphic(List<Map<String, dynamic>> podium) {
    // podium indices: 0 is 1st, 1 is 2nd, 2 is 3rd
    final first = podium[0];
    final second = podium.length > 1 ? podium[1] : null;
    final third = podium.length > 2 ? podium[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (second != null)
            _buildPodiumBlock(second, rank: 2, height: 75, blockColor: Colors.grey.shade700),
          
          // 1st Place (Center and tallest)
          _buildPodiumBlock(first, rank: 1, height: 95, blockColor: AppColors.accentYellow),

          // 3rd Place
          if (third != null)
            _buildPodiumBlock(third, rank: 3, height: 60, blockColor: Colors.brown.shade600),
        ],
      ),
    );
  }

  Widget _buildPodiumBlock(Map<String, dynamic> user, {required int rank, required double height, required Color blockColor}) {
    final isPlayer = user['isPlayer'] == true;
    return Column(
      children: [
        // Avatar + crown for #1
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: blockColor, width: 2),
                color: AppColors.surface,
              ),
              child: Center(
                child: Text(user['avatar'], style: const TextStyle(fontSize: 24)),
              ),
            ),
            if (rank == 1)
              const Positioned(
                top: -16,
                child: Text("👑", style: TextStyle(fontSize: 16)),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user['name'],
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: isPlayer ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
        Text("${user['xp']} XP", style: TextStyle(fontSize: 10, color: blockColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Podium base block
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            color: blockColor.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: blockColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              "$rank",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: blockColor),
            ),
          ),
        ),
      ],
    );
  }
}
