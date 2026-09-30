import 'package:flutter_test/flutter_test.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:zikzak_inappwebview_platform_interface/zikzak_inappwebview_platform_interface.dart';
import 'package:zikzak_inappwebview_windows/src/in_app_webview_windows_controller.dart';

/// Constructs a Windows controller backed by a real (but uninitialized)
/// [WebviewController]. The cache operations exercised below never touch the
/// platform channel, so this is safe to run on the Dart VM.
InAppWebViewWindowsController _buildController() {
  final params = PlatformInAppWebViewControllerCreationParams(id: 0);
  return InAppWebViewWindowsController(params, WebviewController());
}

void main() {
  group('Windows sync getters serve the widget-pushed cache', () {
    test('getUrl() reports the cached URL, and null before any push', () async {
      final controller = _buildController();
      addTearDown(controller.dispose);

      // `webview_windows`' url stream is single-subscription, so the platform
      // cannot re-read it: before the widget pushes a value there is nothing
      // to report, and reporting a guess would be worse than reporting null.
      expect(await controller.getUrl(), isNull);

      controller.cacheUrl('https://example.com/page');
      expect(controller.currentUrl, 'https://example.com/page');
      expect(
        (await controller.getUrl()).toString(),
        'https://example.com/page',
      );
    });

    test(
      'getProgress() is not stuck at 100 and follows the load state',
      () async {
        final controller = _buildController();
        addTearDown(controller.dispose);

        controller.cacheLoadingState(isLoading: true);
        expect(controller.isLoadInFlight, true);
        expect(await controller.getProgress(), 0);

        controller.cacheLoadingState(isLoading: false);
        expect(controller.isLoadInFlight, false);
        expect(await controller.getProgress(), 100);
      },
    );

    test('getTitle() reports null until a document title is pushed', () async {
      final controller = _buildController();
      addTearDown(controller.dispose);

      expect(controller.currentTitle, isNull);
      expect(await controller.getTitle(), isNull);
    });
  });
}
