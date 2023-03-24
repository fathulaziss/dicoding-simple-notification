import 'package:dicoding_simple_notification/main.dart';
import 'package:dicoding_simple_notification/ui/detail_page.dart';
import 'package:dicoding_simple_notification/utils/notification_helper.dart';
import 'package:dicoding_simple_notification/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _notificationHelper = NotificationHelper();

  @override
  void initState() {
    super.initState();
    _notificationHelper
      ..configureSelectNotificationSubject(
        context,
        DetailPage.routeName,
      )
      ..configureDidReceiveLocalNotificationSubject(
        context,
        DetailPage.routeName,
      );
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    didReceiveLocalNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Notification')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              CustomButton(
                text: 'Show plain notification with payload',
                onPressed: () async {
                  await _notificationHelper
                      .showNotification(flutterLocalNotificationsPlugin);
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Show plain notification that has no body with payload',
                onPressed: () async {
                  await _notificationHelper.showNotificationWithNoBody(
                    flutterLocalNotificationsPlugin,
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Show grouped notifications [Android]',
                onPressed: () async {
                  await _notificationHelper.showGroupedNotifications(
                    flutterLocalNotificationsPlugin,
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text:
                    'Show progress notification - updates every second [Android]',
                onPressed: () async {
                  await _notificationHelper.showProgressNotification(
                    flutterLocalNotificationsPlugin,
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Show big picture notification [Android]',
                onPressed: () async {
                  await _notificationHelper.showBigPictureNotification(
                    flutterLocalNotificationsPlugin,
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Show notification with attachment [iOS]',
                onPressed: () async {
                  await _notificationHelper.showNotificationWithAttachment(
                    flutterLocalNotificationsPlugin,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
