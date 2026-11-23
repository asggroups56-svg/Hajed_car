import 'dart:io';

import 'package:car/core/custom_widgets/custom_image/custom_file_image.dart';
import 'package:car/core/custom_widgets/custom_sar_text.dart';
import 'package:car/core/localization/app_locale_keys.dart';
import 'package:car/core/services/permission_service.dart';
import 'package:car/core/theme/app_colors.dart';
import 'package:car/core/theme/app_text_style.dart';
import 'package:car/features/services/presentation/widgets/upload_choice_button_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FinancingDocumentsTab extends StatefulWidget {
  final Map<String, File?>? uploadedFiles;
  final ValueChanged<Map<String, File?>>? onFilesChanged;

  static List<String> get requiredDocuments => [
    AppLocaleKey.agentNationalIdCopy.tr(),
    AppLocaleKey.agentDrivingLicenseCopy.tr(),
    AppLocaleKey.agentSalaryStatement.tr(),
  ];

  const FinancingDocumentsTab({super.key, this.uploadedFiles, this.onFilesChanged});

  @override
  State<FinancingDocumentsTab> createState() => _FinancingDocumentsTabState();
}

class _FinancingDocumentsTabState extends State<FinancingDocumentsTab> {
  late Map<String, File?> uploadedFiles;

  @override
  void initState() {
    super.initState();
    uploadedFiles = widget.uploadedFiles ?? {};
  }

  void _notifyFilesChanged() {
    widget.onFilesChanged?.call(uploadedFiles);
  }

  static const Set<String> _imageExtensions = {'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp'};

  /// The picked file arrives with a full device path, sometimes with a `~`,
  /// `../` or an `Img/Emp/` segment in front of it. Only the file name is part
  /// of the attachment, so every directory segment is dropped.
  String _attachmentFileName(String path) {
    final normalized = path.trim().replaceAll('\\', '/');

    final segments = normalized
        .split('/')
        .where(
          (segment) => segment.isNotEmpty && segment != '.' && segment != '..' && segment != '~',
        )
        .toList();
    return segments.isEmpty ? normalized : segments.last;
  }

