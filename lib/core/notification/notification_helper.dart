import 'dart:async';
import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mishkat_almasabih/core/notification/notification_storage_helper.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static final StreamController<NotificationResponse>
  notificationResponseController =
      StreamController<NotificationResponse>.broadcast();

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      log('NotificationHelper already initialized');
      return;
    }

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notification.initialize(
        initSettings,
        onDidReceiveBackgroundNotificationResponse: _onNotificationTap,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );



  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

  _isInitialized = true;
  log('NotificationHelper initialized successfully');

      log('NotificationHelper initialized successfully');
    } catch (e) {
      log('Error initializing notifications: $e');
    }
  }

  @pragma('vm:entry-point')
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    notificationResponseController.add(notificationResponse);
  }

  static Future<void> dispose() async {
    await notificationResponseController.close();
    _isInitialized = false;
    log('NotificationHelper disposed');
  }

  static Future<void> showBasicNotification({
    required String title,
    required String body,
    int id = 0,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool silent = false,
    String? payload,
    String? soundName,
  }) async {
    try {
      await _notification.show(
        id,
        title,
        body,
        payload: payload,
        _buildNotificationDetails(
          channelId: 'basic_notification',
          channelName: 'Basic Notifications',
          channelDescription: 'Channel for basic notifications',
          importance: importance,
          priority: priority,
          silent: silent,
          soundName: soundName,
        ),
      );

      await NotificationStorageHelper.saveNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        type: 'basic',
      );

      log('Basic notification shown: $title');
    } catch (e) {
      log('Error showing basic notification: $e');
    }
  }

  static Future<void> showRepeatingNotification({
    required String title,
    required String body,
    int id = 0,
    RepeatInterval repeatInterval = RepeatInterval.everyMinute,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool silent = false,
    String? payload,
    String? soundName,
  }) async {
    try {
      await _notification.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        payload: payload,
        _buildNotificationDetails(
          channelId: 'repeating_notification',
          channelName: 'Repeating Notifications',
          channelDescription: 'Channel for repeating notifications',
          importance: importance,
          priority: priority,
          silent: silent,
          soundName: soundName,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      await NotificationStorageHelper.saveNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        type: 'repeating',
      );

      log('Repeating notification shown: $title');
    } catch (e) {
      log('Error showing repeating notification: $e');
    }
  }

  static Future<void> showScheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    int id = 0,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool silent = false,
    String? payload,
    String? soundName,
  }) async {
    try {
      final scheduledDate = tz.TZDateTime.now(tz.local).add(delay);

      await _notification.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _buildNotificationDetails(
          channelId: 'schedule_notification',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          importance: importance,
          priority: priority,
          silent: silent,
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      await NotificationStorageHelper.saveNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        type: 'scheduled',
      );

      log('Scheduled notification for: $scheduledDate');
    } catch (e) {
      log('Error scheduling notification: $e');
    }
  }

  static Future<void> scheduleNotificationAt({
    required String title,
    required String body,
    required DateTime dateTime,
    int id = 0,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
    bool silent = false,
    String? payload,
    String? soundName,
  }) async {
    try {
      log(  'Attempting to schedule notification at: $dateTime');
      final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        log('Cannot schedule notification in the past');
        return;
      }

      await _notification.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _buildNotificationDetails(
          channelId: 'schedule_notification',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          importance: importance,
          priority: priority,
          silent: silent,
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
            log(  'Attempting to schedule notification at:ccccime');

      log('Scheduled notification at: $scheduledDate');
    } catch (e) {
      log('Error scheduling notification: $e');
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _notification.cancel(id);
      log('Notification canceled: ID $id');
    } catch (e) {
      log('Error canceling notification: $e');
    }
  }

  static Future<void> cancelAllNotifications() async {
    try {
      await _notification.cancelAll();
      log('All notifications canceled');
    } catch (e) {
      log('Error canceling all notifications: $e');
    }
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    try {
      return await _notification.pendingNotificationRequests();
    } catch (e) {
      log('Error getting pending notifications: $e');
      return [];
    }
  }

  static Future<List<ActiveNotification>> getActiveNotifications() async {
    try {
      return await _notification.getActiveNotifications();
    } catch (e) {
      log('Error getting active notifications: $e');
      return [];
    }
  }

  static Future<void> showBigPictureNotification({
    required String title,
    required String body,
    required String bigPicturePath,
    int id = 0,
    String? payload,
    String? summaryText,
    bool hideExpandedLargeIcon = false,
  }) async {
    try {
      final BigPictureStyleInformation bigPictureStyle =
          BigPictureStyleInformation(
            FilePathAndroidBitmap(bigPicturePath),
            contentTitle: title,
            summaryText: summaryText ?? body,
            hideExpandedLargeIcon: hideExpandedLargeIcon,
          );

      final androidDetails = AndroidNotificationDetails(
        'big_picture_notification',
        'Big Picture Notifications',
        channelDescription: 'Channel for notifications with images',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyle,
        icon: '@mipmap/launcher_icon',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _notification.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );

      log('Big picture notification shown: $title');
    } catch (e) {
      log('Error showing big picture notification: $e');
    }
  }

  static Future<void> showBigPictureFromDrawable({
    required String title,
    required String body,
    required String drawableName,
    int id = 0,
    String? payload,
    String? summaryText,
  }) async {
    try {
      final BigPictureStyleInformation bigPictureStyle =
          BigPictureStyleInformation(
            DrawableResourceAndroidBitmap(drawableName),
            contentTitle: title,
            summaryText: summaryText ?? body,
          );

      final androidDetails = AndroidNotificationDetails(
        'big_picture_notification',
        'Big Picture Notifications',
        channelDescription: 'Channel for notifications with images',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyle,
        largeIcon: DrawableResourceAndroidBitmap(drawableName),
        icon: '@mipmap/launcher_icon',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _notification.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );

      log('Big picture from drawable shown: $title');
    } catch (e) {
      log('Error showing big picture notification: $e');
    }
  }

  static Future<void> showProgressNotification({
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    int id = 0,
    bool indeterminate = false,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'progress_notification',
        'Progress Notifications',
        channelDescription: 'Channel for progress notifications',
        importance: Importance.low,
        priority: Priority.low,
        showProgress: true,
        maxProgress: maxProgress,
        progress: progress,
        indeterminate: indeterminate,
        ongoing: progress < maxProgress,
        autoCancel: progress >= maxProgress,
        icon: '@mipmap/launcher_icon',
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
      );

      await _notification.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
      );

      log('Progress notification shown: $progress/$maxProgress');
    } catch (e) {
      log('Error showing progress notification: $e');
    }
  }

  static const String actionReply = 'reply_action';
  static const String actionMarkRead = 'mark_read_action';
  static const String actionDismiss = 'dismiss_action';

  static Future<void> showNotificationWithActions({
    required String title,
    required String body,
    int id = 0,
    String? payload,
    bool showReplyAction = true,
    bool showMarkReadAction = true,
  }) async {
    try {
      final List<AndroidNotificationAction> actions = [];

      if (showReplyAction) {
        actions.add(
          AndroidNotificationAction(
            actionReply,
            'Reply',
            inputs: [
              const AndroidNotificationActionInput(label: 'Type a message...'),
            ],
            showsUserInterface: true,
          ),
        );
      }

      if (showMarkReadAction) {
        actions.add(
          const AndroidNotificationAction(
            actionMarkRead,
            'Mark as Read',
            cancelNotification: true,
          ),
        );
      }

      actions.add(
        const AndroidNotificationAction(
          actionDismiss,
          'Dismiss',
          cancelNotification: true,
        ),
      );

      final androidDetails = AndroidNotificationDetails(
        'action_notification',
        'Action Notifications',
        channelDescription: 'Channel for notifications with action buttons',
        importance: Importance.max,
        priority: Priority.high,
        actions: actions,
        icon: '@mipmap/launcher_icon',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _notification.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );

      await NotificationStorageHelper.saveNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        type: 'action',
      );

      log('Notification with actions shown: $title');
    } catch (e) {
      log('Error showing notification with actions: $e');
    }
  }

  static Future<void> showGroupedNotification({
    required String groupKey,
    required String title,
    required String body,
    required int id,
    String? payload,
    bool isSummary = false,
    List<String>? inboxLines,
  }) async {
    try {
      StyleInformation? styleInformation;

      if (isSummary && inboxLines != null && inboxLines.isNotEmpty) {
        styleInformation = InboxStyleInformation(
          inboxLines,
          contentTitle: title,
          summaryText: '${inboxLines.length} messages',
        );
      }

      final androidDetails = AndroidNotificationDetails(
        'grouped_notification',
        'Grouped Notifications',
        channelDescription: 'Channel for grouped notifications',
        importance: Importance.max,
        priority: Priority.high,
        groupKey: groupKey,
        setAsGroupSummary: isSummary,
        styleInformation: styleInformation,
        icon: '@mipmap/launcher_icon',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'grouped_thread',
      );

      await _notification.show(
        id,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );

      if (!isSummary) {
        await NotificationStorageHelper.saveNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
          type: 'grouped',
        );
      }

      log('Grouped notification shown: $title (summary: $isSummary)');
    } catch (e) {
      log('Error showing grouped notification: $e');
    }
  }

  static Future<void> showNotificationGroup({
    required String groupKey,
    required List<Map<String, String>> notifications,
    required String summaryTitle,
    int startId = 1000,
  }) async {
    try {
      for (int i = 0; i < notifications.length; i++) {
        final notification = notifications[i];
        await showGroupedNotification(
          groupKey: groupKey,
          title: notification['title'] ?? 'Notification',
          body: notification['body'] ?? '',
          id: startId + i,
          payload: notification['payload'],
          isSummary: false,
        );
      }

      final inboxLines =
          notifications.map((n) => '${n['title']}: ${n['body']}').toList();

      await showGroupedNotification(
        groupKey: groupKey,
        title: summaryTitle,
        body: '${notifications.length} new notifications',
        id: startId + notifications.length,
        isSummary: true,
        inboxLines: inboxLines,
      );

      log(
        'Notification group shown: $summaryTitle with ${notifications.length} items',
      );
    } catch (e) {
      log('Error showing notification group: $e');
    }
  }

  static Future<void> showMediaNotification({
    required String title,
    required String body,
    required String artist,
    int id = 0,
    String? payload,
    String? albumArt,
    bool isPlaying = true,
  }) async {
    try {
      final List<AndroidNotificationAction> actions = [
        const AndroidNotificationAction(
          'media_previous',
          'Previous',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_skip_previous'),
          showsUserInterface: false,
        ),
        AndroidNotificationAction(
          isPlaying ? 'media_pause' : 'media_play',
          isPlaying ? 'Pause' : 'Play',
          icon: DrawableResourceAndroidBitmap(
            isPlaying ? '@drawable/ic_pause' : '@drawable/ic_play',
          ),
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'media_next',
          'Next',
          icon: DrawableResourceAndroidBitmap('@drawable/ic_skip_next'),
          showsUserInterface: false,
        ),
      ];

      final androidDetails = AndroidNotificationDetails(
        'media_notification',
        'Media Notifications',
        channelDescription: 'Channel for media playback controls',
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.transport,
        ongoing: isPlaying,
        autoCancel: false,
        showWhen: false,
        actions: actions,
        styleInformation: MediaStyleInformation(
          htmlFormatContent: true,
          htmlFormatTitle: true,
        ),
        icon: '@mipmap/launcher_icon',
        largeIcon:
            albumArt != null
                ? FilePathAndroidBitmap(albumArt)
                : const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      await _notification.show(
        id,
        title,
        '$artist • $body',
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload,
      );

      log('Media notification shown: $title by $artist');
    } catch (e) {
      log('Error showing media notification: $e');
    }
  }

  static Future<void> showSimpleMediaNotification({
    required String songTitle,
    required String artist,
    required String album,
    int id = 0,
    String? payload,
    bool isPlaying = true,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'media_notification',
        'Media Notifications',
        channelDescription: 'Channel for media playback controls',
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.transport,
        ongoing: isPlaying,
        autoCancel: false,
        showWhen: false,
        subText: album,
        styleInformation: MediaStyleInformation(
          htmlFormatContent: true,
          htmlFormatTitle: true,
        ),
        icon: '@mipmap/launcher_icon',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      );

      await _notification.show(
        id,
        songTitle,
        artist,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: payload ?? 'media:$songTitle',
      );

      log('Simple media notification shown: $songTitle by $artist');
    } catch (e) {
      log('Error showing simple media notification: $e');
    }
  }

  static NotificationDetails _buildNotificationDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
    bool silent = false,
    String? soundName,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      silent: silent,
      playSound: !silent && soundName != null,
      sound:
          soundName != null
              ? RawResourceAndroidNotificationSound(soundName)
              : null,
      enableVibration: !silent,
      icon: '@mipmap/launcher_icon',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !silent,
      sound: soundName != null ? '$soundName.aiff' : null,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }
}
