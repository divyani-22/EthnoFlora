import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/verification_request.dart';
import '../models/user.dart';
import '../services/verification_service.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class AdminModerationDashboardScreen extends StatefulWidget {
  final AppUser adminUser;
  final String schoolId;

  const AdminModerationDashboardScreen({
    Key? key,
    required this.adminUser,
    required this.schoolId,
  }) : super(key: key);

  @override
  State<AdminModerationDashboardScreen> createState() => _AdminModerationDashboardScreenState();
}

class _AdminModerationDashboardScreenState extends State<AdminModerationDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VerificationService _verificationService = VerificationService();
  final UserService _userService = UserService();

  List<VerificationRequest> _allRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await _verificationService.getSchoolVerificationRequests(widget.schoolId);
      if (mounted) {
        setState(() {
          _allRequests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveRequest(VerificationRequest request, int pointsToAward) async {
    try {
      await _verificationService.approveVerificationRequest(
        requestId: request.id,
        reviewerId: widget.adminUser.id,
        reviewNotes: 'Approved via School Admin Moderation Dashboard',
      );

      await _userService.addUserPoints(request.userId, pointsToAward);
      await NotificationService().sendMissionApprovedNotification(request.missionTitle, pointsToAward);

      await _loadRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.solidBlack,
            content: Text('✅ Approved "${request.missionTitle}" (+$pointsToAward Flora Coins awarded)'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Error approving request: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(VerificationRequest request, String reason) async {
    try {
      await _verificationService.rejectVerificationRequest(
        requestId: request.id,
        reviewerId: widget.adminUser.id,
        reviewNotes: reason.isNotEmpty ? reason : 'Proof image did not satisfy mission requirements.',
      );

      await _loadRequests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.solidBlack,
            content: Text('❌ Request rejected and status updated.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Error rejecting request: $e')),
        );
      }
    }
  }

  void _showImageZoomModal(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 64, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _allRequests.where((r) => r.isPending).toList();
    final approved = _allRequests.where((r) => r.isApproved).toList();
    final rejected = _allRequests.where((r) => r.isRejected).toList();

    return Scaffold(
      backgroundColor: AppColors.paperCream,
      appBar: AppBar(
        backgroundColor: AppColors.paperCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.solidBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'School Admin Dashboard',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.solidBlack,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.solidBlack,
          indicatorWeight: 3.0,
          labelColor: AppColors.solidBlack,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Approved (${approved.length})'),
            Tab(text: 'Rejected (${rejected.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.solidBlack))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestList(pending, isPending: true),
                _buildRequestList(approved),
                _buildRequestList(rejected),
              ],
            ),
    );
  }

  Widget _buildRequestList(List<VerificationRequest> requests, {bool isPending = false}) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          'No requests found in this section.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.solidBlack.withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        request.missionTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.butterYellow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.solidBlack, width: 1.5),
                      ),
                      child: Text(
                        '+${request.points} Flora Coins',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.solidBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Submitted by Student ID: ${request.userId.substring(0, request.userId.length > 8 ? 8 : request.userId.length)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.solidBlack.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),

                // Image Preview
                if (request.proofImageUrl != null && request.proofImageUrl!.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showImageZoomModal(request.proofImageUrl!, request.missionTitle),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            request.proofImageUrl!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 140,
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.broken_image, size: 40)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Tap to Zoom',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (request.description != null && request.description!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Student Notes: ${request.description}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.solidBlack.withValues(alpha: 0.8),
                    ),
                  ),
                ],

                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.solidBlack, width: 1.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _rejectRequest(request, 'Proof incomplete or invalid'),
                          child: Text('Reject', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricMint,
                            foregroundColor: AppColors.solidBlack,
                            side: const BorderSide(color: AppColors.solidBlack, width: 1.8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _approveRequest(request, request.points),
                          child: Text('Approve & Award', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
