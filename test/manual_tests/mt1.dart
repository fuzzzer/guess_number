import 'dart:io';

void main() async {
  stdout.write('Loading: [');
  for (var i = 0; i < 100; i++) {
    stdout.write('='); // Adds '=' without starting a new line.
    await Future.delayed(Duration(milliseconds: 50));
  }
  stdout.write(']');
}
