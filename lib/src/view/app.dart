import 'dart:async' show Future, StreamSubscription;

// Replace 'dart:io' for Web applications
import 'package:universal_platform/universal_platform.dart';

import 'package:flutter/foundation.dart' show FlutterExceptionHandler, kIsWeb;

import 'package:package_info/package_info.dart' show PackageInfo;

import 'package:connectivity/connectivity.dart'
    show Connectivity, ConnectivityResult;

import 'package:mvc_pattern/mvc_pattern.dart' as mvc;

import 'package:mvc_application/model.dart';

import 'package:mvc_application/view.dart' as v;

import 'package:mvc_application/controller.dart'
    show ControllerMVC, DeviceInfo, HandleError;

/// This class is available throughout the app
/// Readily supply properties about the App.
class App {
  //
  factory App({
    FlutterExceptionHandler errorHandler,
    ErrorWidgetBuilder errorScreen,
    v.ReportErrorHandler errorReport,
    bool allowNewHandlers = true,
  }) =>
      _this ??= App._(errorHandler, errorScreen, errorReport, allowNewHandlers);

  App._(
    FlutterExceptionHandler errorHandler,
    ErrorWidgetBuilder errorScreen,
    v.ReportErrorHandler errorReport,
    bool allowNewHandlers,
  ) {
    _errorHandler = v.AppErrorHandler(
      handler: errorHandler,
      builder: errorScreen,
      report: errorReport,
      allowNewHandlers: allowNewHandlers,
    );
  }
  static App _this;

  static v.AppErrorHandler get errorHandler => _errorHandler;
  static v.AppErrorHandler _errorHandler;

  /// Initialize the class with the AppState object.
  bool setState(v.AppState vw) {
    // Only assigned once with the first call.
    _vw ??= vw;
    return _vw != null;
  }

