import 'package:flutter/foundation.dart';

import 'app_config.dart';
import 'app_flavor.dart';
import 'dev_config.dart';
import 'prod_config.dart';

AppConfig appConfigForFlavor(AppFlavor flavor) {
  return switch (flavor) {
    AppFlavor.development => developmentConfig,
    AppFlavor.production => productionConfig,
  };
}

AppConfig defaultAppConfig({bool? isReleaseMode}) {
  final releaseMode = isReleaseMode ?? kReleaseMode;

  return releaseMode ? productionConfig : developmentConfig;
}
