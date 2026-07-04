import 'dart:developer';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safir_drivers/global/global.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/main.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/models/trip_details.dart'; // اصلاح نام پکیج سفیر
import 'package:safir_drivers/widgets/notification_dialog.dart'; // اصلاح نام پکیج سفیر

class PushNotificationSystem {
  FirebaseMessaging firebaseCloudMessaging = FirebaseMessaging.instance;

  Future<String?> generateDeviceRegistrationToken() async {
    String? deviceRecognitionToken = await firebaseCloudMessaging.getToken();

    DatabaseReference referenceOnlineDriver = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");
    
    await referenceOnlineDriver.set(deviceRecognitionToken);
    
    // سابسکرایب به تاپیک‌های مربوطه
    firebaseCloudMessaging.subscribeToTopic("drivers");
    firebaseCloudMessaging.subscribeToTopic("users");
    return deviceRecognitionToken;
  }

  startListeningForNewNotification(BuildContext context) async {
    // ثبت کانال نوتیفیکیشن اختصاصی برای اپلیکیشن سفیر رانندگان
    var result = await FlutterNotificationChannel().registerNotificationChannel(
      description: 'برای نمایش نوتیفیکیشن‌های درخواست سفر سفیر',
      id: 'safirDriversApp', // اصلاح شناسه کانال به نام پروژه سفیر
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Safir Drivers',
    );

    log('\nNotification Channel Result: $result');

    // ۱. وضعیت Terminated (برنامه کاملاً بسته بوده و با کلیک روی نوتیفیکیشن باز شده است)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String? tripID = messageRemote.data["tripID"];
        if (tripID != null) {
          print("Terminated Trip ID: $tripID");
          retrieveTripRequestInfo(tripID, context);
        }
      }
    });

    // ۲. وضعیت Foreground (راننده داخل برنامه است و نوتیفیکیشن دریافت می‌شود)
    FirebaseMessaging.onMessage.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String? tripID = messageRemote.data["tripID"];
        if (tripID != null) {
          print("Foreground Trip ID: $tripID");
          retrieveTripRequestInfo(tripID, context);
        }
      }
    });

    // ۳. وضعیت Background (برنامه باز است ولی در پس‌زمینه قرار دارد و روی نوتیفیکیشن کلیک می‌شود)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? messageRemote) {
      if (messageRemote != null) {
        String? tripID = messageRemote.data["tripID"];
        if (tripID != null) {
          print("Background Trip ID: $tripID");
          retrieveTripRequestInfo(tripID, context);
        }
      }
    });
  }

  retrieveTripRequestInfo(String tripID, BuildContext context) {
    final currentContext = navigatorKey.currentContext;

    if (currentContext != null) {
      DatabaseReference tripRequestsRef =
          FirebaseDatabase.instance.ref().child("tripRequest").child(tripID);

      tripRequestsRef.once().then((dataSnapshot) {
        log("DataSnapshot: ${dataSnapshot.snapshot.value}");

        if (dataSnapshot.snapshot.value == null) {
          log("Error: No data found for tripID $tripID");
          return;
        }

        try {
          final data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
          log("Trip Data: $data");

          // مدیریت پخش صدای هشدار درخواست جدید به صورت امن
          audioPlayer.stop().then((_) {
            audioPlayer.open(
              Audio("assets/audio/alert-sound.mp3"),
            );
            audioPlayer.play();
          });

          TripDetails tripDetailsInfo = TripDetails();

          // پارس کردن اطلاعات مبدا
          final pickUpLatLng = data["pickUpLatLng"] as Map<dynamic, dynamic>;
          double pickUpLat = double.parse(pickUpLatLng["latitude"].toString());
          double pickUpLng = double.parse(pickUpLatLng["longitude"].toString());
          tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);
          tripDetailsInfo.pickupAddress = data["pickUpAddress"].toString();

          // پارس کردن اطلاعات مقصد
          final dropOffLatLng = data["dropOffLatLng"] as Map<dynamic, dynamic>;
          double dropOffLat = double.parse(dropOffLatLng["latitude"].toString());
          double dropOffLng = double.parse(dropOffLatLng["longitude"].toString());
          tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);
          tripDetailsInfo.dropOffAddress = data["dropOffAddress"].toString();

          // جزییات مسافر و مبالغ کرایه
          tripDetailsInfo.userName = data["userName"].toString();
          tripDetailsInfo.userPhone = data["userPhone"].toString();
          bidAmount = data["bidAmount"].toString();
          fareAmount = data["fareAmount"].toString();
          tripDetailsInfo.tripID = tripID;

          // نمایش دیالوگ پاپ‌آپ درخواست سفر به راننده
          showDialog(
            context: currentContext,
            barrierDismissible: false, // راننده حتماً باید دکمه رد یا قبول را بزند
            builder: (BuildContext context) => NotificationDialog(
              tripDetailsInfo: tripDetailsInfo,
              bidAmount: bidAmount,
              fareAmount: fareAmount,
            ),
          );
        } catch (e, stackTrace) {
          log("Error parsing trip request info: $e\n$stackTrace");
        }
      }).catchError((error) {
        log("Firebase error: $error");
      });
    }
  }
}
