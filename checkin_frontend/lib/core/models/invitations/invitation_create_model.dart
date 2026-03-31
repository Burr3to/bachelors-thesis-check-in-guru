import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation_create_model.freezed.dart';
part 'invitation_create_model.g.dart';

@freezed
sealed class InvitationCreateModel with _$InvitationCreateModel {
  const factory InvitationCreateModel({
    required String email,
    required String taskId,
  }) = _InvitationCreateModel;

  factory InvitationCreateModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationCreateModelFromJson(json);
}