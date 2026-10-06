import 'package:car/features/agent/data/model/offer_model.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class _C {
  // Font sizes
  // ignore: unused_field
  static const double fsTitle = 14.0;
  // ignore: unused_field
  static const double fsEnTitle = 9.0;
  // ignore: unused_field
  static const double fsRegInfo = 8.0;
  static const double fsDateBank = 9.5;
  static const double fsTableHeader = 8.0;
  static const double fsTableBody = 8.5;
  static const double fsSpecs = 8.0;
  static const double fsTotal = 10.0;
  static const double fsCondition = 8.5;
  // ignore: unused_field
  static const double fsFooter = 8.0;

  // Spacing
  static const double spXS = 2.0;
  static const double spSM = 4.0;
  static const double spMD = 6.0;

  // Padding
  static const pw.EdgeInsets padCell = pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2);
  static const pw.EdgeInsets padSpecsCell = pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4);

  // Colors
  static const PdfColor headerBg = PdfColors.red50;
  static const PdfColor totalBg = PdfColors.red50;
  static const PdfColor borderColor = PdfColors.black;
  // ignore: unused_field
  static const PdfColor accentRed = PdfColors.red800;
  // ignore: unused_field
  static const PdfColor watermark = PdfColors.blue50;
  // ignore: unused_field
  static const PdfColor greyText = PdfColors.grey700;
}

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════
class _H {
  static String arabicDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String r = input;
    for (int i = 0; i < en.length; i++) {
      r = r.replaceAll(en[i], ar[i]);
    }
    return r;
  }

  static String _group(int n) {
    const ones = [
      '',
      'واحد',
      'اثنان',
      'ثلاثة',
      'أربعة',
      'خمسة',
      'ستة',
      'سبعة',
      'ثمانية',
      'تسعة',
      'عشرة',
      'أحد عشر',
      'اثنا عشر',
      'ثلاثة عشر',
      'أربعة عشر',
      'خمسة عشر',
      'ستة عشر',
      'سبعة عشر',
      'ثمانية عشر',
      'تسعة عشر',
    ];
    const tens = [
      '',
      'عشرة',
      'عشرون',
      'ثلاثون',
      'أربعون',
      'خمسون',
      'ستون',
      'سبعون',
      'ثمانون',
      'تسعون',
    ];
    const hundreds = [
      '',
      'مائة',
      'مائتان',
      'ثلاثمائة',
      'أربعمائة',
      'خمسمائة',
      'ستمائة',
      'سبعمائة',
      'ثمانمائة',
      'تسعمائة',
    ];
    if (n == 0) return '';
    if (n < 20) return ones[n];
    if (n < 100) {
      final t = n ~/ 10, o = n % 10;
      return o == 0 ? tens[t] : '${ones[o]} و${tens[t]}';
    }
    final h = n ~/ 100, rem = n % 100;
    return rem == 0 ? hundreds[h] : '${hundreds[h]} و${_group(rem)}';
  }

  static String numberToWords(int n) {
    if (n == 0) return 'صفر ريال';
    final parts = <String>[];
    final m = n ~/ 1000000, th = (n % 1000000) ~/ 1000, rem = n % 1000;
    if (m > 0) {
      parts.add(
        m == 1
            ? 'مليون'
            : m == 2
            ? 'مليونان'
            : m <= 10
            ? '${_group(m)} ملايين'
            : '${_group(m)} مليون',
      );
    }
    if (th > 0) {
      parts.add(
        th == 1
            ? 'ألف'
            : th == 2
            ? 'ألفان'
            : th <= 10
            ? '${_group(th)} آلاف'
            : '${_group(th)} ألف',
      );
    }
    if (rem > 0) {
      parts.add(_group(rem));
    }
    return '${parts.join(' و')} ريال';
  }

  // ignore: unused_element
  static String todayStr() {
    final now = DateTime.now();
    return arabicDigits(
      '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}',
    );
  }

  static String formatDate(String? date) {
    if (date == null || date.isEmpty) return '—';
    return arabicDigits(date);
  }

  static pw.Widget bilingualTxt(
    String ar,
    pw.Font font, {
    double size = 9,
    PdfColor color = PdfColors.black,
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          ar,
          textDirection: pw.TextDirection.rtl,
          textAlign: align,
          style: pw.TextStyle(font: font, fontSize: size, color: color),
        ),
      ],
    );
  }

  static pw.Text txt(
    String text,
    pw.Font font, {
    double size = 10,
    PdfColor color = PdfColors.black,
    pw.TextAlign align = pw.TextAlign.right,
    pw.TextDecoration? decoration,
    bool rtl = true,
  }) => pw.Text(
    text,
    textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
    textAlign: align,
    style: pw.TextStyle(font: font, fontSize: size, color: color, decoration: decoration),
  );
}

