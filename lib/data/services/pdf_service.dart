import 'dart:io';
import 'package:flutter/material.dart' show Color;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PdfService {
  static PdfColor _c(Color c) =>
      PdfColor(c.red / 255, c.green / 255, c.blue / 255);

  static Future<String?> generateAlbum({
    required String babyName,
    required String? avatarPath,
    required Map<String, Map<String, dynamic>> entries,
    required Color bgColor,
    required Color inkColor,
    required Color goldColor,
    required Color accentColor,
  }) async {
    final pdf = pw.Document();

    final cormorantBoldItalic =
        await PdfGoogleFonts.cormorantGaramondBoldItalic();
    final cormorantItalic =
        await PdfGoogleFonts.cormorantGaramondItalic();
    final cormorantBold =
        await PdfGoogleFonts.cormorantGaramondBold();
    final jost = await PdfGoogleFonts.jostLight();
    final jostMedium = await PdfGoogleFonts.jostMedium();

    final bg = _c(bgColor);
    final ink = _c(inkColor);
    final gold = _c(goldColor);
    final accent = _c(accentColor);
    final soft = PdfColor(
      inkColor.red / 255 * 0.5 + bgColor.red / 255 * 0.5,
      inkColor.green / 255 * 0.5 + bgColor.green / 255 * 0.5,
      inkColor.blue / 255 * 0.5 + bgColor.blue / 255 * 0.5,
    );

    // ════════════════════════════════════════════════════
    // KAPAK
    // ════════════════════════════════════════════════════
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Container(
        color: bg,
        child: pw.Stack(children: [
          _thinBorder(gold),
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (avatarPath != null &&
                    File(avatarPath).existsSync()) ...[
                  pw.Container(
                    width: 110, height: 110,
                    decoration: pw.BoxDecoration(
                      shape: pw.BoxShape.circle,
                      border: pw.Border.all(color: gold, width: 1.8),
                    ),
                    child: pw.ClipOval(
                      child: pw.Image(
                        pw.MemoryImage(
                            File(avatarPath).readAsBytesSync()),
                        fit: pw.BoxFit.cover,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 28),
                ] else
                  pw.SizedBox(height: 50),
                pw.Text('Bebeğimin',
                    style: pw.TextStyle(
                        font: cormorantItalic,
                        fontSize: 22, color: gold)),
                pw.SizedBox(height: 2),
                pw.Text(babyName,
                    style: pw.TextStyle(
                        font: cormorantBoldItalic,
                        fontSize: 58, color: ink)),
                pw.Text('Anı İzleri',
                    style: pw.TextStyle(
                        font: cormorantItalic,
                        fontSize: 28, color: gold)),
                pw.SizedBox(height: 32),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(width: 55, height: 0.6, color: gold),
                    pw.SizedBox(width: 12),
                    _footDots(gold),
                    pw.SizedBox(width: 12),
                    pw.Container(width: 55, height: 0.6, color: gold),
                  ],
                ),
                pw.SizedBox(height: 32),
                pw.Text('T  I  L  S  I  M',
                    style: pw.TextStyle(
                        font: jostMedium, fontSize: 10,
                        letterSpacing: 5, color: soft)),
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

    for (final section in sections) {
      // Ayraç
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Container(
          color: section.color,
          child: pw.Stack(children: [
            pw.Positioned(
              left: 38, top: 38, bottom: 38,
              child: pw.Container(
                  width: 0.6,
                  color: PdfColor(1, 1, 1, 0.35)),
            ),
            pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(section.titleScript,
                      style: pw.TextStyle(
                          font: cormorantItalic,
                          fontSize: 38,
                          color: PdfColors.white)),
                  pw.Text(section.titleBold.toUpperCase(),
                      style: pw.TextStyle(
                          font: jostMedium, fontSize: 17,
                          letterSpacing: 5,
                          color: PdfColors.white)),
                  pw.SizedBox(height: 22),
                  pw.Container(
                      width: 40, height: 0.6,
                      color: PdfColor(1, 1, 1, 0.7)),
                ],
              ),
            ),
            pw.Positioned(
              bottom: 30, right: 36,
              child: pw.Text('T I L S I M',
                  style: pw.TextStyle(
                      font: jost, fontSize: 8,
                      letterSpacing: 4,
                      color: PdfColor(1, 1, 1, 0.5))),
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

          pdf.addPage(pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.fromLTRB(52, 44, 52, 44),
            build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Başlık
                if (isFirst) ...[
                  _header(
                    title: page.title,
                    date: page.date,
                    sectionColor: section.color,
                    boldItalic: cormorantBoldItalic,
                    italic: cormorantItalic,
                    ink: ink,
                    gold: gold,
                  ),
                  pw.SizedBox(height: 18),
                ],

                // Alanlar
                if (isFirst && page.fields.isNotEmpty) ...[
                  _fields(page.fields, jostMedium,
                      cormorantItalic, ink, soft),
                  pw.SizedBox(height: 12),
                ],

                // Metin
                if (isFirst &&
                    page.text != null &&
                    page.text!.isNotEmpty) ...[
                  pw.Text(page.text!,
                      style: pw.TextStyle(
                          font: cormorantItalic,
                          fontSize: 16,
                          color: ink,
                          lineSpacing: 5)),
                  pw.SizedBox(height: 12),
                ],

                // Mektup
                if (isFirst &&
                    page.letter != null &&
                    page.letter!.isNotEmpty) ...[
                  _letter(
                    text: page.letter!,
                    from: page.letterFrom,
                    italic: cormorantItalic,
                    ink: ink, soft: soft, gold: gold,
                    accent: accent,
                  ),
                  pw.SizedBox(height: 12),
                ],

                // Fotoğraflar
                if (chunkPhotos.isNotEmpty) ...[
                  _photos(
                    photos: chunkPhotos,
                    labels: page.photoLabels.isEmpty
                        ? null
                        : page.photoLabels,
                    accent: accent, bg: bg,
                    labelFont: cormorantItalic,
                    soft: soft,
                    tall: page.fields.isEmpty &&
                        (page.text?.isEmpty ?? true) &&
                        page.letter == null,
                  ),
                ],

                pw.Spacer(),
                _footer(jost, gold, section.color),
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
          _thinBorder(gold),
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                _footDots(gold),
                pw.SizedBox(height: 24),
                pw.Text('Her anın bir izi vardır,',
                    style: pw.TextStyle(
                        font: cormorantItalic,
                        fontSize: 21, color: ink)),
                pw.Text('bu defter senin izlerinle dolu.',
                    style: pw.TextStyle(
                        font: cormorantItalic,
                        fontSize: 21, color: ink)),
                pw.SizedBox(height: 30),
                pw.Container(
                    width: 50, height: 0.6, color: gold),
                pw.SizedBox(height: 18),
                pw.Text('T  I  L  S  I  M',
                    style: pw.TextStyle(
                        font: jostMedium, fontSize: 11,
                        letterSpacing: 5, color: gold)),
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

  static pw.Widget _thinBorder(PdfColor gold) {
    return pw.Positioned(
      top: 22, left: 22, right: 22, bottom: 22,
      child: pw.Container(
        decoration: pw.BoxDecoration(
            border: pw.Border.all(color: gold, width: 0.6)),
      ),
    );
  }

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

  static pw.Widget _header({
    required String title,
    required String? date,
    required PdfColor sectionColor,
    required pw.Font boldItalic,
    required pw.Font italic,
    required PdfColor ink,
    required PdfColor gold,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 26, height: 2.5, color: sectionColor),
        pw.SizedBox(height: 7),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(title,
                  style: pw.TextStyle(
                      font: boldItalic, fontSize: 24, color: ink)),
            ),
            if (date != null && date.isNotEmpty)
              pw.Text(date,
                  style: pw.TextStyle(
                      font: italic, fontSize: 11, color: gold)),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Container(height: 0.6, color: gold),
      ],
    );
  }

  static pw.Widget _fields(
    List<_Field> fields,
    pw.Font labelFont,
    pw.Font valueFont,
    PdfColor ink,
    PdfColor soft,
  ) {
    final rows = <pw.Widget>[];
    for (int i = 0; i < fields.length; i += 2) {
      final rowWidgets = <pw.Widget>[];
      for (int j = i; j < i + 2 && j < fields.length; j++) {
        rowWidgets.add(pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(right: 10, bottom: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(fields[j].label.toUpperCase(),
                    style: pw.TextStyle(
                        font: labelFont, fontSize: 7.5,
                        letterSpacing: 0.7, color: soft)),
                pw.SizedBox(height: 2),
                pw.Text(fields[j].value,
                    style: pw.TextStyle(
                        font: valueFont, fontSize: 15, color: ink)),
                pw.SizedBox(height: 3),
                pw.Container(
                    height: 0.4,
                    color: PdfColor(0.8, 0.8, 0.8)),
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

  static pw.Widget _letter({
    required String text,
    required String? from,
    required pw.Font italic,
    required PdfColor ink,
    required PdfColor soft,
    required PdfColor gold,
    required PdfColor accent,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(
            left: pw.BorderSide(color: gold, width: 2)),
        color: PdfColor(
          (accent.red + 1.0) / 2,
          (accent.green + 1.0) / 2,
          (accent.blue + 1.0) / 2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Sevgili bebeğim,',
              style: pw.TextStyle(
                  font: italic, fontSize: 13, color: soft)),
          pw.SizedBox(height: 6),
          pw.Text(text,
              style: pw.TextStyle(
                  font: italic, fontSize: 15,
                  color: ink, lineSpacing: 4)),
          if (from != null && from.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(from,
                  style: pw.TextStyle(
                      font: italic, fontSize: 13, color: gold)),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _photos({
    required List<String> photos,
    required List<String>? labels,
    required PdfColor accent,
    required PdfColor bg,
    required pw.Font labelFont,
    required PdfColor soft,
    required bool tall,
  }) {
    if (photos.isEmpty) return pw.Container();
    // Yüksekliği fotoğrafın boyutuna göre ayarla (kırpma yok)
    final rows = <pw.Widget>[];
    for (int i = 0; i < photos.length; i += 2) {
      final rowW = <pw.Widget>[];
      for (int j = i; j < i + 2 && j < photos.length; j++) {
        final label = (labels != null && j < labels.length)
            ? labels[j]
            : null;
        rowW.add(pw.Expanded(
          child: pw.Padding(
            padding: pw.EdgeInsets.only(
              right: j % 2 == 0 ? 5 : 0,
              left: j % 2 == 1 ? 5 : 0,
              bottom: 10,
            ),
            child: pw.Column(
              children: [
                // Polaroid çerçevesi — BoxFit.contain kullan, kırpma yok
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: bg,
                    border: pw.Border.all(color: accent, width: 0.8),
                    boxShadow: [
                      pw.BoxShadow(
                        color: PdfColor(0, 0, 0, 0.1),
                        offset: const PdfPoint(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const pw.EdgeInsets.fromLTRB(6, 6, 6, 10),
                  child: pw.Image(
                    pw.MemoryImage(
                        File(photos[j]).readAsBytesSync()),
                    // contain: kırpmadan sığdır
                    fit: pw.BoxFit.contain,
                    height: tall ? 260 : 170,
                  ),
                ),
                if (label != null && label.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(label,
                      style: pw.TextStyle(
                          font: labelFont,
                          fontSize: 11,
                          color: soft),
                      textAlign: pw.TextAlign.center),
                ],
              ],
            ),
          ),
        ));
      }
      if (rowW.length == 1 && photos.length > 1) {
        rowW.add(pw.Expanded(child: pw.Container()));
      }
      rows.add(pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: rowW));
    }
    return pw.Column(children: rows);
  }

  static pw.Widget _footer(
      pw.Font jost, PdfColor gold, PdfColor sectionColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Container(width: 22, height: 2, color: sectionColor),
        pw.Text('T I L S I M',
            style: pw.TextStyle(
                font: jost, fontSize: 7,
                letterSpacing: 4, color: gold)),
        pw.Container(width: 22, height: 2, color: sectionColor),
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
    final photos = members
        .where((m) =>
            m['photo'] != null &&
            File(m['photo'].toString()).existsSync())
        .map((m) => m['photo'].toString())
        .toList();
    if (fields.isEmpty) return;
    pages.add(_PdfPage(title: title, fields: fields, photos: photos));
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