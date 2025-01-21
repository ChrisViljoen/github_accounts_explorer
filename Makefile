clean:
	flutter clean && flutter pub get

run:
	flutter clean && flutter pub get && flutter run

apk:
	flutter clean && flutter pub get && flutter build apk --release