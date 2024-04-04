import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/bloc/receiveMessage/receive_message_bloc.dart';
import 'package:chat_app/data/local/cache_manager.dart';
import 'package:chat_app/data/models/message_model.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:chat_app/utils/colors.dart' as cs;

import '../../bloc/sendMessage/send_message_bloc.dart';
import '../../data/injection/dependency_injection.dart';
import '../../data/models/users_model.dart';
import '../../services/socket_services.dart';

class ChatScreen extends StatelessWidget {
  User? user;
  final ReceiveMessageBloc _receiveMessageBloc;

  ChatScreen({super.key, required this.user})
      : _receiveMessageBloc = ReceiveMessageBloc() {
    _receiveMessageBloc.add(ReceiveMessage(receiverId: user!.id!));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController = TextEditingController();
    ScrollController _scrollController = new ScrollController();
    void scrollToItem(int index) {
      if (!_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut);
      } else {
        _scrollController.animateTo(
          index *
              70, // You may need to adjust this value based on your item height
          duration: Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    }

    return Scaffold(
      backgroundColor: cs.Colors().backGroundColor,
    resizeToAvoidBottomInset: true,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_sharp,color: Colors.white,),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(45)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: CachedNetworkImage(
                  width: 50,
                  height: 50,
                  imageUrl: user!.profileImageUrl!,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                
                          image: imageProvider,
                          fit: BoxFit.cover,
                          ),
                    ),
                  ),
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user!.name!,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                Text(user!.phone!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                StreamBuilder(
                    stream: getIt<SocketServices>().onlineUserStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<dynamic> onlineUsers =
                            snapshot.data as List<dynamic>;
                        print(onlineUsers);
                        return onlineUsers.contains(user!.id)
                            ? const Text("Online",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 15))
                            : const SizedBox.shrink();
                      } else {
                        return const SizedBox.shrink();
                      }
                    })
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(

              child: BlocConsumer(
                bloc: _receiveMessageBloc,
                listener: (context, state) {
                  // TODO: implement listener
                  if (state is ReceiverMessageSuccess) {
                    Future.delayed(Duration(milliseconds: 50)).then((value) {
                      scrollToItem(_receiveMessageBloc.messageData.length - 1);
                    });
                  }
                },
                builder: (context, state) {
                  if (state is ReceiverMessageLoading)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  if (state is ReceiverMessageFailed)
                    return Center(
                      child: Text("Failed Retrive Message"),
                    );
                  if (state is ReceiverMessageSuccess) {
                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: state.messageModel.length,
                        itemBuilder: (context, i) {
                          return BubbleSpecialThree(
                            text: state.messageModel[i].message!,
                            isSender: state.messageModel[i].senderId ==
                                getIt<CacheManager>().getUserId(),
                            color: state.messageModel[i].senderId ==
                                    getIt<CacheManager>().getUserId()
                                ? cs.Colors().sendBackgroundColor
                                : cs.Colors().receiveBackgroundColor,
                            tail: true,
                            textStyle: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ).marginSymmetric(horizontal: 5);
                        }).marginSymmetric(vertical: 3);
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 70,
                child: BlocConsumer<SendMessageBloc, SendMessageState>(
                  listener: (context, state) {
                    // TODO: implement listener
                    if (state is SendMessageSuccess) {
                      _receiveMessageBloc.add(AddMessage(
                          messageModel: MessageModel.fromJson(
                              state.sendMessageModel.message!.toJson())));
                      scrollToItem(
                          _receiveMessageBloc.messageData.length - 1);
                    }
                  },
                  builder: (context, state) {
                    return MessageBar(
                      onSend: (_) {
                        if (_.isNotEmpty) {
                          context.read<SendMessageBloc>().add(SendMessage(
                              receiverId: user!.id!,
                              message: _,
                              receiveMessageBloc: _receiveMessageBloc));
                        }
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
