import 'package:bloc/bloc.dart';
import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/network/status.state.dart';
import 'package:car/core/services/notification_service.dart';
import 'package:car/features/auth/data/model/change_password_request_model.dart';
import 'package:car/features/auth/data/model/login_request_model.dart';
import 'package:car/features/auth/data/model/login_response_model.dart';
import 'package:car/features/auth/data/model/register_request_model.dart';
import 'package:car/features/auth/data/model/register_response_model.dart';
import 'package:car/features/auth/data/repository/auth_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  AuthCubit(this.authRepo) : super(const AuthState()) {
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final savedRememberMe = HiveMethods.getRememberMe();
    emit(state.copyWith(rememberMe: savedRememberMe));
    if (savedRememberMe) {
      mobileController.text = HiveMethods.getSavedMobile();
      passwordController.text = HiveMethods.getSavedPassword();
    }
  }

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController accountTypeController = TextEditingController();

  // Registration specific controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController idNoController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();

  void clearRegisterFields() {
    fullNameController.clear();
    userNameController.clear();
    emailController.clear();
    idNoController.clear();
    registerPasswordController.clear();
  }

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool get rememberMe => state.rememberMe;

  void changeRememberMe() {
    final newRememberMe = !state.rememberMe;
    HiveMethods.updateRememberMe(newRememberMe);
    if (!newRememberMe) {
      HiveMethods.clearSavedCredentials();
    }
    emit(state.copyWith(rememberMe: newRememberMe));
  }

  Future<void> login() async {
    emit(state.copyWith(loginStatus: const StatusState.loading()));

    final request = LoginRequest(
      username: mobileController.text.trim(),
      password: passwordController.text.trim(),
      grantType: 'password',
    );

    final result = await authRepo.login(request: request);

    result.fold(
      (failure) {
        emit(state.copyWith(loginStatus: StatusState.failure(failure.errMessage)));
      },
      (response) async {
        HiveMethods.updateIsGuest(false);
        HiveMethods.updateToken(response.accessToken);
        HiveMethods.updateRole(response.type);
        HiveMethods.updateUserName(response.userName);
        HiveMethods.updateUserCode(response.code);
        HiveMethods.updateVatNumber(response.vatSerial);
        HiveMethods.updatecode(response.code);
        HiveMethods.phone(response.tel1 ?? '');
        HiveMethods.updateName(response.name);
        HiveMethods.updateRepresentativeNo(response.represNo);
        String fcmToken = await NotificationService.getFCMToken() ?? '';
        if (fcmToken.isEmpty) {
          fcmToken = 'dummy_token_for_simulator';
        }
        if (response.userId.isNotEmpty) {
          try {
            await authRepo.editFCM(userId: response.userId, fcmToken: fcmToken);
            debugPrint('EditFCM called successfully for user: ${response.userId}');
          } catch (e) {
            debugPrint('EditFCM failed: $e');
          }
        } else {
          debugPrint('EditFCM skipped: userId is empty');
        }

        HiveMethods.updateRememberMe(rememberMe);
        if (rememberMe) {
          HiveMethods.updateSavedMobile(mobileController.text.trim());
          HiveMethods.updateSavedPassword(passwordController.text.trim());
        } else {
          HiveMethods.clearSavedCredentials();
        }

        emit(state.copyWith(loginStatus: StatusState.success(response)));
      },
    );
  }

  Future<void> register() async {
    emit(state.copyWith(registerStatus: const StatusState.loading()));
    String fcmToken = await NotificationService.getFCMToken() ?? '';
    final request = RegisterRequestModel(
      userName: userNameController.text.trim(),
      fullname: fullNameController.text.trim(),
      email: emailController.text.trim(),
      idno: idNoController.text.trim(),
      password: registerPasswordController.text.trim(),
      fcm: fcmToken,
    );

    final result = await authRepo.register(request: request);

    result.fold(
      (failure) {
        emit(state.copyWith(registerStatus: StatusState.failure(failure.errMessage)));
      },
      (response) async {
        if (response.data) {
          clearRegisterFields();

          emit(state.copyWith(registerStatus: StatusState.success(response)));
        } else {
          emit(state.copyWith(registerStatus: const StatusState.failure('Registration failed')));
        }
      },
    );
  }

  Future<void> changePassword() async {
    emit(state.copyWith(changePasswordStatus: const StatusState.loading()));

    if (newPasswordController.text != confirmPasswordController.text) {
      emit(
        state.copyWith(
          changePasswordStatus: StatusState.failure(
            const Locale('ar').languageCode == 'ar'
                ? 'كلمة المرور الجديدة وتأكيدها غير متطابقتين'
                : 'Passwords do not match',
          ),
        ),
      );
      return;
    }

    final request = ChangePasswordRequestModel(
      oldPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    final result = await authRepo.changePassword(request: request);

    result.fold(
      (failure) {
        emit(state.copyWith(changePasswordStatus: StatusState.failure(failure.errMessage)));
      },
      (success) {
        if (success) {
          currentPasswordController.clear();
          newPasswordController.clear();
          confirmPasswordController.clear();
          emit(state.copyWith(changePasswordStatus: const StatusState.success(true)));
        } else {
          emit(
            state.copyWith(
              changePasswordStatus: StatusState.failure(
                const Locale('ar').languageCode == 'ar'
                    ? 'فشل تعديل كلمة المرور'
                    : 'Failed to change password',
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> logout() async {
    await authRepo.logout();
    HiveMethods.updateIsGuest(false);
    HiveMethods.deleteToken();
    HiveMethods.updateRole('user');
    HiveMethods.updateUserName('');
    clearRegisterFields();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    if (!rememberMe) {
      mobileController.clear();
      passwordController.clear();
      HiveMethods.clearSavedCredentials();
    }
    emit(AuthState(rememberMe: rememberMe));
  }

  Future<bool> deleteAccount() async {
    emit(state.copyWith(deleteAccountStatus: const StatusState.loading()));
    final result = await authRepo.deleteAccount();
    return result.fold(
      (failure) {
        emit(state.copyWith(deleteAccountStatus: StatusState.failure(failure.errMessage)));
        return false;
      },
      (success) async {
        await logout();
        emit(state.copyWith(deleteAccountStatus: const StatusState.success(true)));
        return true;
      },
    );
  }
}
