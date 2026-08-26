import React, { useState, useEffect, useRef } from "react";
import {
  Heart, Camera, Mic, ChevronLeft, Check, Plus, Award, Sparkles, Baby, Users,
  Footprints, Star, BookOpen, Image as ImageIcon, Lock, X, Palette, Play,
  Share2, Download, Trash2, ChevronDown, User, GitBranch, Mail
} from "lucide-react";

/* ============================================================
   TILSIM · Bebeğimin Anı İzleri — Premium Prototip v3
   Tüm veriler bellekte (üretimde: Hive + yerel dosya dizini).
   ============================================================ */

const THEMES = {
  mavi: { name: "Bebe Mavisi", bg: "#EAF1F6", panel: "#FBFDFE", ink: "#3A4651", soft: "#6E8092", line: "#D6E2EA", gold: "#8FB3CC", goldDeep: "#6E97B5", accent: "#A9C9DE", tape: "#A9C9DE" },
  gul: { name: "Gül", bg: "#F6ECEA", panel: "#FFFAF9", ink: "#4A3A38", soft: "#9A7872", line: "#EAD7D2", gold: "#C99A90", goldDeep: "#B07C72", accent: "#D9B3AB", tape: "#D9B3AB" },
  altin: { name: "Altın", bg: "#F7F1E8", panel: "#FFFDF9", ink: "#4A4036", soft: "#8C7B66", line: "#E6DBC9", gold: "#B79866", goldDeep: "#9A7D4E", accent: "#C9AE84", tape: "#C9AE84" },
  seftali: { name: "Şeftali", bg: "#F8EEE6", panel: "#FFFAF6", ink: "#4E3F36", soft: "#9A7E6C", line: "#EBD9CC", gold: "#D6A07A", goldDeep: "#BF8460", accent: "#E8C0A3", tape: "#E8C0A3" },
  yesil: { name: "Adaçayı", bg: "#EEF0E8", panel: "#FBFCF8", ink: "#3E463A", soft: "#6E7A63", line: "#DBE0D0", gold: "#9AA77F", goldDeep: "#7E8C63", accent: "#AEB994", tape: "#AEB994" },
  lavanta: { name: "Lavanta", bg: "#F0ECF5", panel: "#FCFAFE", ink: "#463E52", soft: "#7E7290", line: "#E0D8EA", gold: "#A593C0", goldDeep: "#8A77A8", accent: "#C3B4D8", tape: "#C3B4D8" },
  karanlik: { name: "Gece", bg: "#211E1A", panel: "#2B2722", ink: "#EDE3D2", soft: "#B6A78E", line: "#3A352D", gold: "#CBA86E", goldDeep: "#B8965A", accent: "#8C7B5E", tape: "#8C7B5E" },
};

const F = (label, type = "text") => ({ label, type });

function buildYear(no, word) {
  const c = no === 1 ? "#A9B79C" : no === 2 ? "#C9AE84" : "#C99A90";
  return {
    id: `yil${no}`, title: `${word} Yılın`, sub: `${no}. Yıl`, color: c, icon: "star",
    pages: [
      { id: `y${no}-dogum`, title: `${word} Yaş Günün`, kind: "story", hint: "O özel günü anlat..." },
      { id: `y${no}-kare`, title: `${word} Yaş Gününden Kareler`, kind: "album", slots: 4 },
      { id: `y${no}-guncelleme`, title: `${word} Yıl Güncellemesi`, kind: "quick",
        fields: ["Boyun / kilon?", "En sevdiğin oyuncağın?", "En sevdiğin aktivite?", "En sevdiğin yemek?"] },
      { id: `y${no}-defter`, title: "Sevdiklerinden Notlar", kind: "guestbook", note: "O gün yanında olanlar sana not bıraksın" },
      { id: `y${no}-not`, title: `${word} Yaş Notları`, kind: "text", hint: "Bu yıla dair notların..." },
      { id: `y${no}-ozel`, title: "En Özel Anların", kind: "story", hint: "Unutmak istemediklerin...", media: true },
    ],
  };
}

const SECTIONS = [
  {
    id: "aile", title: "Aileni Tanı", sub: "Minik albümümüz, bizi tanı!", color: "#A9B79C", icon: "users",
    pages: [
      { id: "bebek", title: "Bebeğimin Bilgileri", kind: "info", avatar: true,
        fields: [F("Adın"), F("Soyadın"), F("Doğum Tarihin", "date"), F("Doğum Saatin", "time"), F("Doğum Yerin"),
          F("Doğduğun Hastane"), F("Doğum Kilon"), F("Doğum Boyun"), F("Baş Çevren"), F("Kan Grubun"), F("Göz Rengin")] },
      { id: "anne", title: "Anneni Tanı", kind: "info", avatar: true,
        fields: [F("Annenin Adı"), F("Doğum Tarihi / Yeri"), F("En Sevdiği Renk"), F("En Sevdiği Yemek")] },
      { id: "baba", title: "Babanı Tanı", kind: "info", avatar: true,
        fields: [F("Babanın Adı"), F("Doğum Tarihi / Yeri"), F("En Sevdiği Renk"), F("En Sevdiği Yemek")] },
      { id: "ciftler", title: "Anne & Baba", kind: "info",
        fields: [F("Tanıştığımız Tarih / Yer"), F("Evlendiğimiz Tarih / Yer"), F("Seni Öğrendiğimiz Tarih", "date")] },
      { id: "uyeler", title: "Ailemizin Diğer Üyeleri", kind: "members" },
      { id: "anlam", title: "Adının Anlamı", kind: "meaning" },
      { id: "hikaye", title: "İsminin Koyuluş Hikayesi", kind: "text", hint: "Bu ismi neden seçtik..." },
      { id: "soyagaci", title: "Soy Ağacın", kind: "familytree" },
    ],
  },
  {
    id: "beklerken", title: "Seni Beklerken", sub: "Hamilelik günlüğün", color: "#9DB0BE", icon: "baby",
    pages: [
      { id: "ilk-ogren", title: "Seni İlk Öğrendiğimiz An", kind: "story", hint: "O an...", media: true },
      { id: "mujde", title: "Müjdeyi Ailemize Nasıl Verdik?", kind: "story", hint: "Nasıl duyurduk...", media: true },
      { id: "tepki", title: "Tepkileri Nasıl Oldu?", kind: "reactions" },
      { id: "kalp", title: "Kalp Atışını İlk Duyduğumuz An", kind: "story", hint: "İlk kalp atışın...", media: true, audio: true },
      { id: "tahmin", title: "Cinsiyet Tahminleri", kind: "prediction" },
      { id: "cinsiyet", title: "Cinsiyetini İlk Öğrendiğimizde", kind: "story", hint: "O an...", media: true },
      { id: "anilar", title: "Hamilelikte Unutamadığımız Anılar", kind: "memories2" },
      { id: "ham-notlar", title: "Hamilelik Notları", kind: "quick", allowAdd: true,
        fields: ["En çok ne yedim?", "En çok ne dinledim?", "En çok neye şaşırdım?", "En çok neyi merak ettim?",
          "En çok canım ne çekti?", "Beni en çok ne mutlu etti?"] },
      { id: "us-ilk", title: "İlk Ultrason Fotoğrafın", kind: "photo", note: "İlk ultrason" },
      { id: "us-son", title: "Son Ultrason Fotoğrafın", kind: "photo", note: "Son ultrason" },
      { id: "us-guzel", title: "En Güzel Ultrason Fotoğrafın", kind: "photo", note: "En güzel kare" },
      { id: "us-all", title: "Ultrason Fotoğrafların", kind: "ultrasonAll" },
      { id: "anne-degisim", title: "Annenin Değişimi (1–12. Ay)", kind: "monthlyChange" },
      { id: "baba-degisim", title: "Babanın Değişimi (1–12. Ay)", kind: "monthlyChange" },
    ],
  },
  {
    id: "kavusunca", title: "Sana Kavuşunca", sub: "Doğum günün", color: "#D2A878", icon: "heart",
    pages: [
      { id: "dogum-hikaye", title: "Doğum Hikayen", kind: "story", hint: "O gün her şey...", media: true },
      { id: "dogum-kare", title: "Doğumdan Kareler", kind: "album", slots: 4 },
      { id: "kimler", title: "O Gün Kimler Vardı?", kind: "guestbook", note: "Yanında olanlar sana not bıraksın" },
      { id: "dogum-bilgi", title: "Doğum Bilgilerin", kind: "info",
        fields: [F("Boyun"), F("Kilon"), F("Doğum Yerin"), F("Doğum Tarihin / Saatin"), F("Doğum Şeklin")] },
      { id: "ozel", title: "En Özel Anların", kind: "memories2" },
    ],
  },
  {
    id: "izler", title: "Anı İzlerin", sub: "İzlerin ve mektupların", color: "#B6A488", icon: "footprints",
    pages: [
      { id: "el-izi", title: "Minik El İzin", kind: "print", note: "El izini buraya ekle" },
      { id: "ayak-izi", title: "Minik Ayak İzin", kind: "print", note: "Ayak izini buraya ekle" },
      { id: "bileklik", title: "Hastane Bilekliğin", kind: "photo", note: "Hastane bilekliğin" },
      { id: "anne-mektup", title: "Annenden Mektup", kind: "letter", who: "Annen" },
      { id: "baba-mektup", title: "Babandan Mektup", kind: "letter", who: "Baban" },
      { id: "sevdiklerinden", title: "Sevdiklerinden Mektuplar", kind: "letters" },
      { id: "aylik", title: "Aylık Fotoğrafların", kind: "monthly" },
    ],
  },
  {
    id: "ilkler", title: "Unutulmaz İlklerin", sub: "İlk kez yaptıkların", color: "#C99A90", icon: "sparkles",
    pages: [
      { id: "ilk-banyo", title: "İlk Banyon", kind: "story", hint: "İlk banyon nasıldı...", media: true },
      { id: "ilk-sac", title: "İlk Saç Telin", kind: "photo", note: "İlk saç telin" },
      { id: "ilk-dis", title: "İlk Diş Çıkarman", kind: "story", hint: "İlk dişin...", media: true },
      { id: "ilk-adim", title: "İlk Adımın", kind: "story", hint: "İlk adımını attığın gün...", media: true },
      { id: "ilk-custom", title: "İlk… (Kendin Ekle)", kind: "firstsCollection" },
      { id: "bazi-ilkler", title: "Bazı İlklerin", kind: "quick", allowAdd: true,
        fields: ["İlk kelimen?", "İlk söylediğin şarkı?"] },
    ],
  },
  buildYear(1, "Birinci"),
  buildYear(2, "İkinci"),
  buildYear(3, "Üçüncü"),
];

