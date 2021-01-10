class TextUtils {
  static String ellipsis(String text, int max) {
    if (text.length > max) {
      return '${text.substring(0, max - 3)}...';
    }
    return text;
  }
}