  /// Dispose the App properties.
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    // Restore the original error handling.
    _errorHandler.dispose();
  }

  /// The App State object.
  static v.AppState get vw => _vw;
  static v.AppState _vw;

  /// App-level error handling.
  static void onError(FlutterErrorDetails details) {
    // Call the App's 'current'error handler.
    final handler = errorHandler?.flutterExceptionHandler;
    if (handler != null) {
      handler(details);
    } else {
      // Call Flutter's error handler default behaviour.
      FlutterError.presentError(details);
    }
  }

  /// App-level error handling if async operation at start up fails
  static void onAsyncError(AsyncSnapshot<bool> snapshot) {
    final dynamic exception = snapshot.error;
    final details = FlutterErrorDetails(
      exception: exception,
      stack: exception is Error ? exception.stackTrace : null,
      library: 'app_statefulwidget',
      context: ErrorDescription('while getting ready with FutureBuilder Async'),
    );
    onError(details);
  }

  /// Collect the device's information.
  static Future<void> getDeviceInfo() async {
    _packageInfo = await PackageInfo.fromPlatform();
    // Collect Device Information
    await DeviceInfo.init();
  }

  /// More efficient widget tree rebuilds
  static final widgetsAppKey = GlobalKey();

  /// Determine if the App initialized successfully.
  // ignore: unnecessary_getters_setters
  static bool get isInit => _isInit;

  /// Set the init only once.
  // ignore: unnecessary_getters_setters
  static set isInit(bool init) => _isInit ??= init;
  static bool _isInit;

  /// Flag to set hot reload from now on.
  // ignore: unnecessary_getters_setters
  static bool get hotReload => _hotReload;

  /// Once set, it will always hot reload.
  // ignore: unnecessary_getters_setters
  static set hotReload(bool hotReload) {
    // It doesn't accept false.
    // i.e. Once true, it stays true.
    if (!hotReload) {
      return;
    }
    _hotReload = hotReload;
  }

  static bool _hotReload = false;

  // Use Material UI when explicitly specified or even when running in iOS
  /// Indicates if the App is running the Material interface theme.
  static bool get useMaterial =>
      (_vw != null && _vw.useMaterial) ||
      (UniversalPlatform.isAndroid && (_vw == null || !_vw.switchUI)) ||
      (UniversalPlatform.isIOS && (_vw == null || _vw.switchUI));

  // Use Cupertino UI when explicitly specified or even when running in Android
  /// Indicates if the App is running the Cupertino interface theme.
  static bool get useCupertino =>
      (_vw != null && _vw.useCupertino) ||
      (UniversalPlatform.isIOS && (_vw == null || !_vw.switchUI)) ||
      (UniversalPlatform.isAndroid && (_vw == null || _vw.switchUI));

  /// Explicitly change to a particular interface.
  static void changeUI(String ui) {
    _vw?.changeUI(ui);
    refresh();
  }

  /// Return the navigator key used by the App's View.
  static GlobalKey<NavigatorState> get navigatorKey => _vw?.navigatorKey;
  static set navigatorKey(GlobalKey<NavigatorState> v) {
    if (v != null) {
      _vw?.navigatorKey = v;
    }
  }

  /// Returns the routes used by the App's View.
  static Map<String, WidgetBuilder> get routes => _vw?.routes;
  static set routes(Map<String, WidgetBuilder> v) {
    if (v != null) {
      _vw?.routes = v;
    }
  }

  /// Returns to the initial route used by the App's View.
  static String get initialRoute => _vw?.initialRoute;
  static set initialRoute(String v) {
    if (v != null) {
      _vw?.initialRoute = v;
    }
  }

  /// The route generator used when the app is navigated to a named route.
  static RouteFactory get onGenerateRoute => _vw?.onGenerateRoute;
  static set onGenerateRoute(RouteFactory v) {
    if (v != null) {
      _vw?.onGenerateRoute = v;
    }
  }

  /// Called when [onGenerateRoute] fails except for the [initialRoute].
  static RouteFactory get onUnknownRoute => _vw?.onUnknownRoute;
  static set onUnknownRoute(RouteFactory v) {
    if (v != null) {
      _vw?.onUnknownRoute = v;
    }
  }

  /// The list of observers for the [Navigator] for this app.
  static List<NavigatorObserver> get navigatorObservers =>
      _vw?.navigatorObservers;
  static set navigatorObservers(List<NavigatorObserver> v) {
    if (v != null) {
      _vw?.navigatorObservers = v;
    }
  }

  /// if neither [routes], or [onGenerateRoute] was passed.
  static TransitionBuilder get builder => _vw?.builder;
  static set builder(TransitionBuilder v) {
    if (v != null) {
      _vw?.builder = v;
    }
  }

  /// Returns the title for the App's View.
  static String get title => _vw?.title;
  static set title(String v) {
    if (v != null) {
      _vw?.title = v;
    }
  }

  /// Routine used to generate the App's title.
  static GenerateAppTitle get onGenerateTitle => _vw?.onGenerateTitle;
  static set onGenerateTitle(GenerateAppTitle v) {
    if (v != null) {
      _vw?.onGenerateTitle = v;
    }
  }

  // Allow it to be assigned null.
  /// The App's current Material theme.
  static ThemeData get themeData => _themeData;
  static set themeData(dynamic value) {
    if (value == null) {
      return;
    }
    if (value is ThemeData) {
      _themeData = value;
    } else if (value is CupertinoThemeData) {
      // Ignore the value
    } else if (value is! ColorSwatch) {
      // Ignore the value
    } else if (_themeData == null) {
      _themeData = ThemeData(
        primaryColor: value,
      );
    } else {
      _themeData = _themeData?.copyWith(
        primaryColor: value,
      );
    }
  }

  static ThemeData _themeData;

  /// The Apps's current Cupertino theme.
  static CupertinoThemeData get iOSTheme => _iOSTheme;
  static CupertinoThemeData _iOSTheme;
  static set iOSTheme(dynamic value) {
    if (value == null) {
      return;
    }
    if (value is CupertinoThemeData) {
      App._iOSTheme = value;
    } else if (value is ThemeData) {
      _iOSTheme = MaterialBasedCupertinoThemeData(materialTheme: value);
    } else if (value is! ColorSwatch) {
      // Ignore the value
    } else if (App?._iOSTheme == null) {
      App._iOSTheme = CupertinoThemeData(
        primaryColor: value,
      );
    } else {
      App._iOSTheme = App?._iOSTheme?.copyWith(
        primaryColor: value,
      );
    }
  }

  /// Returns the Color passed to the App's View.
  static Color get color => _vw?.color;
  static set color(Color v) {
    if (v != null) {
      _vw?.color = v;
    }
  }

  /// Returns the App's current locale.
  static Locale get locale =>
      _vw?.locale ??
      Localizations.localeOf(context, nullOk: true) ??
      _resolveLocales(
        WidgetsBinding.instance.window.locales,
        _vw?.supportedLocales,
      );
  static set locale(Locale v) {
    if (v != null) {
      _vw?.locale = v;
    }
  }

  /// Determine the locale used by the Mobile phone.
  static Locale _resolveLocales(
    List<Locale> preferredLocales,
    Iterable<Locale> supportedLocales,
  ) {
    // Attempt to use localeListResolutionCallback.
    if (_vw?.localeListResolutionCallback != null) {
      final locale = _vw?.localeListResolutionCallback(
          preferredLocales, _vw?.supportedLocales);
      if (locale != null) {
        return locale;
      }
    }

    final preferred = preferredLocales != null && preferredLocales.isNotEmpty
        ? preferredLocales.first
        : null;

    // localeListResolutionCallback failed, falling back to localeResolutionCallback.
    if (_vw?.localeResolutionCallback != null) {
      final locale = _vw?.localeResolutionCallback(
        preferred,
        _vw?.supportedLocales,
      );
      if (locale != null) {
        return locale;
      }
    }
    // Both callbacks failed, falling back to default algorithm.
//    return basicLocaleListResolution(preferredLocales, supportedLocales);
    return preferred;
  }

  /// Returns the App's current localizations delegates.
  static Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      _vw?.localizationsDelegates;
  static set localizationsDelegates(
      Iterable<LocalizationsDelegate<dynamic>> v) {
    if (v != null) {
      _vw?.localizationsDelegates = v;
    }
  }

  /// Resolves the App's locale.
  static LocaleResolutionCallback get localeResolutionCallback =>
      _vw?.localeResolutionCallback;
  static set localeResolutionCallback(LocaleResolutionCallback v) {
    if (v != null) {
      _vw?.localeResolutionCallback = v;
    }
  }

  /// Returns an iteration of the App's locales.
  static Iterable<Locale> get supportedLocales => _vw?.supportedLocales;
  static set supportedLocales(Iterable<Locale> v) {
    if (v != null) {
      _vw?.supportedLocales = v;
    }
  }

  /// If true, it paints a grid overlay on Material apps.
  static bool get debugShowMaterialGrid => _vw?.debugShowMaterialGrid;
  static set debugShowMaterialGrid(bool v) {
    if (v != null) {
      _vw?.debugShowMaterialGrid = v;
    }
  }

  /// If true, it turns on a performance overlay.
  static bool get showPerformanceOverlay => _vw?.showPerformanceOverlay;
  static set showPerformanceOverlay(bool v) {
    if (v != null) {
      _vw?.showPerformanceOverlay = v;
    }
  }

  /// Checkerboard raster cache to speed up overall rendering.
  static bool get checkerboardRasterCacheImages =>
      _vw?.checkerboardRasterCacheImages;
  static set checkerboardRasterCacheImages(bool v) {
    if (v != null) {
      _vw?.checkerboardRasterCacheImages = v;
    }
  }

  /// Checkerboard layers rendered offscreen bitmaps.
  static bool get checkerboardOffscreenLayers =>
      _vw?.checkerboardOffscreenLayers;
  static set checkerboardOffscreenLayers(bool v) {
    if (v != null) {
      _vw?.checkerboardOffscreenLayers = v;
    }
  }

  /// Shows an overlay of accessibility information
  static bool get showSemanticsDebugger => _vw?.showSemanticsDebugger;
  static set showSemanticsDebugger(bool v) {
    if (v != null) {
      _vw?.showSemanticsDebugger = v;
    }
  }

  /// Shows a little "DEBUG" banner in checked mode.
  static bool get debugShowCheckedModeBanner => _vw?.debugShowCheckedModeBanner;
  static set debugShowCheckedModeBanner(bool v) {
    if (v != null) {
      _vw?.debugShowCheckedModeBanner = v;
    }
  }

  /// Each RenderBox to paint a box around its bounds.
  static bool get debugPaintSizeEnabled => _vw?.debugPaintSizeEnabled;
  static set debugPaintSizeEnabled(bool v) {
    if (v != null) {
      _vw?.debugPaintSizeEnabled = v;
    }
  }

  /// RenderBox paints a line at its baselines.
  static bool get debugPaintBaselinesEnabled => _vw?.debugPaintBaselinesEnabled;
  static set debugPaintBaselinesEnabled(bool v) {
    if (v != null) {
      _vw?.debugPaintBaselinesEnabled = v;
    }
  }

  /// Objects flash while they are being tapped.
  static bool get debugPaintPointersEnabled => _vw?.debugPaintPointersEnabled;
  static set debugPaintPointersEnabled(bool v) {
    if (v != null) {
      _vw?.debugPaintPointersEnabled = v;
    }
  }

  /// Layer paints a box around its bound.
  static bool get debugPaintLayerBordersEnabled =>
      _vw?.debugPaintLayerBordersEnabled;
  static set debugPaintLayerBordersEnabled(bool v) {
    if (v != null) {
      _vw?.debugPaintLayerBordersEnabled = v;
    }
  }

  /// Overlay a rotating set of colors when repainting layers in checked mode.
  static bool get debugRepaintRainbowEnabled => _vw?.debugRepaintRainbowEnabled;
  static set debugRepaintRainbowEnabled(bool v) {
    if (v != null) {
      _vw?.debugRepaintRainbowEnabled = v;
    }
  }

  /// The running platform
  static TargetPlatform get platform {
    if (_platform == null && context != null) {
      _platform = Theme.of(context).platform;
    }
    return _platform;
  }

  static TargetPlatform _platform;

  // Application information
  static PackageInfo _packageInfo;

  /// The Name of the App.
  static String get appName => _packageInfo?.appName;

  /// The 'Package Name' of the App.
  static String get packageName => _packageInfo?.packageName;

  /// The current version of the App.
  static String get version => _packageInfo?.version;

  /// The build number of the App.
  static String get buildNumber => _packageInfo?.buildNumber;

  /// Determines if running in an IDE or in production.
  static bool get inDebugger => v.AppMVC.inDebugger;

  /// Refresh the root State object, AppView.
  static void refresh() => _vw?.refresh();

  /// Catch and explicitly handle the error.
  static void catchError(Object ex) {
    if (ex is! Exception) {
      ex = Exception(ex.toString());
    }
    _vw?.catchError(ex);
  }

  /// The BuildContext for the App's View.
  static BuildContext get context => _vw?.context;

  /// The Scaffold object for this App's View.
  static ScaffoldState get scaffold => Scaffold.of(context);
  // 'maybeOf' only in Beta channel