const ICONS = { users: Users, baby: Baby, heart: Heart, footprints: Footprints, sparkles: Sparkles, star: Star };
const ALL_PAGES = SECTIONS.flatMap((s) => s.pages.map((p) => ({ ...p, sectionId: s.id })));

/* ---------- ilerleme ---------- */
function pageUnits(p) {
  switch (p.kind) {
    case "info": return (p.fields || []).length;
    case "quick": return (p.fields || []).length || 1;
    case "monthlyChange": case "monthly": return 12;
    case "album": return p.slots || 2;
    case "prediction": return 2;
    default: return 1;
  }
}
function entryUnits(p, e) {
  if (!e) return 0;
  switch (p.kind) {
    case "info": return (p.fields || []).filter((_, i) => (e.vals?.[i] || "").trim()).length;
    case "quick": return (e.answers || []).filter((x) => (x.a || "").trim()).length;
    case "members": return (e.members || []).length ? 1 : 0;
    case "meaning": case "text": case "letter": return (e.text || "").trim() ? 1 : 0;
    case "letters": return (e.letters || []).some((l) => (l.text || "").trim()) ? 1 : 0;
    case "familytree": return Object.values(e.tree || {}).some((n) => n && n.name) ? 1 : 0;
    case "story": return (e.text || "").trim() || (e.media || []).length || e.audio ? 1 : 0;
    case "reactions": return (e.reactions || []).some((r) => r.who || r.text) ? 1 : 0;
    case "memories2": return (e.memories || []).length ? 1 : 0;
    case "photo": case "print": return e.photo ? 1 : 0;
    case "ultrasonAll": return (e.items || []).length ? 1 : 0;
    case "monthlyChange": return Object.values(e.months || {}).filter((a) => (a || []).length).length;
    case "guestbook": return (e.notes || []).some((n) => n.who || n.text) ? 1 : 0;
    case "album": return (e.photos || []).filter(Boolean).length;
    case "monthly": return (e.months || []).filter(Boolean).length;
    case "prediction": return (e.kiz?.length ? 1 : 0) + (e.erkek?.length ? 1 : 0);
    case "firstsCollection": return (e.items || []).length ? 1 : 0;
    default: return 0;
  }
}
const TOTAL_UNITS = ALL_PAGES.reduce((a, p) => a + pageUnits(p), 0);
function filledUnits(d) { return ALL_PAGES.reduce((a, p) => a + Math.min(entryUnits(p, d[p.id]), pageUnits(p)), 0); }
function sectionTotal(id) { return SECTIONS.find((s) => s.id === id).pages.reduce((a, p) => a + pageUnits(p), 0); }
function sectionUnits(d, id) { return SECTIONS.find((s) => s.id === id).pages.reduce((a, p) => a + Math.min(entryUnits(p, d[p.id]), pageUnits(p)), 0); }

function entryHasMedia(e) {
  if (!e) return false;
  if (e.photo || e.avatar) return true;
  if ((e.media || []).length) return true;
  if ((e.photos || []).filter(Boolean).length) return true;
  if (Array.isArray(e.months) && e.months.filter(Boolean).length) return true;
  if (e.months && !Array.isArray(e.months) && Object.values(e.months).some((a) => (a || []).length)) return true;
  if ((e.items || []).some((it) => it.photo)) return true;
  if ((e.memories || []).some((m) => (m.media || []).length)) return true;
  if ((e.members || []).some((m) => m.photo)) return true;
  if ((e.notes || []).some((n) => n.photo)) return true;
  if (Object.values(e.tree || {}).some((n) => n && n.photo)) return true;
  return false;
}

const MILESTONES = [
  { id: "ilk", label: "İlk Anı", icon: Heart, test: (d) => filledUnits(d) >= 1 },
  { id: "aile", label: "Aile Tamam", icon: Users, test: (d) => sectionUnits(d, "aile") >= sectionTotal("aile") * 0.7 },
  { id: "hamile", label: "Hamilelik", icon: Baby, test: (d) => sectionUnits(d, "beklerken") >= sectionTotal("beklerken") * 0.5 },
  { id: "dogum", label: "Doğum Hikayesi", icon: Star, test: (d) => !!d["dogum-hikaye"]?.text },
  { id: "foto", label: "İlk Fotoğraf", icon: Camera, test: (d) => Object.values(d).some(entryHasMedia) },
  { id: "yarisi", label: "%50 Doldu", icon: Award, test: (d) => filledUnits(d) >= TOTAL_UNITS * 0.5 },
  { id: "tamam", label: "Defter Tamam", icon: Sparkles, test: (d) => filledUnits(d) >= TOTAL_UNITS * 0.9 },
];

function rowTitle(p, e) {
  if (p.kind === "firstsCollection" && (e?.items || []).length) return e.items.map((i) => i.title || "İlk…").join(" · ");
  return p.title;
}

/* ============================================================ */
export default function App() {
  const [theme, setTheme] = useState("mavi");
  const t = THEMES[theme];
  const [view, setView] = useState("cover");
  const [activeSection, setActiveSection] = useState(null);
  const [activePage, setActivePage] = useState(null);
  const [data, setData] = useState({});
  const [showTheme, setShowTheme] = useState(false);
  const [toast, setToast] = useState(null);

  const babyName = data.bebek?.vals?.[0]?.trim() || "Bebeğim";
  const pct = Math.round((filledUnits(data) / TOTAL_UNITS) * 100);
  const earned = MILESTONES.filter((m) => m.test(data));

  useEffect(() => {
    const id = "tilsim-fonts";
    if (!document.getElementById(id)) {
      const l = document.createElement("link"); l.id = id; l.rel = "stylesheet";
      l.href = "https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400&family=Pinyon+Script&family=Jost:wght@300;400;500;600&display=swap";
      document.head.appendChild(l);
    }
  }, []);

  const flash = (m) => { setToast(m); setTimeout(() => setToast(null), 1800); };
  const save = (id, value) => setData((d) => ({ ...d, [id]: { ...d[id], ...value } }));
  const serif = "'Cormorant Garamond', serif", script = "'Pinyon Script', cursive", sans = "'Jost', sans-serif";

  return (
    <div style={{ background: theme === "karanlik" ? "#1A1714" : "#E2DCD0", minHeight: "100vh" }}>
      <div style={{ minHeight: "100vh", background: t.bg, color: t.ink, fontFamily: sans, maxWidth: 480, margin: "0 auto", position: "relative", overflow: "hidden", transition: "background .5s" }}>
        {view === "cover" && <Cover t={t} serif={serif} script={script} onEnter={() => setView("home")} />}
        {view === "home" && <Home t={t} serif={serif} script={script} babyName={babyName} pct={pct} data={data} earned={earned} onSection={(s) => { setActiveSection(s); setView("section"); }} onTheme={() => setShowTheme(true)} flash={flash} />}
        {view === "section" && activeSection && <SectionView t={t} serif={serif} script={script} section={activeSection} data={data} onBack={() => setView("home")} onPage={(p) => { setActivePage(p); setView("page"); }} />}
        {view === "page" && activePage && <PageEditor t={t} serif={serif} script={script} sans={sans} page={activePage} entry={data[activePage.id]} babyName={babyName} onBack={() => setView("section")} onSave={(v) => save(activePage.id, v)} flash={flash} />}
        {showTheme && <ThemeSheet t={t} serif={serif} current={theme} onPick={(k) => { setTheme(k); setShowTheme(false); }} onClose={() => setShowTheme(false)} />}
        {toast && <div style={{ position: "fixed", bottom: 28, left: "50%", transform: "translateX(-50%)", background: t.ink, color: t.bg, padding: "11px 20px", borderRadius: 999, fontSize: 13, zIndex: 60, boxShadow: "0 10px 30px rgba(0,0,0,.25)", animation: "tsRise .3s ease", maxWidth: 360, textAlign: "center" }}>{toast}</div>}
      </div>
      <style>{css}</style>
    </div>
  );
}

