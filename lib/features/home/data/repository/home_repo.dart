import 'dart:convert';
import 'dart:io';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/error/failures.dart';
import 'package:car/core/network/api_consumer.dart';
import 'package:car/core/network/end_points.dart';
import 'package:car/features/home/data/model/add_booking_permission_model.dart';
import 'package:car/features/home/data/model/add_booking_permission_response_model.dart';
import 'package:car/features/home/data/model/add_loan_application_model.dart';
import 'package:car/features/home/data/model/add_loan_application_response_model.dart';
import 'package:car/features/home/data/model/banks_data_model.dart';
import 'package:car/features/home/data/model/brand_cars_data_model.dart';
import 'package:car/features/home/data/model/cancel_reserved_car_model.dart';
import 'package:car/features/home/data/model/cancel_reserved_car_response_model.dart';
import 'package:car/features/home/data/model/cars_models_response.dart';
import 'package:car/features/home/data/model/customer_loan_application_model.dart';
import 'package:car/features/home/data/model/financing_ad_model.dart';
import 'package:car/features/home/data/model/send_otp_model.dart';
import 'package:car/features/home/data/model/send_otp_response_model.dart';
import 'package:car/features/home/data/model/send_whatsapp_model.dart';
import 'package:car/features/notifications/data/model/notification_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract interface class HomeRepo {
  Future<Either<Failure, CarsModelsResponse>> getCarsModels();
  Future<Either<Failure, List<GetBrandCarsDataModel>>> getBrandCars(
    String brandId,
  );
  Future<Either<Failure, AddBookingPermissionResponseModel>>
  addBookingPermission(AddBookingPermissionModel model);
  Future<Either<Failure, List<GetBrandCarsDataModel>>> fetchAllCars(
    int? brandId,
    String? frommakeyear,
    String? tomakeyear,
    int? fromprice,
    int? toprice,
    String? fuelType,
  );
  Future<Either<Failure, CancelReservedCarResponseModel>> cancelreservedcar(
    CancelReservedCarModel model,
  );
  Future<Either<Failure, SendOtpResponseModel>> sendOtp(SendOtpModel model);
  Future<Either<Failure, List<BANKSDATAModel>>> getBanks(String? Searchval);
  Future<Either<Failure, List<FinancingAdModel>>> getFinancingAds({
    String? code,
  });
  Future<Either<Failure, List<FinancingAdModel>>> getNormalFinancing({
    String? code,
  });
  Future<Either<Failure, AddLoanApplicationResponseModel>>
  addLoanApplicationWithFiles({
    required AddLoanApplicationModel model,
    required List<File> files,
  });
  Future<Either<Failure, List<CustomerLoanApplicationModel>>>
  getCustLoanApplications(String code);
  Future<Either<Failure, List<NotificationModel>>> getNotificationsData({
    required String currentUserId,
    required int userType,
  });
  Future<Either<Failure, String>> editBooking({
    required int represCode,
    required int lpoNo,
    required int customerNo,
    required int notifyId,
  });
  Future<Either<Failure, String>> editLoan({
    required int represCode,
    required int relatedEntityId,
    required int notifyId,
    required int isApproved,
    required int? customerNo,
  });
  Future<Either<Failure, SendWhatsAppResponseModel>> sendWhatsApp(
    SendWhatsAppModel model,
  );
}

class HomeRepoImpl implements HomeRepo {
  @override
  final ApiConsumer apiConsumer;
  HomeRepoImpl(this.apiConsumer);
  @override
  Future<Either<Failure, CarsModelsResponse>> getCarsModels() async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(EndPoints.carsModel);
        return CarsModelsResponse.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, AddBookingPermissionResponseModel>>
  addBookingPermission(AddBookingPermissionModel model) async {
    return handleDioRequest(
      request: () async {
        final userName = HiveMethods.getUserName()?.trim() ?? '';
        final response = await apiConsumer.post(
          EndPoints.addbooking,
          body: model.toJson(),
          headers: userName.isNotEmpty
              ? {'username': Uri.encodeComponent(userName)}
              : null,
        );
        final result = AddBookingPermissionResponseModel.fromJson(response);

        // Fetch FCM tokens and send push notifications
        // try {
        //   final carDetails = model.subLpo.isNotEmpty
        //       ? model.subLpo.first.itemName
        //       : 'حجز سيارة جديدة';
        //   await _sendFcmNotifications(
        //     customerNo: model.customerNo,
        //     represCode: model.represCode,
        //     carDetails: carDetails,
        //     bookingNo: result.lpoNo,
        //   );
        // } catch (e) {
        //   if (kDebugMode) {
        //     print('[addBookingPermission FCM Error] $e');
        //   }
        // }

        return result;
      },
    );
  }

