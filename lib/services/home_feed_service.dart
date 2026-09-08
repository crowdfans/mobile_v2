import 'package:crowdfans/api/api_urls.dart';
import 'package:crowdfans/models/home_feed.dart';
import 'package:crowdfans/services/http_service.dart';

/// Feed autenticado (`GET /api/v1/home`).
abstract final class HomeFeedService {
  static Future<HomeFeedDto> load({int page = 1, int pageSize = 20}) {
    return HttpService.request<HomeFeedDto>(
      '${ApiUrls.homeFeed}?page=$page&pageSize=$pageSize',
      parse: HomeFeedDto.fromJson,
    );
  }
}
