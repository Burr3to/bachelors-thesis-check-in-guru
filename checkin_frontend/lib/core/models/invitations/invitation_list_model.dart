import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_list_model.freezed.dart';
part 'invitation_list_model.g.dart';

@freezed
sealed class InvitationListModel with _$InvitationListModel {
  const factory InvitationListModel({
    required String id,
    required String email,
    required String taskId,
    required bool isAccepted,
    required DateTime sentAt,
  }) = _InvitationListModel;

  factory InvitationListModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationListModelFromJson(json);
}