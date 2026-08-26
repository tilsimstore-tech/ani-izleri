import 'package:flutter/material.dart';

class FieldDef {
  final String label;
  final String type;
  const FieldDef(this.label, [this.type = 'text']);
}

class PageDef {
  final String id;
  final String title;
  final String kind;
  final String? hint;
  final bool avatar;
  final bool mediaField;
  final bool audio;
  final bool allowAdd;
  final int? slots;
  final String? note;
  final String? who;
  final List<FieldDef> fields;

  const PageDef({
    required this.id,
    required this.title,
    required this.kind,
    this.hint,
    this.avatar = false,
    this.mediaField = false,
    this.audio = false,
    this.allowAdd = false,
    this.slots,
    this.note,
    this.who,
    this.fields = const [],
  });
}

class SectionDef {
  final String id;
  final String title;
  final String sub;
  final Color color;
  final String icon;
  final List<PageDef> pages;

  const SectionDef({
    required this.id,
    required this.title,
    required this.sub,
    required this.color,
    required this.icon,
    required this.pages,
  });
}

SectionDef _buildYear(int no, String word) {
  final color = no == 1
      ? const Color(0xFFA9B79C)
      : no == 2
          ? const Color(0xFFC9AE84)
          : const Color(0xFFC99A90);
  return SectionDef(
    id: 'yil$no',
    title: '$word Yılın',
    sub: '$no. Yıl',
    color: color,
    icon: 'star',
    pages: [
      PageDef(id: 'y$no-dogum', title: '$word Yaş Günün', kind: 'story', hint: 'O özel günü anlat...'),
      PageDef(id: 'y$no-kare', title: '$word Yaş Gününden Kareler', kind: 'album', slots: 4),
      PageDef(
        id: 'y$no-guncelleme',
        title: '$word Yıl Güncellemesi',
        kind: 'quick',
        fields: const [
          FieldDef('Boyun'),
          FieldDef('Kilon'),
          FieldDef('Saç rengin'),
          FieldDef('Göz rengin'),
          FieldDef('En sevdiğin oyuncağın'),
          FieldDef('En sevdiğin aktivite'),
          FieldDef('En sevdiğin yemek'),
          FieldDef('En sevdiğin renk'),
          FieldDef('En sevdiğin dizi / çizgi film'),
          FieldDef('En sevdiğin müzik / şarkı'),
          FieldDef('En çok söylediğin söz'),
          FieldDef('En iyi arkadaşın'),
          FieldDef('Seni en çok ne güldürür?'),
          FieldDef('Büyüyünce ne olmak istiyorsun?'),
        ],
      ),
      PageDef(
        id: 'y$no-defter',
        title: 'Sevdiklerinden Notlar',
        kind: 'guestbook',
        note: 'O gün yanında olanlar sana not bıraksın',
      ),
      PageDef(id: 'y$no-not', title: '$word Yaş Notları', kind: 'text', hint: 'Bu yıla dair notların...'),
      PageDef(
        id: 'y$no-ozel',
        title: 'En Özel Anların',
        kind: 'story',
        hint: 'Unutmak istemediklerin...',
        mediaField: true,
      ),
    ],
  );
}

