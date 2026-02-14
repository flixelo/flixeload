import 'ad_type.dart';

/// Response model for ad requests
class AdResponse {
  final String requestId;
  final AdType adType;
  final String creativeType;
  final String? imageUrl;
  final String? videoUrl;
  final String? headline;
  final String? description;
  final String? ctaText;
  final String? clickUrl;
  final int width;
  final int height;
  final Map<String, dynamic> rawData;

  AdResponse({
    required this.requestId,
    required this.adType,
    required this.creativeType,
    this.imageUrl,
    this.videoUrl,
    this.headline,
    this.description,
    this.ctaText,
    this.clickUrl,
    required this.width,
    required this.height,
    required this.rawData,
  });

  factory AdResponse.fromJson(Map<String, dynamic> json) {
    final creative = json['creative'] as Map<String, dynamic>? ?? {};
    
    return AdResponse(
      requestId: json['request_id']?.toString() ?? '', // Handle both int and String
      adType: AdTypeExtension.fromString(json['ad_type']?.toString() ?? 'banner'),
      creativeType: creative['type']?.toString() ?? 'image',
      imageUrl: creative['image_url']?.toString(),
      videoUrl: creative['video_url']?.toString(),
      headline: creative['headline']?.toString(),
      description: creative['description']?.toString(),
      ctaText: creative['cta_text']?.toString(),
      clickUrl: creative['click_url']?.toString(),
      width: (creative['width'] is int) ? creative['width'] : int.tryParse(creative['width']?.toString() ?? '320') ?? 320,
      height: (creative['height'] is int) ? creative['height'] : int.tryParse(creative['height']?.toString() ?? '50') ?? 50,
      rawData: json,
    );
  }

  bool get isValid => requestId.isNotEmpty && 
                      (imageUrl != null || videoUrl != null);
}

/// Ad load event callbacks
class AdLoadEvent {
  final AdResponse? ad;
  final String? error;
  
  AdLoadEvent.success(this.ad) : error = null;
  AdLoadEvent.failed(this.error) : ad = null;
  
  bool get isSuccess => ad != null;
  bool get isFailed => error != null;
}
