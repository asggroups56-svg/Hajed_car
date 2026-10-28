import 'dart:convert';
import 'dart:typed_data';

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
  Future<Either<Failure, Uint8List>> printOfferPrice({
    required int listNo,
    required int listType,
    required bool withChassis,
  });
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

        return result;
      },
    );
  }

  @override
  Future<Either<Failure, Uint8List>> printOfferPrice({
    required int listNo,
    required int listType,
    required bool withChassis,
  }) async {
    return handleDioRequest<Uint8List>(
      request: () async {
        final response = await apiConsumer.get(
          EndPoints.printOfferPrice,
          queryParameters: {
            'LISTNO': listNo,
            'LISTType': listType,
            'withchasse': withChassis ? 1 : '',
          },
          asBytes: true,
        );
        final pdf = _extractPdfBytes(response);
        if (pdf != null) return pdf;
        throw const FormatException('printofferprice returned a non-PDF response');
      },
    );
  }

  Uint8List? _extractPdfBytes(dynamic response) {
    if (response is List<int>) {
      final bytes = Uint8List.fromList(response);
      if (_hasPdfSignature(bytes)) return bytes;
      try {
        return _extractPdfBytes(jsonDecode(utf8.decode(bytes)));
      } catch (_) {
        return null;
      }
    }
    if (response is Map) {
      for (final value in response.values) {
        final pdf = _extractPdfBytes(value);
        if (pdf != null) return pdf;
      }
    }
    if (response is String) {
      var encoded = response.trim();
      const dataUriPrefix = 'data:application/pdf;base64,';
      if (encoded.startsWith(dataUriPrefix)) {
        encoded = encoded.substring(dataUriPrefix.length);
      }
      try {
        final bytes = base64Decode(encoded);
        if (_hasPdfSignature(bytes)) return bytes;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  bool _hasPdfSignature(List<int> bytes) =>
      bytes.length >= 4 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;

  @override
  Future<Either<Failure, CreatOfferResponseModel>> addExternalofferprice(
    CreatOfferModel offer,
  ) async {
    final result = await handleDioRequest(
      request: () async {
        final response = await apiConsumer.post(
          EndPoints.addExternalofferprice,
          body: offer.toExternalOfferJson(),
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
