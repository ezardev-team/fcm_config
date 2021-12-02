import 'dart:async';
import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../click_stream_subscription.dart';
import '../details.dart';
import '../fcm_config_interface.dart';

part 'web_notification_manager.dart';

class FCMConfig extends FCMConfigInterface {
  FCMConfig._();
  static FCMConfig get instance => FCMConfig._();
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  @override
  Future<RemoteMessage?> getInitialMessage() async {
    return await FirebaseMessaging.instance.getInitialMessage();
  }

  @override
  Future init({
    /// this function will be excuted while application is in background
    BackgroundMessageHandler? onBackgroundMessage,

    /// Drawable icon works only in forground
    String defaultAndroidForegroundIcon = '@mipmap/ic_launcher',

    /// Required to show head up notification in foreground
    required dynamic defaultAndroidChannel,

    /// Request permission to display alerts. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool alert = true,

    /// Request permission for Siri to automatically read out notification messages over AirPods.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool announcement = false,

    /// Request permission to update the application badge. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool badge = true,

    /// Request permission to display notifications in a CarPlay environment.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool carPlay = false,

    /// Request permission for critical alerts. Defaults to `false`.
    ///
    /// Note; your application must explicitly state reasoning for enabling
    /// critical alerts during the App Store review process or your may be
    /// rejected.
    ///
    /// iOS only.
    bool criticalAlert = false,

    /// Request permission to provisionally create non-interrupting notifications.
    /// Defaults to `false`.
    ///
    /// iOS only.
    bool provisional = false,

    /// Request permission to play sounds. Defaults to `true`.
    ///
    /// iOS/macOS only.
    bool sound = true,

    /// Options to pass to core intialization method
    FirebaseOptions? options,

    ///Name of the firebase instance app
    String? name,

    /// if false the notification will not show on forground
    bool displayInForeground = true,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(name: name, options: options);
    await FirebaseMessaging.instance.requestPermission(
      alert: alert,
      announcement: announcement,
      criticalAlert: criticalAlert,
      badge: badge,
      carPlay: carPlay,
      sound: sound,
      provisional: provisional,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: alert,
      badge: badge,
      sound: sound,
    );
    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }
    if (displayInForeground) {
      FirebaseMessaging.onMessage.listen((event) {
        displayNotificationFrom(notification: event);
      });
    }
  }

  @override
  void displayNotification({
    required String title,
    required String body,
    String? subTitle,
    String? category,
    int? id,
    String? collapseKey,
    dynamic sound,
    dynamic androidChannel,
    Map<String, dynamic>? data,
  }) {
    var details = WebNotificationDetails(
      title: title,
      body: body,
      tag: collapseKey ?? id?.toString(),
    );
    WebNotificationManager.show(details, data);
  }

  @override
  void displayNotificationWithAndroidStyle({
    required String title,
    required dynamic styleInformation,
    required String body,
    int? id,
    String? subTitle,
    String? category,
    String? collapseKey,
    dynamic sound,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
    Map<String, dynamic>? data,
  }) {
    var details = WebNotificationDetails(
      title: title,
      body: body,
      tag: collapseKey ?? id?.toString(),
    );
    WebNotificationManager.show(details, data);
  }

  @override
  void displayNotificationWith({
    required String title,
    String? body,
    int? id,
    Map<String, dynamic>? data,
    required android,
    required iOS,
    required WebNotificationDetails? web,
  }) {
    WebNotificationManager.show(web!, data);
  }

  @override
  void displayNotificationFrom({
    required RemoteMessage notification,
    int? id,
    String? androidChannelId,
    String? androidChannelName,
    String? androidChannelDescription,
  }) {
    if (notification.notification == null) return;
    var details = WebNotificationDetails(
      title: notification.notification!.title ?? '',
      body: notification.notification!.body ?? '',
      tag: notification.collapseKey ?? id?.toString(),
    );
    WebNotificationManager.show(details, notification.data);
  }

  @override
  StreamSubscription<RemoteMessage> listen(ValueChanged<RemoteMessage> onData) {
    return FirebaseMessaging.onMessage.listen(onData);
  }

  @override
  ClickStreamSubscription listenClick(ValueChanged<RemoteMessage> onData) {
    return ClickStreamSubscription(
      WebNotificationManager.onLocaleClick.stream.listen(onData),
      FirebaseMessaging.onMessageOpenedApp.listen(onData),
    );
  }
}
