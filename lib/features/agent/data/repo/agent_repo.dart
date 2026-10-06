import 'dart:convert';

import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/error/failures.dart';
import 'package:car/core/network/api_consumer.dart';
import 'package:car/core/network/end_points.dart';
import 'package:car/features/agent/data/model/color_model.dart';
import 'package:car/features/agent/data/model/creat_offer_model.dart';
import 'package:car/features/agent/data/model/creat_offer_response_model.dart';
import 'package:car/features/agent/data/model/customer_model.dart';
import 'package:car/features/agent/data/model/customer_profile_model.dart';
import 'package:car/features/agent/data/model/offer_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

abstract interface class AgentRepo {
  Future<Either<Failure, List<ColorModel>>> getColors(String? searchVal);
  Future<Either<Failure, List<CustomerModel>>> getCustomer(String? Searchval);
  Future<Either<Failure, List<OfferModel>>> getOffers(String? Searchval, int REPRESNO, int? LISTNO);
  Future<Either<Failure, List<OfferModel>>> getExternalOffers(
    String? searchVal,
    int represNo,
    int? listNo,
  );
  Future<Either<Failure, CreatOfferResponseModel>> addbookingpermission(CreatOfferModel offer);
  Future<Either<Failure, CreatOfferResponseModel>> addExternalofferprice(CreatOfferModel offer);
  Future<Either<Failure, CustomerProfileModel?>> getCustomerProfile(String code);
}

class AgentImplRepo implements AgentRepo {
  final ApiConsumer apiConsumer;

  AgentImplRepo(this.apiConsumer);

  @override
  Future<Either<Failure, List<ColorModel>>> getColors(String? searchVal) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.customer,
          queryParameters: {'Searchval': searchVal, 'TableName': 'sp_COLOR_DATA_search_sel'},
        );
        return ColorModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, List<CustomerModel>>> getCustomer(String? Searchval) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.customer,
          queryParameters: {'Searchval': Searchval, 'TableName': 'sp_CUSTOMER_DATA_search_sel'},
        );
        return CustomerModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, List<OfferModel>>> getOffers(
    String? Searchval,
    int REPRESNO,
    int? LISTNO,
  ) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getofferprice,
          queryParameters: {'Searchval': Searchval, 'REPRESNO': REPRESNO, 'LISTNO': LISTNO},
        );
        return OfferModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, List<OfferModel>>> getExternalOffers(
    String? searchVal,
    int represNo,
    int? listNo,
  ) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.getExternalofferprice,
          queryParameters: {'Searchval': searchVal, 'REPRESNO': represNo, 'LISTNO': listNo},
        );
        return OfferModel.listFromResponse(response['Data']);
      },
    );
  }

  @override
  Future<Either<Failure, CreatOfferResponseModel>> addbookingpermission(
    CreatOfferModel offer,
  ) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addbookingpermission,
          body: offer.toJson(),
          headers: {'username': Uri.encodeComponent(HiveMethods.getUserName().toString())},
        );
        final result = CreatOfferResponseModel.fromJson(response);

        // Fetch FCM tokens and send push notifications
        try {
          final carDetails = offer.subList.isNotEmpty
              ? offer.subList.first.itemName
              : 'عرض سعر / إذن حجز';
          await _sendFcmNotifications(
            customerNo: offer.customerNo,
            represCode: offer.represCode,
            carDetails: carDetails,
            bookingNo: result.listNo,
          );
        } catch (e) {
          if (kDebugMode) {
            print('[Agent addbookingpermission FCM Error] $e');
          }
        }

        return result;
      },
    );
  }

  @override
  Future<Either<Failure, CreatOfferResponseModel>> addExternalofferprice(
    CreatOfferModel offer,
  ) async {
    final result = await handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addExternalofferprice,
          body: offer.toJson(),
          headers: {'username': Uri.encodeComponent(HiveMethods.getUserName().toString())},
        );
        return CreatOfferResponseModel.fromJson(response);
      },
    );
    return result.fold(
      Left.new,
      (response) => response.success
          ? Right(response)
          : Left(
              ServerFailure(
                response.message.isNotEmpty
                    ? response.message
                    : 'External quotation creation failed',
              ),
            ),
    );
  }

  Future<void> _sendFcmNotifications({
    required int customerNo,
    required int represCode,
    required String carDetails,
    required String bookingNo,
  }) async {
    final fcmResponse = await apiConsumer.get(
      EndPoints.getFCM,
      queryParameters: {'CUSTOMER_NO': customerNo, 'REPRESCODE': represCode},
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

    final String userName = (HiveMethods.getUserName() ?? HiveMethods.getname()) ?? '';
    final String userPhone = HiveMethods.getphone() ?? HiveMethods.getSavedMobile();
    final String userInfo = [
      if (userName.isNotEmpty) 'اسم العميل: $userName',
      if (userPhone.isNotEmpty) 'الجوال: $userPhone',
    ].join(' | ');

    final String bookingText = bookingNo.isNotEmpty ? ' | رقم الحجز: $bookingNo' : '';
    final String bodyForOthers = userInfo.isNotEmpty
        ? '$userInfo$bookingText'
        : 'تم حجز السيارة بنجاح$bookingText';

    // 1st SendNotification: يرسل للعميل الذي قام بالحجز فقط (tokens[0])
    await apiConsumer.post(
      EndPoints.sendNotification,
      body: {
        'deviceToken': [tokens[0]],
        'title': 'تجربة إشعار حجز',
        'body': 'تم حجز السيارة ($carDetails) بنجاح وسيتم التواصل معكم قريباً.',
      },
    );

    // 2nd SendNotification: يرسل لباقي التوكينات فقط (tokens.sublist(1)) مع رقم الحجز
    if (tokens.length > 1) {
      await apiConsumer.post(
        EndPoints.sendNotification,
        body: {
          'deviceToken': tokens.sublist(1),
          'title': carDetails,
          'body': bodyForOthers,
        },
      );
    }
  }

  @override
  Future<Either<Failure, CustomerProfileModel?>> getCustomerProfile(String code) async {
    return handleDioRequest(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.customerProfile,
          queryParameters: {'Code': code},
        );
        return CustomerProfileModel.fromResponse(response['Data']);
      },
    );
  }
}
