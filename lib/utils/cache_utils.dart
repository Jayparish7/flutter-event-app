import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photomall_studio_manager/routes/1.constants/api_constants.dart';

class CacheUtil {
  var customCachedManager = CacheManager(
    Config(
      applicationCode,
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 10000,
    ),
  );
}