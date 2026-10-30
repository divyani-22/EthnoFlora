import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _notificationKey = 'notifications_enabled';
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;
  NotificationService._internal();

  Future<bool> isNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_notificationKey) ?? true;
    } catch (e) {
      print('❌ NotificationService: Error checking notification status: $e');
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, enabled);
      print('✅ NotificationService: Notifications set to $enabled');
    } catch (e) {
      print('❌ NotificationService: Error updating notification preference: $e');
    }
  }

  Future<void> enableNotifications() async => setNotificationsEnabled(true);
  Future<void> disableNotifications() async => setNotificationsEnabled(false);

  Future<void> sendNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final isEnabled = await isNotificationsEnabled();
      if (!isEnabled) return;

      print('📱 [Push Notification] $title — $body (Payload: $payload)');
    } catch (e) {
      print('❌ NotificationService: Error sending notification: $e');
    }
  }

  Future<void> sendDailyStreakReminder() async {
    await sendNotification(
      title: '🔥 Keep Your Botanical Streak Alive!',
      body: 'Complete today\'s EthnoRadar mission to earn +50 Flora Coins and maintain your campus rank.',
      payload: 'streak_reminder',
    );
  }

  Future<void> sendMissionApprovedNotification(String missionTitle, int points) async {
    await sendNotification(
      title: '🌟 Botanical Proof Approved!',
      body: 'Your proof for "$missionTitle" was verified! +$points Flora Coins awarded.',
      payload: 'mission_approved',
    );
  }

  Future<void> sendSwapNotification(String itemTitle) async {
    await sendNotification(
      title: '🌱 BioRepository Request Update',
      body: 'Someone is interested in your listing "$itemTitle". Tap to coordinate specimen handover.',
      payload: 'swap_update',
    );
  }
}
