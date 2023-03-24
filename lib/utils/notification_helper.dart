// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:dicoding_simple_notification/data/models/received_notification_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

final selectNotificationSubject = BehaviorSubject<String?>();
final didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotificationModel>();

class NotificationHelper {
  factory NotificationHelper() => _instance ?? NotificationHelper._internal();

  NotificationHelper._internal() {
    _instance = this;
  }
  static const _channelId = '01';
  static const _channelName = 'channel_01';
  static const _channelDesc = 'dicoding channel';
  static NotificationHelper? _instance;

  // Kita akan membuat beberapa fungsi jenis notifikasi di dalam kelas ini
  Future<void> initNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(
          ReceivedNotificationModel(
            id: id,
            title: title,
            body: body,
            payload: payload,
          ),
        );
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        final payload = details.payload;
        if (payload != null) {
          if (kDebugMode) {
            print('notification payload: $payload');
          }
        }
        selectNotificationSubject.add(payload);
      },
    );
  }

  void requestIOSPermissions(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void configureDidReceiveLocalNotificationSubject(
    BuildContext context,
    String route,
  ) {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotificationModel receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.pushNamed(
                  context,
                  route,
                  arguments: receivedNotification,
                );
              },
            )
          ],
        ),
      );
    });
  }

  Future<void> showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'plain title',
      'plain body',
      platformChannelSpecifics,
      payload: 'plain notification',
    );
  }

  Future<void> showNotificationWithNoBody(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'plain title',
      null,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> scheduleNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    final dateTime =
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));
    final vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      icon: 'secondary_icon',
      sound: const RawResourceAndroidNotificationSound('slow_spring_board'),
      largeIcon: const DrawableResourceAndroidBitmap('sample_large_icon'),
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(sound: 'slow_spring_board.aiff');

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      dateTime,
      platformChannelSpecifics,
      payload: 'scheduled notification',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Future<void> showGroupedNotifications(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    const groupKey = 'com.android.example.WORK_EMAIL';

    const firstNotificationAndroidSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    const firstNotificationPlatformSpecifics =
        NotificationDetails(android: firstNotificationAndroidSpecifics);

    await flutterLocalNotificationsPlugin.show(
      1,
      'Alex Faarborg',
      'You will not believe...',
      firstNotificationPlatformSpecifics,
    );

    const secondNotificationAndroidSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      groupKey: groupKey,
    );

    const secondNotificationPlatformSpecifics =
        NotificationDetails(android: secondNotificationAndroidSpecifics);

    await flutterLocalNotificationsPlugin.show(
      2,
      'Jeff Chang',
      'Please join us to celebrate the...',
      secondNotificationPlatformSpecifics,
    );

    final lines = <String>[];
    lines.add('Alex Faarborg  Check this out');
    lines.add('Jeff Chang    Launch Party');

    final inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: '2 messages',
      summaryText: 'janedoe@example.com',
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: inboxStyleInformation,
      groupKey: groupKey,
      setAsGroupSummary: true,
    );

    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      3,
      'Attention',
      'Two messages',
      platformChannelSpecifics,
    );
  }

  Future<void> showProgressNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    const maxProgress = 5;
    for (var i = 0; i <= maxProgress; i++) {
      await Future.delayed(const Duration(seconds: 1), () async {
        final androidPlatformChannelSpecifics = AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          channelShowBadge: false,
          importance: Importance.max,
          priority: Priority.high,
          onlyAlertOnce: true,
          showProgress: true,
          maxProgress: maxProgress,
          progress: i,
        );

        final platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          0,
          'progress notification title',
          'progress notification body',
          platformChannelSpecifics,
          payload: 'item x',
        );
      });
    }
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showBigPictureNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    final largeIconPath = await _downloadAndSaveFile(
      'http://via.placeholder.com/48x48',
      'largeIcon',
    );
    final bigPicturePath = await _downloadAndSaveFile(
      'http://via.placeholder.com/400x800',
      'bigPicture',
    );

    final bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      contentTitle: 'overridden <b>big</b> content title',
      htmlFormatContentTitle: true,
      summaryText: 'summary <i>text</i>',
      htmlFormatSummaryText: true,
    );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: bigPictureStyleInformation,
    );

    final platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'big text title',
      'silent body',
      platformChannelSpecifics,
    );
  }

  Future<void> showNotificationWithAttachment(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    final bigPicturePath = await _downloadAndSaveFile(
      'http://via.placeholder.com/600x200',
      'bigPicture.jpg',
    );

    final bigPictureAndroidStyle =
        BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath));

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigPictureAndroidStyle,
    );

    final iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      attachments: [DarwinNotificationAttachment(bigPicturePath)],
    );

    final notificationDetails = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'notification with attachment title',
      'notification with attachment body',
      notificationDetails,
    );
  }

  void configureSelectNotificationSubject(BuildContext context, String route) {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(
        context,
        route,
        arguments: ReceivedNotificationModel(payload: payload),
      );
    });
  }
}
