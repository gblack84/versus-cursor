import 'dart:convert';
import 'package:flutter/services.dart';

/// 콘텐츠 필터링 결과
class FilterResult {
  final bool isBlocked;
  final String filteredText;
  final String? blockedWord;
  final String? category;
  final String severity;

  FilterResult({
    required this.isBlocked,
    required this.filteredText,
    this.blockedWord,
    this.category,
    this.severity = 'none',
  });
}

/// 한국어 콘텐츠 필터링 클래스
class ContentFilter {
  static Map<String, dynamic>? _filterData;
  static bool _isInitialized = false;

  /// 필터 초기화
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/blocked_words.json');
      _filterData = Map<String, dynamic>.from(json.decode(jsonString));
      _isInitialized = true;
      print('콘텐츠 필터 초기화 완료: ${_getTotalWordsCount()}개 단어 로드됨');
    } catch (e) {
      print('콘텐츠 필터 초기화 실패: $e');
      _filterData = {'categories': {}};
      _isInitialized = true;
    }
  }

  /// 전체 금지어 개수 반환
  static int _getTotalWordsCount() {
    if (_filterData?['categories'] == null) return 0;

    int count = 0;
    final categories =
        Map<String, dynamic>.from(_filterData!['categories'] as Map);
    for (final category in categories.values) {
      if (category['words'] is List) {
        count += (category['words'] as List).length;
      }
    }
    return count;
  }

  /// 텍스트 필터링 (메인 함수)
  static FilterResult filterText(String text) {
    if (!_isInitialized || _filterData == null) {
      return FilterResult(isBlocked: false, filteredText: text);
    }

    final String normalizedInput = _normalizeText(text);
    final categories =
        Map<String, dynamic>.from(_filterData!['categories'] as Map);

    for (final categoryEntry in categories.entries) {
      final categoryName = categoryEntry.key;
      final categoryData =
          Map<String, dynamic>.from(categoryEntry.value as Map);
      final words = categoryData['words'] as List<dynamic>;
      final severity = categoryData['severity'] as String;

      for (final word in words) {
        final wordStr = word.toString();
        final normalizedWord = _normalizeText(wordStr);

        if (_containsWord(normalizedInput, normalizedWord)) {
          return FilterResult(
            isBlocked: true,
            filteredText: _replaceWord(text, wordStr),
            blockedWord: wordStr,
            category: categoryName,
            severity: severity,
          );
        }
      }
    }

    return FilterResult(isBlocked: false, filteredText: text);
  }

  /// 텍스트 정규화 (공백, 특수문자 제거)
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(
            RegExp(r'[\s@#$%^&*()_+=\-\[\]{}|\\:";' + "'" + '<>?,./~`!]'), '')
        .replaceAll(RegExp(r'[0-9]'), '') // 숫자 제거
        .trim();
  }

  /// 단어 포함 검사
  static bool _containsWord(String text, String word) {
    if (word.isEmpty) return false;

    // 정확한 매칭
    if (text.contains(word)) return true;

    // 자음/모음 분리 패턴 검사
    if (_checkVariantPattern(text, word)) return true;

    return false;
  }

  /// 변형 패턴 검사 (자음모음 분리 등)
  static bool _checkVariantPattern(String text, String word) {
    // ㅅㅣㅂㅏㄹ -> 시발 같은 패턴 검사
    final koreanConsonants = 'ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ';
    final koreanVowels = 'ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ';

    if (word.contains(RegExp('[$koreanConsonants$koreanVowels]'))) {
      // 자음모음이 포함된 경우 변환해서 확인
      final converted = _convertJamoToHangul(word);
      if (converted.isNotEmpty && text.contains(converted)) {
        return true;
      }
    }

    return false;
  }

  /// 자음모음을 한글로 변환 (간단한 구현)
  static String _convertJamoToHangul(String jamo) {
    // 실제 구현에서는 더 정교한 자음모음 조합 로직 필요
    // 여기서는 기본적인 패턴만 처리
    return jamo
        .replaceAll('ㅅㅣㅂㅏㄹ', '시발')
        .replaceAll('ㅂㅕㅇㅅㅣㄴ', '병신')
        .replaceAll('ㅁㅣㅊㅣㄴ', '미친');
  }

  /// 금지어를 대체 문자로 변경
  static String _replaceWord(String text, String blockedWord) {
    final settings = _filterData?['settings'] as Map<String, dynamic>?;
    final replacementChar = settings?['replacementChar'] ?? '*';
    final replacement = replacementChar * blockedWord.length;

    return text.replaceAll(
        RegExp(blockedWord, caseSensitive: false), replacement);
  }

  /// 실시간 텍스트 검증 (TextFormField용)
  static String? validateText(String? value) {
    if (value == null || value.isEmpty) return null;

    final result = filterText(value);
    if (result.isBlocked) {
      return '부적절한 언어가 포함되어 있습니다.';
    }

    return null;
  }

  /// 카테고리별 심각도 반환
  static String getSeverityLevel(String text) {
    final result = filterText(text);
    return result.severity;
  }

  /// 필터 정보 반환
  static Map<String, dynamic> getFilterInfo() {
    if (!_isInitialized || _filterData == null) {
      return {'initialized': false};
    }

    return {
      'initialized': true,
      'version': _filterData!['version'],
      'lastUpdated': _filterData!['lastUpdated'],
      'totalWords': _getTotalWordsCount(),
      'categories':
          (_filterData!['categories'] as Map<String, dynamic>).keys.toList(),
    };
  }
}