//  static ScaffoldState get scaffold => Scaffold.maybeOf(context);

  /// Return a pre-defined theme
  static ThemeData getThemeData() {
    final theme = Prefs.getString('theme');
    ThemeData themeData;
    switch (theme) {
      case 'light':
        themeData = ThemeData.light();
        break;
      case 'dark':
        themeData = ThemeData.dark();
        break;
      default:
        if (theme.isEmpty) {
          themeData = ThemeData.fallback();
        }
    }
    return themeData;
  }

  static void setThemeData() {
    // Supply a theme
    v.App.themeData = v.App.getThemeData();
    // iOS theme
    v.App.iOSTheme =
        MaterialBasedCupertinoThemeData(materialTheme: v.App.themeData);
    // App's menu system
    v.AppMenu.setThemeData();
  }

  /// Determine the connectivity.
  static final Connectivity _connectivity = Connectivity();

  static StreamSubscription<ConnectivityResult> _connectivitySubscription;

  /// The local directory for this App.
  static String get filesDir => _path;
  static String _path;

  /// Returns the connection status of the device.
  static String get connectivity => _connectivityStatus;
  static String _connectivityStatus;

  /// Indicates if the app has access to the Internet.
  static bool get isOnline => _connectivityStatus != 'none';

  /// Connectivity listeners.
  static final Set<ConnectivityListener> _listeners = {};

  /// Add a Connectivity listener.
  static bool addConnectivityListener(ConnectivityListener listener) {
    var add = false;
    if (listener != null) {
      add = _listeners.add(listener);
    }
    return add;
  }

  /// Remove a Connectivity listener.
  static bool removeConnectivityListener(ConnectivityListener listener) {
    var remove = false;
    if (listener != null) {
      remove = _listeners.remove(listener);
    }
    return remove;
  }

  /// Clear Connectivity listeners.
  static void clearConnectivityListener() => _listeners.clear();

  /// The id for this App's particular installation.
  static Future<String> getInstallNum() => InstallFile.id();

  /// The id for this App's particular installation.
  static String get installNum => _installNum;
  static String _installNum;

  /// Internal Initialization routines.
  static Future<void> initInternal() async {
    //
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      for (final listener in _listeners) {
        listener.onConnectivityChanged(result);
      }
    });

    await _initConnectivity().then((status) {
      _connectivityStatus = status;
    }).catchError((e) {
      _connectivityStatus = 'none';
    });

    // If running on the web the rest of the code is incompatible.
    if (kIsWeb) {
      return;
    }

    // Get the installation number
    _installNum = await InstallFile.id();

    // Determine the location to the files directory.
    _path = await Files.localPath;
  }

  static Future<String> _initConnectivity() async {
    String connectionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
    } catch (ex) {
      connectionStatus = 'Failed to get connectivity.';
    }
    return connectionStatus;
  }
}

/// A Listener for the device's own connectivity status at any point in time.
mixin ConnectivityListener {
  void onConnectivityChanged(ConnectivityResult result);
}

/// Supply an MVC State object that hooks into the App class.
abstract class StateMVC<T extends StatefulWidget> extends mvc.StateMVC<T>
    with HandleError {
  //
  StateMVC([ControllerMVC controller]) : super(controller);

  @override
  void refresh() {
    if (mounted) {
      super.refresh();
      App.refresh();
    }
  }
}

/// A standard Drawer object for your Flutter app.
class AppDrawer extends StatelessWidget {
  const AppDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        const DrawerHeader(
          child: Text('DRAWER HEADER..'),
        ),
        ListTile(
          title: const Text('Item => 1'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: const Text('Item => 2'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }
}
