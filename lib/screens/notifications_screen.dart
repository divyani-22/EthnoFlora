import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color badgeColor;
  final String category;
  final int targetTabIndex;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.badgeColor,
    required this.category,
    this.targetTabIndex = 0,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Welcome to EthnoFlora AI! 🌿',
      message: 'Explore biodiversity sentinels, botanical specimen registry, and earn Flora Coins!',
      time: 'Just now',
      icon: Icons.eco_rounded,
      badgeColor: AppColors.sageGreen,
      category: 'Home',
      targetTabIndex: 0,
    ),
    NotificationItem(
      id: '2',
      title: 'BioRepository Specimen Alert 🌿',
      message: 'A peer listed verified "Withania somnifera (Ashwagandha)" seeds for exchange!',
      time: '2h ago',
      icon: Icons.inventory_2_rounded,
      badgeColor: AppColors.dustyCoral,
      category: 'BioRepository',
      targetTabIndex: 5,
    ),
    NotificationItem(
      id: '3',
      title: 'EthnoRadar Biodiversity Sentinel Active 🎯',
      message: 'Western Ghats Flora Sentinel is now active. Verify field observations to earn +75 Flora Coins!',
      time: '5h ago',
      icon: Icons.explore_rounded,
      badgeColor: AppColors.butterYellow,
      category: 'EthnoRadar',
      targetTabIndex: 3,
    ),
    NotificationItem(
      id: '4',
      title: 'Flora Coins Streak Bonus! 🔥',
      message: 'You have maintained a 3-day research streak. Check your rank on the leaderboard!',
      time: '1d ago',
      icon: Icons.local_fire_department_rounded,
      badgeColor: AppColors.sageGreen,
      category: 'Leaderboard',
      targetTabIndex: 2,
    ),
    NotificationItem(
      id: '5',
      title: 'PhytoIntel Monograph & Alert ⚡',
      message: 'New phytochemical safety quiz published. Test your ethnobotany knowledge!',
      time: '1d ago',
      icon: Icons.bolt_rounded,
      badgeColor: AppColors.dustyCoral,
      category: 'PhytoIntel',
      targetTabIndex: 4,
    ),
    NotificationItem(
      id: '6',
      title: 'EthnoCollab Research Discussion 💬',
      message: 'New post trending in your research institute feed. Join the scholarly discussion!',
      time: '2d ago',
      icon: Icons.forum_rounded,
      badgeColor: AppColors.sageGreen,
      category: 'EthnoCollab',
      targetTabIndex: 1,
    ),
    NotificationItem(
      id: '7',
      title: 'PhytoDoc AI Assistant 🤖',
      message: 'Got questions about medicinal plants & herb-drug interactions? Consult PhytoDoc AI!',
      time: '3d ago',
      icon: Icons.smart_toy_rounded,
      badgeColor: AppColors.butterYellow,
      category: 'PhytoDoc AI',
      targetTabIndex: 6,
    ),
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.solidBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.butterYellow, width: 2),
        ),
        content: Text(
          'All notifications marked as read',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: AppColors.paperCream,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.solidBlack, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.solidBlack,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.solidBlack, size: 20),
              ),
            ),
          ),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.solidBlack,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.solidBlack, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.solidBlack,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.more_vert_rounded, color: AppColors.solidBlack, size: 20),
              ),
              color: AppColors.cardWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.solidBlack, width: 2.0),
              ),
              onSelected: (val) {
                if (val == 'read') _markAllAsRead();
                if (val == 'clear') _clearAll();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'read',
                  child: Text(
                    'Mark all as read',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.solidBlack,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Text(
                    'Clear all',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.red[700],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(width: 14),
        ],
      ),
      body: PaperGridBackground(
        child: _notifications.isEmpty
            ? Center(
                child: NeoCard(
                  radius: 20,
                  padding: const EdgeInsets.all(28),
                  color: AppColors.cardWhite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.butterYellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.solidBlack, width: 2.0),
                        ),
                        child: const Icon(Icons.notifications_off_rounded, size: 36, color: AppColors.solidBlack),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All Caught Up!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You have no unread notifications right now.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 40),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final item = _notifications[index];
                  return Dismissible(
                    key: Key(item.id),
                    onDismissed: (_) {
                      setState(() {
                        _notifications.removeAt(index);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeoCard(
                        radius: 18,
                        color: item.isRead ? AppColors.cardWhite : AppColors.pureWhite,
                        padding: const EdgeInsets.all(14),
                        onTap: () {
                          setState(() {
                            item.isRead = true;
                          });
                          final mainScreenState = context.findAncestorStateOfType<MainScreenState>();
                          if (mainScreenState != null) {
                            mainScreenState.onItemTapped(item.targetTabIndex);
                          }
                          Navigator.pop(context, item.targetTabIndex);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item.badgeColor,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.solidBlack, width: 1.8),
                              ),
                              child: Icon(item.icon, color: AppColors.solidBlack, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.paperCream,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.solidBlack, width: 1.2),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.solidBlack,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.time,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                                      color: AppColors.solidBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.message,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[800],
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Open ${item.category} →',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.dustyCoral,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
