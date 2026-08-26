extension TurkishPossessive on String {
  /// Türkçedeki büyük ünlü uyumu ve kaynaştırma kurallarına göre 
  /// isme uygun iyelik ekini ('nın, 'nin, 'ın, 'in vb.) otomatik üretir.
  String get iyelikEki {
    if (isEmpty) return "";

    // İsmin son harfini alıyoruz
    String lastChar = substring(length - 1).toLowerCase();

    // Ünlü harfler listesi
    List<String> vowels = ['a', 'e', 'ı', 'i', 'o', 'ö', 'u', 'ü'];
    bool isLastCharVowel = vowels.contains(lastChar);

    // Kelimedeki sondan başa doğru ilk ünlü harfi buluyoruz
    String lastVowel = '';
    for (int i = length - 1; i >= 0; i--) {
      String char = this[i].toLowerCase();
      if (vowels.contains(char)) {
        lastVowel = char;
        break;
      }
    }

    // Eğer isimde hiç ünlü harf yoksa varsayılan olarak 'in döndür
    if (lastVowel.isEmpty) return "'in";

    String suffix = '';
    
    if (isLastCharVowel) {
      // Son harf ünlü ise araya 'n' kaynaştırma harfi gelir (-nın, -nin, -nun, -nün)
      if (lastVowel == 'a' || lastVowel == 'ı') suffix = "nın";
      if (lastVowel == 'e' || lastVowel == 'i') suffix = "nin";
      if (lastVowel == 'o' || lastVowel == 'u') suffix = "nun";
      if (lastVowel == 'ö' || lastVowel == 'ü') suffix = "nün";
    } else {
      // Son harf ünsüz ise doğrudan ek gelir (-ın, -in, -un, -ün)
      if (lastVowel == 'a' || lastVowel == 'ı') suffix = "ın";
      if (lastVowel == 'e' || lastVowel == 'i') suffix = "in";
      if (lastVowel == 'o' || lastVowel == 'u') suffix = "un";
      if (lastVowel == 'ö' || lastVowel == 'ü') suffix = "ün";
    }

    return "'$suffix";
  }
}