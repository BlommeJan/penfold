import 'package:url_launcher/url_launcher.dart';

/// Opens PDF hyperlink targets. Test hook via [launchOverride].
class PdfLinkLauncher {
  PdfLinkLauncher._();

  static Future<bool> Function(String url)? launchOverride;

  static Future<bool> launch(String url) async {
    if (launchOverride != null) return launchOverride!(url);
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
