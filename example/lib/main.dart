import 'package:flutter/material.dart';
import 'package:flixeload_sdk/flixeload_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FlixeloAd SDK
  await FlixeloAd.instance.initialize(
    appId: 'com.example.demo',
    apiKey: 'demo_api_key',
    baseUrl: 'https://flixeload.com',
    testMode: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlixeloAd SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlixeloAd Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Ad Section
            const Text(
              'Banner Ad (320x50)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BannerAdWidget(
              size: BannerAdSize.standard,
              onAdLoaded: (event) {
                if (event.isSuccess) {
                  debugPrint('✅ Banner ad loaded');
                } else {
                  debugPrint('❌ Banner ad failed: ${event.error}');
                }
              },
              onAdClicked: () {
                debugPrint('👆 Banner ad clicked');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Medium Rectangle Ad
            const Text(
              'Medium Rectangle Ad (300x250)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BannerAdWidget(
              size: BannerAdSize.mediumRectangle,
              targeting: {
                'category': 'demo',
                'keywords': ['flutter', 'ads'],
              },
              onAdLoaded: (event) {
                debugPrint('Medium rectangle loaded: ${event.isSuccess}');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Native Ad
            const Text(
              'Native Ad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            NativeAdWidget(
              style: NativeAdStyle(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                ctaBackgroundColor: Colors.blue,
                ctaTextColor: Colors.white,
              ),
              onAdLoaded: (event) {
                debugPrint('Native ad loaded: ${event.isSuccess}');
              },
            ),
            
            const SizedBox(height: 32),
            
            // Interstitial Ad Button
            ElevatedButton.icon(
              onPressed: () => _showInterstitialAd(context),
              icon: const Icon(Icons.fullscreen),
              label: const Text('Show Interstitial Ad'),
            ),
            
            const SizedBox(height: 16),
            
            // Rewarded Ad Button
            ElevatedButton.icon(
              onPressed: () => _showRewardedAd(context),
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Show Rewarded Ad'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInterstitialAd(BuildContext context) async {
    final interstitialAd = InterstitialAd(
      onAdLoaded: (event) {
        if (event.isSuccess) {
          debugPrint('✅ Interstitial ad loaded');
        } else {
          debugPrint('❌ Failed to load: ${event.error}');
        }
      },
      onAdClosed: () {
        debugPrint('Interstitial ad closed');
      },
    );

    await interstitialAd.load();
    
    if (interstitialAd.isLoaded && context.mounted) {
      await interstitialAd.show(context);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad not ready yet')),
        );
      }
    }
  }

  void _showRewardedAd(BuildContext context) async {
    final rewardedAd = RewardedAd(
      onAdLoaded: (event) {
        if (event.isSuccess) {
          debugPrint('✅ Rewarded ad loaded');
        } else {
          debugPrint('❌ Failed to load: ${event.error}');
        }
      },
      onUserRewarded: () {
        debugPrint('🎁 User earned reward!');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reward earned! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onAdClosed: () {
        debugPrint('Rewarded ad closed');
      },
    );

    await rewardedAd.load();
    
    if (rewardedAd.isLoaded && context.mounted) {
      await rewardedAd.show(context);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad not ready yet')),
        );
      }
    }
  }
}