// ── 1. Header ─────────────────────────────────────────────────
pw.Widget _buildHeader({required pw.Font bold, pw.ImageProvider? logo}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 5, bottom: 15),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        logo != null
            ? pw.Container(width: 65, height: 65, child: pw.Image(logo, fit: pw.BoxFit.contain))
            : pw.SizedBox(width: 65, height: 65),
        _H.txt(
          'شركة هاجد بن وزير المطيري واولادة للتجارة',
          bold,
          size: 16,
          color: PdfColors.black,
          align: pw.TextAlign.right,
        ),
      ],
    ),
  );
}

// ── 2. Title & Salutation ─────────────────────────────────────
pw.Widget _buildTitleAndSalutation({
  required pw.Font bold,
  required String bankName,
  required OfferModel offer,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.SizedBox(height: _C.spSM),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          // _H.txt(
          //   'رقم العرض: ${_H.arabicDigits(offer.listNo.toString())}',
          //   bold,
          //   size: _C.fsDateBank,
          //   align: pw.TextAlign.right,
          // ),
          _H.txt(
            'التاريخ: ${_H.formatDate(offer.listDate)}',
            bold,
            size: _C.fsDateBank,
            align: pw.TextAlign.right,
          ),
        ],
      ),
      pw.SizedBox(height: _C.spSM),
      pw.Center(
        child: _H.txt(
          'عرض أسعار للبنوك ',
          bold,
          size: _C.fsDateBank + 1,
          align: pw.TextAlign.center,
          decoration: pw.TextDecoration.underline,
        ),
      ),
      pw.SizedBox(height: _C.spMD),
      _H.txt(
        'السادة / $bankName'.replaceAll('ي', "ئ"),
        bold,
        size: _C.fsDateBank,
        align: pw.TextAlign.right,
      ),
      pw.SizedBox(height: _C.spXS),
      _H.txt('المحترمين ', bold, size: _C.fsDateBank, align: pw.TextAlign.center),
      pw.SizedBox(height: _C.spXS),
      _H.txt('تحية طيبة وبعد ،،،،،، ,', bold, size: _C.fsDateBank, align: pw.TextAlign.center),
      pw.SizedBox(height: _C.spMD),
    ],
  );
}

// ── 3. Table header cell ───────────────────────────────────────
pw.Widget _headerCell(String ar, pw.Font bold) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
  alignment: pw.Alignment.center,
  child: _H.bilingualTxt(ar, bold, size: _C.fsTableHeader),
);

// ── 4. Table body cell ────────────────────────────────────────
pw.Widget _bodyCell(String text, pw.Font font, {bool rtl = false}) => pw.Container(
  width: double.infinity,
  padding: _C.padCell,
  child: _H.txt(text, font, size: _C.fsTableBody, align: pw.TextAlign.center, rtl: rtl),
);

// ── 5. Specs cell ─────────────────────────────────────────────
pw.Widget _specsCell({
  required OfferModel offer,
  required pw.Font bold,
  required pw.Font regular,
  required bool showChassis,
}) {
  final specs = <String>[];

  if (offer.groupName != null && offer.groupName!.isNotEmpty) {
    specs.add('المجموعة: ${offer.groupName}');
  }
  if (offer.makeYear != null && offer.makeYear! > 0) {
    specs.add('الموديل: ${offer.makeYear}');
  }
  if (offer.colorName != null && offer.colorName!.isNotEmpty) {
    specs.add('اللون: ${offer.colorName}');
  }
  if (showChassis && offer.chassisNo != null && offer.chassisNo!.isNotEmpty) {
    specs.add('رقم الهيكل: ${offer.chassisNo}');
  }
  if (offer.itemCode != null && offer.itemCode!.isNotEmpty) {
    specs.add('كود الصنف: ${offer.itemCode}');
  }

  final specsText = specs.isNotEmpty ? specs.join(' - ') : '—';

  return pw.Padding(
    padding: _C.padSpecsCell,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _H.txt(offer.itemName ?? 'غير محدد', bold, size: _C.fsTableBody, align: pw.TextAlign.right),
        pw.SizedBox(height: _C.spXS),
        _H.txt('المواصفات :-', bold, size: _C.fsSpecs, align: pw.TextAlign.right),
        pw.SizedBox(height: _C.spXS),
        _H.txt(_H.arabicDigits(specsText), regular, size: _C.fsSpecs, align: pw.TextAlign.right),
      ],
    ),
  );
}

