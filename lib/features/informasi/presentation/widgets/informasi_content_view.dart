import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_typography.dart';

class InformasiContentView extends StatelessWidget {
  const InformasiContentView({
    super.key,
    required this.content,
    this.contentFormat = 'html',
  });

  final String content;
  final String contentFormat;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final markdownData = _normalizeContent(content, contentFormat);

    return MarkdownBody(
      data: markdownData,
      selectable: true,
      onTapLink: (text, href, title) async {
        if (href == null || href.isEmpty) return;
        final uri = Uri.tryParse(href);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      styleSheet: MarkdownStyleSheet(
        p: typography.bodyMedium.copyWith(
          color: colors.onSurface.withValues(alpha: 0.85),
          height: 1.75,
        ),
        h1: typography.titleLarge.copyWith(color: colors.onSurface),
        h2: typography.titleMedium.copyWith(color: colors.onSurface),
        h3: typography.titleSmall.copyWith(color: colors.onSurface),
        listBullet: typography.bodyMedium.copyWith(color: colors.onSurface),
        blockquote: typography.bodyMedium.copyWith(
          color: colors.onSurface.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(left: BorderSide(color: colors.primary, width: 4)),
          color: colors.primary.withValues(alpha: 0.05),
        ),
        code: typography.bodySmall.copyWith(
          fontFamily: 'monospace',
          color: colors.onSurface,
          backgroundColor: colorScheme.surfaceContainerHighest,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.r8),
        ),
      ),
    );
  }

  static String _normalizeContent(String raw, String format) {
    if (raw.trim().isEmpty) return '';
    if (format.toLowerCase() == 'html' || _looksLikeHtml(raw)) {
      return _htmlToMarkdown(raw);
    }
    return raw;
  }

  static bool _looksLikeHtml(String raw) =>
      RegExp(r'<[a-z][\s\S]*>', caseSensitive: false).hasMatch(raw);

  static String _htmlToMarkdown(String html) {
    var text = html.replaceAll('\r\n', '\n');

    text = text.replaceAllMapped(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      (_) => '\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'<h1[^>]*>(.*?)</h1>', caseSensitive: false, dotAll: true),
      (m) => '# ${_stripInlineTags(m.group(1) ?? '')}\n\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'<h2[^>]*>(.*?)</h2>', caseSensitive: false, dotAll: true),
      (m) => '## ${_stripInlineTags(m.group(1) ?? '')}\n\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'<h3[^>]*>(.*?)</h3>', caseSensitive: false, dotAll: true),
      (m) => '### ${_stripInlineTags(m.group(1) ?? '')}\n\n',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'<blockquote[^>]*>(.*?)</blockquote>',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) {
        final content = _stripInlineTags(m.group(1) ?? '')
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => '> ${line.trim()}')
            .join('\n');
        return '$content\n\n';
      },
    );
    text = text.replaceAllMapped(
      RegExp(
        r'<pre[^>]*><code[^>]*>(.*?)</code></pre>',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) =>
          '```\n${_decodeEntities(_stripHtmlTags(m.group(1) ?? '')).trim()}\n```\n\n',
    );
    text = text.replaceAllMapped(
      RegExp(r'<code[^>]*>(.*?)</code>', caseSensitive: false, dotAll: true),
      (m) => '`${_decodeEntities(_stripHtmlTags(m.group(1) ?? '')).trim()}`',
    );
    text = text.replaceAllMapped(
      RegExp(
        '<a[^>]*href=["\\\']([^"\\\']+)["\\\'][^>]*>(.*?)</a>',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) =>
          '[${_stripInlineTags(m.group(2) ?? '').trim()}](${m.group(1) ?? ''})',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'<(strong|b)[^>]*>(.*?)</\1>',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) => '**${_stripInlineTags(m.group(2) ?? '').trim()}**',
    );
    text = text.replaceAllMapped(
      RegExp(r'<(em|i)[^>]*>(.*?)</\1>', caseSensitive: false, dotAll: true),
      (m) => '*${_stripInlineTags(m.group(2) ?? '').trim()}*',
    );
    text = text.replaceAllMapped(
      RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true),
      (m) => '- ${_stripInlineTags(m.group(1) ?? '').trim()}\n',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'</p>|</div>|</section>|</article>|</ul>|</ol>',
        caseSensitive: false,
      ),
      (_) => '\n\n',
    );
    text = text.replaceAllMapped(
      RegExp(
        r'<p[^>]*>|<div[^>]*>|<section[^>]*>|<article[^>]*>|<ul[^>]*>|<ol[^>]*>',
        caseSensitive: false,
      ),
      (_) => '',
    );

    text = _decodeEntities(_stripHtmlTags(text));
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return text.trim();
  }

  static String _stripInlineTags(String input) => _decodeEntities(
    input
        .replaceAllMapped(
          RegExp(r'<br\s*/?>', caseSensitive: false),
          (_) => '\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), ''),
  );

  static String _stripHtmlTags(String input) =>
      input.replaceAll(RegExp(r'<[^>]+>'), '');

  static String _decodeEntities(String input) {
    return input
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");
  }
}