  // Future<void> _sendFcmNotifications({
  //   required int customerNo,
  //   required int represCode,
  //   required String carDetails,
  //   required String bookingNo,
  // }) async {
  //   final fcmResponse = await apiConsumer.get(
  //     EndPoints.getFCM,
  //     queryParameters: {'CUSTOMER_NO': customerNo, 'REPRESCODE': represCode},
  //   );

  //   List<String> tokens = [];
  //   dynamic rawData = fcmResponse['Data'];
  //   if (rawData is String && rawData.isNotEmpty && rawData != 'null') {
  //     try {
  //       rawData = jsonDecode(rawData);
  //     } catch (_) {}
  //   }

  //   if (rawData is List) {
  //     for (var item in rawData) {
  //       if (item is Map && item.containsKey('FCM') && item['FCM'] != null) {
  //         final t = item['FCM'].toString().trim();
  //         if (t.isNotEmpty) tokens.add(t);
  //       }
  //     }
  //   }

  //   if (tokens.isEmpty) return;

  //   final String userName = (HiveMethods.getname() ?? HiveMethods.getname()) ?? '';
  //   final String userPhone = (HiveMethods.getphone() ?? HiveMethods.getSavedMobile()) ?? '';
  //   final String userInfo = [
  //     if (userName.isNotEmpty) 'اسم العميل: $userName',
  //     if (userPhone.isNotEmpty) 'الجوال: $userPhone',
  //   ].join(' | ');

  //   final String bookingText = bookingNo.isNotEmpty ? ' | رقم الحجز: $bookingNo' : '';
  //   final String bodyForOthers = userInfo.isNotEmpty
  //       ? '$userInfo$bookingText'
  //       : 'تم حجز السيارة بنجاح$bookingText';

  //   // 1st SendNotification: يرسل للعميل الذي قام بالحجز فقط (tokens[0])
  //   await apiConsumer.post(
  //     EndPoints.sendNotification,
  //     body: {
  //       'deviceToken': [tokens[0]],
  //       'title': 'تجربة إشعار حجز',
  //       'body': 'تم حجز السيارة ($carDetails) بنجاح وسيتم التواصل معكم قريباً.',
  //     },
  //   );

  //   // 2nd SendNotification: يرسل لباقي التوكينات فقط (tokens.sublist(1)) مع رقم الحجز
  //   if (tokens.length > 1) {
  //     await apiConsumer.post(
  //       EndPoints.sendNotification,
  //       body: {'deviceToken': tokens.sublist(1), 'title': carDetails, 'body': bodyForOthers},
  //     );
  //   }
  // }

  @override
  Future<Either<Failure, List<GetBrandCarsDataModel>>> getBrandCars(
    String brandId,
  ) async {
    if (brandId.isEmpty || brandId == 'null') {
      return const Right([]);
    }
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getprandcars,
          queryParameters: {'id': brandId},
        );
        return GetBrandCarsDataModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, List<GetBrandCarsDataModel>>> fetchAllCars(
    int? brandId,
    String? frommakeyear,
    String? tomakeyear,
    int? fromprice,
    int? toprice,
    String? fuelType,
  ) async {
    return handleDioRequest(
      request: () async {
        final queryParams = {
          'id': brandId.toString(),
          'frommakeyear': frommakeyear ?? '',
          'tomakeyear': tomakeyear ?? '',
          'fromprice': fromprice.toString(),
          'toprice': toprice.toString(),
          'FUEL_TYPE': fuelType ?? '',
        };

        try {
          final response = await apiConsumer.get(
            EndPoints.getprandcars,
            queryParameters: queryParams,
          );
          return GetBrandCarsDataModel.listFromResponse(response['Data']);
        } on DioException catch (e) {
          if (e.response?.statusCode == 500) {
            final data = e.response?.data;
            final carsData = data is Map ? data['Data'] : null;
            if (carsData != null && carsData != 'null' && carsData != '[]') {
              if (kDebugMode)
                print(
                  '[fetchAllCars] Got 500 but found valid Data, parsing...',
                );
              return GetBrandCarsDataModel.listFromResponse(carsData);
            }
          }
          rethrow;
        }
      },
    );
  }

  @override
  Future<Either<Failure, CancelReservedCarResponseModel>> cancelreservedcar(
    CancelReservedCarModel model,
  ) {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.cancelreservedcar,
          body: model.toJson(),
          headers: {
            'username': Uri.encodeComponent(
              HiveMethods.getUserName().toString(),
            ),
          },
        );
        final result = CancelReservedCarResponseModel.fromJson(response);

        // if (result.success) {
        //   try {
        //     await _sendCancelFcmNotification(model);
        //   } catch (e) {
        //     if (kDebugMode) {
        //       print('[cancelreservedcar FCM Error] $e');
        //     }
        //   }
        // }

