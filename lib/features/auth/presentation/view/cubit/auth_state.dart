part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final StatusState<LoginResponse> loginStatus;
  final StatusState<RegisterResponseModel> registerStatus;
  final StatusState<bool> changePasswordStatus;
  final StatusState<bool> deleteAccountStatus;
  final bool rememberMe;

  const AuthState({
    this.loginStatus = const StatusState.initial(),
    this.registerStatus = const StatusState.initial(),
    this.changePasswordStatus = const StatusState.initial(),
    this.deleteAccountStatus = const StatusState.initial(),
    this.rememberMe = false,
  });

  AuthState copyWith({
    StatusState<LoginResponse>? loginStatus,
    StatusState<RegisterResponseModel>? registerStatus,
    StatusState<bool>? changePasswordStatus,
    StatusState<bool>? deleteAccountStatus,
    bool? rememberMe,
  }) {
    return AuthState(
      loginStatus: loginStatus ?? this.loginStatus,
      registerStatus: registerStatus ?? this.registerStatus,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      deleteAccountStatus: deleteAccountStatus ?? this.deleteAccountStatus,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  @override
  List<Object?> get props => [
        loginStatus,
        registerStatus,
        changePasswordStatus,
        deleteAccountStatus,
        rememberMe,
      ];
}
