class XViewNavigationHistory {
  final String hash;
  final String url;

  XViewNavigationHistory({
    required this.hash,
    required this.url,
  });

  @override
  String toString() {
    return 'XViewNavigationHistory(hash: $hash, url: $url)';
  }
}