/* ---------------- COVER ---------------- */
function Cover({ t, serif, script, onEnter }) {
  return (
    <div onClick={onEnter} style={{ height: "100vh", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", cursor: "pointer", position: "relative", padding: 24 }}>
      <div style={{ position: "absolute", inset: 0, background: `radial-gradient(120% 80% at 50% 30%, ${t.panel} 0%, ${t.bg} 60%)` }} />
      <div style={{ position: "relative", textAlign: "center", animation: "tsFade 1.1s ease" }}>
        <div style={{ fontFamily: script, fontSize: 30, color: t.gold, marginBottom: -4 }}>Bebeğimin</div>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
          <span style={{ fontFamily: script, fontSize: 64, color: t.goldDeep, lineHeight: 1 }}>Anı</span>
          <Footprints size={34} color={t.soft} style={{ transform: "rotate(12deg)" }} />
        </div>
        <div style={{ fontFamily: script, fontSize: 50, color: t.goldDeep, marginTop: -8 }}>izleri</div>
        <div style={{ marginTop: 54, fontFamily: serif, letterSpacing: 8, fontSize: 15, color: t.soft, fontWeight: 500 }}>T I L S I M</div>
        <div style={{ marginTop: 40, fontSize: 12, letterSpacing: 2, color: t.soft, opacity: .7, display: "flex", alignItems: "center", gap: 7, justifyContent: "center", animation: "tsPulse 2.4s infinite" }}><Play size={11} /> DEFTERİ AÇMAK İÇİN DOKUN</div>
      </div>
    </div>
  );
}

/* ---------------- HOME ---------------- */
function Home({ t, serif, script, babyName, pct, data, earned, onSection, onTheme, flash }) {
  return (
    <div style={{ paddingBottom: 40 }}>
      <div style={{ padding: "20px 22px 8px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div style={{ fontFamily: serif, letterSpacing: 6, fontSize: 12, color: t.soft }}>T I L S I M</div>
        <button onClick={onTheme} style={iconBtn(t)}><Palette size={17} /></button>
      </div>
      <div style={{ textAlign: "center", padding: "4px 24px 6px" }}>
        <div style={{ fontFamily: script, fontSize: 26, color: t.gold }}>{babyName}'in</div>
        <div style={{ fontFamily: serif, fontSize: 34, fontWeight: 600, marginTop: -2 }}>Anı İzleri</div>
      </div>
      <AniTree t={t} pct={pct} />
      <div style={{ padding: "0 28px" }}>
        <div style={{ display: "flex", justifyContent: "space-between", fontSize: 12, color: t.soft, marginBottom: 7 }}>
          <span style={{ letterSpacing: 1 }}>ANI AĞACIN BÜYÜYOR</span><span style={{ fontWeight: 600, color: t.goldDeep }}>%{pct}</span>
        </div>
        <div style={{ height: 7, background: t.line, borderRadius: 99, overflow: "hidden" }}>
          <div style={{ width: `${pct}%`, height: "100%", borderRadius: 99, background: `linear-gradient(90deg, ${t.accent}, ${t.goldDeep})`, transition: "width .6s" }} />
        </div>
      </div>
      <div style={{ padding: "20px 22px 4px" }}>
        <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 600, marginBottom: 10 }}>Kilometre Taşların</div>
        <div style={{ display: "flex", gap: 12, overflowX: "auto", paddingBottom: 6 }}>
          {MILESTONES.map((m) => {
            const got = earned.some((e) => e.id === m.id); const Ic = m.icon;
            return (
              <div key={m.id} onClick={() => flash(got ? `🏅 "${m.label}" rozetini kazandın!` : "Bu rozet henüz kilitli")} style={{ flex: "0 0 auto", width: 74, textAlign: "center", opacity: got ? 1 : .42, cursor: "pointer" }}>
                <div style={{ width: 56, height: 56, borderRadius: "50%", margin: "0 auto 6px", display: "grid", placeItems: "center", background: got ? `linear-gradient(145deg, ${t.accent}, ${t.goldDeep})` : t.line, color: got ? "#fff" : t.soft, boxShadow: got ? `0 6px 16px ${t.accent}66` : "none", border: got ? "none" : `1px dashed ${t.soft}55` }}>{got ? <Ic size={22} /> : <Lock size={16} />}</div>
                <div style={{ fontSize: 10.5, color: t.soft, lineHeight: 1.2 }}>{m.label}</div>
              </div>
            );
          })}
        </div>
      </div>
      <div style={{ padding: "16px 22px 0" }}>
        <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 600, marginBottom: 12 }}>Bölümler</div>
        <div style={{ display: "flex", flexDirection: "column", gap: 13 }}>
          {SECTIONS.map((s, i) => {
            const tot = sectionTotal(s.id), fil = sectionUnits(data, s.id), sp = Math.round((fil / tot) * 100); const Ic = ICONS[s.icon];
            return (
              <button key={s.id} onClick={() => onSection(s)} className="tsCard" style={{ textAlign: "left", border: "none", cursor: "pointer", borderRadius: 20, background: t.panel, padding: 16, display: "flex", alignItems: "center", gap: 15, boxShadow: "0 4px 22px rgba(60,50,35,.06)", animationDelay: `${i * 60}ms` }}>
                <div style={{ width: 52, height: 52, borderRadius: 15, flexShrink: 0, display: "grid", placeItems: "center", background: `${s.color}26`, color: s.color }}><Ic size={24} /></div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: serif, fontSize: 19, fontWeight: 600, color: t.ink, lineHeight: 1.1 }}>{s.title}</div>
                  <div style={{ fontSize: 12, color: t.soft, marginBottom: 7 }}>{s.pages.length} sayfa · %{sp}</div>
                  <div style={{ height: 5, background: t.line, borderRadius: 99 }}><div style={{ width: `${sp}%`, height: "100%", borderRadius: 99, background: s.color, transition: "width .5s" }} /></div>
                </div>
                <ChevronLeft size={18} color={t.soft} style={{ transform: "rotate(180deg)", flexShrink: 0 }} />
              </button>
            );
          })}
        </div>
      </div>
      <div style={{ padding: "22px 22px 0", display: "flex", gap: 12 }}>
        <button onClick={() => flash("📖 PDF / dijital albüm dışa aktarma — üretimde aktif")} className="tsGhost" style={ghostBtn(t)}><Download size={16} /> PDF Albüm</button>
        <button onClick={() => flash("☁️ Yerel yedek (iCloud / Drive) — üretimde aktif")} className="tsGhost" style={ghostBtn(t)}><Share2 size={16} /> Yedekle</button>
      </div>
      <div style={{ textAlign: "center", fontSize: 11, color: t.soft, opacity: .6, marginTop: 26, padding: "0 30px", lineHeight: 1.6 }}>Tüm anıların yalnızca senin cihazında saklanır.<br />Tılsım'ın ışığı her zaman seninle olsun.</div>
    </div>
  );
}

function AniTree({ t, pct }) {
  const blossoms = [[88, 70], [120, 52], [150, 74], [70, 100], [104, 92], [136, 96], [168, 100], [60, 130], [96, 124], [128, 120], [160, 126], [184, 132], [78, 158], [112, 150], [146, 152], [176, 158], [50, 158]];
  const show = Math.round((pct / 100) * blossoms.length);
  return (
    <div style={{ display: "grid", placeItems: "center", padding: "6px 0 14px" }}>
      <svg width="220" height="210" viewBox="0 0 230 210">
        <ellipse cx="115" cy="196" rx="62" ry="9" fill={t.line} opacity=".7" />
        <path d="M115 196 L115 120" stroke={t.soft} strokeWidth="7" strokeLinecap="round" />
        <path d="M115 150 C100 140 86 128 74 112" stroke={t.soft} strokeWidth="5" fill="none" strokeLinecap="round" />
        <path d="M115 142 C132 132 150 120 162 104" stroke={t.soft} strokeWidth="5" fill="none" strokeLinecap="round" />
        <path d="M115 128 C108 116 104 100 106 84" stroke={t.soft} strokeWidth="4.5" fill="none" strokeLinecap="round" />
        <path d="M115 122 C128 112 140 96 142 80" stroke={t.soft} strokeWidth="4" fill="none" strokeLinecap="round" />
        {blossoms.map(([x, y], i) => {
          const on = i < show;
          return (
            <g key={i} style={{ transition: "all .5s ease", transformOrigin: `${x}px ${y}px`, transform: on ? "scale(1)" : "scale(0)", opacity: on ? 1 : 0 }}>
              {[0, 72, 144, 216, 288].map((a) => (<ellipse key={a} cx={x} cy={y - 5} rx="3.4" ry="6" fill={t.accent} transform={`rotate(${a} ${x} ${y})`} opacity=".92" />))}
              <circle cx={x} cy={y} r="2.6" fill={t.goldDeep} />
            </g>
          );
        })}
      </svg>
    </div>
  );
}

