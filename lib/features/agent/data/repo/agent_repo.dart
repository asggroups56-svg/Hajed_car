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
