import 'package:car/core/cache/hive/hive_methods.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/utils/car_quotation_offers_pdf_generator.dart';
import 'package:car/features/agent/data/model/offer_model.dart';
import 'package:car/features/agent/presentation/cubit/agent_cubit.dart';
import 'package:car/features/agent/presentation/cubit/agent_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:printing/printing.dart';

class CarQuotationOffersPreviewScreen extends StatefulWidget {
  final List<OfferModel> offers;
  final int offerId;
  final bool showChassis;
  final bool isExternalOffer;

  const CarQuotationOffersPreviewScreen({
    super.key,
    required this.offers,
    required this.offerId,
    this.showChassis = true,
    this.isExternalOffer = false,
  });

  @override
  State<CarQuotationOffersPreviewScreen> createState() => _CarQuotationOffersPreviewScreenState();
}

class _CarQuotationOffersPreviewScreenState extends State<CarQuotationOffersPreviewScreen> {
  OfferModel? _selectedOffer;

  @override
  void initState() {
    super.initState();
    try {
      _selectedOffer = widget.offers.firstWhere((offer) => offer.listNo == widget.offerId);
    } catch (e) {
      _selectedOffer = null;
    }
    if (!widget.isExternalOffer) {
      final represNo = int.tryParse(HiveMethods.getUserCode() ?? '1') ?? 1;
      context.read<AgentCubit>().getSingleOffer(represNo, widget.offerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        appBarColor: AppColor.scaffoldColor(context),
        elevation: 0,
        centerTitle: true,
        title: Text(AppLocaleKey.quotation_preview.tr()),
      ),
      body: BlocListener<AgentCubit, AgentState>(
        listener: (context, state) {
          if (!widget.isExternalOffer &&
              state.singleOfferStatus.isSuccess &&
              state.singleOfferStatus.data != null) {
            setState(() {
              _selectedOffer = state.singleOfferStatus.data;
            });
          }
        },
        child: _selectedOffer == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 60, color: AppColor.redColor(context)),
                    Gap(16),
                    Text('العرض غير موجود'),
                    Gap(16),
                    ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('رجوع')),
                  ],
                ),
              )
            : PdfPreview(
                build: (format) => CarQuotationOffersGenerator.generateOffersQuotationPdf(
                  offer: _selectedOffer!,
                  bankName: _selectedOffer!.customerName,
                  showChassis: widget.showChassis,
                ),
                pdfFileName:
                    '${AppLocaleKey.quotation_file_name.tr()}_${_selectedOffer!.customerName}.pdf',
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
              ),
      ),
    );
  }
}
