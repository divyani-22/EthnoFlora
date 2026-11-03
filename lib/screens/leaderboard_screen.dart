import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';
import 'community_screen.dart';

class CampusLeaderboardEntry {
  final String id;
  final String name;
  final String city;
  final int points;
  final int members;
  final int actions;
  final String badge;
  final Color badgeColor;

  const CampusLeaderboardEntry({
    required this.id,
    required this.name,
    required this.city,
    required this.points,
    required this.members,
    required this.actions,
    required this.badge,
    required this.badgeColor,
  });
}

class LeaderboardScreen extends StatefulWidget {
  final AppUser user;

  const LeaderboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  List<AppUser> _allTimeUsers = [];
  List<AppUser> _weeklyUsers = [];
  bool _isLoading = true;

  static const List<CampusLeaderboardEntry> _campusRankings = [
    CampusLeaderboardEntry(
      id: 'iesp_athens',
      name: 'IESP Athens & Botanical Survey',
      city: 'Athens',
      points: 18450,
      members: 184,
      actions: 1420,
      badge: '🏆 #1 Defending Research Institute',
      badgeColor: AppColors.butterYellow,
    ),
    CampusLeaderboardEntry(
      id: 'bsi_western',
      name: 'Botanical Survey of India — Western Circle',
      city: 'Athens',
      points: 17820,
      members: 245,
      actions: 1380,
      badge: '🥈 Flora Conservation Leaders',
      badgeColor: AppColors.electricMint,
    ),
    CampusLeaderboardEntry(
      id: 'bits_pilani',
      name: 'BITS Pilani Medicinal Flora Lab',
      city: 'Pilani',
      points: 16940,
      members: 280,
      actions: 1290,
      badge: '🥉 Arid Ethnobotany Pioneers',
      badgeColor: AppColors.dustyCoral,
    ),
    CampusLeaderboardEntry(
      id: 'frlht_bengaluru',
      name: 'FRLHT Institute of Bio-Sciences',
      city: 'Vellore',
      points: 16310,
      members: 320,
      actions: 1210,
      badge: '🌊 Medicinal Taxonomists',
      badgeColor: AppColors.softSky,
    ),
    CampusLeaderboardEntry(
      id: 'ari_pune',
      name: 'Agharkar Research Institute — Biodiversity Wing',
      city: 'Athens',
      points: 15760,
      members: 210,
      actions: 1140,
      badge: '🔬 Phytochemical Profiling',
      badgeColor: AppColors.butterYellow,
    ),
    CampusLeaderboardEntry(
      id: 'mit_wpu',
      name: 'MIT Herbarium & Phytochemistry Division',
      city: 'Athens',
      points: 15200,
      members: 220,
      actions: 1080,
      badge: '🌳 Western Ghats Bio-Survey',
      badgeColor: AppColors.electricMint,
    ),
    CampusLeaderboardEntry(
      id: 'pict',
      name: 'PICT Bio-Informatics Research Center',
      city: 'Athens',
      points: 14890,
      members: 195,
      actions: 995,
      badge: '💻 Phytochemical AI Innovators',
      badgeColor: AppColors.dustyCoral,
    ),
    CampusLeaderboardEntry(
      id: 'viit',
      name: 'VIIT Botanical Genomics Wing',
      city: 'Athens',
      points: 14240,
      members: 165,
      actions: 910,
      badge: '🌱 Nagoya ABS Field Verifiers',
      badgeColor: AppColors.softSky,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadAllUsers();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        _loadFallbackData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('points', descending: true)
          .get()
          .timeout(const Duration(seconds: 8));

      if (snapshot.docs.isEmpty) {
        _loadFallbackData();
        return;
      }

      final allUsers = snapshot.docs.map((doc) {
        try {
          return AppUser.fromMap(doc.id, doc.data());
        } catch (e) {
          return null;
        }
      }).whereType<AppUser>().toList();

      final allTimeSorted = [...allUsers]..sort((a, b) => b.points.compareTo(a.points));
      final weeklySorted = [...allUsers]..sort((a, b) => b.weekPoints.compareTo(a.weekPoints));

      if (mounted) {
        setState(() {
          _allTimeUsers = allTimeSorted;
          _weeklyUsers = weeklySorted;
          _isLoading = false;
        });
      }
    } catch (e) {
      _loadFallbackData();
    }
  }