/* ---------------- SECTION ---------------- */
function SectionView({ t, serif, script, section, data, onBack, onPage }) {
  const Ic = ICONS[section.icon];
  return (
    <div style={{ animation: "tsSlide .35s ease", paddingBottom: 40 }}>
      <div style={{ background: section.color, padding: "26px 22px 34px", color: "#fff", position: "relative" }}>
        <button onClick={onBack} style={{ ...iconBtn(t), background: "rgba(255,255,255,.25)", color: "#fff", border: "none" }}><ChevronLeft size={20} /></button>
        <div style={{ textAlign: "center", marginTop: 10 }}>
          <Ic size={28} color="#fff" style={{ opacity: .9 }} />
          <div style={{ fontFamily: script, fontSize: 30, marginTop: 4, opacity: .95 }}>{section.title.split(" ")[0]}</div>
          <div style={{ fontFamily: serif, fontSize: 30, fontWeight: 700, letterSpacing: 2, textTransform: "uppercase", marginTop: -4 }}>{section.title.split(" ").slice(1).join(" ") || section.sub}</div>
          <div style={{ fontSize: 12.5, opacity: .85, marginTop: 4 }}>{section.sub}</div>
        </div>
      </div>
      <div style={{ padding: "22px 22px 0", position: "relative" }}>
        <div style={{ position: "absolute", left: 38, top: 30, bottom: 24, width: 2, background: t.line }} />
        {section.pages.map((p, i) => {
          const e = data[p.id]; const u = entryUnits(p, e); const total = pageUnits(p); const done = u >= total && total > 0; const started = u > 0;
          return (
            <button key={p.id} onClick={() => onPage(p)} className="tsRow" style={{ width: "100%", textAlign: "left", border: "none", background: "transparent", cursor: "pointer", display: "flex", alignItems: "center", gap: 16, padding: "9px 0", animationDelay: `${i * 40}ms` }}>
              <div style={{ width: 34, height: 34, borderRadius: "50%", flexShrink: 0, zIndex: 1, display: "grid", placeItems: "center", border: `2px solid ${done ? section.color : t.line}`, background: done ? section.color : started ? `${section.color}30` : t.panel, color: done ? "#fff" : section.color }}>{done ? <Check size={16} /> : <PageGlyph kind={p.kind} size={15} />}</div>
              <div style={{ flex: 1, background: t.panel, borderRadius: 15, padding: "13px 15px", boxShadow: "0 3px 14px rgba(60,50,35,.05)" }}>
                <div style={{ fontFamily: serif, fontSize: 17, fontWeight: 600, color: t.ink, lineHeight: 1.15 }}>{rowTitle(p, e)}</div>
                <div style={{ fontSize: 11.5, color: t.soft, marginTop: 3 }}>{done ? "Tamamlandı" : started ? `${u}/${total} dolduruldu` : kindLabel(p.kind)}</div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}
function PageGlyph({ kind, size }) {
  const M = { story: BookOpen, info: User, quick: Star, album: ImageIcon, photo: Camera, print: Footprints, letter: Mail, letters: Mail, monthly: Camera, monthlyChange: Camera, prediction: Heart, firstsCollection: Sparkles, members: Users, meaning: BookOpen, text: BookOpen, familytree: GitBranch, reactions: Users, memories2: Heart, ultrasonAll: ImageIcon, guestbook: Users };
  const C = M[kind] || BookOpen; return <C size={size} />;
}
function kindLabel(k) {
  return { story: "Yazı + albüm", info: "Bilgi formu", quick: "Hızlı notlar", album: "Foto/video albümü", photo: "Tek fotoğraf", print: "İz / damga", letter: "Mektup", letters: "Mektup koleksiyonu", monthly: "12 aylık seri", monthlyChange: "Aylık değişim", prediction: "Tahmin oyunu", firstsCollection: "Özel ilkler", members: "Aile üyeleri", meaning: "İsim anlamı", text: "Serbest yazı", familytree: "Soy ağacı", reactions: "Tepkiler", memories2: "Anılar (klasör)", ultrasonAll: "Ultrason albümü", guestbook: "Sevgi notları" }[k] || "Sayfa";
}

/* ---------------- PAGE EDITOR ---------------- */
function PageEditor({ t, serif, script, sans, page, entry = {}, babyName, onBack, onSave, flash }) {
  const [local, setLocal] = useState(entry);
  const set = (v) => setLocal((p) => ({ ...p, ...v }));
  const commit = () => { onSave(local); flash("✓ Cihazına kaydedildi"); onBack(); };
  const isMeaning = page.kind === "meaning";

  return (
    <div style={{ animation: "tsSlide .35s ease", minHeight: "100vh", display: "flex", flexDirection: "column" }}>
      <div style={{ padding: "18px 20px 6px", display: "flex", alignItems: "center", gap: 12 }}>
        <button onClick={onBack} style={iconBtn(t)}><ChevronLeft size={20} /></button>
        <div style={{ fontFamily: script, fontSize: 22, color: t.gold }}>{page.title.split(" ")[0]}</div>
      </div>
      {!isMeaning && (
        <div style={{ padding: "0 24px 4px" }}>
          <div style={{ fontFamily: serif, fontSize: 27, fontWeight: 600, lineHeight: 1.1 }}>{page.title}</div>
          <div style={{ width: 46, height: 2, background: t.gold, marginTop: 12, borderRadius: 2 }} />
        </div>
      )}
      <div style={{ flex: 1, padding: "20px 22px 110px" }}>
        {(page.kind === "info") && <InfoForm t={t} page={page} entry={local} set={set} />}
        {(page.kind === "quick") && <QuickForm t={t} page={page} entry={local} set={set} />}
        {(page.kind === "members") && <MembersForm t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "meaning") && <MeaningForm t={t} serif={serif} script={script} babyName={babyName} entry={local} set={set} />}
        {(page.kind === "text") && <TextForm t={t} page={page} entry={local} set={set} />}
        {(page.kind === "familytree") && <FamilyTree t={t} serif={serif} babyName={babyName} entry={local} set={set} />}
        {(page.kind === "story") && <StoryForm t={t} page={page} entry={local} set={set} />}
        {(page.kind === "reactions") && <ReactionsForm t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "memories2") && <Memories2Form t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "photo" || page.kind === "print") && <PhotoForm t={t} page={page} entry={local} set={set} />}
        {(page.kind === "album") && <AlbumForm t={t} entry={local} set={set} />}
        {(page.kind === "monthly") && <Monthly t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "monthlyChange") && <MonthlyChange t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "ultrasonAll") && <UltrasonAll t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "guestbook") && <Guestbook t={t} serif={serif} page={page} entry={local} set={set} />}
        {(page.kind === "letter") && <LetterForm t={t} serif={serif} page={page} entry={local} set={set} />}
        {(page.kind === "letters") && <LettersForm t={t} serif={serif} entry={local} set={set} />}
        {(page.kind === "prediction") && <Prediction t={t} entry={local} set={set} flash={flash} />}
        {(page.kind === "firstsCollection") && <FirstsCollection t={t} serif={serif} entry={local} set={set} />}
      </div>
      <div style={{ position: "sticky", bottom: 0, padding: "14px 22px", background: `linear-gradient(transparent, ${t.bg} 30%)` }}>
        <button onClick={commit} style={{ width: "100%", border: "none", cursor: "pointer", borderRadius: 16, padding: 15, fontFamily: sans, fontSize: 15, fontWeight: 600, color: "#fff", background: `linear-gradient(135deg, ${t.accent}, ${t.goldDeep})`, boxShadow: `0 10px 26px ${t.accent}55` }}>Cihaza Kaydet</button>
      </div>
    </div>
  );
}

/* ---------------- shared ---------------- */
function Label({ t, children }) { return <div style={{ fontSize: 12.5, letterSpacing: .8, color: t.soft, marginBottom: 7, textTransform: "uppercase" }}>{children}</div>; }
const labelInput = (t) => ({ width: "100%", boxSizing: "border-box", background: "transparent", border: "none", borderBottom: `1px solid ${t.line}`, borderRadius: 0, padding: "4px 2px", marginBottom: 8, outline: "none", fontFamily: "'Jost', sans-serif", fontSize: 12.5, letterSpacing: .8, textTransform: "uppercase", color: t.soft });
const inputStyle = (t) => ({ width: "100%", boxSizing: "border-box", background: t.panel, border: `1px solid ${t.line}`, borderRadius: 13, padding: "13px 15px", fontSize: 15, color: t.ink, outline: "none", fontFamily: "'Jost', sans-serif" });
function readFile(file, cb) { const r = new FileReader(); r.onload = () => cb(r.result); r.readAsDataURL(file); }

function RoundPhoto({ t, value, onSet, size = 70 }) {
  const ref = useRef();
  return (
    <div style={{ position: "relative", width: size, height: size }}>
      <button onClick={() => ref.current.click()} style={{ width: size, height: size, borderRadius: "50%", cursor: "pointer", border: `2px solid ${t.gold}`, background: value ? `center/cover url(${value})` : t.panel, display: "grid", placeItems: "center", overflow: "hidden", boxShadow: `0 4px 14px ${t.accent}44` }}>{!value && <Camera size={size * .32} color={t.soft} />}</button>
      {value && <button onClick={() => onSet(null)} style={{ position: "absolute", top: -4, right: -4, width: 22, height: 22, borderRadius: "50%", border: "none", background: t.ink, color: "#fff", cursor: "pointer", display: "grid", placeItems: "center" }}><X size={12} /></button>}
      <input ref={ref} type="file" accept="image/*" hidden onChange={(e) => { const f = e.target.files?.[0]; if (f) readFile(f, onSet); e.target.value = ""; }} />
    </div>
  );
}

/* polaroid tek foto */
function PhotoSlot({ t, value, onSet, label, ratio = "4/3", tape = true }) {
  const ref = useRef();
  return (
    <div style={{ position: "relative" }}>
      {tape && <div style={{ position: "absolute", top: -8, left: "50%", transform: "translateX(-50%) rotate(-3deg)", width: 60, height: 18, background: `${t.tape}cc`, zIndex: 2, borderRadius: 2, opacity: .85 }} />}
      <button onClick={() => ref.current.click()} style={{ width: "100%", aspectRatio: ratio, borderRadius: 6, cursor: "pointer", overflow: "hidden", background: t.panel, border: `1px solid ${t.line}`, padding: 8, display: "block", boxShadow: "0 8px 22px rgba(60,50,35,.1)" }}>
        <div style={{ width: "100%", height: "100%", borderRadius: 3, overflow: "hidden", background: value ? `center/cover no-repeat url(${value})` : t.bg, display: "grid", placeItems: "center", border: value ? "none" : `1px dashed ${t.soft}66` }}>
          {!value && <div style={{ textAlign: "center", color: t.soft }}><Camera size={26} style={{ opacity: .6 }} /><div style={{ fontSize: 12, marginTop: 6 }}>{label || "Fotoğraf ekle"}</div></div>}
        </div>
      </button>
      {value && <button onClick={() => onSet(null)} style={{ position: "absolute", top: 14, right: 14, width: 28, height: 28, borderRadius: "50%", border: "none", background: "rgba(0,0,0,.5)", color: "#fff", cursor: "pointer", zIndex: 3, display: "grid", placeItems: "center" }}><X size={15} /></button>}
      <input ref={ref} type="file" accept="image/*" hidden onChange={(e) => { const f = e.target.files?.[0]; if (f) readFile(f, onSet); e.target.value = ""; }} />
    </div>
  );
}

