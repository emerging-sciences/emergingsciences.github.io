// File chooser for web pages shown inside the app (e.g. "Add a photo of the problem" on the Doubts page).
// Android's WebView silently ignores <input type="file"> unless the app provides a picker.
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'theme.dart';

enum _Pick { camera, gallery, files }

const List<String> _imageExt = <String>['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif', '.bmp'];

bool _isImageType(String t) {
  final s = t.toLowerCase();
  return s.startsWith('image/') || _imageExt.contains(s);
}

/// What the WebView expects back: a list of file:// or content:// URIs (empty = nothing chosen).
String _toUri(String path) => path.startsWith('/') ? Uri.file(path).toString() : path;

Future<_Pick?> _ask(BuildContext context, {required bool imageOnly}) {
  Widget option(BuildContext ctx, IconData icon, String label, _Pick value) {
    return ListTile(
      leading: Icon(icon, color: C.blue),
      title: Text(label, style: kTitle),
      onTap: () => Navigator.of(ctx).pop(value),
    );
  }

  return showModalBottomSheet<_Pick>(
    context: context,
    backgroundColor: C.surface,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Align(alignment: Alignment.centerLeft, child: Text('Photo / file chuno', style: kH1)),
          ),
          option(ctx, Icons.photo_camera_outlined, 'Camera se photo kheencho', _Pick.camera),
          option(ctx, Icons.photo_library_outlined, 'Gallery se photo chuno', _Pick.gallery),
          if (!imageOnly) option(ctx, Icons.folder_open, 'Files (PDF / document)', _Pick.files),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

/// Called by the Android WebView when a page asks for a file.
Future<List<String>> pickFilesForWebView(BuildContext context, FileSelectorParams params) async {
  final types = params.acceptTypes.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
  final imageOnly = types.isNotEmpty && types.every(_isImageType);
  final multiple = params.mode == FileSelectorMode.openMultiple;

  final _Pick? pick = (params.isCaptureEnabled && imageOnly) ? _Pick.camera : await _ask(context, imageOnly: imageOnly);
  if (pick == null) return const <String>[];

  try {
    final picker = ImagePicker();
    switch (pick) {
      case _Pick.camera:
        final f = await picker.pickImage(source: ImageSource.camera, imageQuality: 88, maxWidth: 2400, maxHeight: 2400);
        return f == null ? const <String>[] : <String>[_toUri(f.path)];
      case _Pick.gallery:
        if (multiple) {
          final list = await picker.pickMultiImage(imageQuality: 88, maxWidth: 2400, maxHeight: 2400);
          return <String>[for (final f in list) _toUri(f.path)];
        }
        final f = await picker.pickImage(source: ImageSource.gallery, imageQuality: 88, maxWidth: 2400, maxHeight: 2400);
        return f == null ? const <String>[] : <String>[_toUri(f.path)];
      case _Pick.files:
        final mimes = <String>[for (final t in types) if (t.contains('/')) t];
        final exts = <String>[for (final t in types) if (t.startsWith('.')) t.substring(1)];
        final group = XTypeGroup(label: 'Files', mimeTypes: mimes.isEmpty ? null : mimes, extensions: exts.isEmpty ? null : exts);
        final groups = (mimes.isEmpty && exts.isEmpty) ? const <XTypeGroup>[] : <XTypeGroup>[group];
        if (multiple) {
          final list = await openFiles(acceptedTypeGroups: groups);
          return <String>[for (final f in list) _toUri(f.path)];
        }
        final f = await openFile(acceptedTypeGroups: groups);
        return f == null ? const <String>[] : <String>[_toUri(f.path)];
    }
  } catch (_) {
    return const <String>[]; // picker closed / permission refused: the page simply gets no file
  }
}