        return result;
      },
    );
  }

  // Future<void> _sendCancelFcmNotification(CancelReservedCarModel model) async {
  //   final fcmToken = await NotificationService.getFCMToken();
  //   if (fcmToken == null || fcmToken.isEmpty) return;

  //   final String carInfo = model.notes.isNotEmpty ? model.notes : model.itemCode;
  //   final String lpoText = model.lpoNo.isNotEmpty ? ' | رقم الحجز: ${model.lpoNo}' : '';
  //   final String bodyText = 'تم إلغاء حجز السيارة بنجاح ($carInfo)$lpoText';

  //   await apiConsumer.post(
  //     EndPoints.sendNotification,
  //     body: {
  //       'deviceToken': [fcmToken],
  //       'title': 'تجربة إشعار حجز',
  //       'body': bodyText,
  //     },
  //   );
  // }

  @override
  Future<Either<Failure, SendOtpResponseModel>> sendOtp(
    SendOtpModel model,
  ) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.sendotp,
          body: model.toJson(),
        );
        return SendOtpResponseModel.fromJson(response);
      },
    );
  }

  @override
  Future<Either<Failure, List<BANKSDATAModel>>> getBanks(
    String? Searchval,
  ) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.customer,
          queryParameters: {
            'Searchval': Searchval,
            'TableName': 'sp_BANKS_DATA_search_sel',
          },
        );
        return BANKSDATAModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, List<FinancingAdModel>>> getFinancingAds({
    String? code,
  }) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getFinancingAds,
          queryParameters: {'code': code},
        );
        return FinancingAdModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, List<FinancingAdModel>>> getNormalFinancing({
    String? code,
  }) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getFinancingNormal,
          queryParameters: {'Code': code ?? ''},
        );
        return FinancingAdModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, AddLoanApplicationResponseModel>>
  addLoanApplicationWithFiles({
    required AddLoanApplicationModel model,
    required List<File> files,
  }) async {
    return handleDioRequest(
      request: () async {
        final formData = FormData();

        final modelJson = model.toJson();
        if (kDebugMode) {
          print(
            '[addLoanApplicationWithFiles] modelData: ${jsonEncode(modelJson)}',
          );
        }
        formData.fields.add(MapEntry('modelData', jsonEncode(modelJson)));

        // Use a unique key per file (file_0, file_1, ...) so the
        // server can distinguish between uploaded documents.
        int fileIndex = 0;
        for (final file in files) {
          if (await file.exists()) {
            final fileName = file.path.split('/').last;
            final ext = fileName.split('.').last.toLowerCase();
            final contentType = ext == 'pdf'
                ? DioMediaType('application', 'pdf')
                : (ext == 'png'
                      ? DioMediaType('image', 'png')
                      : DioMediaType('image', 'jpeg'));

            formData.files.add(
              MapEntry(
                'file_$fileIndex',
                await MultipartFile.fromFile(
                  file.path,
                  filename: fileName,
                  contentType: contentType,
                ),
              ),
            );
            fileIndex++;
          }
        }

        if (kDebugMode) {
          print(
            '[addLoanApplicationWithFiles] Total files attached: $fileIndex',
          );
        }

        final response = await apiConsumer.post(
          EndPoints.addLoanApplicationsWithFiles,
          body: formData,
          isFormData: true,
          headers: {
            'username': Uri.encodeComponent(
              HiveMethods.getUserName().toString(),
            ),
          },
        );

        final result = AddLoanApplicationResponseModel.fromJson(response);

        // Fetch FCM tokens and send push notifications
        try {
          await _sendLoanFcmNotifications(
            customerNo: model.customerNo,
            carDetails: model.itemName,
            applicationId: result.applicationId,
          );
        } catch (e) {
          if (kDebugMode) {
            print('[addLoanApplication FCM Error] $e');
          }
        }

        return result;
      },
    );
  }

  Future<void> _sendLoanFcmNotifications({
    required int customerNo,
    required String carDetails,
    required String applicationId,
  }) async {
    final fcmResponse = await apiConsumer.get(
      EndPoints.getFCM,
      queryParameters: {'CUSTOMER_NO': customerNo, 'REPRESCODE': 0},
    );

    List<String> tokens = [];
    dynamic rawData = fcmResponse['Data'];
    if (rawData is String && rawData.isNotEmpty && rawData != 'null') {
      try {
        rawData = jsonDecode(rawData);
      } catch (_) {}
    }

    if (rawData is List) {
      for (var item in rawData) {
        if (item is Map && item.containsKey('FCM') && item['FCM'] != null) {
          final t = item['FCM'].toString().trim();
          if (t.isNotEmpty) tokens.add(t);
        }
      }
    }

    if (tokens.isEmpty) return;

    final String userName = HiveMethods.getname() ?? '';
    final String userPhone =
        HiveMethods.getphone() ?? HiveMethods.getSavedMobile();
    final String userInfo = [
      if (userName.isNotEmpty) 'اسم العميل: $userName',
      if (userPhone.isNotEmpty) 'الجوال: $userPhone',
    ].join(' | ');

    final String appText = applicationId.isNotEmpty
        ? ' | رقم الطلب: $applicationId'
        : '';
    final String bodyForOthers = userInfo.isNotEmpty
        ? '$userInfo$appText'
        : 'تم تقديم طلب تمويل جديد لسيارة ($carDetails)$appText';

    // 1st SendNotification: يرسل للعميل فقط (tokens[0])
    await apiConsumer.post(
      EndPoints.sendNotification,
      body: {
        'deviceToken': [tokens[0]],
        'title': 'طلب تمويل سيارة',
        'body':
            'تم تقديم طلب التمويل لسيارة ($carDetails) بنجاح وسيتم التواصل معكم قريباً.',
      },
    );

    // 2nd SendNotification: يرسل لباقي التوكينات للادارة والمندوبين (tokens.sublist(1))
    if (tokens.length > 1) {
      await apiConsumer.post(
        EndPoints.sendNotification,
        body: {
          'deviceToken': tokens.sublist(1),
          'title': 'طلب تمويل جديد - $carDetails',
          'body': bodyForOthers,
        },
      );
    }
  }

  @override
  Future<Either<Failure, List<CustomerLoanApplicationModel>>>
  getCustLoanApplications(String code) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getCustLoanApplications,
          queryParameters: {'Code': code},
        );

        dynamic rawData = response;
        if (response is Map) {
          final dataEntry = response.entries.where(
            (entry) => entry.key.toString().toLowerCase() == 'data',
          );
          rawData = dataEntry.isEmpty ? response : dataEntry.first.value;
        }
        if (rawData is String && rawData.isNotEmpty && rawData != 'null') {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }

        if (rawData is List) {
          return rawData
              .map(
                (e) => CustomerLoanApplicationModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }

        return [];
      },
    );
  }

  @override
  Future<Either<Failure, List<NotificationModel>>> getNotificationsData({
    required String currentUserId,
    required int userType,
  }) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getNotificationsData,
          queryParameters: {
            'CurrentUserId': currentUserId,
            'UserType': userType,
          },
        );

        dynamic rawData = response;
        if (response is Map) {
          final dataEntry = response.entries.where(
            (entry) => entry.key.toString().toLowerCase() == 'data',
          );
          rawData = dataEntry.isEmpty ? response : dataEntry.first.value;
        }
        if (rawData is String && rawData.isNotEmpty && rawData != 'null') {
          try {
            rawData = jsonDecode(rawData);
          } catch (_) {}
        }

        if (rawData is List) {
          return rawData
              .map(
                (e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }

        return [];
      },
    );
  }

  @override
  Future<Either<Failure, String>> editBooking({
    required int represCode,
    required int lpoNo,
    required int customerNo,
    required int notifyId,
  }) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(
          EndPoints.editBooking,
          body: {
            'REPRESCODE': represCode,
            'LPONO': lpoNo,
            'CUSTOMERNO': customerNo,
            'notifyid': notifyId,
          },
        );
        if (response is Map) {
          final message = response.entries
              .where(
                (entry) =>
                    entry.key.toString().toLowerCase() == 'message' ||
                    entry.key.toString().toLowerCase() == 'msg',
              )
              .map((entry) => entry.value?.toString() ?? '')
              .firstWhere((value) => value.isNotEmpty, orElse: () => '');
          if (message.isNotEmpty) return message;
        }
        return 'تمت الموافقة بنجاح';
      },
    );
  }

  @override
  Future<Either<Failure, String>> editLoan({
    required int represCode,
    required int relatedEntityId,
    required int notifyId,
    required int isApproved,
    required int? customerNo,
  }) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.put(
          EndPoints.editLoan,
          body: {
            'REPRESCODE': represCode,
            'ApplicationID': relatedEntityId,
            'notifyid': notifyId,
            'IsApproved': isApproved,
            'CUSTOMERNO': customerNo ?? 0,
          },
        );
        if (response is Map) {
          final message = response.entries
              .where((entry) => entry.key.toString().toLowerCase() == 'message')
              .map((entry) => entry.value?.toString() ?? '')
              .firstWhere((value) => value.isNotEmpty, orElse: () => '');
          if (message.isNotEmpty) return message;
        }
        return isApproved == 1 ? 'تمت الموافقة بنجاح' : 'تم رفض الطلب بنجاح';
      },
    );
  }

  @override
  Future<Either<Failure, SendWhatsAppResponseModel>> sendWhatsApp(
    SendWhatsAppModel model,
  ) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.sendWhatsApp,
          body: model.toJson(),
        );
        return SendWhatsAppResponseModel.fromJson(response);
      },
    );
  }
}
