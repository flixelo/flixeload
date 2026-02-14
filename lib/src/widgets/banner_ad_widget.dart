import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../flixeload_ad.dart';
import '../models/ad_type.dart';
import '../models/ad_response.dart';
import 'package:url_launcher/url_launcher.dart';

/// Banner ad widget
/// Display banner ads in your Flutter app
class BannerAdWidget extends StatefulWidget {
  final BannerAdSize size;
  final Function(AdLoadEvent)? onAdLoaded;
  final Function()? onAdClicked;
  final Map<String, dynamic>? targeting;

  const BannerAdWidget({
    Key? key,
    this.size = BannerAdSize.standard,
    this.onAdLoaded,
    this.onAdClicked,
    this.targeting,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
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
        adType: AdType.banner,
        adSize: widget.size.apiValue,
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
    
    // Track click
    FlixeloAd.instance.apiService.trackClick(_ad!.requestId);

    // Open URL
    final url = Uri.parse(_ad!.clickUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.size.width.toDouble();
    final height = widget.size.height.toDouble();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Text(
          'Ad failed to load',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      );
    }

    if (_ad == null || !_ad!.isValid) {
      return Center(
        child: Text(
          'No ad available',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      );
    }

    // Track impression when ad is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackImpression();
    });

    return GestureDetector(
      onTap: _handleClick,
      child: _ad!.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: _ad!.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.error),
              ),
            )
          : Center(
              child: Text(
                _ad!.headline ?? 'Advertisement',
                style: const TextStyle(fontSize: 14),
              ),
            ),
    );
  }
}
