import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/compass.dart';

void main() {
  // Flat, face up: gravity reads +z. The field points north and down.
  const flat = (x: 0.0, y: 0.0, z: 9.8);

  test('heading is 0 when the top of the phone points north', () {
    expect(headingFrom(flat, (x: 0.0, y: 20.0, z: -40.0)), closeTo(0, 0.01));
  });

  test('heading is 90 when the top points east', () {
    // North is now to the phone's left (−x).
    expect(headingFrom(flat, (x: -20.0, y: 0.0, z: -40.0)), closeTo(90, 0.01));
  });

  test('heading is 180 facing south and 270 facing west', () {
    expect(headingFrom(flat, (x: 0.0, y: -20.0, z: -40.0)), closeTo(180, 0.01));
    expect(headingFrom(flat, (x: 20.0, y: 0.0, z: -40.0)), closeTo(270, 0.01));
  });

  test('no heading without a usable field', () {
    expect(headingFrom(flat, (x: 0.0, y: 0.0, z: 0.0)), isNull);
  });

  test('angleDiff takes the short way round', () {
    expect(angleDiff(350, 10), 20);
    expect(angleDiff(10, 350), -20);
    expect(angleDiff(0, 180).abs(), 180);
  });
}
