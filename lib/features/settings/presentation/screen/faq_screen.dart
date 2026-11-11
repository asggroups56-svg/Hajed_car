import 'package:animate_do/animate_do.dart';
import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/settings/presentation/screen/widget/fAQ_Item_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': AppLocaleKey.faqQ2, 'a': AppLocaleKey.faqA2},
      {'q': AppLocaleKey.faqQ3, 'a': AppLocaleKey.faqA3},
      {'q': AppLocaleKey.faqQ4, 'a': AppLocaleKey.faqA4},
    ];
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(
        context,
        title: Text(
          AppLocaleKey.faqs.tr(),
          style: AppTextStyle.titleMedium(
            context,
          ).copyWith(color: AppColor.blackTextColor(context), fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: FAQItem(question: faqs[index]['q']!.tr(), answer: faqs[index]['a']!.tr()),
          );
        },
      ),
    );
  }
}
