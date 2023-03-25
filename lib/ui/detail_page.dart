import 'package:dicoding_simple_notification/data/models/received_notification_model.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({Key? key}) : super(key: key);

  static const routeName = '/detail';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments != null
        ? ModalRoute.of(context)!.settings.arguments!
            as ReceivedNotificationModel
        : ReceivedNotificationModel();

    return Scaffold(
      appBar: AppBar(title: Text('Title: ${args.payload}')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