/* sınırsız albüm — boş slot yok, eklenen kadar foto + ekleme butonu */
function Album({ t, value = [], onChange, label = "Fotoğraf / Video Ekle" }) {
  const ref = useRef();
  const add = (e) => { const f = e.target.files?.[0]; if (f) readFile(f, (d) => onChange([...(value || []), d])); e.target.value = ""; };
  return (
    <div>
      {value.length > 0 && (
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12, marginBottom: 12 }}>
          {value.map((src, i) => (
            <div key={i} style={{ transform: `rotate(${i % 2 ? 1.3 : -1.3}deg)`, position: "relative", background: t.panel, padding: 7, borderRadius: 5, boxShadow: "0 6px 16px rgba(60,50,35,.12)", border: `1px solid ${t.line}` }}>
              <div style={{ aspectRatio: "1/1", background: `center/cover url(${src})`, borderRadius: 2 }} />
              <button onClick={() => onChange(value.filter((_, j) => j !== i))} style={{ position: "absolute", top: 12, right: 12, width: 24, height: 24, borderRadius: "50%", border: "none", background: "rgba(0,0,0,.5)", color: "#fff", cursor: "pointer", display: "grid", placeItems: "center" }}><X size={13} /></button>
            </div>
          ))}
        </div>
      )}
      <button onClick={() => ref.current.click()} style={addBtn(t)}><Plus size={16} /> {label}</button>
      <input ref={ref} type="file" accept="image/*,video/*" hidden onChange={add} />
    </div>
  );
}

/* ---- INFO ---- */
function InfoForm({ t, page, entry, set }) {
  const onField = (i, v) => { const vals = [...(entry.vals || [])]; vals[i] = v; set({ vals }); };
  return (
    <div>
      {page.avatar && <div style={{ display: "flex", justifyContent: "flex-end", marginTop: -6, marginBottom: 10 }}><RoundPhoto t={t} value={entry.avatar} onSet={(p) => set({ avatar: p })} /></div>}
      <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
        {page.fields.map((f, i) => {
          const label = typeof f === "string" ? f : f.label; const type = typeof f === "string" ? "text" : f.type;
          return (<div key={i}><Label t={t}>{label}</Label><input type={type} value={entry.vals?.[i] || ""} onChange={(e) => onField(i, e.target.value)} placeholder={type === "text" ? "Buraya yaz..." : ""} style={inputStyle(t)} /></div>);
        })}
      </div>
    </div>
  );
}

/* ---- QUICK ---- */
function QuickForm({ t, page, entry, set }) {
  const answers = entry.answers || page.fields.map((q) => ({ q, a: "", preset: true }));
  const update = (i, patch) => set({ answers: answers.map((x, j) => (j === i ? { ...x, ...patch } : x)) });
  const addCustom = () => set({ answers: [...answers, { q: "", a: "", preset: false }] });
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
      {answers.map((row, i) => (
        <div key={i}>
          {row.preset ? <Label t={t}>{row.q}</Label>
            : <input value={row.q} onChange={(e) => update(i, { q: e.target.value })} placeholder="Soru / Başlık" style={labelInput(t)} />}
          <div style={{ position: "relative" }}>
            <input value={row.a} onChange={(e) => update(i, { a: e.target.value })} placeholder="Cevabın..." style={inputStyle(t)} />
            {!row.preset && <button onClick={() => set({ answers: answers.filter((_, j) => j !== i) })} style={{ position: "absolute", right: 8, top: 8, width: 30, height: 30, borderRadius: 8, border: "none", background: "transparent", color: t.soft, cursor: "pointer" }}><Trash2 size={15} /></button>}
          </div>
        </div>
      ))}
      {page.allowAdd && <button onClick={addCustom} style={addBtn(t)}><Plus size={16} /> Kendi notunu ekle</button>}
    </div>
  );
}

/* ---- MEMBERS ---- */
const RELATIONS = ["Anneanne", "Babaanne", "Dede", "Hala", "Teyze", "Amca", "Dayı", "Kardeş", "Kuzen"];
function MembersForm({ t, serif, entry, set }) {
  const members = entry.members || [];
  const add = () => set({ members: [...members, { name: "", rel: "", photo: null, custom: false }] });
  const upd = (i, patch) => set({ members: members.map((m, j) => (j === i ? { ...m, ...patch } : m)) });
  return (
    <div>
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        {members.map((m, i) => (
          <div key={i} style={{ background: t.panel, borderRadius: 18, padding: 16, border: `1px solid ${t.line}`, display: "flex", gap: 14, alignItems: "flex-start", boxShadow: "0 4px 16px rgba(60,50,35,.05)" }}>
            <RoundPhoto t={t} value={m.photo} onSet={(p) => upd(i, { photo: p })} size={60} />
            <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 9 }}>
              <input value={m.name} onChange={(e) => upd(i, { name: e.target.value })} placeholder="Ad Soyad" style={inputStyle(t)} />
              <div style={{ display: "flex", gap: 7, flexWrap: "wrap" }}>
                {RELATIONS.map((r) => { const sel = m.rel === r && !m.custom; return (<button key={r} onClick={() => upd(i, { rel: r, custom: false })} style={chip(t, sel)}>{r}</button>); })}
                <button onClick={() => upd(i, { custom: true, rel: RELATIONS.includes(m.rel) ? "" : m.rel })} style={chip(t, m.custom)}>Diğer</button>
              </div>
              {m.custom && <input value={m.rel} onChange={(e) => upd(i, { rel: e.target.value })} placeholder="Yakınlık derecesini yaz..." style={inputStyle(t)} autoFocus />}
            </div>
            <button onClick={() => set({ members: members.filter((_, j) => j !== i) })} style={{ border: "none", background: "transparent", color: t.soft, cursor: "pointer", padding: 4 }}><Trash2 size={16} /></button>
          </div>
        ))}
      </div>
      {!members.length && <Empty t={t} serif={serif}>Ailenin diğer üyelerini ekle</Empty>}
      <button onClick={add} style={{ ...addBtn(t), marginTop: 14 }}><Plus size={16} /> Üye Ekle</button>
    </div>
  );
}
const chip = (t, sel) => ({ border: `1px solid ${sel ? t.gold : t.line}`, background: sel ? `${t.accent}33` : "transparent", color: sel ? t.goldDeep : t.soft, borderRadius: 99, padding: "5px 11px", fontSize: 12, cursor: "pointer", fontFamily: "'Jost',sans-serif" });

/* ---- MEANING ---- */
function MeaningForm({ t, serif, script, babyName, entry, set }) {
  return (
    <div>
      <div style={{ textAlign: "center", marginBottom: 22 }}>
        <div style={{ fontFamily: script, fontSize: 22, color: t.gold }}>İsminin anlamı</div>
        <div style={{ fontFamily: serif, fontSize: 42, fontWeight: 600, color: t.ink, lineHeight: 1.1 }}>{babyName}</div>
        <div style={{ width: 50, height: 2, background: t.gold, margin: "14px auto 0", borderRadius: 2 }} />
      </div>
      <textarea rows={8} value={entry.text || ""} onChange={(e) => set({ text: e.target.value })} placeholder="Adının anlamını buraya yaz..." style={{ ...inputStyle(t), resize: "vertical", lineHeight: 1.7, fontFamily: serif, fontSize: 18, textAlign: "center" }} />
    </div>
  );
}

/* ---- TEXT ---- */
function TextForm({ t, page, entry, set }) {
  return <textarea rows={9} value={entry.text || ""} onChange={(e) => set({ text: e.target.value })} placeholder={page.hint || "Buraya yaz..."} style={{ ...inputStyle(t), resize: "vertical", lineHeight: 1.7 }} />;
}

