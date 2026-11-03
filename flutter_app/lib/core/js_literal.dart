// Tolerant reader for JavaScript object literals such as `window.ES_DATA = {...};`
// Supports: // and /* */ comments, quoted or bare keys, single/double/backtick strings,
// trailing commas, numbers, true/false/null/undefined. No Flutter imports on purpose.

class JsLiteralError implements Exception {
  final String message;
  JsLiteralError(this.message);
  @override
  String toString() => 'JsLiteralError: $message';
}

/// Finds `NAME = <literal>` (optionally `window.NAME`) in [src] and returns the parsed literal.
dynamic parseJsAssignment(String src, String name) {
  final re = RegExp('(?:window\\s*\\.\\s*)?' + RegExp.escape(name) + '\\s*=(?!=)');
  // Skip matches that sit inside // comments.
  for (final m in re.allMatches(src)) {
    final lineStart = src.lastIndexOf('\n', m.start) + 1;
    final before = src.substring(lineStart, m.start);
    if (before.contains('//')) continue;
    final p = _Parser(src, m.end);
    return p.parseValue();
  }
  throw JsLiteralError('assignment to $name not found');
}

class _Parser {
  final String s;
  int i;
  _Parser(this.s, this.i);

  Never _fail(String msg) {
    final start = i > 40 ? i - 40 : 0;
    final end = i + 40 < s.length ? i + 40 : s.length;
    throw JsLiteralError('$msg at $i near "${s.substring(start, end).replaceAll('\n', ' ')}"');
  }

  void _ws() {
    while (i < s.length) {
      final c = s.codeUnitAt(i);
      if (c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D || c == 0xFEFF || c == 0xA0) {
        i++;
      } else if (c == 0x2F && i + 1 < s.length) {
        final d = s.codeUnitAt(i + 1);
        if (d == 0x2F) {
          while (i < s.length && s.codeUnitAt(i) != 0x0A) {
            i++;
          }
        } else if (d == 0x2A) {
          final e = s.indexOf('*/', i + 2);
          i = e < 0 ? s.length : e + 2;
        } else {
          break;
        }
      } else {
        break;
      }
    }
  }

  dynamic parseValue() {
    _ws();
    if (i >= s.length) _fail('unexpected end');
    final c = s[i];
    if (c == '{') return _object();
    if (c == '[') return _array();
    if (c == '"' || c == "'" || c == '`') return _string();
    if (c == '-' || c == '+' || _isDigit(s.codeUnitAt(i)) || c == '.') return _number();
    return _word();
  }

  bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

  bool _isIdentChar(int c) =>
      (c >= 0x30 && c <= 0x39) ||
      (c >= 0x41 && c <= 0x5A) ||
      (c >= 0x61 && c <= 0x7A) ||
      c == 0x5F ||
      c == 0x24 ||
      c > 0x7F;

  Map<String, dynamic> _object() {
    final out = <String, dynamic>{};
    i++; // {
    while (true) {
      _ws();
      if (i >= s.length) _fail('unterminated object');
      if (s[i] == '}') {
        i++;
        return out;
      }
      String key;
      final c = s[i];
      if (c == '"' || c == "'" || c == '`') {
        key = _string();
      } else {
        final st = i;
        while (i < s.length && _isIdentChar(s.codeUnitAt(i))) {
          i++;
        }
        if (i == st) _fail('bad object key');
        key = s.substring(st, i);
      }
      _ws();
      if (i >= s.length || s[i] != ':') _fail('expected ":"');
      i++;
      final v = parseValue();
      out[key] = v;
      _ws();
      if (i >= s.length) _fail('unterminated object');
      if (s[i] == ',') {
        i++;
        continue;
      }
      if (s[i] == '}') {
        i++;
        return out;
      }
      _fail('expected "," or "}"');
    }
  }

  List<dynamic> _array() {
    final out = <dynamic>[];
    i++; // [
    while (true) {
      _ws();
      if (i >= s.length) _fail('unterminated array');
      if (s[i] == ']') {
        i++;
        return out;
      }
      out.add(parseValue());
      _ws();
      if (i >= s.length) _fail('unterminated array');
      if (s[i] == ',') {
        i++;
        continue;
      }
      if (s[i] == ']') {
        i++;
        return out;
      }
      _fail('expected "," or "]"');
    }
  }

  int _hex(String h) {
    final v = int.tryParse(h, radix: 16);
    if (v == null) _fail('bad hex escape');
    return v;
  }

  String _string() {
    final q = s[i];
    i++;
    final b = StringBuffer();
    while (true) {
      if (i >= s.length) _fail('unterminated string');
      final c = s[i];
      if (c == q) {
        i++;
        return b.toString();
      }
      if (c == '\\') {
        i++;
        if (i >= s.length) _fail('unterminated string');
        final e = s[i];
        switch (e) {
          case 'n':
            b.write('\n');
            i++;
            break;
          case 't':
            b.write('\t');
            i++;
            break;
          case 'r':
            b.write('\r');
            i++;
            break;
          case 'b':
            b.write('\b');
            i++;
            break;
          case 'f':
            b.write('\f');
            i++;
            break;
          case 'v':
            b.write('\v');
            i++;
            break;
          case '0':
            b.write('\u0000');
            i++;
            break;
          case 'u':
            if (i + 1 < s.length && s[i + 1] == '{') {
              final end = s.indexOf('}', i + 2);
              if (end < 0) _fail('bad unicode escape');
              b.write(String.fromCharCode(_hex(s.substring(i + 2, end))));
              i = end + 1;
            } else {
              if (i + 5 > s.length) _fail('bad unicode escape');
              b.writeCharCode(_hex(s.substring(i + 1, i + 5)));
              i += 5;
            }
            break;
          case 'x':
            if (i + 3 > s.length) _fail('bad hex escape');
            b.writeCharCode(_hex(s.substring(i + 1, i + 3)));
            i += 3;
            break;
          case '\r':
            i++;
            if (i < s.length && s[i] == '\n') i++;
            break;
          case '\n':
            i++;
            break;
          default:
            b.write(e);
            i++;
        }
        continue;
      }
      if (c == '\n' && q != '`') _fail('newline in string');
      b.write(c);
      i++;
    }
  }

  num _number() {
    final m = RegExp(r'[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?').matchAsPrefix(s, i);
    if (m == null) _fail('bad number');
    final t = m.group(0)!;
    i = m.end;
    final v = num.tryParse(t.startsWith('+') ? t.substring(1) : t);
    if (v == null) _fail('bad number');
    if (v is double && v == v.truncateToDouble() && !t.contains('.') && !t.contains('e') && !t.contains('E')) {
      return v.toInt();
    }
    return v;
  }

  dynamic _word() {
    final st = i;
    while (i < s.length && _isIdentChar(s.codeUnitAt(i))) {
      i++;
    }
    if (i == st) _fail('unexpected character "${s[i]}"');
    final w = s.substring(st, i);
    switch (w) {
      case 'true':
        return true;
      case 'false':
        return false;
      case 'null':
      case 'undefined':
        return null;
      default:
        _fail('unsupported value "$w"');
    }
  }
}
