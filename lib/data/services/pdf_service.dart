import 'dart:io';
import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static PdfColor _c(Color c) =>
      PdfColor(c.red / 255, c.green / 255, c.blue / 255);

  static PdfColor _mix(PdfColor a, PdfColor b, double t) => PdfColor(
        a.red + (b.red - a.red) * t,
        a.green + (b.green - a.green) * t,
        a.blue + (b.blue - a.blue) * t,
      );

  static Future<String?> generateAlbum({
    required String babyName,
    required String? avatarPath,
    required Map<String, Map<String, dynamic>> entries,
    required Color bgColor,
    required Color inkColor,
    required Color goldColor,
    required Color accentColor,
    Color? panelColor,
    Color? lineColor,
  }) async {
    final pdf = pw.Document();

    // Tipografi: Cormorant Garamond (seri/duygusal başlıklar ve metin) +
    // Jost (ince büyük harf etiketler, künye) — hiyerarşiye göre ağırlıklandırılmış.
    final scriptItalic = await PdfGoogleFonts.cormorantGaramondItalic();
    final headingBold = await PdfGoogleFonts.cormorantGaramondSemiBold();
    final bodyRegular = await PdfGoogleFonts.cormorantGaramondRegular();
    final bodyMedium = await PdfGoogleFonts.cormorantGaramondMedium();
    final labelSans = await PdfGoogleFonts.jostRegular();
    final labelSansMedium = await PdfGoogleFonts.jostMedium();

    final bg = _c(bgColor);
    final ink = _c(inkColor);
    final gold = _c(goldColor);
    final accent = _c(accentColor);
    final soft = PdfColor(
      inkColor.red / 255 * 0.5 + bgColor.red / 255 * 0.5,
      inkColor.green / 255 * 0.5 + bgColor.green / 255 * 0.5,
      inkColor.blue / 255 * 0.5 + bgColor.blue / 255 * 0.5,
    );
    // Kapak avatarının arka planı için sakin bir zemin tonu.
    final mat = panelColor != null ? _c(panelColor) : _mix(bg, ink, 0.045);
    // İnce ayraç çizgileri (kicker altı, mektup çizgisi, dipnot çizgisi).
    final line = lineColor != null ? _c(lineColor) : _mix(bg, ink, 0.16);
    // Fotoğraf alt yazıları için temaya hafifçe göz kırpan ton.
    final caption = _mix(soft, accent, 0.35);
    // İçerik sayfalarının kenar boşluğu ve kullanılabilir genişliği —
    // fotoğrafları kırpmadan "justified" (ortak yükseklikte) dizmek için.
    const contentMarginH = 60.0;
    final contentWidth = PdfPageFormat.a4.width - contentMarginH * 2;

    // ════════════════════════════════════════════════════
    // KAPAK
    // ════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: bg,
        child: pw.Stack(children: [
          // Masthead çizgileri — kutu çerçeve yok, sade üst/alt hat.
          pw.Positioned(
              top: 48, left: 56, right: 56,
              child: pw.Container(height: 0.6, color: line)),
          pw.Positioned(
              bottom: 48, left: 56, right: 56,
              child: pw.Container(height: 0.6, color: line)),
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (avatarPath != null &&
                    File(avatarPath).existsSync()) ...[
                  pw.Container(
                    width: 116, height: 116,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      color: mat,
                      boxShadow: [
                        pw.BoxShadow(
                          color: PdfColor(0, 0, 0, 0.14),
                          offset: const PdfPoint(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: pw.ClipOval(
                      child: pw.Image(
                        pw.MemoryImage(
                            File(avatarPath).readAsBytesSync()),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 32),
                ] else
                  pw.SizedBox(height: 58),
                pw.Text('BEBEĞİMİN',
                    style: pw.TextStyle(
                        font: labelSansMedium,
                        fontSize: 11, color: gold,
                        letterSpacing: 4)),
                pw.SizedBox(height: 10),
                pw.Text(babyName,
                    style: pw.TextStyle(
                        font: headingBold,
                        fontSize: 62, color: ink,
                        letterSpacing: 0.2)),
                pw.SizedBox(height: 8),
                pw.Text('A n ı   İ z l e r i',
                    style: pw.TextStyle(
                        font: scriptItalic,
                        fontSize: 20, color: gold)),
                pw.SizedBox(height: 40),
                _footDots(gold),
                pw.SizedBox(height: 36),
                pw.Text('T  I  L  S  I  M',
                    style: pw.TextStyle(
                        font: labelSansMedium, fontSize: 10,
                        letterSpacing: 6, color: soft)),
              ],
            ),
          ),
        ]),
      ),
    ));

    // ════════════════════════════════════════════════════
    // BÖLÜMLER
    // ════════════════════════════════════════════════════
    final sections = _buildSections(entries);

    // Toplam içerik sayfası sayısını önceden hesapla (dipnot numaralandırması için)
    int totalContentPages = 0;
    for (final section in sections) {
      for (final page in section.pages) {
        final n = _chunk(page.photos, 4).length;
        totalContentPages += n == 0 ? 1 : n;
      }
    }
    int pageCounter = 0;

    for (int si = 0; si < sections.length; si++) {
      final section = sections[si];
      // Ayraç
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Container(
          color: section.color,
          child: pw.Stack(children: [
            pw.Positioned(
              left: 56, top: 50,
              child: pw.Text(
                  (si + 1).toString().padLeft(2, '0'),
                  style: pw.TextStyle(
                      font: labelSans, fontSize: 10,
                      letterSpacing: 3,
                      color: PdfColor(1, 1, 1, 0.5))),
            ),
            pw.Positioned(
              right: 56, top: 50,
              child: pw.Text(
                  (si + 1).toString().padLeft(2, '0') +
                      ' / ' +
                      sections.length.toString().padLeft(2, '0'),
                  style: pw.TextStyle(
                      font: labelSans, fontSize: 10,
                      letterSpacing: 1.5,
                      color: PdfColor(1, 1, 1, 0.5))),
            ),
            pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(section.titleBold.toUpperCase(),
                      style: pw.TextStyle(
                          font: labelSansMedium, fontSize: 13,
                          letterSpacing: 6,
                          color: PdfColor(1, 1, 1, 0.75))),
                  pw.SizedBox(height: 14),
                  pw.Text(section.titleScript,
                      style: pw.TextStyle(
                          font: headingBold,
                          fontSize: 50,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 26),
                  pw.Container(
                      width: 34, height: 0.6,
                      color: PdfColor(1, 1, 1, 0.6)),
                ],
              ),
            ),
          ]),
        ),
      ));

      // Sayfalar
      for (final page in section.pages) {
        // Fotoğrafları 4'lü gruplara böl
        final photoChunks = _chunk(page.photos, 4);
        final totalChunks =
            photoChunks.isEmpty ? 1 : photoChunks.length;

        for (int ci = 0; ci < totalChunks; ci++) {
          final chunkPhotos =
              photoChunks.isEmpty ? <String>[] : photoChunks[ci];
          final isFirst = ci == 0;
          pageCounter++;

          // Sayfada foto dışında içerik yoksa, foto bloğu kalan dikey
          // alanda ortalanır (üstte yığılıp altta boş kalmasın diye).
          final isTallPage = page.fields.isEmpty &&
              (page.text?.isEmpty ?? true) &&
              page.letter == null;
          final photosWidget = chunkPhotos.isEmpty
              ? null
              : _photos(
                  photos: chunkPhotos,
                  labels: page.photoLabels.isEmpty
                      ? null
                      : page.photoLabels,
                  captionFont: scriptItalic,
                  captionColor: caption,
                  bg: bg,
                  availableWidth: contentWidth,
                  tall: isTallPage,
                );
          pw.Widget middle;
          if (photosWidget == null) {
            middle = pw.SizedBox();
          } else if (isTallPage) {
            middle = pw.Expanded(child: pw.Center(child: photosWidget));
          } else {
            middle = photosWidget;
          }

          pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(
                contentMarginH, 54, contentMarginH, 46),
            build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Başlık
                if (isFirst) ...[
                  _header(
                    kicker: '${section.titleScript} ${section.titleBold}',
                    title: page.title,
                    date: page.date,
                    kickerFont: labelSans,
                    titleFont: headingBold,
                    dateFont: scriptItalic,
                    ink: ink,
                    gold: gold,
                    soft: soft,
                    line: line,
                  ),
                  pw.SizedBox(height: 24),
                ],

                // Alanlar
                if (isFirst && page.fields.isNotEmpty) ...[
                  _fields(page.fields, labelSans,
                      bodyMedium, ink, soft, line),
                  pw.SizedBox(height: 16),
                ],

                // Metin
                if (isFirst &&
                    page.text != null &&
                    page.text!.isNotEmpty) ...[
                  pw.Text(page.text!,
                      style: pw.TextStyle(
                          font: bodyRegular,
                          fontSize: 15.5,
                          color: ink,
                          lineSpacing: 6)),
                  pw.SizedBox(height: 16),
                ],

                // Mektup
                if (isFirst &&
                    page.letter != null &&
                    page.letter!.isNotEmpty) ...[
                  _letter(
                    text: page.letter!,
                    from: page.letterFrom,
                    bodyFont: bodyRegular,
                    accentFont: scriptItalic,
                    labelFont: labelSans,
                    ink: ink, soft: soft, gold: gold, line: line,
                  ),
                  pw.SizedBox(height: 16),
                ],

                // Fotoğraflar
                middle,

                if (!isTallPage) pw.Spacer(),
                _footer(
                  font: labelSans,
                  line: line,
                  soft: soft,
                  pageNo: pageCounter,
                  totalPages: totalContentPages,
                ),
              ],
            ),
          ));
        }
      }
    }

    // ════════════════════════════════════════════════════
    // KAPANIŞ
    // ════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: bg,
        child: pw.Stack(children: [
          pw.Positioned(
              top: 48, left: 56, right: 56,
              child: pw.Container(height: 0.6, color: line)),
          pw.Positioned(
              bottom: 48, left: 56, right: 56,
              child: pw.Container(height: 0.6, color: line)),
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _footDots(gold),
                pw.SizedBox(height: 30),
                pw.Text('Her anın bir izi vardır,',
                    style: pw.TextStyle(
                        font: bodyRegular,
                        fontSize: 20, color: ink)),
                pw.Text('bu defter senin izlerinle dolu.',
                    style: pw.TextStyle(
                        font: bodyRegular,
                        fontSize: 20, color: ink)),
                pw.SizedBox(height: 34),
                pw.Container(
                    width: 32, height: 0.6, color: gold),
                pw.SizedBox(height: 20),
                pw.Text('T  I  L  S  I  M',
                    style: pw.TextStyle(
                        font: labelSansMedium, fontSize: 10,
                        letterSpacing: 6, color: soft)),
              ],
            ),
          ),
        ]),
      ),
    ));

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/tilsim_album.pdf');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (e) {
      return null;
    }
  }

  // ── Bileşenler ─────────────────────────────────────────

  static pw.Widget _footDots(PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 9, height: 13,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Container(
          width: 9, height: 13,
          decoration: pw.BoxDecoration(
            color: color,
            borderRadius:
                const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
        ),
      ],
    );
  }

  // Editoryal "kicker" başlık bloğu: küçük bölüm etiketi + büyük sayfa
  // başlığı + tek ince ayraç çizgisi. Renkli kutu/çerçeve yok.
  static pw.Widget _header({
    required String kicker,
    required String title,
    required String? date,
    required pw.Font kickerFont,
    required pw.Font titleFont,
    required pw.Font dateFont,
    required PdfColor ink,
    required PdfColor gold,
    required PdfColor soft,
    required PdfColor line,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(kicker.toUpperCase(),
            style: pw.TextStyle(
                font: kickerFont, fontSize: 9.5,
                letterSpacing: 3, color: soft)),
        pw.SizedBox(height: 8),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(title,
                  style: pw.TextStyle(
                      font: titleFont, fontSize: 27, color: ink)),
            ),
            if (date != null && date.isNotEmpty) ...[
              pw.SizedBox(width: 10),
              pw.Text(date,
                  style: pw.TextStyle(
                      font: dateFont, fontSize: 12.5, color: gold)),
            ],
          ],
        ),
        pw.SizedBox(height: 11),
        pw.Container(height: 0.6, color: line),
      ],
    );
  }

  static pw.Widget _fields(
    List<_Field> fields,
    pw.Font labelFont,
    pw.Font valueFont,
    PdfColor ink,
    PdfColor soft,
    PdfColor line,
  ) {
    final rows = <pw.Widget>[];
    for (int i = 0; i < fields.length; i += 2) {
      final rowWidgets = <pw.Widget>[];
      for (int j = i; j < i + 2 && j < fields.length; j++) {
        rowWidgets.add(pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: 14, bottom: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(fields[j].label.toUpperCase(),
                    style: pw.TextStyle(
                        font: labelFont, fontSize: 7.5,
                        letterSpacing: 1.2, color: soft)),
                pw.SizedBox(height: 3),
                pw.Text(fields[j].value,
                    style: pw.TextStyle(
                        font: valueFont, fontSize: 15.5, color: ink)),
                pw.SizedBox(height: 4),
                pw.Container(height: 0.5, color: line),
              ],
            ),
          ),
        ));
      }
      if (rowWidgets.length == 1) {
        rowWidgets.add(pw.Expanded(child: pw.Container()));
      }
      rows.add(pw.Row(children: rowWidgets));
    }
    return pw.Column(children: rows);
  }

  // Sade bir "pull-quote" bloğu: renkli dolgu yok, sadece ince sol çizgi
  // ve rahat bir sağ boşluk — dergi alıntısı hissi.
  static pw.Widget _letter({
    required String text,
    required String? from,
    required pw.Font bodyFont,
    required pw.Font accentFont,
    required pw.Font labelFont,
    required PdfColor ink,
    required PdfColor soft,
    required PdfColor gold,
    required PdfColor line,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(left: 20),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: line, width: 1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Sevgili bebeğim,',
              style: pw.TextStyle(
                  font: accentFont, fontSize: 13, color: soft)),
          pw.SizedBox(height: 8),
          pw.Text(text,
              style: pw.TextStyle(
                  font: bodyFont, fontSize: 15,
                  color: ink, lineSpacing: 6)),
          if (from != null && from.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            pw.Text(from.toUpperCase(),
                style: pw.TextStyle(
                    font: labelFont, fontSize: 9.5,
                    letterSpacing: 2, color: gold)),
          ],
        ],
      ),
    );
  }

  // Bir fotoğrafı, gerçek en boy oranıyla tam eşleşen bir kutuda,
  // ince bir gölgeyle yerleştirir. Kutu = fotoğrafın görünür alanı
  // olduğundan (justified boyutlandırma sayesinde) kırpma da,
  // gölgenin görüntüden kopması da olmaz.
  static pw.Widget _frame({
    required pw.MemoryImage image,
    required String? caption,
    required double width,
    required double height,
    required PdfColor bg,
    required PdfColor captionColor,
    required pw.Font captionFont,
  }) {
    return pw.Column(
      children: [
        pw.Container(
          width: width,
          height: height,
          decoration: pw.BoxDecoration(
            color: bg,
            boxShadow: [
              pw.BoxShadow(
                color: const PdfColor(0, 0, 0, 0.16),
                offset: const PdfPoint(0, 3),
                blurRadius: 9,
              ),
            ],
          ),
          child: pw.Image(image, fit: pw.BoxFit.contain),
        ),
        if (caption != null && caption.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.SizedBox(
            width: width,
            child: pw.Text(caption,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    font: captionFont, fontSize: 10.5,
                    letterSpacing: 0.2, color: captionColor)),
          ),
        ],
      ],
    );
  }

  // Bir satırdaki 1-2 fotoğrafı, gerçek en boy oranlarını koruyarak ortak
  // bir yükseklikte ("justified") yan yana dizer. Fotoğraflar sayfa
  // genişliğine sığmıyorsa yükseklik daralır — asla kırpma yapılmaz.
  static pw.Widget _justifiedRow({
    required List<String> paths,
    required List<String?> captions,
    required double maxHeight,
    required double availableWidth,
    required PdfColor bg,
    required PdfColor captionColor,
    required pw.Font captionFont,
    double spacing = 16,
  }) {
    final images =
        paths.map((p) => pw.MemoryImage(File(p).readAsBytesSync())).toList();
    final aspects =
        images.map((img) => (img.width ?? 1) / (img.height ?? 1)).toList();
    final sumAspect = aspects.reduce((a, b) => a + b);
    final spacingTotal = (images.length - 1) * spacing;
    final justifiedHeight = (availableWidth - spacingTotal) / sumAspect;
    final rowHeight =
        justifiedHeight < maxHeight ? justifiedHeight : maxHeight;

    final children = <pw.Widget>[];
    for (int i = 0; i < images.length; i++) {
      if (i > 0) children.add(pw.SizedBox(width: spacing));
      children.add(_frame(
        image: images[i],
        caption: captions[i],
        width: aspects[i] * rowHeight,
        height: rowHeight,
        bg: bg,
        captionColor: captionColor,
        captionFont: captionFont,
      ));
    }
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  static pw.Widget _photos({
    required List<String> photos,
    required List<String>? labels,
    required pw.Font captionFont,
    required PdfColor captionColor,
    required PdfColor bg,
    required double availableWidth,
    required bool tall,
  }) {
    if (photos.isEmpty) return pw.Container();
    String? labelOf(int i) =>
        (labels != null && i < labels.length) ? labels[i] : null;

    // Tek fotoğraf: öne çıkan bir "hero" görsel.
    // İki fotoğraf: yan yana bir "diptik" — kare/ızgara hissi vermez.
    if (photos.length <= 2) {
      final cap = photos.length == 1
          ? (tall ? 380.0 : 235.0)
          : (tall ? 300.0 : 205.0);
      return _justifiedRow(
        paths: photos,
        captions: List.generate(photos.length, labelOf),
        maxHeight: cap,
        availableWidth: availableWidth,
        bg: bg,
        captionColor: captionColor,
        captionFont: captionFont,
      );
    }

    // Üç veya dört fotoğraf: sakin, ikişerli satırlar — her satır kendi
    // içinde ortak yükseklikte hizalanır.
    final cap = tall ? 230.0 : 168.0;
    final rows = <pw.Widget>[];
    for (int i = 0; i < photos.length; i += 2) {
      final end = (i + 2 > photos.length) ? photos.length : i + 2;
      final rowPaths = photos.sublist(i, end);
      final rowCaptions = List.generate(rowPaths.length, (k) => labelOf(i + k));
      if (i > 0) rows.add(pw.SizedBox(height: 18));
      rows.add(_justifiedRow(
        paths: rowPaths,
        captions: rowCaptions,
        maxHeight: cap,
        availableWidth: availableWidth,
        bg: bg,
        captionColor: captionColor,
        captionFont: captionFont,
      ));
    }
    return pw.Column(children: rows);
  }

  static pw.Widget _footer({
    required pw.Font font,
    required PdfColor line,
    required PdfColor soft,
    required int pageNo,
    required int totalPages,
  }) {
    return pw.Column(
      children: [
        pw.Container(height: 0.5, color: line),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
              '${pageNo.toString().padLeft(2, '0')}  ·  '
              '${totalPages.toString().padLeft(2, '0')}',
              style: pw.TextStyle(
                  font: font, fontSize: 8,
                  letterSpacing: 1.5, color: soft)),
        ),
      ],
    );
  }

  static List<List<T>> _chunk<T>(List<T> list, int size) {
    if (list.isEmpty) return [];
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(
          i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }

  // ── Bölüm verisi ─────────────────────────────────────

  static List<_Section> _buildSections(
      Map<String, Map<String, dynamic>> entries) {
    final result = <_Section>[];

    // AİLE
    final aile = <_PdfPage>[];
    _addInfoPage(aile, entries, 'bebek', 'Bebeğimin Bilgileri',
        ['Adın', 'Soyadın', 'Doğum Tarihin', 'Doğum Saatin',
         'Doğum Yerin', 'Doğduğun Hastane', 'Doğum Kilon',
         'Doğum Boyun', 'Baş Çevren', 'Kan Grubun', 'Göz Rengin'],
        avatarField: true);
    _addInfoPage(aile, entries, 'anne', 'Anneni Tanı',
        ['Annenin Adı', 'Doğum Tarihi', 'Doğum Yeri', 'Mesleği',
         'En Sevdiği Renk', 'En Sevdiği Yemek', 'En Sevdiği Müzik',
         'Seni Nasıl Bekledi'], avatarField: true);
    _addInfoPage(aile, entries, 'baba', 'Babanı Tanı',
        ['Babanın Adı', 'Doğum Tarihi', 'Doğum Yeri', 'Mesleği',
         'En Sevdiği Renk', 'En Sevdiği Yemek', 'En Sevdiği Müzik',
         'Seni Nasıl Bekledi'], avatarField: true);
    _addInfoPage(aile, entries, 'ciftler', 'Anne & Baba',
        ['Tanıştığımız Tarih', 'Tanıştığımız Yer',
         'Evlendiğimiz Tarih', 'Evlendiğimiz Yer',
         'Seni Öğrendiğimiz Tarih', 'Evlilik Yıl Dönümü',
         'Birbirimize Verdiğimiz Takma Adlar',
         'Bizi En Çok Ne Güldürür?',
         'Birlikte En Sevdiğimiz Şey',
         'Bebeğimize Ortak Hayalimiz',
         'İlk Buluşma Hikayemiz']);
    _addMembersPage(aile, entries, 'uyeler', 'Ailemizin Diğer Üyeleri');
    _addTextPage(aile, entries, 'anlam', 'Adının Anlamı');
    _addTextPage(aile, entries, 'hikaye', 'İsminin Koyuluş Hikayesi');
    if (aile.isNotEmpty) result.add(_Section(
        color: PdfColor(0.663, 0.718, 0.612),
        titleScript: 'Aileni', titleBold: 'Tanı', pages: aile));

    // SENİ BEKLERKEİN
    final beklerken = <_PdfPage>[];
    _addStoryPage(beklerken, entries, 'ilk-ogren', 'Seni İlk Öğrendiğimiz An');
    _addStoryPage(beklerken, entries, 'mujde', 'Müjdeyi Ailemize Nasıl Verdik?');
    _addReactionsPage(beklerken, entries, 'tepki', 'Tepkileri Nasıl Oldu?');
    _addStoryPage(beklerken, entries, 'kalp', 'Kalp Atışını İlk Duyduğumuz An');
    _addPredictionPage(beklerken, entries, 'tahmin', 'Cinsiyet Tahminleri');
    _addStoryPage(beklerken, entries, 'cinsiyet', 'Cinsiyetini İlk Öğrendiğimizde');
    _addMemoriesPage(beklerken, entries, 'anilar', 'Hamilelikte Unutamadığımız Anılar');
    _addQuickPage(beklerken, entries, 'ham-notlar', 'Hamilelik Notları');
    _addPhotoPage(beklerken, entries, 'us-ilk', 'İlk Ultrason Fotoğrafın');
    _addPhotoPage(beklerken, entries, 'us-son', 'Son Ultrason Fotoğrafın');
    _addPhotoPage(beklerken, entries, 'us-guzel', 'En Güzel Ultrason Fotoğrafın');
    _addUltrasonPage(beklerken, entries, 'us-all', 'Ultrason Fotoğrafların');
    if (beklerken.isNotEmpty) result.add(_Section(
        color: PdfColor(0.616, 0.690, 0.745),
        titleScript: 'Seni', titleBold: 'Beklerken', pages: beklerken));

    // SANA KAVUŞUNCA
    final kavusunca = <_PdfPage>[];
    _addStoryPage(kavusunca, entries, 'dogum-hikaye', 'Doğum Hikayen');
    _addAlbumPage(kavusunca, entries, 'dogum-kare', 'Doğumdan Kareler');
    _addGuestbookPage(kavusunca, entries, 'kimler', 'O Gün Kimler Vardı?');
    _addInfoPage(kavusunca, entries, 'dogum-bilgi', 'Doğum Bilgilerin',
        ['Boyun', 'Kilon', 'Doğum Yerin', 'Doğum Tarihin',
         'Doğum Saatin', 'Doğum Şeklin']);
    _addMemoriesPage(kavusunca, entries, 'ozel', 'En Özel Anların');
    if (kavusunca.isNotEmpty) result.add(_Section(
        color: PdfColor(0.824, 0.659, 0.471),
        titleScript: 'Sana', titleBold: 'Kavuşunca', pages: kavusunca));

    // ANI İZLERİN
    final izler = <_PdfPage>[];
    _addPhotoPage(izler, entries, 'el-izi', 'Minik Ellerin');
    _addPhotoPage(izler, entries, 'ayak-izi', 'Minik Ayakların');
    _addPhotoPage(izler, entries, 'bileklik', 'Hastane Bilekliğin');
    _addLetterPage(izler, entries, 'anne-mektup', 'Annenden Mektup', 'Annen');
    _addLetterPage(izler, entries, 'baba-mektup', 'Babandan Mektup', 'Baban');
    _addLettersPage(izler, entries, 'sevdiklerinden', 'Sevdiklerinden Mektuplar');
    _addMonthlyPage(izler, entries, 'aylik', 'Aylık Fotoğrafların');
    if (izler.isNotEmpty) result.add(_Section(
        color: PdfColor(0.714, 0.643, 0.533),
        titleScript: 'Anı', titleBold: 'İzlerin', pages: izler));

    // UNUTULMAZ İLKLERİN
    final ilkler = <_PdfPage>[];
    _addStoryPage(ilkler, entries, 'ilk-banyo', 'İlk Banyon');
    _addPhotoPage(ilkler, entries, 'ilk-sac', 'İlk Saç Telin');
    _addStoryPage(ilkler, entries, 'ilk-dis', 'İlk Diş Çıkarman');
    _addStoryPage(ilkler, entries, 'ilk-adim', 'İlk Adımın');
    _addFirstsPage(ilkler, entries, 'ilk-custom', 'Özel İlklerin');
    _addQuickPage(ilkler, entries, 'bazi-ilkler', 'Bazı İlklerin');
    if (ilkler.isNotEmpty) result.add(_Section(
        color: PdfColor(0.788, 0.604, 0.565),
        titleScript: 'Unutulmaz', titleBold: 'İlklerin', pages: ilkler));

    // YILLAR
    final yilRenkleri = [
      PdfColor(0.663, 0.718, 0.612),
      PdfColor(0.788, 0.682, 0.518),
      PdfColor(0.788, 0.604, 0.565),
    ];
    for (int no = 1; no <= 3; no++) {
      final word = no == 1 ? 'Birinci' : no == 2 ? 'İkinci' : 'Üçüncü';
      final yil = <_PdfPage>[];
      _addStoryPage(yil, entries, 'y$no-dogum', '$word Yaş Günün');
      _addAlbumPage(yil, entries, 'y$no-kare', '$word Yaş Gününden Kareler');
      _addQuickPage(yil, entries, 'y$no-guncelleme', '$word Yıl Güncellemesi');
      _addGuestbookPage(yil, entries, 'y$no-defter', 'Sevdiklerinden Notlar');
      _addTextPage(yil, entries, 'y$no-not', '$word Yaş Notları');
      _addStoryPage(yil, entries, 'y$no-ozel', 'En Özel Anların');
      if (yil.isNotEmpty) result.add(_Section(
          color: yilRenkleri[no - 1],
          titleScript: word, titleBold: 'Yılın', pages: yil));
    }

    return result;
  }

  // ── Yardımcı üreticiler ──────────────────────────────

  static void _addInfoPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title, List<String> labels, {
    bool avatarField = false,
  }) {
    final e = entries[id];
    if (e == null || e.isEmpty) return;
    final vals = (e['vals'] as List?) ?? [];
    final fields = <_Field>[];
    for (int i = 0; i < labels.length && i < vals.length; i++) {
      final v = vals[i]?.toString().trim() ?? '';
      if (v.isNotEmpty) fields.add(_Field(labels[i], v));
    }
    if (fields.isEmpty) return;
    final photos = <String>[];
    if (avatarField) {
      final av = e['avatar']?.toString();
      if (av != null && File(av).existsSync()) photos.add(av);
    }
    pages.add(_PdfPage(title: title, fields: fields, photos: photos));
  }

  static void _addTextPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final text = e['text']?.toString().trim() ?? '';
    if (text.isEmpty) return;
    pages.add(_PdfPage(title: title, text: text));
  }

  static void _addStoryPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null || e.isEmpty) return;
    final text = e['text']?.toString().trim() ?? '';
    final date = e['date']?.toString();
    final mediaList = (e['media'] as List?) ?? [];
    final photos = mediaList
        .where((m) => (m['type'] as String?) == 'photo')
        .map((m) => m['path']?.toString() ?? '')
        .where((p) => p.isNotEmpty && File(p).existsSync())
        .toList();
    if (text.isEmpty && photos.isEmpty) return;
    pages.add(_PdfPage(
        title: title,
        text: text.isEmpty ? null : text,
        date: date,
        photos: photos));
  }

  static void _addAlbumPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final rawPhotos = (e['photos'] as List?) ?? [];
    final photos = rawPhotos
        .where((p) => p != null && File(p.toString()).existsSync())
        .map((p) => p.toString())
        .toList();
    if (photos.isEmpty) return;
    pages.add(_PdfPage(title: title, photos: photos));
  }

  static void _addPhotoPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final photo = e['photo']?.toString();
    final text = e['text']?.toString().trim();
    if (photo == null || !File(photo).existsSync()) return;
    pages.add(_PdfPage(
        title: title,
        photos: [photo],
        text: (text?.isNotEmpty ?? false) ? text : null));
  }

  static void _addLetterPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title, String from,
  ) {
    final e = entries[id];
    if (e == null) return;
    final text = e['text']?.toString().trim() ?? '';
    if (text.isEmpty) return;
    pages.add(_PdfPage(title: title, letter: text, letterFrom: '— $from'));
  }

  static void _addLettersPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final letters = (e['letters'] as List?) ?? [];
    for (final l in letters) {
      final text = l['text']?.toString().trim() ?? '';
      final who = l['who']?.toString().trim() ?? '';
      if (text.isEmpty) continue;
      pages.add(_PdfPage(
          title: title,
          letter: text,
          letterFrom: who.isNotEmpty ? '— $who' : null));
    }
  }

  static void _addQuickPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final answers = (e['answers'] as List?) ?? [];
    final fields = answers
        .where((a) => (a['a']?.toString().trim().isNotEmpty ?? false))
        .map((a) => _Field(
            a['q']?.toString() ?? '', a['a']?.toString() ?? ''))
        .toList();
    if (fields.isEmpty) return;
    pages.add(_PdfPage(title: title, fields: fields));
  }

  static void _addMembersPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final members = (e['members'] as List?) ?? [];
    if (members.isEmpty) return;
    final fields = members
        .where((m) => (m['name']?.toString().isNotEmpty ?? false))
        .map((m) => _Field(
            m['rel']?.toString().isNotEmpty == true
                ? m['rel'].toString()
                : 'Aile Üyesi',
            m['name']?.toString() ?? ''))
        .toList();
    final photoMembers = members.where((m) =>
        m['photo'] != null && File(m['photo'].toString()).existsSync());
    final photos = photoMembers.map((m) => m['photo'].toString()).toList();
    final photoLabels = photoMembers
        .map((m) => m['name']?.toString().trim().isNotEmpty == true
            ? m['name'].toString().trim()
            : (m['rel']?.toString().trim().isNotEmpty == true
                ? m['rel'].toString().trim()
                : 'Aile Üyesi'))
        .toList();
    if (fields.isEmpty) return;
    pages.add(_PdfPage(
        title: title,
        fields: fields,
        photos: photos,
        photoLabels: photoLabels));
  }

  static void _addReactionsPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final reactions = (e['reactions'] as List?) ?? [];
    final fields = reactions
        .where((r) =>
            (r['who']?.toString().isNotEmpty ?? false) ||
            (r['text']?.toString().isNotEmpty ?? false))
        .map((r) => _Field(
            r['who']?.toString() ?? 'Kişi',
            r['text']?.toString() ?? ''))
        .toList();
    if (fields.isEmpty) return;
    pages.add(_PdfPage(title: title, fields: fields));
  }

  static void _addPredictionPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final kiz = (e['kiz'] as List?) ?? [];
    final erkek = (e['erkek'] as List?) ?? [];
    if (kiz.isEmpty && erkek.isEmpty) return;
    final fields = <_Field>[];
    if (kiz.isNotEmpty) fields.add(_Field('Kız Diyenler', kiz.join(', ')));
    if (erkek.isNotEmpty) fields.add(_Field('Erkek Diyenler', erkek.join(', ')));
    pages.add(_PdfPage(title: title, fields: fields));
  }

  static void _addMemoriesPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final memories = (e['memories'] as List?) ?? [];
    for (final m in memories) {
      final mTitle = m['title']?.toString().trim() ?? '';
      final date = m['date']?.toString();
      final texts = (m['texts'] as List?)
              ?.map((t) => t.toString().trim())
              .where((t) => t.isNotEmpty)
              .toList() ??
          [m['text']?.toString().trim() ?? ''];
      final fullText = texts.join('\n\n');
      final mediaList = (m['media'] as List?) ?? [];
      final photos = mediaList
          .where((mi) => (mi['type'] as String?) == 'photo')
          .map((mi) => mi['path']?.toString() ?? '')
          .where((p) => p.isNotEmpty && File(p).existsSync())
          .toList();
      if (fullText.isEmpty && photos.isEmpty) continue;
      pages.add(_PdfPage(
        title: mTitle.isNotEmpty ? '$title — $mTitle' : title,
        text: fullText.isEmpty ? null : fullText,
        date: date,
        photos: photos,
      ));
    }
  }

  static void _addGuestbookPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final notes = (e['notes'] as List?) ?? [];
    final fields = notes
        .where((n) => (n['text']?.toString().isNotEmpty ?? false))
        .map((n) => _Field(
            n['who']?.toString().isNotEmpty == true
                ? n['who'].toString()
                : 'Sevdiklerin',
            n['text']?.toString() ?? ''))
        .toList();
    if (fields.isEmpty) return;
    pages.add(_PdfPage(title: title, fields: fields));
  }

  static void _addMonthlyPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final months = (e['months'] as List?) ?? [];
    final photos = <String>[];
    final labels = <String>[];
    for (int i = 0; i < months.length; i++) {
      final p = months[i]?.toString();
      if (p != null && File(p).existsSync()) {
        photos.add(p);
        labels.add('${i + 1}. Ay');
      }
    }
    if (photos.isEmpty) return;
    pages.add(_PdfPage(
        title: title, photos: photos, photoLabels: labels));
  }

  static void _addUltrasonPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final items = (e['items'] as List?) ?? [];
    final sorted = [...items]
      ..sort((a, b) =>
          (a['month'] as int? ?? 0).compareTo(b['month'] as int? ?? 0));
    final photos = <String>[];
    final labels = <String>[];
    for (final item in sorted) {
      final p = item['photo']?.toString();
      if (p != null && File(p).existsSync()) {
        photos.add(p);
        labels.add('${item['month']}. Ay');
      }
    }
    if (photos.isEmpty) return;
    pages.add(_PdfPage(
        title: title, photos: photos, photoLabels: labels));
  }

  static void _addFirstsPage(
    List<_PdfPage> pages,
    Map<String, Map<String, dynamic>> entries,
    String id, String title,
  ) {
    final e = entries[id];
    if (e == null) return;
    final items = (e['items'] as List?) ?? [];
    for (final item in items) {
      final t = item['title']?.toString().trim() ?? '';
      final text = item['text']?.toString().trim() ?? '';
      final date = item['date']?.toString();
      final photo = item['photo']?.toString();
      if (t.isEmpty && text.isEmpty) continue;
      pages.add(_PdfPage(
        title: t.isNotEmpty ? t : title,
        text: text.isNotEmpty ? text : null,
        date: date,
        photos: photo != null && File(photo).existsSync() ? [photo] : [],
      ));
    }
  }
}

// ── Modeller ────────────────────────────────────────────────

class _Section {
  final PdfColor color;
  final String titleScript;
  final String titleBold;
  final List<_PdfPage> pages;
  _Section({required this.color, required this.titleScript,
      required this.titleBold, required this.pages});
}

class _PdfPage {
  final String title;
  final String? text;
  final String? date;
  final List<_Field> fields;
  final List<String> photos;
  final List<String> photoLabels;
  final String? letter;
  final String? letterFrom;
  _PdfPage({
    required this.title,
    this.text, this.date,
    this.fields = const [],
    this.photos = const [],
    this.photoLabels = const [],
    this.letter, this.letterFrom,
  });
}

class _Field {
  final String label;
  final String value;
  _Field(this.label, this.value);
}