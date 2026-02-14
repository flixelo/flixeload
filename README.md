# FlixeloAd SDK

Official Flutter SDK for FlixeloAd mobile ad network.

## Features

- 🎯 **Banner Ads** - Display banner ads in standard sizes (320x50, 300x250, 728x90)
- 📱 **Interstitial Ads** - Show full-screen ads between content
- 🎨 **Native Ads** - Customizable native ads that match your app design
- 🎁 **Rewarded Ads** - Reward users for watching video ads

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flixeload_sdk:
    path: ../flixeload_sdk  # Or from pub.dev once published
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the SDK

In your `main.dart`, initialize FlixeloAd before running your app:

```dart
import 'package:flixeload_sdk/flixeload_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FlixeloAd.instance.initialize(
    appId: 'com.example.myapp',
    apiKey: 'your_api_key_here',
    baseUrl: 'https://flixeload.com', // Your backend URL
    testMode: true, // Set to false in production
  );
  
  runApp(MyApp());
}
```

### 2. Display Banner Ads

```dart
import 'package:flixeload_sdk/flixeload_sdk.dart';

BannerAdWidget(
  size: BannerAdSize.standard, // 320x50
  onAdLoaded: (event) {
    if (event.isSuccess) {
      print('Banner ad loaded');
    } else {
      print('Banner ad failed: ${event.error}');
    }
  },
  onAdClicked: () {
    print('Banner ad clicked');
  },
)
```

### 3. Show Interstitial Ads

```dart
final interstitialAd = InterstitialAd(
  onAdLoaded: (event) {
    if (event.isSuccess) {
      print('Interstitial ad loaded');
    }
  },
  onAdClosed: () {
    print('Interstitial ad closed');
  },
);

// Load the ad
await interstitialAd.load();

// Show when ready
if (interstitialAd.isLoaded) {
  await interstitialAd.show(context);
}
```

### 4. Display Native Ads

```dart
NativeAdWidget(
  style: NativeAdStyle(
    elevation: 2,
    borderRadius: BorderRadius.circular(12),
    ctaBackgroundColor: Colors.blue,
  ),
  onAdLoaded: (event) {
    print('Native ad loaded');
  },
)
```

### 5. Show Rewarded Ads

```dart
final rewardedAd = RewardedAd(
  onAdLoaded: (event) {
    if (event.isSuccess) {
      print('Rewarded ad loaded');
    }
  },
  onUserRewarded: () {
    print('User earned reward!');
    // Give reward to user
  },
  onAdClosed: () {
    print('Rewarded ad closed');
  },
);

// Load the ad
await rewardedAd.load();

// Show when ready
if (rewardedAd.isLoaded) {
  await rewardedAd.show(context);
}
```

## Banner Ad Sizes

```dart
BannerAdSize.standard         // 320x50
BannerAdSize.mediumRectangle  // 300x250
BannerAdSize.leaderboard      // 728x90
```

## Privacy & Compliance

### GDPR Compliance

```dart
// Set user consent for personalized ads
FlixeloAd.instance.setUserConsent(true);
```

### COPPA Compliance

```dart
// Set user age for COPPA compliance
FlixeloAd.instance.setUserAge(age);
```

## Targeting

You can pass targeting parameters to customize ad delivery:

```dart
BannerAdWidget(
  size: BannerAdSize.standard,
  targeting: {
    'category': 'sports',
    'keywords': ['football', 'basketball'],
  },
)
```

## Testing

Enable test mode during development:

```dart
await FlixeloAd.instance.initialize(
  appId: 'com.example.myapp',
  apiKey: 'your_api_key_here',
  testMode: true, // Test mode enabled
);
```

## Support

For support and documentation, visit [flixeload.com](https://flixeload.com)

## License

Copyright © 2026 FlixeloAd. All rights reserved.