  void _loadFallbackData() {
    final sampleUsers = [
      AppUser(
        id: widget.user.id,
        firstName: widget.user.firstName.isNotEmpty ? widget.user.firstName : 'Aarav',
        lastName: widget.user.lastName.isNotEmpty ? widget.user.lastName : 'Sharma',
        points: widget.user.points > 0 ? widget.user.points : 420,
        savedPosts: [],
        likedPosts: [],
        actions: 14,
        streak: 5,
        weekPoints: 310,
        weekGoal: 500,
      ),
      AppUser(
        id: 'u2',
        firstName: 'Ananya',
        lastName: 'Deshmukh',
        points: 680,
        savedPosts: [],
        likedPosts: [],
        actions: 22,
        streak: 7,
        weekPoints: 490,
        weekGoal: 500,
      ),
      AppUser(
        id: 'u3',
        firstName: 'Rohan',
        lastName: 'Patil',
        points: 540,
        savedPosts: [],
        likedPosts: [],
        actions: 18,
        streak: 4,
        weekPoints: 360,
        weekGoal: 500,
      ),
      AppUser(
        id: 'u4',
        firstName: 'Pooja',
        lastName: 'Kulkarni',
        points: 390,
        savedPosts: [],
        likedPosts: [],
        actions: 12,
        streak: 3,
        weekPoints: 240,
        weekGoal: 500,
      ),
      AppUser(
        id: 'u5',
        firstName: 'Tanmay',
        lastName: 'Joshi',
        points: 310,
        savedPosts: [],
        likedPosts: [],
        actions: 9,
        streak: 2,
        weekPoints: 180,
        weekGoal: 500,
      ),
      AppUser(
        id: 'u6',
        firstName: 'Sneha',
        lastName: 'Kapadia',
        points: 290,
        savedPosts: [],
        likedPosts: [],
        actions: 8,
        streak: 2,
        weekPoints: 160,
        weekGoal: 500,
      ),
      AppUser(
        id: 'u7',
        firstName: 'Aditya',
        lastName: 'Verma',
        points: 260,
        savedPosts: [],
        likedPosts: [],
        actions: 7,
        streak: 1,
        weekPoints: 140,
        weekGoal: 500,
      ),
    ];

    if (mounted) {
      setState(() {
        _allTimeUsers = [...sampleUsers]..sort((a, b) => b.points.compareTo(a.points));
        _weeklyUsers = [...sampleUsers]..sort((a, b) => b.weekPoints.compareTo(a.weekPoints));
        _isLoading = false;
      });
    }
  }

