import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:from_css_color/from_css_color.dart';
import 'package:intl/intl.dart';
import 'package:json_path/json_path.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '/app/app.dart';

export '/app/types/lat_lng.dart';
export '/core/models/uploaded_file.dart';
export '/core/models/app_model.dart';
export 'dart:math' show min, max;
export 'dart:typed_data' show Uint8List;
export 'dart:convert' show jsonEncode, jsonDecode;
export 'package:intl/intl.dart';
export 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FirebaseFirestore;
export 'package:page_transition/page_transition.dart';
export '/core/localization/app_localizations.dart';
export '/app/router/navigation/nav.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

T valueOrDefault<T>(T? value, T defaultValue) =>
    (value is String && value.isEmpty) || value == null ? defaultValue : value;

void _setTimeagoLocales() {
  timeago.setLocaleMessages('en', timeago.EnMessages());
  timeago.setLocaleMessages('en_short', timeago.EnShortMessages());
  timeago.setLocaleMessages('de', timeago.DeMessages());
  timeago.setLocaleMessages('de_short', timeago.DeShortMessages());
}

String dateTimeFormat(String format, DateTime? dateTime, {String? locale}) {
  if (dateTime == null) {
    return '';
  }
  if (format == 'relative') {
    _setTimeagoLocales();
    return timeago.format(dateTime, locale: locale, allowFromNow: true);
  }
  return DateFormat(format, locale).format(dateTime);
}

Future launchURL(String url) async {
  var uri = Uri.parse(url);
  try {
    await launchUrl(uri);
  } catch (e) {
    throw 'Could not launch $uri: $e';
  }
}

Color colorFromCssString(String color, {Color? defaultColor}) {
  try {
    return fromCssColor(color);
  } catch (_) {}
  return defaultColor ?? Colors.black;
}

enum FormatType {
  decimal,
  percent,
  scientific,
  compact,
  compactLong,
  custom,
}

enum DecimalType {
  automatic,
  periodDecimal,
  commaDecimal,
}

String formatNumber(
  num? value, {
  required FormatType formatType,
  DecimalType? decimalType,
  String? currency,
  bool toLowerCase = false,
  String? format,
  String? locale,
}) {
  if (value == null) {
    return '';
  }
  var formattedValue = '';
  switch (formatType) {
    case FormatType.decimal:
      switch (decimalType!) {
        case DecimalType.automatic:
          formattedValue = NumberFormat.decimalPattern(locale).format(value);
          break;
        case DecimalType.periodDecimal:
          formattedValue = NumberFormat.decimalPattern('en_US').format(value);
          break;
        case DecimalType.commaDecimal:
          formattedValue = NumberFormat.decimalPattern('es_PA').format(value);
          break;
      }
      break;
    case FormatType.percent:
      formattedValue = NumberFormat.percentPattern(locale).format(value);
      break;
    case FormatType.scientific:
      formattedValue = NumberFormat.scientificPattern(locale).format(value);
      if (toLowerCase) {
        formattedValue = formattedValue.toLowerCase();
      }
      break;
    case FormatType.compact:
      formattedValue = NumberFormat.compact(locale: locale).format(value);
      break;
    case FormatType.compactLong:
      formattedValue = NumberFormat.compactLong(locale: locale).format(value);
      break;
    case FormatType.custom:
      final hasLocale = locale != null && locale.isNotEmpty;
      formattedValue =
          NumberFormat(format, hasLocale ? locale : null).format(value);
  }

  if (formattedValue.isEmpty) {
    return value.toString();
  }

  if (currency != null) {
    final currencySymbol = currency.isNotEmpty
        ? currency
        : NumberFormat.simpleCurrency(locale: locale).currencySymbol;
    formattedValue = '$currencySymbol$formattedValue';
  }

  return formattedValue;
}

DateTime? dateCopy(DateTime? dateTime) => dateTime != null
    ? DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch)
    : null;

