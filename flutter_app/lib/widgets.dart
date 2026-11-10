import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'theme.dart';

/// Opens a link in the phone's browser / the matching app (Telegram, YouTube, UPI ...).
const List<String> _allowedSchemes = ['http', 'https', 'tg', 'upi', 'mailto', 'tel'];

Future<void> openExternal(BuildContext context, String url) async {
  var ok = false;
  try {
    final uri = Uri.parse(url);
    if (_allowedSchemes.contains(uri.scheme.toLowerCase())) {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (_) {
    ok = false;
  }
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the link')));
  }
}

void copyText(BuildContext context, String text, String message) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Rounded dark card with a ripple.
class EsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  const EsCard({super.key, required this.child, this.onTap, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: radius,
          border: Border.all(color: C.border),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// A list row: icon / emoji box, title, subtitle lines, chevron. Greyed out when [onTap] is null.
class PickRow extends StatelessWidget {
  final String icon;
  final Color? iconColor;
  final String title;
  final List<String> lines;
  final VoidCallback? onTap;
  final double? progress;
  const PickRow({
    super.key,
    required this.icon,
    required this.title,
    this.lines = const <String>[],
    this.onTap,
    this.iconColor,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kTitle),
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(l, style: kBody),
          ),
        if (progress != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Bar(value: progress!),
          ),
      ],
    );
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: C.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              icon,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: iconColor ?? C.text, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: col),
        if (onTap != null) Icon(Icons.chevron_right, color: C.text3),
      ],
    );
    return EsCard(
      onTap: onTap,
      child: onTap == null ? Opacity(opacity: 0.5, child: row) : row,
    );
  }
}

/// Thin progress bar.
class Bar extends StatelessWidget {
  final double value; // 0..1
  const Bar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : (value < 0 ? 0.0 : (value > 1 ? 1.0 : value));
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: v,
        minHeight: 6,
        backgroundColor: C.surface2,
        valueColor: AlwaysStoppedAnimation<Color>(C.blue),
      ),
    );
  }
}

/// Pill-shaped button.
class Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool filled;
  const Pill({super.key, required this.label, this.icon, this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : C.text;
    return Container(
      decoration: BoxDecoration(
        color: filled ? C.blue : C.surface2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: filled ? C.blue : C.border),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) Icon(icon, size: 16, color: fg),
                if (icon != null) const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Row of selectable chips (All / Theory / Practice ...).
class ChipRow extends StatelessWidget {
  final List<String> labels;
  final String selected;
  final void Function(String) onSelect;
  const ChipRow({super.key, required this.labels, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final l in labels)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(l),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: l == selected ? const Color(0x334F8CFF) : C.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: l == selected ? C.blue : C.border),
                  ),
                  child: Text(l, style: TextStyle(color: l == selected ? C.blue : C.text2, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  const Tag(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: C.text2, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Text(text, style: TextStyle(color: C.text, fontSize: 17, fontWeight: FontWeight.w700)),
    );
  }
}

/// Scaffold with the app's standard top bar.
class EsPage extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget> actions;
  const EsPage({super.key, required this.title, required this.body, this.actions = const <Widget>[]});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        backgroundColor: C.bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: C.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        actions: actions,
      ),
      body: body,
    );
  }
}

class CenterMessage extends StatelessWidget {
  final String text;
  const CenterMessage(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(text, textAlign: TextAlign.center, style: kBody),
      ),
    );
  }
}
