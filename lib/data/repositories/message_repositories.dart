import 'package:chat_app/data/models/message_model.dart';
import 'package:chat_app/data/models/send_messages_model.dart';
import 'package:dio/dio.dart';

import '../../services/messages_services.dart';

class MessageRepositories {
  final MessageServices _messageServices = MessageServices();
  Future<dynamic> sendMessage(String receiverId, String message) async {
    Response response = await _messageServices.sendMessage(receiverId, message);
    if (response.statusCode == 200 || response.statusCode == 201) {
      SendMessageModel sendMessageModel =
          SendMessageModel.fromJson(response.data);
      return sendMessageModel;
    }
    return null;
  }

  Future<dynamic> getMessage(String receiverId) async {
    Response response = await _messageServices.getMessage(receiverId);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<MessageModel> sendMessageModel = [];
      List listMessage = response.data;
      for (int i = 0; i < listMessage.length; i++) {
        sendMessageModel.add(MessageModel.fromJson(listMessage[i]));
      }
      return sendMessageModel;
    }
    return null;
  }
}
