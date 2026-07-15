import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';

const _uuid = Uuid();

/// Local page-level audio: copy into `audio/` and play via [just_audio].
class PageAudioService {
  PageAudioService._();
  static final PageAudioService instance = PageAudioService._();

  static const audioDirName = 'audio';

  Future<Directory> audioDirectory({String? docsOverride}) async {
    final docsPath = docsOverride ?? (await _docsPath());
    final dir = Directory(p.join(docsPath, audioDirName));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<String> _docsPath() async {
    final override = AppDatabase.overrideDirPath;
    if (override != null) return override;
    return (await getApplicationDocumentsDirectory()).path;
  }

  /// Copies [sourcePath] into `audio/` and returns the stored absolute path.
  Future<String> copyAudioFile(
    String sourcePath, {
    String? docsOverride,
  }) async {
    final dir = await audioDirectory(docsOverride: docsOverride);
    final ext = p.extension(sourcePath);
    final dest = p.join(dir.path, '${_uuid.v4()}$ext');
    await File(sourcePath).copy(dest);
    return dest;
  }

  /// Replaces any existing attachment for [pageId] with a new file copy.
  Future<String?> attachToPage({
    required String pageId,
    required String sourcePath,
    String? existingPath,
    String? docsOverride,
  }) async {
    final stored = await copyAudioFile(sourcePath, docsOverride: docsOverride);
    await AppDatabase.instance.updatePageAudioPath(pageId, stored);
    if (existingPath != null && existingPath != stored) {
      await deleteAudioFile(existingPath);
    }
    return stored;
  }

  Future<void> removeFromPage({
    required String pageId,
    String? currentPath,
  }) async {
    await AppDatabase.instance.updatePageAudioPath(pageId, null);
    if (currentPath != null) {
      await deleteAudioFile(currentPath);
    }
  }

  Future<void> deleteAudioFile(String path) async {
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<String?> pickAndAttach({
    required String pageId,
    String? existingPath,
    String? docsOverride,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'flac', 'wma'],
      withData: false,
    );
    final src = result?.files.single.path;
    if (src == null) return null;
    return attachToPage(
      pageId: pageId,
      sourcePath: src,
      existingPath: existingPath,
      docsOverride: docsOverride,
    );
  }
}

/// Short-lived player for page settings preview (local files only).
class PageAudioPlayer extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  String? _loadedPath;

  bool get isPlaying => _playing;
  String? get loadedPath => _loadedPath;

  PageAudioPlayer() {
    _player.playerStateStream.listen((state) {
      final playing = state.playing;
      if (_playing != playing) {
        _playing = playing;
        notifyListeners();
      }
    });
  }

  Future<void> play(String path) async {
    if (_loadedPath != path) {
      await _player.setFilePath(path);
      _loadedPath = path;
    }
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> toggle(String path) async {
    if (_playing && _loadedPath == path) {
      await pause();
    } else {
      await play(path);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _loadedPath = null;
    _playing = false;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    super.dispose();
  }

  @visibleForTesting
  AudioPlayer get playerForTest => _player;
}