extension DateTimeComparisonOperators on DateTime {
  bool operator <(DateTime other) => isBefore(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator <=(DateTime other) => this < other || isAtSameMomentAs(other);
  bool operator >=(DateTime other) => this > other || isAtSameMomentAs(other);
}

extension DateTimeExtension on DateTime? {
  DateTime get startOfDay => DateTime(this!.year, this!.month, this!.day);
  DateTime get endOfDay =>
      DateTime(this!.year, this!.month, this!.day, 23, 59, 59, 999);
}

extension ListFilterExt<T> on List<T> {
  List<T> filterList(bool Function(T element) filter) =>
      where((element) => filter(element)).toList();
}

// String? _serializeParameterValue(dynamic value) {
//   if (value == null) {
//     return null;
//   }
//
//   if (value is String) {
//     return value;
//   }
//
//   if (value is bool || value is int || value is double) {
//     return value.toString();
//   }
//
//   if (value is Timestamp) {
//     return value.millisecondsSinceEpoch.toString();
//   }
//
//   if (value is DateTime) {
//     return value.millisecondsSinceEpoch.toString();
//   }
//
//   if (value is LatLng) {
//     return value.serialize();
//   }
//
//   return jsonEncode(value);
// }

dynamic getJsonField(
  dynamic jsonObj,
  String path, {
  bool isForList = false,
}) {
  dynamic value = jsonObj ?? {};
  final field = JsonPath(path).read(value);
  if (field.isEmpty) {
    return null;
  }
  if (field.length > 1) {
    return field.map((f) => f.value).toList();
  }
  final firstValue = field.first.value;
  if (isForList) {
    return firstValue is! Iterable
        ? [firstValue]
        : (firstValue is List ? firstValue : firstValue.toList());
  }
  return firstValue;
}

Rect? getWidgetBoundingBox(BuildContext context) {
  try {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox!.localToGlobal(Offset.zero) & renderBox.size;
  } catch (_) {
    return null;
  }
}

bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isiOS => !kIsWeb && Platform.isIOS;
bool get isWeb => kIsWeb;
bool get isMacOS => !kIsWeb && Platform.isMacOS;
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isLinux => !kIsWeb && Platform.isLinux;

// 플랫폼 문자열 반환 함수
String getPlatformSuffix() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  return 'unknown';
}

// 플랫폼 표시 이름
String getPlatformDisplayName() {
  if (kIsWeb) return 'Web';
  if (Platform.isIOS) return 'iOS';
  if (Platform.isAndroid) return 'Android';
  if (Platform.isMacOS) return 'macOS';
  if (Platform.isWindows) return 'Windows';
  if (Platform.isLinux) return 'Linux';
  return 'Unknown';
}

const kBreakpointSmall = 479.0;
const kBreakpointMedium = 767.0;
const kBreakpointLarge = 991.0;
bool isMobileWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width < kBreakpointSmall;
bool responsiveVisibility({
  required BuildContext context,
  bool phone = true,
  bool tablet = true,
  bool tabletLandscape = true,
  bool desktop = true,
}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < kBreakpointSmall) {
    return phone;
  } else if (width < kBreakpointMedium) {
    return tablet;
  } else if (width < kBreakpointLarge) {
    return tabletLandscape;
  } else {
    return desktop;
  }
}

const kTextValidatorUsernameRegex = r'^[a-zA-Z][a-zA-Z0-9_-]{2,16}$';
const kTextValidatorEmailRegex =
    "^(?:[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#\$%&\'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-zA-Z0-9-]*[a-zA-Z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])\$";
const kTextValidatorWebsiteRegex =
    r'(https?:\/\/)?(www\.)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)|(https?:\/\/)?(www\.)?(?!ww)[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,10}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)';

extension TextEditingControllerExt on TextEditingController? {
  String get text => this == null ? '' : this!.text;
  set text(String newText) => this?.text = newText;
}

extension IterableExt<T> on Iterable<T> {
  List<T> sortedList<S extends Comparable>(
      {S Function(T)? keyOf, bool desc = false}) {
    final sortedAscending = toList()
      ..sort(keyOf == null ? null : ((a, b) => keyOf(a).compareTo(keyOf(b))));
    if (desc) {
      return sortedAscending.reversed.toList();
    }
    return sortedAscending;
  }

