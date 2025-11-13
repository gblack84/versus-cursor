import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '/services/geo_location/geo_location_service.dart';

/// 국가 선택 위젯 (IP 자동 감지 + 수동 변경)
///
/// **기능**:
/// - IP 기반 국가 자동 감지
/// - country_code_picker로 수동 변경 가능
/// - 국가 변경 시 콜백 호출
///
/// **사용 예시**:
/// ```dart
/// CountrySelectorWidget(
///   initialCountryCode: 'KR',
///   onChanged: (country) {
///     setState(() {
///       selectedCountry = country.name;       // "South Korea"
///       selectedCountryCode = country.code;   // "KR"
///     });
///   },
/// )
/// ```
///
/// **동작 플로우**:
/// 1. 초기화 시 IP 기반 국가 자동 감지 (initialCountryCode가 없을 경우)
/// 2. 감지된 국가로 CountryCodePicker 초기화
/// 3. 사용자가 수동으로 국가 변경 가능
/// 4. 변경 시 onChanged 콜백 호출
class CountrySelectorWidget extends StatefulWidget {
  /// 초기 국가 코드 (ISO 3166-1 alpha-2)
  ///
  /// null이면 IP 기반 자동 감지 실행
  final String? initialCountryCode;

  /// 국가 변경 시 콜백
  ///
  /// **Parameters**:
  /// - CountryCode: country_code_picker 패키지의 국가 객체
  ///   - code: "KR", "US" 등 (ISO 3166-1 alpha-2)
  ///   - name: "South Korea", "United States" 등
  ///   - dialCode: "+82", "+1" 등 (전화번호 국가 코드)
  final Function(CountryCode) onChanged;

  /// 배경색
  final Color? backgroundColor;

  /// 테두리 색상
  final Color? borderColor;

  /// 테두리 둥글기
  final double borderRadius;

  /// 텍스트 스타일
  final TextStyle? textStyle;

  const CountrySelectorWidget({
    Key? key,
    this.initialCountryCode,
    required this.onChanged,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.textStyle,
  }) : super(key: key);

  @override
  State<CountrySelectorWidget> createState() => _CountrySelectorWidgetState();
}

class _CountrySelectorWidgetState extends State<CountrySelectorWidget> {
  String? _countryCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _detectCountry();
  }

  /// IP 기반 국가 자동 감지
  ///
  /// **로직**:
  /// 1. initialCountryCode가 있으면 자동 감지 생략
  /// 2. 없으면 CountryDetectionService로 IP 기반 감지
  /// 3. 감지 실패 시 Fallback (US)
  Future<void> _detectCountry() async {
    if (widget.initialCountryCode != null) {
      // 초기값이 있으면 자동 감지 생략
      setState(() {
        _countryCode = widget.initialCountryCode;
        _isLoading = false;
      });
      return;
    }

    // IP 기반 자동 감지
    final service = CountryDetectionService();
    final detected = await service.detectCountry();

    setState(() {
      _countryCode = detected.countryCode;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 44.0,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? const Color(0xFF1D2429),
          border: Border.all(
            color: widget.borderColor ?? const Color(0xFF262D34),
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: const Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFF1D2429),
        border: Border.all(
          color: widget.borderColor ?? const Color(0xFF262D34),
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: CountryCodePicker(
          onChanged: widget.onChanged,
          initialSelection: _countryCode,
          favorite: const ['+82', '+1', '+49'], // 자주 쓰는 국가
          showCountryOnly: true, // 국가명만 표시 (전화번호 숨김)
          showOnlyCountryWhenClosed: true,
          alignLeft: true,
          textStyle: widget.textStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
          flagDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
          ),
          searchDecoration: InputDecoration(
            hintText: 'Search country...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1D2429),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Color(0xFF262D34)),
            ),
          ),
          dialogBackgroundColor: const Color(0xFF1D2429),
          barrierColor: Colors.black54,
          dialogTextStyle: const TextStyle(color: Colors.white),
          searchStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
