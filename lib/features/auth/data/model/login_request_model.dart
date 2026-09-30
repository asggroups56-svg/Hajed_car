import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  final String username;
  final String password;
  final String grantType;
  final String clientType;

  const LoginRequest({
    required this.username,
    required this.password,
    this.grantType = 'password',
    required this.clientType,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'grant_type': grantType,
      'client_type': clientType,
    };
  }

  @override
  List<Object?> get props => [username, password, grantType];
}
