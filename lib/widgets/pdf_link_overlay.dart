import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../services/pdf_link_extractor.dart';
import '../services/pdf_link_launcher.dart';

/// Read-only URI tap targets for imported PDF hyperlinks.
///
/// Stylus pointers pass through so ink can be drawn over link regions.
class PdfLinkOverlay extends StatelessWidget {
  final List<PdfPageLink> links;
  final Size displaySize;

  const PdfLinkOverlay({
    super.key,
    required this.links,
    required this.displaySize,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final link in links)
          Positioned(
            left: link.left * displaySize.width,
            top: link.top * displaySize.height,
            width: link.width * displaySize.width,
            height: link.height * displaySize.height,
            child: _PdfLinkTapTarget(url: link.url),
          ),
      ],
    );
  }
}

class _PdfLinkTapTarget extends StatelessWidget {
  final String url;

  const _PdfLinkTapTarget({required this.url});

  bool _isStylus(PointerDeviceKind kind) =>
      kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: (event) {
        if (_isStylus(event.kind)) return;
        PdfLinkLauncher.launch(url);
      },
      child: const MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox.expand(),
      ),
    );
  }
}