  List<S> mapIndexed<S>(S Function(int, T) func) => toList()
      .asMap()
      .map((index, value) => MapEntry(index, func(index, value)))
      .values
      .toList();
}

extension StringDocRef on String {
  DocumentReference get ref => FirebaseFirestore.instance.doc(this);
}

void setAppLanguage(BuildContext context, String language) =>
    VersusApp.of(context).setLocale(language);

void setDarkModeSetting(BuildContext context, ThemeMode themeMode) =>
    VersusApp.of(context).setThemeMode(themeMode);

void showSnackbar(
  BuildContext context,
  String message, {
  bool loading = false,
  int duration = 4,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (loading)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 10.0),
              child: Container(
                height: 20,
                width: 20,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
          Text(message),
        ],
      ),
      duration: Duration(seconds: duration),
    ),
  );
}

extension DoubleStringExt on double {
  String toStringAsFixedNoZero(int fractionDigits) {
    final val = toStringAsFixed(fractionDigits);
    if (val.endsWith('0' * fractionDigits)) {
      return val.substring(0, val.length - fractionDigits - 1);
    }
    return val;
  }
}

// 추가된 유틸리티 함수들
DateTime getCurrentTimestamp() => DateTime.now();

extension MapExtensions on Map<String, dynamic> {
  Map<String, dynamic> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value)),
      );
}

extension ListDivideExtension<T> on List<T> {
  List<List<T>> chunk(int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += chunkSize) {
      int end = (i + chunkSize < length) ? i + chunkSize : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }

  List<T> divide(T separator) {
    if (isEmpty) return this;
    final List<T> list = [];
    for (int i = 0; i < length; i++) {
      list.add(this[i]);
      if (i < length - 1) {
        list.add(separator);
      }
    }
    return list;
  }

  List<T> addToStart(T item) {
    return [item, ...this];
  }

  List<T> addToEnd(T item) {
    return [...this, item];
  }
}

// castToType 함수 추가
T? castToType<T>(dynamic value) {
  if (value == null) {
    return null;
  }

  switch (T) {
    case String:
      return value.toString() as T;
    case int:
      if (value is int) return value as T;
      if (value is double) return value.toInt() as T;
      if (value is String) return int.tryParse(value) as T?;
      break;
    case double:
      if (value is double) return value as T;
      if (value is int) return value.toDouble() as T;
      if (value is String) return double.tryParse(value) as T?;
      break;
    case bool:
      if (value is bool) return value as T;
      if (value is String) {
        return (value.toLowerCase() == 'true' || value == '1') as T;
      }
      if (value is int) return (value != 0) as T;
      break;
    case DateTime:
      if (value is DateTime) return value as T;
      if (value is String) return DateTime.tryParse(value) as T?;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value) as T;
      break;
  }

  // Try direct cast as last resort
  try {
    return value as T;
  } catch (_) {
    return null;
  }
}

// Extension for Iterable to filter out nulls
extension IterableNullableExt<T> on Iterable<T?> {
  List<T> get withoutNulls => where((e) => e != null).cast<T>().toList();
}

// Extension for double divide method
extension DoubleExtension on double {
  double divide(double divisor) => divisor != 0 ? this / divisor : 0.0;
}

// Extension for String capitalization
extension StringCapitalizationExt on String {
  String toCapitalization(TextCapitalization capitalization) {
    if (isEmpty) return this;

    switch (capitalization) {
      case TextCapitalization.words:
        return split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
      case TextCapitalization.sentences:
        if (isEmpty) return this;
        return this[0].toUpperCase() + substring(1);
      case TextCapitalization.characters:
        return toUpperCase();
      case TextCapitalization.none:
        return this;
    }
  }
}

// Extension for Color alpha
extension ColorExtension on Color {
  Color applyAlpha(double factor) {
    return withAlpha((a * 255.0 * factor).round().clamp(0, 255));
  }
}

// Fix status bar on iOS 16 and below
void fixStatusBarOniOS16AndBelow(BuildContext context) {
  if (!kIsWeb && Platform.isIOS) {
    // Apply fix for iOS 16 and below
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }
}
