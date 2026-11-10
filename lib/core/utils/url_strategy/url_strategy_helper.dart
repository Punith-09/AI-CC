export 'configure_non_web.dart'
    if (dart.library.js_interop) 'configure_web.dart'
    if (dart.library.html) 'configure_web.dart';