final List<SectionDef> kSections = [
  const SectionDef(
    id: 'aile',
    title: 'Aileni Tanı',
    sub: 'Minik albümümüz, bizi tanı!',
    color: Color(0xFFA9B79C),
    icon: 'users',
    pages: [
      PageDef(
        id: 'bebek',
        title: 'Bebeğimin Bilgileri',
        kind: 'info',
        avatar: true,
        fields: [
          FieldDef('Adın'),
          FieldDef('Soyadın'),
          FieldDef('Doğum Tarihin', 'date'),
          FieldDef('Doğum Saatin', 'time'),
          FieldDef('Doğum Yerin'),
          FieldDef('Doğduğun Hastane'),
          FieldDef('Doğum Kilon'),
          FieldDef('Doğum Boyun'),
          FieldDef('Baş Çevren'),
          FieldDef('Kan Grubun'),
          FieldDef('Göz Rengin'),
        ],
      ),
      PageDef(
        id: 'anne',
        title: 'Anneni Tanı',
        kind: 'info',
        avatar: true,
        fields: [
          FieldDef('Annenin Adı'),
          FieldDef('Doğum Tarihi', 'date'),
          FieldDef('Doğum Yeri'),
          FieldDef('Mesleği'),
          FieldDef('En Sevdiği Renk'),
          FieldDef('En Sevdiği Yemek'),
          FieldDef('En Sevdiği Müzik'),
          FieldDef('Seni Nasıl Bekledi'),
        ],
      ),
      PageDef(
        id: 'baba',
        title: 'Babanı Tanı',
        kind: 'info',
        avatar: true,
        fields: [
          FieldDef('Babanın Adı'),
          FieldDef('Doğum Tarihi', 'date'),
          FieldDef('Doğum Yeri'),
          FieldDef('Mesleği'),
          FieldDef('En Sevdiği Renk'),
          FieldDef('En Sevdiği Yemek'),
          FieldDef('En Sevdiği Müzik'),
          FieldDef('Seni Nasıl Bekledi'),
        ],
      ),
      PageDef(
        id: 'ciftler',
        title: 'Anne & Baba',
        kind: 'info',
        fields: [
          FieldDef('Tanıştığımız Tarih', 'date'),
          FieldDef('Tanıştığımız Yer'),
          FieldDef('Evlendiğimiz Tarih', 'date'),
          FieldDef('Evlendiğimiz Yer'),
          FieldDef('Seni Öğrendiğimiz Tarih', 'date'),
          FieldDef('Evlilik Yıl Dönümü', 'date'),
          FieldDef('Birbirimize Verdiğimiz Takma Adlar'),
          FieldDef('Bizi En Çok Ne Güldürür?'),
          FieldDef('Birlikte En Sevdiğimiz Şey'),
          FieldDef('Bebeğimize Ortak Hayalimiz'),
          FieldDef('İlk Buluşma Hikayemiz'),
        ],
      ),
      PageDef(id: 'uyeler', title: 'Ailemizin Diğer Üyeleri', kind: 'members'),
      PageDef(id: 'anlam', title: 'Adının Anlamı', kind: 'meaning'),
      PageDef(id: 'hikaye', title: 'İsminin Koyuluş Hikayesi', kind: 'text', hint: 'Bu ismi neden seçtik...'),
      PageDef(id: 'soyagaci', title: 'Soy Ağacın', kind: 'familytree'),
    ],
  ),
  const SectionDef(
    id: 'beklerken',
    title: 'Seni Beklerken',
    sub: 'Hamilelik günlüğün',
    color: Color(0xFF9DB0BE),
    icon: 'baby',
    pages: [
      PageDef(id: 'ilk-ogren', title: 'Seni İlk Öğrendiğimiz An', kind: 'story', hint: 'O an...', mediaField: true),
      PageDef(id: 'mujde', title: 'Müjdeyi Ailemize Nasıl Verdik?', kind: 'story', hint: 'Nasıl duyurduk...', mediaField: true),
      PageDef(id: 'tepki', title: 'Tepkileri Nasıl Oldu?', kind: 'reactions'),
      PageDef(id: 'kalp', title: 'Kalp Atışını İlk Duyduğumuz An', kind: 'story', hint: 'İlk kalp atışın...', mediaField: true, audio: true),
      PageDef(id: 'tahmin', title: 'Cinsiyet Tahminleri', kind: 'prediction'),
      PageDef(id: 'cinsiyet', title: 'Cinsiyetini İlk Öğrendiğimizde', kind: 'story', hint: 'O an...', mediaField: true),
      PageDef(id: 'anilar', title: 'Hamilelikte Unutamadığımız Anılar', kind: 'memories2'),
      PageDef(
        id: 'ham-notlar',
        title: 'Hamilelik Notları',
        kind: 'quick',
        allowAdd: true,
        fields: [
          FieldDef('En çok ne yedim?'),
          FieldDef('En çok ne dinledim?'),
          FieldDef('En çok neye şaşırdım?'),
          FieldDef('En çok neyi merak ettim?'),
          FieldDef('En çok canım ne çekti?'),
          FieldDef('Beni en çok ne mutlu etti?'),
        ],
      ),
      PageDef(id: 'us-ilk', title: 'İlk Ultrason Fotoğrafın', kind: 'photo', note: 'İlk ultrason'),
      PageDef(id: 'us-son', title: 'Son Ultrason Fotoğrafın', kind: 'photo', note: 'Son ultrason'),
      PageDef(id: 'us-guzel', title: 'En Güzel Ultrason Fotoğrafın', kind: 'photo', note: 'En güzel kare'),
      PageDef(id: 'us-all', title: 'Ultrason Fotoğrafların', kind: 'ultrasonAll'),
      PageDef(id: 'anne-degisim', title: 'Annenin Değişimi (1–9. Ay)', kind: 'monthlyChange'),
      PageDef(id: 'baba-degisim', title: 'Babanın Değişimi (1–9. Ay)', kind: 'monthlyChange'),
    ],
  ),
  const SectionDef(
    id: 'kavusunca',
    title: 'Sana Kavuşunca',
    sub: 'Doğum günün',
    color: Color(0xFFD2A878),
    icon: 'heart',
    pages: [
      PageDef(id: 'dogum-hikaye', title: 'Doğum Hikayen', kind: 'story', hint: 'O gün her şey...', mediaField: true),
      PageDef(id: 'dogum-kare', title: 'Doğumdan Kareler', kind: 'album', slots: 4),
      PageDef(id: 'kimler', title: 'O Gün Kimler Vardı?', kind: 'guestbook', note: 'Yanında olanlar sana not bıraksın'),
      PageDef(
        id: 'dogum-bilgi',
        title: 'Doğum Bilgilerin',
        kind: 'info',
        fields: [
          FieldDef('Boyun'),
          FieldDef('Kilon'),
          FieldDef('Doğum Yerin'),
          FieldDef('Doğum Tarihin', 'date'),
          FieldDef('Doğum Saatin', 'time'),
          FieldDef('Doğum Şeklin'),
        ],
      ),
      PageDef(id: 'ozel', title: 'En Özel Anların', kind: 'memories2'),
    ],
  ),
  const SectionDef(
    id: 'izler',
    title: 'Anı İzlerin',
    sub: 'İzlerin ve mektupların',
    color: Color(0xFFB6A488),
    icon: 'footprints',
    pages: [
      PageDef(id: 'el-izi', title: 'Minik Ellerin', kind: 'print', note: 'El izini buraya ekle'),
      PageDef(id: 'ayak-izi', title: 'Minik Ayakların', kind: 'print', note: 'Ayak izini buraya ekle'),
      PageDef(id: 'bileklik', title: 'Hastane Bilekliğin', kind: 'photo', note: 'Hastane bilekliğin'),
      PageDef(id: 'anne-mektup', title: 'Anneden Mektup', kind: 'letter', who: 'Annen'),
      PageDef(id: 'baba-mektup', title: 'Babandan Mektup', kind: 'letter', who: 'Baban'),
      PageDef(id: 'sevdiklerinden', title: 'Sevdiklerinden Mektuplar', kind: 'letters'),
      PageDef(id: 'aylik', title: 'Aylık Fotoğrafların', kind: 'monthly'),
    ],
  ),
  const SectionDef(
    id: 'ilkler',
    title: 'Unutulmaz İlklerin',
    sub: 'İlk kez yaptıkların',
    color: Color(0xFFC99A90),
    icon: 'sparkles',
    pages: [
      PageDef(id: 'ilk-banyo', title: 'İlk Banyon', kind: 'story', hint: 'İlk banyon nasıldı...', mediaField: true),
      PageDef(id: 'ilk-sac', title: 'İlk Saç Telin', kind: 'photo', note: 'İlk saç telin'),
      PageDef(id: 'ilk-dis', title: 'İlk Diş Çıkarman', kind: 'story', hint: 'İlk dişin...', mediaField: true),
      PageDef(id: 'ilk-adim', title: 'İlk Adımın', kind: 'story', hint: 'İlk adımını attığın gün...', mediaField: true),
      PageDef(id: 'ilk-custom', title: 'İlk…', kind: 'firstsCollection'),
      PageDef(
        id: 'bazi-ilkler',
        title: 'Bazı İlklerin',
        kind: 'quick',
        allowAdd: true,
        fields: [
          FieldDef('İlk kelimen?'),
          FieldDef('İlk söylediğin şarkı?'),
        ],
      ),
    ],
  ),
];

