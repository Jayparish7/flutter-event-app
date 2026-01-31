// To parse this JSON data, do
//
//     final refreshToken = refreshTokenFromJson(jsonString);

import 'dart:convert';

RefreshToken refreshTokenFromJson(str) => RefreshToken.fromJson(json.decode(str));

String refreshTokenToJson(RefreshToken data) => json.encode(data.toJson());

class RefreshToken {
  String? tokenType;
  int? expiresIn;
  String? accessToken;
  String? refreshToken;

  RefreshToken({
    this.tokenType,
    this.expiresIn,
    this.accessToken,
    this.refreshToken,
  });

  factory RefreshToken.fromJson(Map<String, dynamic> json) => RefreshToken(
    tokenType: json["token_type"],
    expiresIn: json["expires_in"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
  );

  Map<String, dynamic> toJson() => {
    "token_type": tokenType,
    "expires_in": expiresIn,
    "access_token": accessToken,
    "refresh_token": refreshToken,
  };
}
