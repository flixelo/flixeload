# FlixeloAd SDK - Integration Example

## Complete Example App

Here's a complete example showing how to integrate FlixeloAd SDK into your Flutter app.

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flixeload_sdk/flixeload_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FlixeloAd SDK
  await FlixeloAd.instance.initialize(
    appId: 'com.example.myapp',
    apiKey: 'your_api_key_from_dashboard',
    baseUrl: 'http://localhost/adrocks', // Your backend URL
    testMode: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixeloAd Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    _interstitialAd = InterstitialAd(
      onAdLoaded: (event) {
        if (event.isSuccess) {
          print('✅ Interstitial ad loaded');
        } else {
          print('❌ Interstitial ad failed: ${event.error}');
        }
      },
      onAdClosed: () {
        print('Interstitial ad closed');
        // Load next ad
        _loadInterstitialAd();
      },
      onAdClicked: () {
        print('Interstitial ad clicked');
      },
    );
    
    _interstitialAd!.load();
  }

  void _loadRewardedAd() {
    _rewardedAd = RewardedAd(
      onAdLoaded: (event) {
        if (event.isSuccess) {
          print('✅ Rewarded ad loaded');
          setState(() {});
        } else {
          print('❌ Rewarded ad failed: ${event.error}');
        }
      },
      onUserRewarded: () {
        print('🎁 User earned reward!');
        setState(() {
          _coins += 10;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 You earned 10 coins!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdClosed: () {
        print('Rewarded ad closed');
        // Load next ad
        _loadRewardedAd();
      },
    );
    
    _rewardedAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlixeloAd Example'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.yellow),
                  const SizedBox(width: 4),
                  Text('$_coins', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Ad - Standard
            const Text(
              'Banner Ad (320x50)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: BannerAdWidget(
                size: BannerAdSize.standard,
                onAdLoaded: (event) {
                  if (event.isSuccess) {
                    print('✅ Banner ad loaded');
                  }
                },
              ),
            ),

            const SizedBox(height: 32),

            // Banner Ad - Medium Rectangle
            const Text(
              'Banner Ad (300x250)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: BannerAdWidget(
                size: BannerAdSize.mediumRectangle,
                onAdLoaded: (event) {
                  if (event.isSuccess) {
                    print('✅ Medium banner ad loaded');
                  }
                },
              ),
            ),

            const SizedBox(height: 32),

            // Interstitial Ad Button
            ElevatedButton.icon(
              onPressed: () async {
                if (_interstitialAd?.isLoaded == true) {
                  await _interstitialAd!.show(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Interstitial ad is not ready yet'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.fullscreen),
              label: const Text('Show Interstitial Ad'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 16),

            // Rewarded Ad Button
            ElevatedButton.icon(
              onPressed: () async {
                if (_rewardedAd?.isLoaded == true) {
                  await _rewardedAd!.show(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rewarded ad is not ready yet'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Watch Ad & Earn 10 Coins'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
            ),

            const SizedBox(height: 32),

            // Native Ad
            const Text(
              'Native Ad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            NativeAdWidget(
              style: const NativeAdStyle(
                elevation: 4,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                ctaBackgroundColor: Colors.blue,
              ),
              onAdLoaded: (event) {
                if (event.isSuccess) {
                  print('✅ Native ad loaded');
                }
              },
            ),

            const SizedBox(height: 32),

            // App content
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.blue),
                    SizedBox(height: 16),
                    Text(
                      'Your App Content',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This is where your app content goes. The ads are seamlessly integrated above.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }
}
```

## How to Get Your API Key

1. Go to your FlixeloAd dashboard
2. Navigate to Publishers section
3. Register your app
4. Copy your API key
5. Paste it in the `initialize()` method

## Testing Locally

When testing with XAMPP locally:

```dart
await FlixeloAd.instance.initialize(
  appId: 'com.example.myapp',
  apiKey: 'your_api_key',
  baseUrl: 'http://localhost/adrocks', // or http://10.0.2.2/adrocks for Android emulator
  testMode: true,
);
```

## Production Setup

When going to production:

```dart
await FlixeloAd.instance.initialize(
  appId: 'com.example.myapp',
  apiKey: 'your_production_api_key',
  baseUrl: 'https://flixeload.com',
  testMode: false, // Disable test mode
);
```
