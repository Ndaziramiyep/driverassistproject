import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driverassist/models/chat_message_model.dart';
import 'package:driverassist/utils/constants.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ChatMessageModel>> getChatMessages(
      String userId, String serviceProviderId) {
    return _db
        .collection(AppConstants.chatCollection)
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ChatMessageModel.fromFirestore(d)).toList());
  }

  Future<void> sendMessage(ChatMessageModel message) async {
    await _db.collection(AppConstants.chatCollection).add(message.toMap());
  }

  Future<void> markAsRead(String messageId) async {
    await _db
        .collection(AppConstants.chatCollection)
        .doc(messageId)
        .update({'isRead': true});
  }

  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _db
        .collection(AppConstants.chatCollection)
        .where('receiverId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }
}
