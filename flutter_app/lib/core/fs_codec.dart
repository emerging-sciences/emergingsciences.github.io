// Firestore REST <-> plain Dart values. Pure Dart (no Flutter), so it can be tested on its own.
import 'dart:math';

/// Decodes one Firestore REST "Value" ({"stringValue": "x"}, {"integerValue": "3"}, ...).
Object? decodeFsValue(Map<String, dynamic> v) {
  if (v.containsKey('stringValue')) return '${v['stringValue']}';
  if (v.containsKey('integerValue')) return int.tryParse('${v['integerValue']}') ?? 0;
  if (v.containsKey('doubleValue')) {
    final d = v['doubleValue'];
    return d is num ? d.toDouble() : (double.tryParse('$d') ?? 0.0);
  }
  if (v.containsKey('booleanValue')) return v['booleanValue'] == true;
  if (v.containsKey('timestampValue')) return DateTime.tryParse('${v['timestampValue']}');
  if (v.containsKey('arrayValue')) {
    final a = v['arrayValue'];
    final vals = a is Map ? a['values'] : null;
    if (vals is! List) return <Object?>[];
    final out = <Object?>[];
    for (final e in vals) {
      if (e is Map) out.add(decodeFsValue(Map<String, dynamic>.from(e)));
    }
    return out;
  }
  if (v.containsKey('mapValue')) {
    final m = v['mapValue'];
    final f = m is Map ? m['fields'] : null;
    return f is Map ? decodeFsFields(f) : <String, Object?>{};
  }
  return null; // nullValue and types this app never uses
}

Map<String, Object?> decodeFsFields(Map<dynamic, dynamic> fields) {
  final out = <String, Object?>{};
  fields.forEach((k, v) {
    if (v is Map) out['$k'] = decodeFsValue(Map<String, dynamic>.from(v));
  });
  return out;
}

/// A document returned by Firestore: its id (last path segment) and decoded fields.
class FsDoc {
  final String path;
  final String id;
  final Map<String, Object?> fields;
  const FsDoc(this.path, this.id, this.fields);
}

FsDoc? decodeFsDoc(Object? raw) {
  if (raw is! Map) return null;
  final name = raw['name'];
  if (name is! String || name.isEmpty) return null;
  final f = raw['fields'];
  return FsDoc(name, name.substring(name.lastIndexOf('/') + 1), f is Map ? decodeFsFields(f) : <String, Object?>{});
}

/// Dart value -> Firestore REST "Value". Supports String, bool, int, double, null, List and Map<String, Object?>.
Map<String, Object?> encodeFsValue(Object? v) {
  if (v == null) return <String, Object?>{'nullValue': null};
  if (v is String) return <String, Object?>{'stringValue': v};
  if (v is bool) return <String, Object?>{'booleanValue': v};
  if (v is int) return <String, Object?>{'integerValue': '$v'};
  if (v is double) return <String, Object?>{'doubleValue': v};
  if (v is List) {
    return <String, Object?>{
      'arrayValue': v.isEmpty ? <String, Object?>{} : <String, Object?>{'values': <Object?>[for (final e in v) encodeFsValue(e)]},
    };
  }
  if (v is Map<String, Object?>) {
    return <String, Object?>{
      'mapValue': <String, Object?>{'fields': encodeFsFields(v)},
    };
  }
  throw ArgumentError('Unsupported Firestore value: ${v.runtimeType}');
}

Map<String, Object?> encodeFsFields(Map<String, Object?> m) {
  final out = <String, Object?>{};
  m.forEach((k, v) => out[k] = encodeFsValue(v));
  return out;
}

final Random _rng = Random.secure();
const String _idChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

/// 20-character random document id (same style as the Firebase SDKs).
String newDocId() {
  final b = StringBuffer();
  for (var i = 0; i < 20; i++) {
    b.write(_idChars[_rng.nextInt(_idChars.length)]);
  }
  return b.toString();
}

/// At most [max] characters (code points, so emoji are never cut in half).
String clip(String s, int max) {
  final r = s.runes;
  if (r.length <= max) return s;
  return String.fromCharCodes(r.take(max));
}
