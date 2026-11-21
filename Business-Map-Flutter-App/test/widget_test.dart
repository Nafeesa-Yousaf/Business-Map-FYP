import 'package:flutter_test/flutter_test.dart';
import 'package:business_map/utils/media_url.dart';

void main() {
  test('MediaUrl leaves absolute URLs unchanged', () {
    const url = 'https://images.pexels.com/photos/example.jpg';
    expect(MediaUrl.resolve(url), url);
  });

  test('MediaUrl returns empty for blank input', () {
    expect(MediaUrl.resolve(null), '');
    expect(MediaUrl.resolve(''), '');
    expect(MediaUrl.resolve('   '), '');
  });
}
