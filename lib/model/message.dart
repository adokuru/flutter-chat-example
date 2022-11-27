class Message {
  final String message;
  final String chatID;
  final String senderUsername;
  final String sentAt;

  Message({
    required this.message,
    required this.senderUsername,
    required this.chatID,
    required this.sentAt,
  });

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      senderUsername: message['sender'],
      chatID: message['chatID'],
      sentAt: message['sentAt'],
    );
  }
}
