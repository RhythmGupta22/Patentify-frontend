import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:metalink_flutter/metalink_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


class LinkPreviewExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'a'};

  @override
  bool matches(ExtensionContext context) {
    return context.elementName == 'a' &&
        context.attributes['href'] != null &&
        Uri.tryParse(context.attributes['href']!)?.hasAbsolutePath == true;
  }


  @override
  InlineSpan build(ExtensionContext context) {
    print("usedddd");
    final url = context.attributes['href']!;
    final text = context.innerHtml;

    return WidgetSpan(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original clickable link
          GestureDetector(
            onTap: () => _launchUrl(url),
            child: Text(
              text.isNotEmpty ? text : url,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          // Link preview using link_preview_generator
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxWidth: 450),
            child: LinkPreview(
              url: url,
              config: LinkPreviewConfig(
                style: LinkPreviewStyle.card,
                titleMaxLines: 2,
                descriptionMaxLines: 3,
                showImage: true,
                showFavicon: true,
                handleNavigation: true,
                animateLoading: true,
                cacheDuration: Duration(hours: 24),
              ),


            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  if (!await launchUrl(Uri.parse(url))) {
    throw Exception('Could not launch $url');
  }
}

