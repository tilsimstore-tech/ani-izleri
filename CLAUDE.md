# CLAUDE.md

Flutter app "Bebeğimin Anı İzleri" — Android (Play Store, built locally) and iOS (built on Codemagic, no Mac).

- Release process, IDs and current status live in `YAYIN_KILAVUZU.md`. After every release or release-related change, update its "Güncel Durum" table and add an entry to "Sürüm Geçmişi".
- Work on branch `master` (the `main` branch on GitHub is unused).
- Never commit secrets: `android/key.properties`, `*.jks`, or anything from `C:\Users\semih\ani_izleri_ios_gizli\`.
- iOS build number is set by Codemagic (`PROJECT_BUILD_NUMBER + 6`); Android uses the `+N` in `pubspec.yaml`.
