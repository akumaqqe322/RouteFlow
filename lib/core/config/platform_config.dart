import 'package:route_flow/core/config/platform_options.dart' 
  if (dart.library.html) 'package:route_flow/core/config/platform_options_web.dart' as platform;

void configurePlatform() {
  platform.configurePlatform();
}
