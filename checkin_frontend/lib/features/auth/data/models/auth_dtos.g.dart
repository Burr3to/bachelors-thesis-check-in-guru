// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FirebaseTokenRequest _$FirebaseTokenRequestFromJson(
  Map<String, dynamic> json,
) => _FirebaseTokenRequest(idToken: json['idToken'] as String);

Map<String, dynamic> _$FirebaseTokenRequestToJson(
  _FirebaseTokenRequest instance,
) => <String, dynamic>{'idToken': instance.idToken};

_AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) =>
    _AuthResponse(
      token: json['token'] as String,
      userId: json['userId'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$AuthResponseToJson(_AuthResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'userId': instance.userId,
      'email': instance.email,
    };
