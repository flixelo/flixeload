import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../flixeload_ad.dart';
import '../models/ad_type.dart';
import '../models/ad_response.dart';
import 'package:url_launcher/url_launcher.dart';

/// Rewarded ad controller
/// Load and show rewarded video ads
class RewardedAd {
  AdResponse? _ad;
  bool _isLoaded = false;
  bool _isShowing = false;
  Function(AdLoadEvent)? onAdLoaded;
  Function()? onAdClosed;
  Function()? onAdClicked;
  Function()? onUserRewarded;

  RewardedAd({
    this.onAdLoaded,
    this.onAdClosed,
    this.onAdClicked,
    this.onUserRewarded,
  });

  /// Load a rewarded ad
  Future<void> load({Map<String, dynamic>? targeting}) async {
    if (!FlixeloAd.instance.isInitialized) {
      onAdLoaded?.call(AdLoadEvent.failed('SDK not initialized'));
      return;
    }

    try {
      final ad = await FlixeloAd.instance.apiService.requestAd(
        adType: AdType.rewarded,
        adSize: 'mobile-rewarded',
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

  /// Show the rewarded ad
  Future<void> show(BuildContext context) async {
    if (!isLoaded || _isShowing) return;

    _isShowing = true;

    // Track impression
    FlixeloAd.instance.apiService.trackImpression(_ad!.requestId);

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => _RewardedAdScreen(
          ad: _ad!,
          onClose: (bool rewarded) {
            _isShowing = false;
            _isLoaded = false;
            if (rewarded) {
              onUserRewarded?.call();
            }
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

class _RewardedAdScreen extends StatefulWidget {
  final AdResponse ad;
  final Function(bool) onClose;
  final VoidCallback onAdClicked;

  const _RewardedAdScreen({
    required this.ad,
    required this.onClose,
    required this.onAdClicked,
  });

  @override
  State<_RewardedAdScreen> createState() => _RewardedAdScreenState();
}

class _RewardedAdScreenState extends State<_RewardedAdScreen> {
  bool _canClose = false;
  bool _rewarded = false;
  int _countdown = 30; // 30 seconds to watch

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _canClose = true;
          _rewarded = true;
        }
      });

      return _countdown > 0;
    });
  }

  void _handleClose() {
    widget.onClose(_rewarded);
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
                            const Icon(
                              Icons.video_library,
                              color: Colors.white,
                              size: 64,
                            ),
                            const SizedBox(height: 24),
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

            // Countdown/Close button
            Positioned(
              top: 16,
              right: 16,
              child: _canClose
                  ? Material(
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
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Watch $_countdown s for reward',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
            ),

            // Reward indicator
            if (_rewarded)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Reward Earned!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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
}
