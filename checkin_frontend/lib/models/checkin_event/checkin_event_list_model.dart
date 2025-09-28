import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkin_event_list_model.freezed.dart';

part 'checkin_event_list_model.g.dart';

@freezed
abstract class CheckInEventListModel with _$CheckInEventListModel {
  const factory CheckInEventListModel({
    required String id,
    required String title,
    required String hash,      
    required DateTime createdAt,
    required String ownerId,
  }) = _CheckInEventListModel;

  factory CheckInEventListModel.fromJson(Map<String, dynamic> json) =>
      _$CheckInEventListModelFromJson(json);
}
