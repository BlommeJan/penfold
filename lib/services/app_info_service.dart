import 'package:package_info_plus/package_info_plus.dart';

/// App name and version from the platform package metadata.
class AppInfoService {
  AppInfoService._();
  static final AppInfoService instance = AppInfoService._();

  PackageInfo? _info;
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _info = await PackageInfo.fromPlatform();
    _loaded = true;
  }

  String get appName => _info?.appName ?? 'Penfold';

  String get version => _info?.version ?? '0.0.0';

  String get versionLabel => 'v$version';

  void resetForTests() {
    _info = null;
    _loaded = false;
  }
}