/* ---- FAMILY TREE ---- */
const TREE_NODES = [
  { key: "anneanne", role: "Anneanne" }, { key: "dedeanne", role: "Dede" },
  { key: "babaanne", role: "Babaanne" }, { key: "babababa", role: "Dede" },
  { key: "anne", role: "Anne" }, { key: "baba", role: "Baba" },
];
function FamilyTree({ t, serif, babyName, entry, set }) {
  const tree = entry.tree || {};
  const [edit, setEdit] = useState(null);
  const upd = (key, patch) => set({ tree: { ...tree, [key]: { ...(tree[key] || {}), ...patch } } });
  const Node = ({ k, role, child }) => {
    const n = child ? { name: babyName, photo: tree.cocuk?.photo } : (tree[k] || {});
    return (
      <button onClick={() => setEdit(child ? "cocuk" : k)} style={{ background: "transparent", border: "none", cursor: "pointer", textAlign: "center", width: child ? 84 : 70 }}>
        <div style={{ width: child ? 64 : 50, height: child ? 64 : 50, borderRadius: "50%", margin: "0 auto", border: `2px solid ${child ? t.gold : t.soft}`, background: n.photo ? `center/cover url(${n.photo})` : t.panel, display: "grid", placeItems: "center", boxShadow: child ? `0 4px 14px ${t.accent}55` : "none" }}>{!n.photo && <User size={child ? 26 : 20} color={t.soft} />}</div>
        <div style={{ fontSize: 10, color: t.soft, marginTop: 4, textTransform: "uppercase", letterSpacing: .5 }}>{role}</div>
        <div style={{ fontFamily: serif, fontSize: 13.5, fontWeight: 600, color: t.ink, lineHeight: 1.1, marginTop: 1 }}>{n.name || "—"}</div>
      </button>
    );
  };
  const L = () => <div style={{ width: 2, height: 18, background: t.line, margin: "0 auto" }} />;
  const roleName = edit === "cocuk" ? "Bebeğimiz" : TREE_NODES.find((x) => x.key === edit)?.role;
  return (
    <div>
      <div style={{ background: t.panel, borderRadius: 20, padding: "20px 10px", border: `1px solid ${t.line}` }}>
        <div style={{ display: "flex", justifyContent: "space-around" }}>
          <div style={{ display: "flex", gap: 2 }}><Node k="anneanne" role="Anneanne" /><Node k="dedeanne" role="Dede" /></div>
          <div style={{ display: "flex", gap: 2 }}><Node k="babaanne" role="Babaanne" /><Node k="babababa" role="Dede" /></div>
        </div>
        <div style={{ display: "flex", justifyContent: "space-around" }}><L /><L /></div>
        <div style={{ display: "flex", justifyContent: "space-around", alignItems: "center" }}>
          <Node k="anne" role="Anne" /><Heart size={16} color={t.gold} fill={t.accent} /><Node k="baba" role="Baba" />
        </div>
        <L />
        <div style={{ display: "flex", justifyContent: "center" }}><Node child role="Bebeğimiz" /></div>
      </div>
      {edit && (
        <div style={{ marginTop: 16, background: t.panel, borderRadius: 16, padding: 16, border: `1px solid ${t.gold}` }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
            <div style={{ fontFamily: serif, fontSize: 18, fontWeight: 600 }}>{roleName}</div>
            <button onClick={() => setEdit(null)} style={{ border: "none", background: "transparent", color: t.soft, cursor: "pointer" }}><X size={18} /></button>
          </div>
          <div style={{ display: "flex", gap: 14, alignItems: "center" }}>
            <RoundPhoto t={t} value={(edit === "cocuk" ? tree.cocuk : tree[edit])?.photo} onSet={(p) => upd(edit, { photo: p })} size={56} />
            {edit === "cocuk" ? <div style={{ ...inputStyle(t), color: t.soft }}>{babyName} (otomatik)</div>
              : <input value={(tree[edit] || {}).name || ""} onChange={(e) => upd(edit, { name: e.target.value })} placeholder="İsim" style={inputStyle(t)} />}
          </div>
        </div>
      )}
      <div style={{ fontSize: 11.5, color: t.soft, textAlign: "center", marginTop: 12, opacity: .7 }}>Düzenlemek için bir kişiye dokun</div>
    </div>
  );
}

/* ---- STORY ---- */
const MOODS = ["🥰", "😭", "🤍", "😮", "🤩", "😌", "🙏"];
function StoryForm({ t, page, entry, set }) {
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
      <div><Label t={t}>Tarih</Label><input type="date" value={entry.date || ""} onChange={(e) => set({ date: e.target.value })} style={inputStyle(t)} /></div>
      {page.media && <div><Label t={t}>Fotoğraf / Video Albümü</Label><Album t={t} value={entry.media || []} onChange={(m) => set({ media: m })} /></div>}
      {page.audio && <AudioRow t={t} value={entry.audio} onToggle={() => set({ audio: !entry.audio })} />}
      <div><Label t={t}>Anı</Label><textarea rows={6} value={entry.text || ""} onChange={(e) => set({ text: e.target.value })} placeholder={page.hint || "Buraya yaz..."} style={{ ...inputStyle(t), resize: "vertical", lineHeight: 1.6 }} /></div>
      <MoodPicker t={t} value={entry.mood} onPick={(m) => set({ mood: m })} />
    </div>
  );
}
function MoodPicker({ t, value, onPick }) {
  return (<div><Label t={t}>O anki his</Label><div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>{MOODS.map((m) => (<button key={m} onClick={() => onPick(m === value ? "" : m)} style={{ width: 44, height: 44, borderRadius: 12, fontSize: 22, cursor: "pointer", background: value === m ? t.accent : t.panel, border: `1px solid ${value === m ? t.accent : t.line}` }}>{m}</button>))}</div></div>);
}

/* ---- REACTIONS ---- */
function ReactionsForm({ t, serif, entry, set }) {
  const list = entry.reactions || [];
  const add = () => set({ reactions: [...list, { who: "", text: "" }] });
  const upd = (i, patch) => set({ reactions: list.map((r, j) => (j === i ? { ...r, ...patch } : r)) });
  return (
    <div>
      <div style={{ display: "flex", flexDirection: "column", gap: 13 }}>
        {list.map((r, i) => (
          <div key={i} style={{ background: t.panel, borderRadius: 16, padding: 14, border: `1px solid ${t.line}` }}>
            <div style={{ display: "flex", gap: 8, alignItems: "center", marginBottom: 9 }}>
              <input value={r.who} onChange={(e) => upd(i, { who: e.target.value })} placeholder="Kim? (ör. Amcan)" style={{ ...inputStyle(t), fontWeight: 600 }} />
              <button onClick={() => set({ reactions: list.filter((_, j) => j !== i) })} style={{ border: "none", background: "transparent", color: t.soft, cursor: "pointer" }}><Trash2 size={16} /></button>
            </div>
            <textarea rows={2} value={r.text} onChange={(e) => upd(i, { text: e.target.value })} placeholder="Tepkisi nasıldı?" style={{ ...inputStyle(t), resize: "vertical" }} />
          </div>
        ))}
      </div>
      {!list.length && <Empty t={t} serif={serif}>Herkesin tepkisini ayrı ayrı ekle</Empty>}
      <button onClick={add} style={{ ...addBtn(t), marginTop: 13 }}><Plus size={16} /> Kişi / Tepki Ekle</button>
    </div>
  );
}

/* ---- MEMORIES (klasör) ---- */
function Memories2Form({ t, serif, entry, set }) {
  const list = entry.memories || [];
  const [open, setOpen] = useState(null);
  const add = () => { set({ memories: [...list, { title: "", text: "", media: [] }] }); setOpen(list.length); };
  const upd = (i, patch) => set({ memories: list.map((m, j) => (j === i ? { ...m, ...patch } : m)) });
  if (open !== null && list[open]) {
    const m = list[open];
    return (
      <div style={{ animation: "tsFade .25s" }}>
        <button onClick={() => setOpen(null)} style={{ ...ghostBtn(t), width: "auto", padding: "8px 14px", marginBottom: 14 }}><ChevronLeft size={15} /> Anılara dön</button>
        <input value={m.title} onChange={(e) => upd(open, { title: e.target.value })} placeholder="Anı başlığı (ör. İlk tekme)" style={{ ...inputStyle(t), fontFamily: serif, fontSize: 20, fontWeight: 600, marginBottom: 14 }} />
        <Label t={t}>Fotoğraf / Video</Label>
        <Album t={t} value={m.media || []} onChange={(md) => upd(open, { media: md })} />
        <textarea rows={5} value={m.text} onChange={(e) => upd(open, { text: e.target.value })} placeholder="Anlat..." style={{ ...inputStyle(t), resize: "vertical", marginTop: 14, lineHeight: 1.6 }} />
      </div>
    );
  }
  return (
    <div>
      <div style={{ display: "flex", flexDirection: "column", gap: 11 }}>
        {list.map((m, i) => {
          const cover = (m.media || [])[0];
          return (
            <button key={i} onClick={() => setOpen(i)} style={{ width: "100%", textAlign: "left", cursor: "pointer", border: `1px solid ${t.line}`, background: t.panel, borderRadius: 16, padding: 12, display: "flex", gap: 13, alignItems: "center", boxShadow: "0 3px 14px rgba(60,50,35,.05)" }}>
              <div style={{ width: 54, height: 54, borderRadius: 12, flexShrink: 0, background: cover ? `center/cover url(${cover})` : `${t.accent}26`, display: "grid", placeItems: "center", color: t.gold }}>{!cover && <Heart size={22} />}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontFamily: serif, fontSize: 17, fontWeight: 600, color: t.ink }}>{m.title || `Anı ${i + 1}`}</div>
                <div style={{ fontSize: 12, color: t.soft }}>{(m.media || []).length} medya · {m.text ? "yazı var" : "yazı yok"}</div>
              </div>
              <ChevronLeft size={17} color={t.soft} style={{ transform: "rotate(180deg)" }} />
            </button>
          );
        })}
      </div>
      {!list.length && <Empty t={t} serif={serif}>Her anıyı kendi klasöründe sakla</Empty>}
      <button onClick={add} style={{ ...addBtn(t), marginTop: 14 }}><Plus size={16} /> Yeni Anı Klasörü</button>
    </div>
  );
}

/* ---- PHOTO ---- */
function PhotoForm({ t, page, entry, set }) {
  return (<div><div style={{ padding: "0 6px" }}><PhotoSlot t={t} value={entry.photo} onSet={(p) => set({ photo: p })} label={page.note} ratio="1/1" /></div><div style={{ marginTop: 18 }}><Label t={t}>Not</Label><input value={entry.text || ""} onChange={(e) => set({ text: e.target.value })} placeholder="Bir not ekle..." style={inputStyle(t)} /></div></div>);
}
function AlbumForm({ t, entry, set }) { return <Album t={t} value={entry.photos || []} onChange={(p) => set({ photos: p })} />; }

/* ---- MONTHLY ---- */
const AYLAR = Array.from({ length: 12 }, (_, i) => `${i + 1}. Ay`);
function Monthly({ t, serif, entry, set }) {
  const months = entry.months || Array(12).fill(null);
  const setOne = (i, v) => { const n = [...months]; while (n.length < 12) n.push(null); n[i] = v; set({ months: n }); };
  return (<div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 14 }}>{AYLAR.map((m, i) => (<div key={i}><PhotoSlot t={t} value={months[i]} onSet={(v) => setOne(i, v)} label={m} ratio="1/1" tape={false} /><div style={{ textAlign: "center", fontFamily: serif, fontSize: 14, color: t.soft, marginTop: 6 }}>{m}</div></div>))}</div>);
}

