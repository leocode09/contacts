@echo off
:: Build for Windows
flutter build windows
pause
:: Build for Web
flutter build web
pause
:: Build for Android
flutter build apk
pause
echo Build completed for Windows, Web, and Android.
pause