// ── 6. Full table ─────────────────────────────────────────────
pw.Widget _buildTable({
  required OfferModel offer,
  required pw.Font bold,
  required pw.Font regular,
  required bool showChassis,
}) {
  final price = offer.price;
  final vat = offer.taxVal;
  final paintings = offer.paintingsVal;
  final total = offer.total;

  return pw.Column(
    children: [
      pw.Table(
        border: pw.TableBorder.all(color: _C.borderColor, width: 0.8),
        columnWidths: {
          0: pw.FlexColumnWidth(1.2), // Total
          1: pw.FlexColumnWidth(1.0), // Paintings
          2: pw.FlexColumnWidth(1.1), // VAT
          3: pw.FlexColumnWidth(1.1), // Price
          if (showChassis) 4: pw.FlexColumnWidth(1.5), // Chassis
          (showChassis ? 5 : 4): pw.FlexColumnWidth(0.9), // Year
          (showChassis ? 6 : 5): pw.FlexColumnWidth(0.9), // Color
          (showChassis ? 7 : 6): pw.FlexColumnWidth(3.5), // Specs
          (showChassis ? 8 : 7): pw.FlexColumnWidth(0.5), // No.
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _C.headerBg),
            children: [
              _headerCell('الإجمالي', bold),
              _headerCell('قيمة اللوحات', bold),
              _headerCell('قيمة مضافة 15%', bold),
              _headerCell('سعر الوحدة', bold),
              if (showChassis) _headerCell('رقم الهيكل', bold),
              _headerCell('الموديل', bold),
              _headerCell('اللون', bold),
              _headerCell('نوع ومواصفات السيارة', bold),
              _headerCell('م', bold),
            ],
          ),
          pw.TableRow(
            children: [
              _bodyCell(total.toStringAsFixed(2), bold),
              _bodyCell(paintings.toStringAsFixed(2), bold),
              _bodyCell(vat.toStringAsFixed(2), bold),
              _bodyCell(price.toStringAsFixed(2), bold),
              if (showChassis) _bodyCell(offer.chassisNo ?? '—', bold),
              _bodyCell(offer.makeYear?.toString() ?? '—', bold),
              _bodyCell(offer.colorName ?? '—', bold, rtl: true),
              _specsCell(offer: offer, bold: bold, regular: regular, showChassis: showChassis),
              _bodyCell('1', bold),
            ],
          ),
        ],
      ),
      pw.Container(
        width: double.infinity,
        decoration: const pw.BoxDecoration(
          color: _C.totalBg,
          border: pw.Border(
            left: pw.BorderSide(color: _C.borderColor, width: 0.8),
            right: pw.BorderSide(color: _C.borderColor, width: 0.8),
            bottom: pw.BorderSide(color: _C.borderColor, width: 0.8),
          ),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 10),
        child: _H.txt(
          'الإجمـــــالي  : ${_H.numberToWords(total.toInt())}',
          bold,
          size: _C.fsTotal,
          align: pw.TextAlign.start,
        ),
      ),
    ],
  );
}