/* ---- MONTHLY CHANGE ---- */
function MonthlyChange({ t, serif, entry, set }) {
  const months = entry.months || {};
  const [open, setOpen] = useState(1);
  const setMonth = (m, arr) => set({ months: { ...months, [m]: arr } });
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
      {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => {
        const arr = months[m] || []; const isOpen = open === m;
        return (
          <div key={m} style={{ background: t.panel, borderRadius: 16, border: `1px solid ${isOpen ? t.gold : t.line}`, overflow: "hidden" }}>
            <button onClick={() => setOpen(isOpen ? null : m)} style={{ width: "100%", border: "none", background: "transparent", cursor: "pointer", padding: "13px 16px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontFamily: serif, fontSize: 17, fontWeight: 600, color: t.ink }}>{m}. Ay</span>
              <span style={{ display: "flex", alignItems: "center", gap: 8, color: t.soft, fontSize: 13 }}>{arr.length ? `${arr.length} fotoğraf` : "boş"}<ChevronDown size={17} style={{ transform: isOpen ? "rotate(180deg)" : "none", transition: ".2s" }} /></span>
            </button>
            {isOpen && <div style={{ padding: "0 14px 16px" }}><Album t={t} value={arr} onChange={(a) => setMonth(m, a)} label="Fotoğraf Ekle" /></div>}
          </div>
        );
      })}
    </div>
  );
}

/* ---- ULTRASON ALL (önce ay sorulur, aya göre gruplanır) ---- */
function UltrasonAll({ t, serif, entry, set }) {
  const ref = useRef();
  const [picking, setPicking] = useState(false);
  const pendingMonth = useRef(null);
  const items = entry.items || [];
  const chooseMonth = (m) => { pendingMonth.current = m; setPicking(false); ref.current.click(); };
  const addPhoto = (e) => { const f = e.target.files?.[0]; if (f && pendingMonth.current) readFile(f, (d) => set({ items: [...items, { month: pendingMonth.current, photo: d }] })); e.target.value = ""; pendingMonth.current = null; };
  const presentMonths = [...new Set(items.map((i) => i.month))].sort((a, b) => a - b);
  return (
    <div>
      <button onClick={() => setPicking((p) => !p)} style={{ ...addBtn(t), marginBottom: 14 }}><Plus size={16} /> Ultrason Ekle</button>
      {picking && (
        <div style={{ background: t.panel, border: `1px solid ${t.gold}`, borderRadius: 16, padding: 14, marginBottom: 16, animation: "tsFade .2s" }}>
          <div style={{ fontSize: 13, color: t.soft, marginBottom: 10 }}>Hangi aya ait?</div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: 8 }}>
            {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => (<button key={m} onClick={() => chooseMonth(m)} style={{ border: `1px solid ${t.line}`, background: t.bg, color: t.ink, borderRadius: 10, padding: "10px 0", fontSize: 13, fontWeight: 600, cursor: "pointer", fontFamily: "'Jost',sans-serif" }}>{m}. Ay</button>))}
          </div>
        </div>
      )}
      <input ref={ref} type="file" accept="image/*" hidden onChange={addPhoto} />
      {presentMonths.map((m) => {
        const monthItems = items.map((it, gi) => ({ ...it, gi })).filter((it) => it.month === m);
        return (
          <div key={m} style={{ marginBottom: 22 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
              <div style={{ fontFamily: serif, fontSize: 21, fontWeight: 600, color: t.goldDeep }}>{m}. Ay</div>
              <div style={{ flex: 1, height: 1, background: t.line }} />
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
              {monthItems.map((it) => (
                <div key={it.gi} style={{ position: "relative", background: t.panel, padding: 7, borderRadius: 5, border: `1px solid ${t.line}`, boxShadow: "0 6px 16px rgba(60,50,35,.1)", transform: `rotate(${it.gi % 2 ? 1.2 : -1.2}deg)` }}>
                  <div style={{ aspectRatio: "1/1", background: `center/cover url(${it.photo})`, borderRadius: 3 }} />
                  <button onClick={() => set({ items: items.filter((_, j) => j !== it.gi) })} style={{ position: "absolute", top: 12, right: 12, width: 24, height: 24, borderRadius: "50%", border: "none", background: "rgba(0,0,0,.5)", color: "#fff", cursor: "pointer" }}><X size={13} /></button>
                </div>
              ))}
            </div>
          </div>
        );
      })}
      {!items.length && <Empty t={t} serif={serif}>Ay seç, fotoğrafı ekle — otomatik sıralanır</Empty>}
    </div>
  );
}

/* ---- GUESTBOOK ---- */
function Guestbook({ t, serif, page, entry, set }) {
  const notes = entry.notes || [];
  const add = () => set({ notes: [...notes, { who: "", text: "", photo: null }] });
  const upd = (i, patch) => set({ notes: notes.map((n, j) => (j === i ? { ...n, ...patch } : n)) });
  return (
    <div>
      {page.note && <div style={{ fontSize: 13, color: t.soft, marginTop: -8, marginBottom: 14 }}>{page.note}</div>}
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        {notes.map((n, i) => (
          <div key={i} style={{ background: t.panel, borderRadius: 18, padding: 16, border: `1px solid ${t.line}`, boxShadow: "0 4px 16px rgba(60,50,35,.05)" }}>
            <div style={{ display: "flex", gap: 12, alignItems: "center", marginBottom: 11 }}>
              <RoundPhoto t={t} value={n.photo} onSet={(p) => upd(i, { photo: p })} size={48} />
              <input value={n.who} onChange={(e) => upd(i, { who: e.target.value })} placeholder="Kim yazıyor?" style={{ ...inputStyle(t), fontWeight: 600 }} />
              <button onClick={() => set({ notes: notes.filter((_, j) => j !== i) })} style={{ border: "none", background: "transparent", color: t.soft, cursor: "pointer" }}><Trash2 size={16} /></button>
            </div>
            <textarea rows={3} value={n.text} onChange={(e) => upd(i, { text: e.target.value })} placeholder="Bebeğe bir not bırak..." style={{ ...inputStyle(t), resize: "vertical", fontFamily: serif, fontSize: 16, lineHeight: 1.6 }} />
          </div>
        ))}
      </div>
      {!notes.length && <Empty t={t} serif={serif}>Sevdiklerin sana not bıraksın</Empty>}
      <button onClick={add} style={{ ...addBtn(t), marginTop: 14 }}><Plus size={16} /> Not Ekle</button>
    </div>
  );
}

/* ---- LETTER (tek) ---- */
function LetterForm({ t, serif, page, entry, set }) {
  return (
    <div style={{ background: t.panel, borderRadius: 18, padding: "22px 20px", border: `1px solid ${t.line}`, boxShadow: "0 6px 22px rgba(60,50,35,.06)" }}>
      <div style={{ fontFamily: serif, fontStyle: "italic", fontSize: 18, color: t.soft, marginBottom: 14 }}>Sevgili bebeğim,</div>
      <textarea rows={11} value={entry.text || ""} onChange={(e) => set({ text: e.target.value })} placeholder={`${page.who} senin için bir mektup yazsın...`} style={{ width: "100%", boxSizing: "border-box", background: "transparent", border: "none", outline: "none", fontFamily: serif, fontSize: 17, lineHeight: 1.8, color: t.ink, resize: "vertical" }} />
      <div style={{ textAlign: "right", fontFamily: serif, fontStyle: "italic", fontSize: 16, color: t.gold, marginTop: 8 }}>— {page.who}</div>
    </div>
  );
}

/* ---- LETTERS (sevdiklerinden, koleksiyon) ---- */
function LettersForm({ t, serif, entry, set }) {
  const list = entry.letters || [];
  const add = () => set({ letters: [...list, { who: "", text: "" }] });
  const upd = (i, patch) => set({ letters: list.map((l, j) => (j === i ? { ...l, ...patch } : l)) });
  return (
    <div>
      <div style={{ display: "flex", flexDirection: "column", gap: 18 }}>
        {list.map((l, i) => (
          <div key={i} style={{ background: t.panel, borderRadius: 18, padding: "20px 18px", border: `1px solid ${t.line}`, boxShadow: "0 6px 22px rgba(60,50,35,.07)", position: "relative" }}>
            <button onClick={() => set({ letters: list.filter((_, j) => j !== i) })} style={{ position: "absolute", top: 12, right: 12, border: "none", background: "transparent", color: t.soft, cursor: "pointer" }}><Trash2 size={16} /></button>
            <div style={{ fontFamily: serif, fontStyle: "italic", fontSize: 17, color: t.soft, marginBottom: 12 }}>Sevgili bebeğim,</div>
            <textarea rows={6} value={l.text} onChange={(e) => upd(i, { text: e.target.value })} placeholder="Mektubunu buraya yaz..." style={{ width: "100%", boxSizing: "border-box", background: "transparent", border: "none", outline: "none", fontFamily: serif, fontSize: 16.5, lineHeight: 1.8, color: t.ink, resize: "vertical" }} />
            <div style={{ display: "flex", alignItems: "center", justifyContent: "flex-end", gap: 6, marginTop: 8 }}>
              <span style={{ fontFamily: serif, fontStyle: "italic", fontSize: 16, color: t.gold }}>—</span>
              <input value={l.who} onChange={(e) => upd(i, { who: e.target.value })} placeholder="kimden (ör. Babaannen)" style={{ background: "transparent", border: "none", borderBottom: `1px solid ${t.line}`, outline: "none", textAlign: "right", fontFamily: serif, fontStyle: "italic", fontSize: 16, color: t.gold, width: 170, padding: "2px 0" }} />
            </div>
          </div>
        ))}
      </div>
      {!list.length && <Empty t={t} serif={serif}>Sevdiklerin bebeğe birer mektup yazsın</Empty>}
      <button onClick={add} style={{ ...addBtn(t), marginTop: 16 }}><Mail size={16} /> Mektup Ekle</button>
    </div>
  );
}