  void _navigateHome() {
    final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
    if (mainScreenState != null) {
      mainScreenState.onItemTapped(0);
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _openCollegeCommunity(String schoolId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityScreen(
          user: widget.user,
          schoolId: schoolId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: AppColors.paperCream,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: NeoBackButton(
              onPressed: _navigateHome,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.butterYellow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.solidBlack, width: 2.0),
              ),
              child: Text(
                'LEADERBOARD',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 0.8,
                  color: AppColors.solidBlack,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [SizedBox(width: 50)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.solidBlack, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.solidBlack,
                    offset: Offset(2, 2.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.butterYellow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.solidBlack, width: 2.0),
                ),
                labelColor: AppColors.solidBlack,
                unselectedLabelColor: AppColors.solidBlack.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(text: 'Weekly'),
                  Tab(text: 'All-Time'),
                  Tab(text: 'Research Cup 🏆'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: PaperGridBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.solidBlack))
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList(_weeklyUsers, isWeekly: true),
                  _buildLeaderboardList(_allTimeUsers, isWeekly: false),
                  _buildCampusLeaderboardList(),
                ],
              ),
      ),
    );
  }

  Widget _buildCampusLeaderboardList() {
    final topCollege = _campusRankings.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      children: [
        // Trophy Banner
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.electricMint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.solidBlack, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: AppColors.solidBlack,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.butterYellow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.solidBlack, width: 2.0),
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INTER-INSTITUTE BIODIVERSITY TROPHY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.solidBlack,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap any institute to explore their live EthnoCollab feed & field research!',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.solidBlack.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Champion Spotlight
        Text(
          '👑 CURRENT #1 RESEARCH INSTITUTE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        NeoCard(
          color: AppColors.cardWhite,
          radius: 18,
          borderWidth: 2.0,
          shadowOffset: const Offset(3.5, 4.0),
          padding: const EdgeInsets.all(16),
          onTap: () => _openCollegeCommunity(topCollege.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.butterYellow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.solidBlack, width: 2.0),
                    ),
                    child: const Center(
                      child: Text('🥇', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                topCollege.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.solidBlack,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.electricMint,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.solidBlack, width: 1.2),
                              ),
                              child: Text(
                                topCollege.city,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.solidBlack,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${topCollege.members} researchers • ${topCollege.actions} field logs',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    ),
                    child: Text(
                      '${topCollege.points} pts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.solidBlack, thickness: 1.5, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: topCollege.badgeColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.solidBlack, width: 1.2),
                    ),
                    child: Text(
                      topCollege.badge,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Open IESP Athens EthnoCollab',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.solidBlack),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'ALL INSTITUTE RANKINGS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        ..._campusRankings.asMap().entries.map((entry) {
          final index = entry.key;
          final college = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoCard(
              color: AppColors.cardWhite,
              radius: 16,
              borderWidth: 2.0,
              shadowOffset: const Offset(3.0, 3.0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              onTap: () => _openCollegeCommunity(college.id),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.butterYellow
                          : index == 1
                              ? const Color(0xFFE2E8F0)
                              : index == 2
                                  ? AppColors.dustyCoral
                                  : AppColors.paperCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // College Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          college.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.softSky.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.solidBlack, width: 1.0),
                              ),
                              child: Text(
                                college.city,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.solidBlack,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${college.members} researchers • ${college.actions} field logs',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Points & Navigate icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.paperCream,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.solidBlack, width: 1.4),
                        ),
                        child: Text(
                          '${college.points} pts',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'EthnoCollab',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.solidBlack.withValues(alpha: 0.6),
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.solidBlack),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLeaderboardList(List<AppUser> users, {required bool isWeekly}) {
    final winner = users.isNotEmpty ? users.first : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      children: [
        // User's Own Points Card
        NeoCard(
          color: AppColors.cardWhite,
          radius: 20,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YOUR FLORA COINS BALANCE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.solidBlack, width: 1.2),
                    ),
                    child: Text(
                      'ACTIVE RESEARCHER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.butterYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.solidBlack, width: 2.0),
                    ),
                    child: const Icon(Icons.eco_rounded, color: AppColors.solidBlack, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.user.points} Flora Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      Text(
                        '${widget.user.actions} field observations logged',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dustyCoral,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.solidBlack, width: 1.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.solidBlack),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.user.streak}d',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.solidBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Quick Campus Trophy Shortcut
        GestureDetector(
          onTap: () {
            _tabController.animateTo(2);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.butterYellow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.solidBlack, width: 1.5),
            ),
            child: Row(
              children: [
                const Text('🏆', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Research Cup: IESP Athens leads with 18,450 pts!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.solidBlack,
                    ),
                  ),
                ),
                Text(
                  'View All →',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.solidBlack,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Champion Spotlight Card
        if (winner != null) ...[
          Text(
            isWeekly ? "🏆 THIS WEEK'S CHAMPION" : '👑 ALL-TIME TOP WARRIOR',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.grey[800],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          NeoCard(
            color: AppColors.cardWhite,
            radius: 18,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.butterYellow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.solidBlack, width: 2.0),
                  ),
                  child: const Center(
                    child: Text('🥇', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        winner.fullName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      Text(
                        '${winner.actions} actions • ${winner.streak} day streak',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.sageGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.solidBlack, width: 1.5),
                  ),
                  child: Text(
                    '${isWeekly ? winner.weekPoints : winner.points} pts',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.solidBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        Text(
          'INDIVIDUAL STUDENT RANKINGS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.grey[800],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),

        ...users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final isCurrentUser = user.id == widget.user.id || (user.id == _currentUserId);
          final points = isWeekly ? user.weekPoints : user.points;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoCard(
              color: isCurrentUser ? AppColors.butterYellow.withValues(alpha: 0.35) : AppColors.cardWhite,
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? AppColors.butterYellow
                          : index == 1
                              ? const Color(0xFFE2E8F0)
                              : index == 2
                                  ? AppColors.dustyCoral
                                  : AppColors.paperCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '#${index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.sageGreen,
                    child: Text(
                      user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.fullName,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.solidBlack,
                                ),
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.dustyCoral,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.solidBlack, width: 1.0),
                                ),
                                child: Text(
                                  'YOU',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.solidBlack,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${user.actions} actions completed',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.paperCream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.solidBlack, width: 1.5),
                    ),
                    child: Text(
                      '$points pts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.solidBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 100), // padding for floating nav bar
      ],
    );
  }
}