// ── 7. Conditions ─────────────────────────────────────────────
pw.Widget _buildConditions({required pw.Font bold, required OfferModel offer}) {
  final items = <String>[
    '- العرض سارئ لمدة ${offer.listPeriod ?? 3} أيام من تاريخ العرض',
    '- السعر شامل الضريبة',
    if (offer.paymentType != null && offer.paymentType!.isNotEmpty)
      '- نوع الدفع: ${offer.paymentType}',
    if (offer.guarPrimary != null) '- الضمان الأساسي: ${offer.guarPrimary}',
    if (offer.guarFinal != null) '- الضمان النهائي: ${offer.guarFinal}',
    if (offer.deliveryPeriod != null) '- مدة التسليم: ${offer.deliveryPeriod} يوم',
    if (offer.receivePlace != null && offer.receivePlace!.isNotEmpty)
      '- مكان التسليم: ${offer.receivePlace}',
    '- مندوب المبيعات : ${offer.represName}',
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: items
        .map(
          (c) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: _C.spSM),
            child: _H.txt(_H.arabicDigits(c), bold, size: _C.fsCondition),
          ),
        )
        .toList(),
  );
}

// ── 8. Stamp ──────────────────────────────────────────────────
pw.Widget _buildStamp({pw.ImageProvider? stamp}) => pw.Center(
  child: stamp != null ? pw.Image(stamp, width: 100) : pw.SizedBox(width: 100, height: 100),
);

// ── 9. Footer ─────────────────────────────────────────────────
pw.Widget _buildFooter({required pw.Font bold}) {
  return pw.Column(
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _H.txt(
            'info@binwazir.com   www.binwazir.com   ${_H.arabicDigits("0112311114")}',
            bold,
            size: 8.5,
            color: PdfColors.black,
            rtl: false,
          ),
          pw.Row(
            children: [
              _H.txt(
                'الرقم الضريبي: ${_H.arabicDigits("300021909200003")}',
                bold,
                size: 8.5,
                color: PdfColors.black,
              ),
              pw.SizedBox(width: 20),
              _H.txt(
                'السجل التجارئ: ${_H.arabicDigits("1010179293")}',
                bold,
                size: 8.5,
                color: PdfColors.black,
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Divider(color: PdfColors.black, thickness: 0.8),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _H.txt('الرياض - حي القادسية - شارع وادي الرمة', bold, size: 8.5, color: PdfColors.black),
        ],
      ),
    ],
  );
}

// ── 10. Watermark ─────────────────────────────────────────────
pw.Widget _buildWatermark({pw.ImageProvider? logo}) {
  if (logo == null) return pw.SizedBox();
  return pw.Positioned.fill(
    child: pw.Center(
      child: pw.Opacity(
        opacity: 0.05,
        child: pw.Image(logo, width: 320, height: 320, fit: pw.BoxFit.contain),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  MAIN GENERATOR CLASS
// ═══════════════════════════════════════════════════════════════
class CarQuotationOffersGenerator {
  static String toArabicDigits(String input) => _H.arabicDigits(input);
  static String numberToArabicWords(int number) => _H.numberToWords(number);

  static Future<Uint8List> generateOffersQuotationPdf({
    required OfferModel offer,
    String? bankName,
    bool showChassis = true,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pw.ImageProvider? logoImage;
    pw.ImageProvider? stampImage;

    try {
      final data = await rootBundle.load('assets/images/loge_black.png');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      try {
        final data = await rootBundle.load('assets/images/loge3.png');
        logoImage = pw.MemoryImage(data.buffer.asUint8List());
      } catch (_) {}
    }
    try {
      final data = await rootBundle.load('assets/images/stamp2.png');
      stampImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {}

    final bank = bankName ?? offer.customerName;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              _buildWatermark(logo: logoImage),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(bold: fontBold, logo: logoImage),
                  pw.SizedBox(height: _C.spXS),
                  _buildTitleAndSalutation(bold: fontBold, bankName: bank, offer: offer),
                  _buildTable(
                    offer: offer,
                    bold: fontBold,
                    regular: fontRegular,
                    showChassis: showChassis,
                  ),
                  pw.SizedBox(height: _C.spMD),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: _buildConditions(bold: fontBold, offer: offer),
                        ),
                        pw.Expanded(child: _buildStamp(stamp: stampImage)),
                      ],
                    ),
                  ),
                  _buildFooter(bold: fontBold),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  static Future<Uint8List> generateMultipleOffersPdf({
    required List<OfferModel> offers,
    String? bankName,
  }) async {
    if (offers.isEmpty) {
      throw Exception('لا توجد عروض لعرضها');
    }
    return generateOffersQuotationPdf(offer: offers.first, bankName: bankName);
  }
}
