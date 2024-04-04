
import 'package:chat_app/data/injection/dependency_injection.dart';
import 'package:chat_app/data/local/app_notification.dart';
import 'package:chat_app/data/local/cache_manager.dart';
import 'package:chat_app/presentation/chat/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../data/models/users_model.dart';

class OneSignalServices {
  Future<void> initPlatformState() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.consentRequired(true);
    OneSignal.consentGiven(true);
    OneSignal.initialize("ac7e228f-efea-4b46-9007-25524ccbc5eb");

    OneSignal.Notifications.requestPermission(true);

    OneSignal.User.pushSubscription.addObserver((state) {
      print("OneSignal Krish ${OneSignal.User.pushSubscription.optedIn}");
      print("OneSignal Krish ${OneSignal.User.pushSubscription.id}");
      print("OneSignal Krish ${OneSignal.User.pushSubscription.token}");
      print("OnSignal Krish ${state.current.jsonRepresentation()}");
    });

    hasPermission();


    OneSignal.Notifications.addClickListener((event) {
      navigate(event);

    });
  }
  void navigate(OSNotificationClickEvent event){
    Map<String,dynamic> json = event.notification.additionalData!;
    print("Krish ${json}");
    print("Krish ${json["user"]["_id"]}");
    print("Krish");
    Navigator.push(Get.context!, MaterialPageRoute(builder: (builder)=>ChatScreen(user: User(id: json["_id"], name: json["name"], email: json["email"], phone: json["phone"], profileImageUrl: json["profileImageUrl"], createdAt: json["createdAt"], updatedAt: json["updatedAt"], v: json["__v"]))));
    print("Krish");

  }

  Future<void> setUserLogin() async {
    String userId = getIt<CacheManager>().getUserId();
    await OneSignal.login(userId);
    await OneSignal.User.pushSubscription.optIn();
  }

  Future<void> hasPermission() async {
    OneSignal.Notifications.addPermissionObserver((state) {
      if (kDebugMode) {
        print("Has permission $state");
      }
    });
  }

  Future<void> setNotificationToken() async {
    print("Krish${OneSignal.User.pushSubscription.id.toString()}");
    await getIt<CacheManager>().setNotificationSubscription(
        OneSignal.User.pushSubscription.id.toString());

    OneSignal.User.pushSubscription.addObserver((state) {
      print("OneSignal Krish ${OneSignal.User.pushSubscription.optedIn}");
      print("OneSignal Krish ${OneSignal.User.pushSubscription.id}");
      print("OneSignal Krish ${OneSignal.User.pushSubscription.token}");
      print("OnSignal Krish ${state.current.jsonRepresentation()}");
    });
  }

  void handlePromptForPushPermission() {
    if (kDebugMode) {
      print("Prompting for Permission");
    }
    OneSignal.Notifications.requestPermission(true);
  }

  void handleConsent() {
    if (kDebugMode) {
      print("Setting consent to true");
    }
    OneSignal.consentGiven(true);
  }

  Future<void> handleLogin() async {
    //await OneSignal.login(userId);
    // await OneSignal.User.addAlias("user_id", userId);
  }

  Future<void> handleLogout() async {
    await OneSignal.logout();
    await OneSignal.User.removeAlias("user_id");
  }

  Future<void> handleOptIn() async {
    await OneSignal.User.pushSubscription.optIn();
  }

  Future<void> handleOptOut() async {
    await OneSignal.User.pushSubscription.optOut();
  }
}
