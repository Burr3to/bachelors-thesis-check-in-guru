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
      sentAt: DateTime.parse(json['sentAt'] as String),
    );

Map<String, dynamic> _$InvitationListModelToJson(
  _InvitationListModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'taskId': instance.taskId,
  'isAccepted': instance.isAccepted,
  'sentAt': instance.sentAt.toIso8601String(),
};