  Future<File> _toCleanFile(XFile image) async {
    final dir = await getTemporaryDirectory();
    final name = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path).toLowerCase()}';
    return File(image.path).copy(p.join(dir.path, name));
  }

  bool _isImageAttachment(String path) {
    final name = _attachmentFileName(path);
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return false;
    return _imageExtensions.contains(name.substring(dot + 1).toLowerCase());
  }

  // ─── Pickers (Camera & Gallery Only) ───────────────────────────────────────

  Future<void> _pickImageFromGallery(String key) async {
    final hasPermission = await PermissionService.requestPhotoPermission(context);
    if (!hasPermission) return;
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final clean = await _toCleanFile(image);
      if (!mounted) return;
      setState(() => uploadedFiles[key] = clean);
      _notifyFilesChanged();
    }
    print('Picked image from camera: ${image?.path}');
  }

  Future<void> _pickImageFromCamera(String key) async {
    final hasPermission = await PermissionService.requestCameraPermission(context);
    if (!hasPermission) return;
    final image = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (image != null) {
      final clean = await _toCleanFile(image);
      if (!mounted) return;
      setState(() => uploadedFiles[key] = clean);
      _notifyFilesChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildRequirementsSection(context),
          Gap(24.h),
          _buildDocumentsSection(context),
          Gap(24.h),
          _buildUploadSection(context),
          Gap(16.h),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocaleKey.agentFinancingRequirements.tr(),
          style: AppTextStyle.titleSmall(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: AppColor.blackTextColor(context)),
        ),
        Gap(14.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColor.cardColor(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.borderColor(context)),
          ),
          child: Column(
            children: [
              _buildRequirementRow(
                context,
                icon: Icons.person_outline_rounded,
                title: AppLocaleKey.agentCustomerAge.tr(),
                value: AppLocaleKey.agentCustomerAgeLimit.tr(),
                isLast: false,
              ),
              _buildRequirementRow(
                context,
                icon: Icons.credit_card_rounded,
                title: AppLocaleKey.agentDrivingLicense.tr(),
                value: AppLocaleKey.agentValidLicense.tr(),
                isLast: false,
              ),
              _buildRequirementRow(
                context,
                icon: Icons.receipt_long_rounded,
                title: AppLocaleKey.agentTrafficViolations.tr(),
                value: AppLocaleKey.agentNoViolations.tr(),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: AppColor.primaryColor(context), size: 18.sp),
              ),
              Gap(12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                value,
                style: AppTextStyle.bodySmall(
                  context,
                ).copyWith(color: AppColor.greyColor(context), fontSize: 12.sp),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: AppColor.dividerColor(context), indent: 16.w, endIndent: 16.w),
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    final docs = [
      AppLocaleKey.agentMinSalaryDoc.tr(),
      AppLocaleKey.agentNoSalaryTransfer.tr(),
      AppLocaleKey.agentEmployerNotApproved.tr(),
      AppLocaleKey.agentNoDownPaymentDoc.tr(),
      AppLocaleKey.agentLastPaymentDoc.tr(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocaleKey.agentRequiredDocumentsList.tr(),
          style: AppTextStyle.titleSmall(
            context,
          ).copyWith(fontWeight: FontWeight.w900, color: AppColor.blackTextColor(context)),
        ),
        Gap(14.h),
        ...docs.map(
          (doc) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _buildDocItem(context, doc),
          ),
        ),
      ],
    );
  }

  Widget _buildDocItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, color: AppColor.greenColor(context), size: 20.sp),
        Gap(10.w),
        Expanded(
          child: ValueWithCurrencyIcon(
            text: text,
            textStyle: AppTextStyle.bodyMedium(
              context,
            ).copyWith(color: AppColor.blackTextColor(context), height: 1.4),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    final uploadItems = FinancingDocumentsTab.requiredDocuments;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.cardColor(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColor.primaryColor(context).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.redColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  AppLocaleKey.required.tr(),
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppColor.redColor(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              Text(
                AppLocaleKey.agentUploadDocuments.tr(),
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w900, color: AppColor.blackTextColor(context)),
              ),
            ],
          ),
          Gap(12.h),
          ...uploadItems.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildUploadTile(context, item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadTile(BuildContext context, String label) {
    final file = uploadedFiles[label];
    final bool uploaded = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Label
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (uploaded) ...[
              Icon(Icons.check_circle_rounded, color: AppColor.greenColor(context), size: 16.sp),
              Gap(6.w),
            ],
            Text(
              '* ',
              style: TextStyle(
                color: AppColor.redColor(context),
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.bodyMedium(
                  context,
                ).copyWith(fontWeight: FontWeight.w700, color: AppColor.blackTextColor(context)),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),

        Gap(10.h),

        Row(
          children: [
            UploadChoiceButton(
              icon: Icons.camera_alt_rounded,
              label: AppLocaleKey.camera.tr(),
              accentColor: AppColor.blueColor(context),
              onTap: () => _pickImageFromCamera(label),
            ),
            Gap(12.w),
            UploadChoiceButton(
              icon: Icons.photo_library_rounded,
              label: AppLocaleKey.selectImage.tr(),
              accentColor: AppColor.primaryColor(context),
              onTap: () => _pickImageFromGallery(label),
            ),
          ],
        ),

        if (uploaded) ...[
          Gap(8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColor.greenColor(context).withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.greenColor(context).withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                _buildAttachmentPreview(context, file),
                Gap(10.w),
                Expanded(
                  child: Text(
                    _attachmentFileName(file.path),
                    style: AppTextStyle.bodySmall(
                      context,
                    ).copyWith(color: AppColor.greenColor(context), fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                Gap(6.w),
                GestureDetector(
                  onTap: () {
                    setState(() => uploadedFiles[label] = null);
                    _notifyFilesChanged();
                  },
                  child: Icon(Icons.close_rounded, size: 16.sp, color: AppColor.greyColor(context)),
                ),
              ],
            ),
          ),
        ],

        Gap(12.h),
        Divider(height: 1, color: AppColor.dividerColor(context)),
      ],
    );
  }

  Widget _buildAttachmentPreview(BuildContext context, File file) {
    if (_isImageAttachment(file.path)) {
      return CustomFileImage(
        imageFile: file,
        width: 44.w,
        height: 44.w,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8.r),
        hasZoom: true,
      );
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColor.redColor(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.picture_as_pdf_rounded, color: AppColor.redColor(context), size: 22.sp),
    );
  }
}