final List<SectionDef> sections = [
  ...kSections,
  _buildYear(1, 'Birinci'),
  _buildYear(2, 'İkinci'),
  _buildYear(3, 'Üçüncü'),
];

final List<PageDef> allPages =
    sections.expand((s) => s.pages.map((p) => p)).toList();

// ---------- Progress ----------

int pageUnits(PageDef p) {
  switch (p.kind) {
    case 'info':
      return p.fields.length;
    case 'quick':
      return p.fields.isEmpty ? 1 : p.fields.length;
    case 'monthlyChange':
    case 'monthly':
      return 12;
    case 'album':
      return p.slots ?? 2;
    case 'prediction':
      return 2;
    default:
      return 1;
  }
}

int entryUnits(PageDef p, Map<String, dynamic> e) {
  if (e.isEmpty) return 0;
  final List vals = (e['vals'] as List?) ?? [];
  final List answers = (e['answers'] as List?) ?? [];
  final List members = (e['members'] as List?) ?? [];
  final List reactions = (e['reactions'] as List?) ?? [];
  final List memories = (e['memories'] as List?) ?? [];
  final List media = (e['media'] as List?) ?? [];
  final List letters = (e['letters'] as List?) ?? [];
  final List items = (e['items'] as List?) ?? [];
  final List notes = (e['notes'] as List?) ?? [];
  final List photos = (e['photos'] as List?) ?? [];
  final List months = (e['months'] is List) ? (e['months'] as List) : [];
  final Map monthsMap = (e['months'] is Map) ? (e['months'] as Map) : {};
  final Map tree = (e['tree'] as Map?) ?? {};
  final List kiz = (e['kiz'] as List?) ?? [];
  final List erkek = (e['erkek'] as List?) ?? [];

  switch (p.kind) {
    case 'info':
      return p.fields
          .asMap()
          .entries
          .where((en) =>
              (vals.length > en.key
                  ? vals[en.key]?.toString().trim()
                  : null) !=
                  null &&
                  (vals[en.key]?.toString().trim().isNotEmpty ?? false))
          .length;
    case 'quick':
      return answers
          .where((x) => (x['a']?.toString().trim().isNotEmpty ?? false))
          .length;
    case 'members':
      return members.isNotEmpty ? 1 : 0;
    case 'meaning':
    case 'text':
    case 'letter':
      return (e['text']?.toString().trim().isNotEmpty ?? false) ? 1 : 0;
    case 'letters':
      return letters.any(
              (l) => (l['text']?.toString().trim().isNotEmpty ?? false))
          ? 1
          : 0;
    case 'familytree':
      return tree.values.any(
              (n) => n != null && (n['name']?.toString().isNotEmpty ?? false))
          ? 1
          : 0;
    case 'story':
      return ((e['text']?.toString().trim().isNotEmpty ?? false) ||
              media.isNotEmpty ||
              (e['audio'] == true))
          ? 1
          : 0;
    case 'reactions':
      return reactions.any((r) =>
              (r['who']?.toString().isNotEmpty ?? false) ||
              (r['text']?.toString().isNotEmpty ?? false))
          ? 1
          : 0;
    case 'memories2':
      return memories.isNotEmpty ? 1 : 0;
    case 'photo':
    case 'print':
      return (e['photo'] != null) ? 1 : 0;
    case 'ultrasonAll':
      return items.isNotEmpty ? 1 : 0;
    case 'monthlyChange':
      return monthsMap.values
          .where((a) => (a as List?)?.isNotEmpty ?? false)
          .length;
    case 'guestbook':
      return notes.any((n) =>
              (n['who']?.toString().isNotEmpty ?? false) ||
              (n['text']?.toString().isNotEmpty ?? false))
          ? 1
          : 0;
    case 'album':
      return photos.where((p) => p != null).length;
    case 'monthly':
      return months.where((p) => p != null).length;
    case 'prediction':
      return (kiz.isNotEmpty ? 1 : 0) + (erkek.isNotEmpty ? 1 : 0);
    case 'firstsCollection':
      return items.isNotEmpty ? 1 : 0;
    default:
      return 0;
  }
}

