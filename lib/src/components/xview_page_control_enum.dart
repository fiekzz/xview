enum XViewPageControlEnum {
  title,
  currenturl,
  scrollToTop,
  scrollToBottom,
  setLocalStorage,
  setZoomEnabled,
}

extension PageControlEnumExtension on XViewPageControlEnum {
  String get script {
    switch (this) {
      case XViewPageControlEnum.currenturl:
        return 'document.title';
      case XViewPageControlEnum.title:
        return 'window.location.href';
      case XViewPageControlEnum.scrollToTop:
        return 'window.scrollTo(0, 0);';
      case XViewPageControlEnum.scrollToBottom:
        return 'window.scrollTo(0, document.body.scrollHeight);';
      case XViewPageControlEnum.setLocalStorage:
        return '';
      case XViewPageControlEnum.setZoomEnabled:
        return '';
    }
  }

  String scriptLocalStorage(String key, String value) {
    if (this == XViewPageControlEnum.setLocalStorage) {
      return "localStorage.setItem('mate_pref_$key', '${value.toString()}');";
    }
    return "";
  }

  String setZoomEnabled(bool enabled) {
    if (this == XViewPageControlEnum.setZoomEnabled) {
      return """
        document.querySelector('meta[name="viewport"]')?.remove();
        var meta = document.createElement('meta');
        meta.name = 'viewport';
        meta.content = 'width=device-width, initial-scale=1.0, ${enabled ? 'user-scalable=yes' : 'user-scalable=no'}';
        document.head.appendChild(meta);
      """;
    }
    return "";
  }
}
