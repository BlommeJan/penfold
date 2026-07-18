import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../l10n/l10n.dart';
import '../services/page_audio_service.dart';

/// Audio attach / play / remove controls for the page settings sheet.
class PageAudioSettings extends StatefulWidget {
  final String pageId;
  final String? audioPath;
  final ValueChanged<String?> onAudioChanged;

  const PageAudioSettings({
    super.key,
    required this.pageId,
    required this.audioPath,
    required this.onAudioChanged,
  });

  @override
  State<PageAudioSettings> createState() => _PageAudioSettingsState();
}

class _PageAudioSettingsState extends State<PageAudioSettings> {
  final _audio = PageAudioService.instance;
  final _player = PageAudioPlayer();
  bool _busy = false;
  late String? _audioPath;

  @override
  void initState() {
    super.initState();
    _audioPath = widget.audioPath;
  }

  @override
  void didUpdateWidget(PageAudioSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath) {
      _audioPath = widget.audioPath;
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _attach() async {
    setState(() => _busy = true);
    try {
      final path = await _audio.pickAndAttach(
        pageId: widget.pageId,
        existingPath: _audioPath,
      );
      if (path != null && mounted) {
        setState(() => _audioPath = path);
        widget.onAudioChanged(path);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    await _player.stop();
    await _audio.removeFromPage(
      pageId: widget.pageId,
      currentPath: _audioPath,
    );
    if (mounted) {
      setState(() => _audioPath = null);
      widget.onAudioChanged(null);
    }
  }

  Future<void> _togglePlay() async {
    final path = _audioPath;
    if (path == null) return;
    await _player.toggle(path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final path = _audioPath;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(l10n.pageAudioTitle, style: Theme.of(context).textTheme.titleSmall),
        ),
        if (path == null)
          ListTile(
            leading: const Icon(Icons.audio_file_outlined),
            title: Text(l10n.pageAudioAttach),
            subtitle: Text(l10n.pageAudioAttachSubtitle),
            enabled: !_busy,
            onTap: _busy ? null : _attach,
          )
        else ...[
          ListenableBuilder(
            listenable: _player,
            builder: (context, _) {
              final playing =
                  _player.isPlaying && _player.loadedPath == path;
              return ListTile(
                leading: IconButton(
                  icon: Icon(
                    playing
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                  ),
                  tooltip: playing ? l10n.pageAudioPause : l10n.pageAudioPlay,
                  onPressed: _togglePlay,
                ),
                title: Text(p.basename(path)),
                subtitle: Text(l10n.pageAudioAttachedToPage),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded),
            title: Text(l10n.pageAudioReplace),
            enabled: !_busy,
            onTap: _busy ? null : _attach,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: Text(l10n.pageAudioRemove),
            onTap: _remove,
          ),
        ],
        const Divider(height: 1),
      ],
    );
  }
}
