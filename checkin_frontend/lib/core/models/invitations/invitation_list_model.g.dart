// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InvitationListModel _$InvitationListModelFromJson(Map<String, dynamic> json) =>
    _InvitationListModel(
      id: json['id'] as String,
      email: json['email'] as String,
      taskId: json['taskId'] as String,
      isAccepted: json['isAccepted'] as bool,
      isSent: json['isSent'] as bool,
      isCompleted: json['isCompleted'] as bool,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$InvitationListModelToJson(
  _InvitationListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'taskId': instance.taskId,
  'isAccepted': instance.isAccepted,
  'isSent': instance.isSent,
  'isCompleted': instance.isCompleted,
  'sentAt': instance.sentAt?.toIso8601String(),
};
