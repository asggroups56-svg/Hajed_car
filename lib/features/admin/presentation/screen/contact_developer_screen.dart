import 'package:car/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:car/core/custom_widgets/developer_contact_bottom_sheet.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ContactDeveloperScreen extends StatelessWidget {
  const ContactDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldColor(context),
      appBar: CustomAppBar(context, title: Text(AppLocaleKey.contactDeveloper.tr())),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: DeveloperContactContent(isFullScreen: true),
      ),
    );
  }
}
