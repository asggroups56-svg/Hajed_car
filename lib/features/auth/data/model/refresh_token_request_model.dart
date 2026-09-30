import 'package:equatable/equatable.dart';

class RefreshTokenRequest extends Equatable {
  final String refreshToken;
  final String grantType;

  const RefreshTokenRequest({required this.refreshToken, this.grantType = 'refresh_token'});

  Map<String, dynamic> toJson() {
    return {'grant_type': grantType, 'refresh_token': refreshToken};
  }

  @override
  List<Object?> get props => [refreshToken, grantType];
}
