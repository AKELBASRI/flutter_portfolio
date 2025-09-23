class User {
  final String id;
  final String name;
  final String avatar;
  final bool isOnline;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    this.isOnline = false,
  });
}

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
  });
}

enum MessageType {
  text,
  image,
  file,
}

class ChatRoom {
  final String id;
  final String name;
  final List<User> participants;
  final List<Message> messages;
  final String? avatar;
  final DateTime lastActivity;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    required this.messages,
    this.avatar,
    required this.lastActivity,
  });

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;

  User get otherParticipant {
    // For demo purposes, return the first participant that's not the current user
    return participants.firstWhere((user) => user.id != 'current_user', orElse: () => participants.first);
  }
}