/* ---- PREDICTION ---- */
function Prediction({ t, entry, set, flash }) {
  const [name, setName] = useState("");
  const kiz = entry.kiz || [], erkek = entry.erkek || [];
  const add = (g) => { if (!name.trim()) return flash("Önce bir isim yaz"); if (g === "kiz") set({ kiz: [...kiz, name.trim()] }); else set({ erkek: [...erkek, name.trim()] }); setName(""); };
  const col = (title, list, color, key) => (
    <div style={{ flex: 1, background: t.panel, borderRadius: 16, padding: 14, border: `1px solid ${t.line}` }}>
      <div style={{ textAlign: "center", fontWeight: 600, color, marginBottom: 10 }}>{title}</div>
      <div style={{ display: "flex", flexDirection: "column", gap: 7, minHeight: 40 }}>
        {list.map((n, i) => (<div key={i} style={{ background: `${color}1f`, color, borderRadius: 9, padding: "7px 10px", fontSize: 13, display: "flex", justifyContent: "space-between", alignItems: "center" }}>{n}<X size={13} style={{ cursor: "pointer" }} onClick={() => set({ [key]: list.filter((_, j) => j !== i) })} /></div>))}
        {!list.length && <div style={{ textAlign: "center", fontSize: 12, color: t.soft, opacity: .6, padding: 6 }}>Henüz yok</div>}
      </div>
    </div>
  );
  return (
    <div>
      <input value={name} onChange={(e) => setName(e.target.value)} placeholder="Tahmin eden kişinin adı..." style={{ ...inputStyle(t), marginBottom: 12 }} />
      <div style={{ display: "flex", gap: 10, marginBottom: 16 }}>
        <button onClick={() => add("kiz")} style={predBtn("#C99A90")}>👧 Kız diyor</button>
        <button onClick={() => add("erkek")} style={predBtn("#7A93A3")}>👦 Erkek diyor</button>
      </div>
      <div style={{ display: "flex", gap: 12 }}>{col("Kız Hissedenler", kiz, "#C99A90", "kiz")}{col("Erkek Hissedenler", erkek, "#7A93A3", "erkek")}</div>
    </div>
  );
}
const predBtn = (c) => ({ flex: 1, border: "none", cursor: "pointer", borderRadius: 12, padding: 12, background: `${c}26`, color: c, fontSize: 14, fontWeight: 600, fontFamily: "'Jost',sans-serif" });

/* ---- FIRSTS COLLECTION ---- */
function FirstsCollection({ t, serif, entry, set }) {
  const items = entry.items || [];
  const [open, setOpen] = useState(null);
  const add = () => { set({ items: [...items, { title: "", date: "", photo: null, text: "" }] }); setOpen(items.length); };
  const upd = (i, patch) => set({ items: items.map((it, j) => (j === i ? { ...it, ...patch } : it)) });
  if (open !== null && items[open]) {
    const it = items[open];
    return (
      <div style={{ animation: "tsFade .25s" }}>
        <button onClick={() => setOpen(null)} style={{ ...ghostBtn(t), width: "auto", padding: "8px 14px", marginBottom: 14 }}><ChevronLeft size={15} /> Listeye dön</button>
        <Label t={t}>İlk ne?</Label>
        <input value={it.title} onChange={(e) => upd(open, { title: e.target.value })} placeholder="ör. İlk Banyon, İlk Tatilin..." style={{ ...inputStyle(t), fontFamily: serif, fontSize: 19, fontWeight: 600, marginBottom: 14 }} />
        <Label t={t}>Tarih</Label>
        <input type="date" value={it.date} onChange={(e) => upd(open, { date: e.target.value })} style={{ ...inputStyle(t), marginBottom: 14 }} />
        <PhotoSlot t={t} value={it.photo} onSet={(p) => upd(open, { photo: p })} label="Fotoğraf ekle" />
        <textarea rows={4} value={it.text} onChange={(e) => upd(open, { text: e.target.value })} placeholder="O an..." style={{ ...inputStyle(t), resize: "vertical", marginTop: 14, lineHeight: 1.6 }} />
      </div>
    );
  }
  return (
    <div>
      <div style={{ display: "flex", flexDirection: "column", gap: 11 }}>
        {items.map((it, i) => (
          <button key={i} onClick={() => setOpen(i)} style={{ width: "100%", textAlign: "left", cursor: "pointer", border: `1px solid ${t.line}`, background: t.panel, borderRadius: 16, padding: 12, display: "flex", gap: 13, alignItems: "center", boxShadow: "0 3px 14px rgba(60,50,35,.05)" }}>
            <div style={{ width: 52, height: 52, borderRadius: 12, flexShrink: 0, background: it.photo ? `center/cover url(${it.photo})` : `${t.accent}26`, display: "grid", placeItems: "center", color: t.gold }}>{!it.photo && <Sparkles size={20} />}</div>
            <div style={{ flex: 1, minWidth: 0 }}><div style={{ fontFamily: serif, fontSize: 17, fontWeight: 600, color: t.ink }}>{it.title || "İsimsiz ilk"}</div><div style={{ fontSize: 12, color: t.soft }}>{it.date || "tarih yok"}</div></div>
            <ChevronLeft size={17} color={t.soft} style={{ transform: "rotate(180deg)" }} />
          </button>
        ))}
      </div>
      {!items.length && <Empty t={t} serif={serif}>Kendi özel "ilk"lerini ekle — adı otomatik başlık olur</Empty>}
      <button onClick={add} style={{ ...addBtn(t), marginTop: 14 }}><Plus size={16} /> Yeni İlk Ekle</button>
    </div>
  );
}

/* ---- AUDIO ---- */
function AudioRow({ t, value, onToggle }) {
  return (<button onClick={onToggle} style={{ width: "100%", border: `1px solid ${value ? t.accent : t.line}`, cursor: "pointer", borderRadius: 13, padding: "13px 15px", background: value ? `${t.accent}1f` : t.panel, display: "flex", alignItems: "center", gap: 12, fontFamily: "'Jost',sans-serif" }}><div style={{ width: 38, height: 38, borderRadius: "50%", background: value ? t.accent : t.line, color: value ? "#fff" : t.soft, display: "grid", placeItems: "center" }}><Mic size={18} /></div><div style={{ textAlign: "left" }}><div style={{ fontSize: 14, color: t.ink, fontWeight: 500 }}>{value ? "Sesli anı kaydedildi" : "Sesli anı ekle"}</div><div style={{ fontSize: 11.5, color: t.soft }}>{value ? "Dokun: kaldır" : "İlk kalp atışını, kahkahanı kaydet"}</div></div></button>);
}

/* ---- THEME SHEET ---- */
function ThemeSheet({ t, serif, current, onPick, onClose }) {
  return (
    <div onClick={onClose} style={{ position: "fixed", inset: 0, background: "rgba(20,16,12,.45)", zIndex: 50, display: "flex", alignItems: "flex-end", justifyContent: "center", animation: "tsFade .25s" }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: "100%", maxWidth: 480, background: t.panel, borderRadius: "26px 26px 0 0", padding: "22px 22px 34px", maxHeight: "80vh", overflowY: "auto", animation: "tsRise .3s ease" }}>
        <div style={{ width: 40, height: 4, background: t.line, borderRadius: 9, margin: "0 auto 18px" }} />
        <div style={{ fontFamily: serif, fontSize: 22, fontWeight: 600, marginBottom: 16, color: t.ink }}>Tema Seç</div>
        <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
          {Object.entries(THEMES).map(([k, th]) => (
            <button key={k} onClick={() => onPick(k)} style={{ border: `2px solid ${current === k ? th.gold : "transparent"}`, cursor: "pointer", borderRadius: 16, padding: 14, background: th.bg, display: "flex", alignItems: "center", gap: 11, textAlign: "left" }}>
              <div style={{ display: "flex" }}><span style={{ width: 22, height: 22, borderRadius: "50%", background: th.accent }} /><span style={{ width: 22, height: 22, borderRadius: "50%", background: th.goldDeep, marginLeft: -8 }} /></div>
              <span style={{ fontSize: 14, color: th.ink, fontWeight: 500, fontFamily: "'Jost',sans-serif" }}>{th.name}</span>
            </button>
          ))}
        </div>
        <div style={{ fontSize: 11.5, color: t.soft, marginTop: 14, textAlign: "center" }}>Bebe mavisi, gül, altın, şeftali, adaçayı, lavanta ve gece — dilediğinde değiştir.</div>
      </div>
    </div>
  );
}

/* ---- helpers ---- */
function Empty({ t, serif, children }) { return <div style={{ textAlign: "center", color: t.soft, fontFamily: serif, fontStyle: "italic", fontSize: 16, padding: "18px 0" }}>{children}</div>; }
const iconBtn = (t) => ({ width: 38, height: 38, borderRadius: "50%", border: `1px solid ${t.line}`, background: t.panel, color: t.soft, cursor: "pointer", display: "grid", placeItems: "center" });
const ghostBtn = (t) => ({ flex: 1, border: `1px solid ${t.line}`, background: t.panel, color: t.ink, cursor: "pointer", borderRadius: 14, padding: 13, fontSize: 13.5, fontWeight: 500, fontFamily: "'Jost',sans-serif", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 });
const addBtn = (t) => ({ width: "100%", border: `1.5px dashed ${t.gold}`, background: `${t.accent}14`, color: t.goldDeep, cursor: "pointer", borderRadius: 14, padding: 13, fontSize: 14, fontWeight: 600, fontFamily: "'Jost',sans-serif", display: "flex", alignItems: "center", justifyContent: "center", gap: 8 });

const css = `
*{-webkit-tap-highlight-color:transparent;}
@keyframes tsFade{from{opacity:0}to{opacity:1}}
@keyframes tsSlide{from{opacity:0;transform:translateX(16px)}to{opacity:1;transform:translateX(0)}}
@keyframes tsRise{from{opacity:0;transform:translateY(30px)}to{opacity:1;transform:translateY(0)}}
@keyframes tsPulse{0%,100%{opacity:.55}50%{opacity:1}}
.tsCard{animation:tsRise .5s ease backwards;transition:transform .2s}
.tsCard:active{transform:scale(.985)}
.tsRow{animation:tsFade .5s ease backwards}
.tsRow:active{opacity:.7}
.tsGhost:active{opacity:.7}
textarea,input,select{font-family:'Jost',sans-serif}
::-webkit-scrollbar{width:0;height:0}
`;
