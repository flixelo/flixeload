import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../flixeload_ad.dart';
import '../models/ad_type.dart';
import '../models/ad_response.dart';
import 'package:url_launcher/url_launcher.dart';

/// Interstitial ad controller
/// Load and show full-screen interstitial ads
class InterstitialAd {
  AdResponse? _ad;
  bool _isLoaded = false;
  bool _isShowing = false;
  Function(AdLoadEvent)? onAdLoaded;
  Function()? onAdClosed;
  Function()? onAdClicked;

  InterstitialAd({
    this.onAdLoaded,
    this.onAdClosed,
    this.onAdClicked,
  });

  /// Load an interstitial ad
  Future<void> load({Map<String, dynamic>? targeting}) async {
    if (!FlixeloAd.instance.isInitialized) {
      onAdLoaded?.call(AdLoadEvent.failed('SDK not initialized'));
      return;
    }

    try {
      final ad = await FlixeloAd.instance.apiService.requestAd(
        adType: AdType.interstitial,
        adSize: 'mobile-interstitial',
        targeting: targeting,
      );

      _ad = ad;
      _isLoaded = true;
      onAdLoaded?.call(AdLoadEvent.success(ad));
    } catch (e) {
      _isLoaded = false;
      onAdLoaded?.call(AdLoadEvent.failed(e.toString()));
    }
  }

  /// Check if ad is loaded and ready to show
  bool get isLoaded => _isLoaded && _ad != null;

  /// Show the interstitial ad
  Future<void> show(BuildContext context) async {
    if (!isLoaded || _isShowing) return;

    _isShowing = true;

    // Track impression
    FlixeloAd.instance.apiService.trackImpression(_ad!.requestId);

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _InterstitialAdScreen(
          ad: _ad!,
          onClose: () {
            _isShowing = false;
            _isLoaded = false;
            onAdClosed?.call();
          },
          onAdClicked: () {
            FlixeloAd.instance.apiService.trackClick(_ad!.requestId);
            onAdClicked?.call();
          },
        ),
      ),
    );
  }

  /// Dispose the ad
  void dispose() {
    _ad = null;
    _isLoaded = false;
  }
}

class _InterstitialAdScreen extends StatefulWidget {
  final AdResponse ad;
  final VoidCallback onClose;
  final VoidCallback onAdClicked;

  const _InterstitialAdScreen({
    required this.ad,
    required this.onClose,
    required this.onAdClicked,
  });

  @override
  State<_InterstitialAdScreen> createState() => _InterstitialAdScreenState();
}

class _InterstitialAdScreenState extends State<_InterstitialAdScreen> {
  bool _canClose = false;

  @override
  void initState() {
    super.initState();
    // Allow closing after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _canClose = true);
      }
    });
  }

  void _handleClose() {
    widget.onClose();
    Navigator.of(context).pop();
  }

  Future<void> _handleClick() async {
    if (widget.ad.clickUrl == null) return;

    widget.onAdClicked();

    final url = Uri.parse(widget.ad.clickUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Ad content
            Center(
              child: GestureDetector(
                onTap: _handleClick,
                child: widget.ad.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.ad.imageUrl!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.ad.headline != null)
                              Text(
                                widget.ad.headline!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            if (widget.ad.description != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                widget.ad.description!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),

            // Close button (appears after 5 seconds)
            if (_canClose)
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _handleClose,
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

            // Timer indicator
            if (!_canClose)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Ad',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
