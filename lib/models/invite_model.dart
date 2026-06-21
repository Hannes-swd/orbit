import 'package:cloud_firestore/cloud_firestore.dart';

class CircleInvite {
  final String id;
  final String circleId;
  final String circleName;
  final String invitedUserId;
  final String invitedDisplayName;
  final String invitedBy;
  final DateTime invitedAt;
  final String status;

  CircleInvite({
    required this.id,
    required this.circleId,
    required this.circleName,
    required this.invitedUserId,
    required this.invitedDisplayName,
    required this.invitedBy,
    required this.invitedAt,
    required this.status,
  });

  factory CircleInvite.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CircleInvite(
      id: doc.id,
      circleId: data['circleId'] ?? '',
      circleName: data['circleName'] ?? '',
      invitedUserId: data['invitedUserId'] ?? '',
      invitedDisplayName: data['invitedDisplayName'] ?? '',
      invitedBy: data['invitedBy'] ?? '',
      invitedAt: (data['invitedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}
