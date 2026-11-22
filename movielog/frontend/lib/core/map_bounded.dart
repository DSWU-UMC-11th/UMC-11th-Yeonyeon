import 'dart:math' as math;

Future<List<R?>> mapBounded<T, R>(
  Iterable<T> values,
  int concurrency,
  Future<R> Function(T) mapper,
) async {
  final input = values.toList();
  final output = List<R?>.filled(input.length, null);
  var next = 0;
  Future<void> worker() async {
    while (true) {
      final index = next++;
      if (index >= input.length) return;
      try {
        output[index] = await mapper(input[index]);
      } catch (_) {
        output[index] = null;
      }
    }
  }

  await Future.wait(
    List.generate(math.min(concurrency, input.length), (_) => worker()),
  );
  return output;
}
