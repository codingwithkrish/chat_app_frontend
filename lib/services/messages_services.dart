import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/networks/dio_simple.dart';

class MessageServices {
  DioNetwork dioNetwork = DioNetwork();
  final String _messages = dotenv.env['MESSAGES']!;
  final String _sendMessages = dotenv.env['SEND_MESSAGES']!;
  Future<dynamic> sendMessage(String receiverId, String message) async {
    var data = {"message": message};
    try {
      Response response =
          await dioNetwork.postData(_messages + _sendMessages + receiverId,data: data);

      return response;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
  Future<dynamic> getMessage(String receiverId) async {

    try {
      Response response =
      await dioNetwork.postData(_messages  + receiverId);

      return response;
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