final int kTotalUnits =
    allPages.fold(0, (a, p) => a + pageUnits(p));

int filledUnits(Map<String, Map<String, dynamic>> data) {
  return allPages.fold(0, (a, p) {
    final e = data[p.id] ?? {};
    return a + entryUnits(p, e).clamp(0, pageUnits(p));
  });
}

int sectionTotal(String id) {
  final s = sections.firstWhere((s) => s.id == id);
  return s.pages.fold(0, (a, p) => a + pageUnits(p));
}

int sectionFilled(String id, Map<String, Map<String, dynamic>> data) {
  final s = sections.firstWhere((s) => s.id == id);
  return s.pages.fold(0, (a, p) {
    final e = data[p.id] ?? {};
    return a + entryUnits(p, e).clamp(0, pageUnits(p));
  });
}

String kindLabel(String k) {
  const m = {
    'story': 'Yazı + albüm',
    'info': 'Bilgi formu',
    'quick': 'Hızlı notlar',
    'album': 'Foto/video albümü',
    'photo': 'Tek fotoğraf',
    'print': 'İz / damga',
    'letter': 'Mektup',
    'letters': 'Mektup koleksiyonu',
    'monthly': '12 aylık seri',
    'monthlyChange': 'Aylık değişim',
    'prediction': 'Tahmin oyunu',
    'firstsCollection': 'Özel ilkler',
    'members': 'Aile üyeleri',
    'meaning': 'İsim anlamı',
    'text': 'Serbest yazı',
    'familytree': 'Soy ağacı',
    'reactions': 'Tepkiler',
    'memories2': 'Anılar (klasör)',
    'ultrasonAll': 'Ultrason albümü',
    'guestbook': 'Sevgi notları',
  };
  return m[k] ?? 'Sayfa';
}

String rowTitle(PageDef p, Map<String, dynamic> e) {
  if (p.kind == 'firstsCollection') {
    final items = (e['items'] as List?) ?? [];
    if (items.isNotEmpty) {
      return items
          .map((i) =>
              i['title']?.toString().isNotEmpty == true ? i['title'] : 'İlk…')
          .join(' · ');
    }
  }
  return p.title;
}