import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../flixeload_ad.dart';
import '../models/ad_type.dart';
import '../models/ad_response.dart';
import 'package:url_launcher/url_launcher.dart';

/// Native ad widget
/// Display native ads that match your app's design
class NativeAdWidget extends StatefulWidget {
  final Function(AdLoadEvent)? onAdLoaded;
  final Function()? onAdClicked;
  final Map<String, dynamic>? targeting;
  final NativeAdStyle style;

  const NativeAdWidget({
    Key? key,
    this.onAdLoaded,
    this.onAdClicked,
    this.targeting,
    this.style = const NativeAdStyle(),
  }) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  AdResponse? _ad;
  bool _isLoading = true;
  String? _error;
  bool _impressionTracked = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (!FlixeloAd.instance.isInitialized) {
      setState(() {
        _error = 'SDK not initialized';
        _isLoading = false;
      });
      widget.onAdLoaded?.call(AdLoadEvent.failed(_error!));
      return;
    }

    try {
      final ad = await FlixeloAd.instance.apiService.requestAd(
        adType: AdType.native,
        adSize: 'mobile-native',
        targeting: widget.targeting,
      );

      if (mounted) {
        setState(() {
          _ad = ad;
          _isLoading = false;
        });
        widget.onAdLoaded?.call(AdLoadEvent.success(ad));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        widget.onAdLoaded?.call(AdLoadEvent.failed(e.toString()));
      }
    }
  }

  void _trackImpression() {
    if (_ad != null && !_impressionTracked) {
      _impressionTracked = true;
      FlixeloAd.instance.apiService.trackImpression(_ad!.requestId);
    }
  }

  Future<void> _handleClick() async {
    if (_ad?.clickUrl == null) return;

    widget.onAdClicked?.call();
    
    FlixeloAd.instance.apiService.trackClick(_ad!.requestId);

    final url = Uri.parse(_ad!.clickUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _ad == null || !_ad!.isValid) {
      return const SizedBox.shrink();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackImpression();
    });

    return Card(
      margin: widget.style.margin,
      elevation: widget.style.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: widget.style.borderRadius,
      ),
      child: InkWell(
        onTap: _handleClick,
        borderRadius: widget.style.borderRadius,
        child: Padding(
          padding: widget.style.padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ad badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Ad',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Image
              if (_ad!.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: _ad!.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),

              const SizedBox(height: 12),

              // Headline
              if (_ad!.headline != null)
                Text(
                  _ad!.headline!,
                  style: widget.style.headlineStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              // Description
              if (_ad!.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  _ad!.description!,
                  style: widget.style.descriptionStyle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // CTA Button
              if (_ad!.ctaText != null) ...[
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _handleClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.style.ctaBackgroundColor,
                    foregroundColor: widget.style.ctaTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_ad!.ctaText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Style configuration for native ads
class NativeAdStyle {
  final EdgeInsets margin;
  final EdgeInsets padding;
  final double elevation;
  final BorderRadius borderRadius;
  final TextStyle headlineStyle;
  final TextStyle descriptionStyle;
  final Color ctaBackgroundColor;
  final Color ctaTextColor;

  const NativeAdStyle({
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(12),
    this.elevation = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.headlineStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    this.descriptionStyle = const TextStyle(
      fontSize: 14,
      color: Colors.grey,
    ),
    this.ctaBackgroundColor = Colors.blue,
    this.ctaTextColor = Colors.white,
  });
}
