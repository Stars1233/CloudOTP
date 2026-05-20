class SearchQuery {
  final String text;
  final List<String> tags;
  final String? categoryName;
  final String? tokenType;

  const SearchQuery({
    this.text = '',
    this.tags = const [],
    this.categoryName,
    this.tokenType,
  });

  bool get hasFilters =>
      tags.isNotEmpty || categoryName != null || tokenType != null;
}

class SearchQueryParser {
  static final _tagPattern = RegExp(r'#(\S+)');
  static final _catPattern = RegExp(r'cat:(\S+)');
  static final _typePattern = RegExp(r'type:(\S+)');

  static SearchQuery parse(String input) {
    if (input.trim().isEmpty) return const SearchQuery();

    final tags = _tagPattern
        .allMatches(input)
        .map((m) => m.group(1)!)
        .toList();

    final catMatch = _catPattern.firstMatch(input);
    final categoryName = catMatch?.group(1);

    final typeMatch = _typePattern.firstMatch(input);
    final tokenType = typeMatch?.group(1);

    var text = input
        .replaceAll(_tagPattern, '')
        .replaceAll(_catPattern, '')
        .replaceAll(_typePattern, '')
        .trim();

    return SearchQuery(
      text: text,
      tags: tags,
      categoryName: categoryName,
      tokenType: tokenType,
    );
  }
}
