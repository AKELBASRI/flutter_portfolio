import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatRoom> _chatRooms = [];
  final User _currentUser = User(
    id: 'current_user',
    name: 'You',
    avatar: '😊',
    isOnline: true,
  );

  List<ChatRoom> get chatRooms => _chatRooms;
  User get currentUser => _currentUser;

  ChatProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final users = [
      User(id: 'user1', name: 'Alice Johnson', avatar: '👩‍💼', isOnline: true),
      User(id: 'user2', name: 'Bob Smith', avatar: '👨‍💻', isOnline: false),
      User(id: 'user3', name: 'Carol Davis', avatar: '👩‍🎨', isOnline: true),
      User(id: 'user4', name: 'David Wilson', avatar: '👨‍🔬', isOnline: true),
      User(id: 'user5', name: 'Emma Brown', avatar: '👩‍🏫', isOnline: false),
    ];

    final now = DateTime.now();

    _chatRooms.addAll([
      ChatRoom(
        id: 'chat1',
        name: 'Alice Johnson',
        participants: [_currentUser, users[0]],
        lastActivity: now.subtract(const Duration(minutes: 5)),
        messages: [
          Message(
            id: 'msg1',
            senderId: users[0].id,
            content: 'Hey! How are you doing today?',
            timestamp: now.subtract(const Duration(minutes: 10)),
          ),
          Message(
            id: 'msg2',
            senderId: _currentUser.id,
            content: 'I\'m doing great! Just working on some Flutter projects.',
            timestamp: now.subtract(const Duration(minutes: 8)),
          ),
          Message(
            id: 'msg3',
            senderId: users[0].id,
            content: 'That sounds awesome! I love Flutter too.',
            timestamp: now.subtract(const Duration(minutes: 5)),
          ),
        ],
      ),
      ChatRoom(
        id: 'chat2',
        name: 'Bob Smith',
        participants: [_currentUser, users[1]],
        lastActivity: now.subtract(const Duration(hours: 2)),
        messages: [
          Message(
            id: 'msg4',
            senderId: users[1].id,
            content: 'Can we schedule a meeting for tomorrow?',
            timestamp: now.subtract(const Duration(hours: 3)),
          ),
          Message(
            id: 'msg5',
            senderId: _currentUser.id,
            content: 'Sure! What time works for you?',
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      ChatRoom(
        id: 'chat3',
        name: 'Carol Davis',
        participants: [_currentUser, users[2]],
        lastActivity: now.subtract(const Duration(hours: 6)),
        messages: [
          Message(
            id: 'msg6',
            senderId: users[2].id,
            content: 'Check out this amazing design I just finished!',
            timestamp: now.subtract(const Duration(hours: 8)),
          ),
          Message(
            id: 'msg7',
            senderId: _currentUser.id,
            content: 'Wow, that looks incredible! Great work!',
            timestamp: now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),
      ChatRoom(
        id: 'chat4',
        name: 'David Wilson',
        participants: [_currentUser, users[3]],
        lastActivity: now.subtract(const Duration(days: 1)),
        messages: [
          Message(
            id: 'msg8',
            senderId: users[3].id,
            content: 'Happy birthday! Hope you have a wonderful day!',
            timestamp: now.subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ChatRoom(
        id: 'chat5',
        name: 'Emma Brown',
        participants: [_currentUser, users[4]],
        lastActivity: now.subtract(const Duration(days: 2)),
        messages: [
          Message(
            id: 'msg9',
            senderId: users[4].id,
            content: 'Thanks for helping me with the project!',
            timestamp: now.subtract(const Duration(days: 3)),
          ),
          Message(
            id: 'msg10',
            senderId: _currentUser.id,
            content: 'You\'re welcome! Anytime!',
            timestamp: now.subtract(const Duration(days: 2)),
          ),
        ],
      ),
    ]);

    notifyListeners();
  }

  void sendMessage(String chatRoomId, String content) {
    final chatRoomIndex = _chatRooms.indexWhere((room) => room.id == chatRoomId);
    if (chatRoomIndex != -1) {
      final message = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: _currentUser.id,
        content: content,
        timestamp: DateTime.now(),
      );

      _chatRooms[chatRoomIndex].messages.add(message);

      // Update last activity
      final updatedRoom = ChatRoom(
        id: _chatRooms[chatRoomIndex].id,
        name: _chatRooms[chatRoomIndex].name,
        participants: _chatRooms[chatRoomIndex].participants,
        messages: _chatRooms[chatRoomIndex].messages,
        avatar: _chatRooms[chatRoomIndex].avatar,
        lastActivity: DateTime.now(),
      );

      _chatRooms[chatRoomIndex] = updatedRoom;

      // Sort chat rooms by last activity
      _chatRooms.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

      notifyListeners();
    }
  }

  ChatRoom? getChatRoomById(String id) {
    try {
      return _chatRooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }
}