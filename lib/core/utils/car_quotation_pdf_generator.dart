import 'package:car/features/home/data/model/brand_cars_data_model.dart';
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
    if (n == 0) {
      return 'صفر ريال';
    }
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

  static String todayStr() {
    final now = DateTime.now();
    return arabicDigits(
      '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}',
    );
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
          'شركة هاجد بن وزير واولادة للتجارة',
          bold,
          size: 16,
          color: PdfColors.black,
          align: pw.TextAlign.right,
        ),
      ],
    ),
  );
}

pw.Widget _buildTitleAndSalutation({required pw.Font bold, required String bankName}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.SizedBox(height: _C.spSM),
      _H.txt('التاريخ: ${_H.todayStr()}', bold, size: _C.fsDateBank, align: pw.TextAlign.right),
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
      _H.txt('السادة / $bankName', bold, size: _C.fsDateBank, align: pw.TextAlign.right),
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
  required GetBrandCarsDataModel car,
  required pw.Font bold,
  required pw.Font regular,
}) {
  final List<String> featureListAr = [];
  final List<String> featureListEn = [];

  if (car.cylinder.isNotEmpty && car.cylinder != '0') {
    featureListAr.add('أسطوانات: ${car.cylinder}');
    featureListEn.add('Cylinders: ${car.cylinder}');
  }
  if (car.fuelType.isNotEmpty) {
    featureListAr.add('وقود: ${car.fuelType}');
    featureListEn.add('Fuel: ${car.fuelType}');
  }
  if (car.seatNo != 0) {
    featureListAr.add('ركاب: ${car.seatNo}');
    featureListEn.add('Seats: ${car.seatNo}');
  }

  final featuresAr = featureListAr.isNotEmpty ? '\n${featureListAr.join(' - ')}' : '';
  final featuresEn = featureListEn.isNotEmpty ? '\n${featureListEn.join(' - ')}' : '';

  return pw.Padding(
    padding: _C.padSpecsCell,
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _H.txt(car.itemName, bold, size: _C.fsTableBody, align: pw.TextAlign.right),
        if (car.itemEName != null && car.itemEName!.isNotEmpty)
          _H.txt(
            car.itemEName!,
            bold,
            size: _C.fsTableBody - 1,
            align: pw.TextAlign.right,
            rtl: false,
          ),
        pw.SizedBox(height: _C.spXS),
        _H.txt('المواصفات  :-', bold, size: _C.fsSpecs, align: pw.TextAlign.right),
        pw.SizedBox(height: _C.spXS),
        _H.txt(
          '${(car.specificName != null && car.specificName!.trim().isNotEmpty) ? car.specificName! : (car.carSpecification ?? '—')}$featuresAr',
          regular,
          size: _C.fsSpecs,
          align: pw.TextAlign.right,
        ),
        if (featuresEn.isNotEmpty)
          _H.txt(featuresEn, regular, size: _C.fsSpecs - 1, align: pw.TextAlign.right, rtl: false),
        if (car.luxury != null && car.luxury!.trim().isNotEmpty) ...[
          pw.SizedBox(height: _C.spXS),
          _H.txt(
            'درجة الفخامة: ${car.luxury!.trim()}',
            bold,
            size: _C.fsSpecs,
            align: pw.TextAlign.right,
          ),
        ],
      ],
    ),
  );
}

// ── 6. Full table ─────────────────────────────────────────────
pw.Widget _buildTable({
  required GetBrandCarsDataModel car,
  required pw.Font bold,
  required pw.Font regular,
}) {
  final price = double.tryParse(car.price?.replaceAll(',', '') ?? '0') ?? 0;
  final vat = price * 0.15;
  const plates = 1250.0;
  final total = price + vat + plates;

  return pw.Column(
    children: [
      pw.Table(
        border: pw.TableBorder.all(color: _C.borderColor, width: 0.8),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.1), // Total
          1: pw.FlexColumnWidth(1.0), // Plates
          2: pw.FlexColumnWidth(1.1), // VAT
          3: pw.FlexColumnWidth(1.1), // Price
          4: pw.FlexColumnWidth(0.9), // Color
          5: pw.FlexColumnWidth(5.5), // Specs
          6: pw.FlexColumnWidth(0.5), // No.
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _C.headerBg),
            children: [
              _headerCell('إجمالي', bold),
              _headerCell('قيمة اللوحات', bold),
              _headerCell('قيمة مضافة', bold),
              _headerCell('سعر الوحدة', bold),
              _headerCell('اللون', bold),
              _headerCell('نوع ومواصفات السيارة', bold),
              _headerCell('م', bold),
            ],
          ),
          pw.TableRow(
            children: [
              _bodyCell(total.toStringAsFixed(0), bold),
              _bodyCell(plates.toStringAsFixed(0), bold),
              _bodyCell(vat.toStringAsFixed(0), bold),
              _bodyCell(price.toStringAsFixed(0), bold),
              _bodyCell(car.bodyColor, bold, rtl: true),
              _specsCell(car: car, bold: bold, regular: regular),
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
          align: pw.TextAlign.center,
        ),
      ),
    ],
  );
}

// ── 7. Conditions ─────────────────────────────────────────────
pw.Widget _buildConditions({required pw.Font bold}) {
  final items = [
    '1/ العرض ساري لمدة 3 أيام من تاريخ العرض ',
    '2/ السعر شامل الضريبة و شامل اللوحات ',
    '3/ السيارة مواصفات وضمان عبد اللطيف جميل ',
    '4/ مكان التسليم : مقر شركتنا ',
    '5/ مندوب المبيعات : يوسف هاجد',
    '6/ جوال : 0505568888',
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
                'السجل التجاري: ${_H.arabicDigits("1010179293")}',
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

class CarQuotationPdfGenerator {
  static String toArabicDigits(String input) => _H.arabicDigits(input);
  static String numberToArabicWords(int number) => _H.numberToWords(number);

  static Future<Uint8List> generateQuotationPdf({required GetBrandCarsDataModel car}) async {
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

    final bankName = car.storeCode.isNotEmpty ? car.storeCode : 'مصرف الراجحي ';

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
                  _buildTitleAndSalutation(bold: fontBold, bankName: bankName),
                  _buildTable(car: car, bold: fontBold, regular: fontRegular),
                  pw.SizedBox(height: _C.spMD),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Expanded(flex: 2, child: _buildConditions(bold: fontBold)),
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
}
