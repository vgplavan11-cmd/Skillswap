class ChatModel {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final Map<String, String> participantProfilePics;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;
  final Map<String, bool> typingStatus;
  final Map<String, bool> onlineStatus;

  ChatModel({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.participantProfilePics,
    this.lastMessage = '',
    this.lastMessageSenderId = '',
    required this.lastMessageTime,
    this.unreadCounts = const {},
    this.typingStatus = const {},
    this.onlineStatus = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantProfilePics': participantProfilePics,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCounts': unreadCounts,
      'typingStatus': typingStatus,
      'onlineStatus': onlineStatus,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      participantProfilePics: Map<String, String>.from(map['participantProfilePics'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : DateTime.now(),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
      typingStatus: Map<String, bool>.from(map['typingStatus'] ?? {}),
      onlineStatus: Map<String, bool>.from(map['onlineStatus'] ?? {}),
    );
  }
}
