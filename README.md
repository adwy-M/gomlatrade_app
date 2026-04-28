# Gomla Trade App

Flutter WebView app for Gomla Trade.

## Build

Install dependencies:

```bash
flutter pub get
```

Build with WooCommerce credentials when needed:

```bash
flutter build apk --release \
  --dart-define=WC_CONSUMER_KEY=your_key \
  --dart-define=WC_CONSUMER_SECRET=your_secret
```

For iOS, run the final archive on macOS with Xcode installed:

```bash
cd ios
pod install
cd ..
flutter build ipa --release \
  --dart-define=WC_CONSUMER_KEY=your_key \
  --dart-define=WC_CONSUMER_SECRET=your_secret
```
