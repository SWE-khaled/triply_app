/// JavaScript applied to every loaded Paymob page so the checkout renders
/// with a proper mobile viewport instead of a zoomed-out desktop layout
/// (giant logos, tiny misaligned fields).
///
/// Shared by the card screen and the mobile wallet screen.
const String paymobMobileViewportJs = '''
(function() {
  try {
    var meta = document.querySelector('meta[name="viewport"]');
    if (!meta) {
      meta = document.createElement('meta');
      meta.name = 'viewport';
      document.head.appendChild(meta);
    }
    meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0';
    var style = document.createElement('style');
    style.textContent =
      'img{max-width:100% !important;height:auto !important;}' +
      'html,body{max-width:100vw !important;overflow-x:hidden !important;' +
      'background:#ffffff !important;min-height:100vh !important;}' +
      'iframe{max-width:100% !important;}';
    document.head.appendChild(style);
  } catch (e) {}
})();
''';