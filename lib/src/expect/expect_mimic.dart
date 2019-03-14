import './expect_mimic_utils.dart';
import 'package:test/test.dart';

/// This is an atrocity but I can't see a way around it at the moment
/// To use the expect() it must be called within a test() or this happens:
///
/// https://github.com/dart-lang/test/blob/7555efe8cab11fea89a22685c6c2198c81a58c2b/lib/src/frontend/expect.dart#L95
/// https://github.com/dart-lang/test/blob/7555efe8cab11fea89a22685c6c2198c81a58c2b/lib/src/frontend/expect_async.dart#L237
///
/// Unfortunately, I cannot get the test framework to play nicely with dynamically
/// creating and adding tests as the tests framework seems to build the tests before
/// I need it to and this happens:
///
/// "Can't call test() once tests have begun running."
///
/// https://github.com/dart-lang/test/blob/7555efe8cab11fea89a22685c6c2198c81a58c2b/lib/src/backend/declarer.dart#L274
///
/// We still want to be able to use the Matchers are we can't expect people not to use them
/// So we are stuck here using smoke and mirrors and mimicing the expect / expectAsync methods in our step class
///
/// https://github.com/dart-lang/test/blob/7555efe8cab11fea89a22685c6c2198c81a58c2b/lib/src/frontend/expect.dart
class ExpectMimic {
  /// Assert that [actual] matches [matcher].
  ///
  /// This is the main assertion function. [reason] is optional and is typically
  /// not supplied, as a reason is generated from [matcher]; if [reason]
  /// is included it is appended to the reason generated by the matcher.
  ///
  /// [matcher] can be a value in which case it will be wrapped in an
  /// [equals] matcher.
  ///
  /// If the assertion fails a [TestFailure] is thrown.
  ///
  /// If [skip] is a String or `true`, the assertion is skipped. The arguments are
  /// still evaluated, but [actual] is not verified to match [matcher]. If
  /// [actual] is a [Future], the test won't complete until the future emits a
  /// value.
  ///
  /// Certain matchers, like [completion] and [throwsA], either match or fail
  /// asynchronously. When you use [expect] with these matchers, it ensures that
  /// the test doesn't complete until the matcher has either matched or failed. If
  /// you want to wait for the matcher to complete before continuing the test, you
  /// can call [expectLater] instead and `await` the result.
  void expect(actualValue, matcher, {String reason}) {
    final matchState = {};
    matcher = wrapMatcher(matcher);
    final result = matcher.matches(actualValue, matchState);
    final formatter = (actual, matcher, reason, matchState, verbose) {
      final mismatchDescription = StringDescription();
      matcher.describeMismatch(
          actual, mismatchDescription, matchState, verbose);

      return formatFailure(matcher, actual, mismatchDescription.toString(),
          reason: reason);
    };
    if (!result) {
      fail(formatter(
          actualValue, matcher as Matcher, reason, matchState, false));
    }
  }
}
