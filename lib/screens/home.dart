// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_socket_io/model/message.dart';
import 'package:flutter_socket_io/providers/home.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IO.Socket _socket;
  final TextEditingController _messageInputController = TextEditingController();
  final chatID = 'chat';

  _sendMessage() {
    _socket.emit('message', {
      'message': _messageInputController.text.trim(),
      'chatID': chatID,
      'sender': widget.username,
      'sentAt': "1 mintue ago",
    });
    _messageInputController.clear();
    Provider.of<HomeProvider>(context, listen: false).addNewMessage(Message(
      message: _messageInputController.text.trim(),
      chatID: chatID,
      senderUsername: widget.username,
      sentAt: "1 mintue ago",
    ));
  }

  _connectSocket() {
    // Connect to socket
    _socket.onConnect((data) =>
        {print('Connected to socket'), _socket.emit('signIn', chatID)});

    // Errors
    _socket.onConnectError((data) => print('Connect Error: $data'));

    // Disconnect
    _socket.onDisconnect((data) => {
          print('Socket.IO server disconnected'),
          _socket.emit('signOut', chatID)
        });

    _socket.on(
      'message',
      (data) => {
        print('Message received: $data'),
        Provider.of<HomeProvider>(context, listen: false).addNewMessage(
          Message.fromJson(data),
        )
      },
    );
  }

  @override
  void initState() {
    super.initState();
    //Important: If your server is running on localhost and you are testing your app on Android then replace http://localhost:3000 with http://10.0.2.2:3000
    _socket = IO.io(
      'https://mycircle-chat-server.onrender.com',
      IO.OptionBuilder().setTransports(['websocket']).setQuery(
          {'username': widget.username}).build(),
    );
    _connectSocket();
  }

  @override
  void dispose() {
    _messageInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Socket.IO'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<HomeProvider>(
              builder: (_, provider, __) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final message = provider.messages[index];
                  return Wrap(
                    alignment: message.senderUsername == widget.username
                        ? WrapAlignment.end
                        : WrapAlignment.start,
                    children: [
                      Card(
                        color: message.senderUsername == widget.username
                            ? Theme.of(context).primaryColorLight
                            : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                message.senderUsername == widget.username
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Text(message.message),
                              Text(
                                message.sentAt,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
                separatorBuilder: (_, index) => const SizedBox(
                  height: 5,
                ),
                itemCount: provider.messages.length,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageInputController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_messageInputController.text.trim().isNotEmpty) {
                        _sendMessage();
                      }
                    },
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
