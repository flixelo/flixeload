/// Ad format types supported by FlixeloAd
enum AdType {
  /// Standard banner ads (320x50, 300x250, 728x90)
  banner,
  
  /// Full-screen interstitial ads
  interstitial,
  
  /// Native ads that match your app's design
  native,
  
  /// Rewarded video ads
  rewarded,
}

extension AdTypeExtension on AdType {
  String get apiValue {
    switch (this) {
      case AdType.banner:
        return 'banner';
      case AdType.interstitial:
        return 'interstitial';
      case AdType.native:
        return 'native';
      case AdType.rewarded:
        return 'rewarded';
    }
  }

  static AdType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'banner':
        return AdType.banner;
      case 'interstitial':
        return AdType.interstitial;
      case 'native':
        return AdType.native;
      case 'rewarded':
        return AdType.rewarded;
      default:
        return AdType.banner;
    }
  }
}

/// Banner ad sizes
enum BannerAdSize {
  /// Standard banner (320x50)
  standard,
  
  /// Medium rectangle (300x250)
  mediumRectangle,
  
  /// Leaderboard (728x90)
  leaderboard,
}

extension BannerAdSizeExtension on BannerAdSize {
  int get width {
    switch (this) {
      case BannerAdSize.standard:
        return 320;
      case BannerAdSize.mediumRectangle:
        return 300;
      case BannerAdSize.leaderboard:
        return 728;
    }
  }

  int get height {
    switch (this) {
      case BannerAdSize.standard:
        return 50;
      case BannerAdSize.mediumRectangle:
        return 250;
      case BannerAdSize.leaderboard:
        return 90;
    }
  }

  String get apiValue {
    switch (this) {
      case BannerAdSize.standard:
        return 'mobile-banner-320x50';
      case BannerAdSize.mediumRectangle:
        return 'mobile-banner-300x250';
      case BannerAdSize.leaderboard:
        return 'mobile-banner-728x90';
    }
  }
}
