# 📂 Search Domain Models

> 검색 기능의 핵심 도메인 모델 정의

## 📋 개요

Domain Models는 검색 기능의 핵심 비즈니스 엔티티를 정의합니다. 외부 의존성 없이 순수한 Dart 객체로 구성되며, 비즈니스 규칙과 불변성을 보장합니다.

## 🎯 모델 설계 원칙

### 핵심 원칙
- **불변성(Immutability)**: 모든 모델은 immutable
- **값 동등성(Value Equality)**: Equatable 사용
- **비즈니스 규칙 캡슐화**: 모델 내 검증 로직
- **직렬화 지원**: JSON 변환 메서드 제공
- **Null Safety**: 명확한 nullable 정의

### 모델이 하지 않는 것
- UI 로직 포함
- 외부 서비스 호출
- 상태 변경 (모든 변경은 copyWith)
- 데이터베이스 의존성

## 📁 파일 구조

```
models/
├── search_result_model.dart      # 검색 결과 모델
├── search_filter_model.dart      # 검색 필터 모델
├── search_history_model.dart     # 검색 기록 모델
├── search_query_model.dart       # 검색 쿼리 모델
└── algolia_result_model.dart     # Algolia 결과 모델
```

## 🔄 마이그레이션 대상

### 이동할 파일
```bash
# 검색 기록 모델 이동
git mv lib/backend/schema/searches_model.dart lib/features/search/domain/models/search_history_model.dart
```

### 새로 생성할 파일
```bash
touch lib/features/search/domain/models/search_result_model.dart
touch lib/features/search/domain/models/search_filter_model.dart
touch lib/features/search/domain/models/search_query_model.dart
touch lib/features/search/domain/models/algolia_result_model.dart
```

## 📂 모델 사양

### SearchResult Model
- **역할**: 통합 검색 결과 표현
- **검색 결과 타입**:
  - post: 게시물
  - user: 사용자  
  - chat: 채팅
  - comment: 댓글
- **핵심 필드**:
  - id, title, description
  - imageUrl, imageUrls (멀티 이미지 지원)
  - type (SearchResultType)
  - metadata (Map<String, dynamic>)
  - relevanceScore (관련성 점수)
  - createdAt, updatedAt
  - userId, userName, userProfileImage
  - votesCount, commentsCount
  - tags
- **비즈니스 규칙**:
  - isRelevant: relevanceScore >= 0.3
  - isPopular: votesCount >= 100
  - isRecent: 7일 이내 생성
- **주요 메서드**:
  - copyWith(): 불변 객체 복사
  - toJson()/fromJson(): JSON 직렬화
  - Equatable 구현으로 값 동등성 보장

### SearchFilter Model
- **역할**: 검색 필터 및 옵션 관리
- **정렬 옵션 (SearchSortOrder)**:
  - relevance: 관련성
  - dateDesc: 최신순
  - dateAsc: 오래된순
  - popularityDesc: 인기순
  - popularityAsc: 인기역순
- **날짜 범위 (DateTimeRange)**:
  - start, end DateTime
  - isValid: 유효한 범위 검증
  - days: 기간 계산
- **필터 필드**:
  - type, category, dateRange
  - tags, minRelevance
  - sortOrder (기본값: relevance)
  - limit (기본값: 20), offset (기본값: 0)
  - userId, hasImage, hasVideo
  - minVotes, language
- **페이지네이션 메서드**:
  - page: 현재 페이지 번호
  - nextOffset/previousOffset: 페이지 이동
  - nextPage()/previousPage(): 페이지네이션 헬퍼
- **유틸리티 메서드**:
  - hasActiveFilters: 필터 활성화 여부
  - reset(): 필터 초기화

### SearchHistory Model
- **역할**: 사용자 검색 기록 저장
- **핵심 필드**:
  - id, userId, query
  - type (SearchResultType)
  - resultCount (검색 결과 수)
  - timestamp
- **메타데이터**:
  - category: 검색 카테고리
  - appliedFilters: 적용된 필터 목록
  - deviceInfo: 디바이스 정보
  - sessionId: 세션 식별자
- **비즈니스 규칙**:
  - isRecent: 24시간 이내 검색
  - hasResults: 결과가 있는 검색
- **데이터 변환**:
  - fromFirestore()/toFirestore(): Firestore 직렬화
  - fromJson()/toJson(): JSON 직렬화
  - copyWith(): 불변 객체 복사

### SearchQuery Model
```dart
import 'package:equatable/equatable.dart';

/// 검색 쿼리 모델
class SearchQuery extends Equatable {
  final String text;
  final List<String> keywords;
  final bool isExactMatch;
  final String? language;
  final SearchQueryType type;
  
  // 고급 검색 옵션
  final List<String>? includeWords; // 반드시 포함
  final List<String>? excludeWords; // 제외
  final String? site; // 특정 도메인
  final int? maxWords; // 최대 단어 수
  
  SearchQuery({
    required this.text,
    List<String>? keywords,
    this.isExactMatch = false,
    this.language,
    this.type = SearchQueryType.normal,
    this.includeWords,
    this.excludeWords,
    this.site,
    this.maxWords,
  }) : keywords = keywords ?? _extractKeywords(text);
  
  /// 키워드 추출
  static List<String> _extractKeywords(String text) {
    // 특수문자 제거 및 공백 분리
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s가-힣]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    
    // 불용어 제거 (간단한 예시)
    const stopWords = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at'};
    
    return words
        .where((word) => word.length > 1 && !stopWords.contains(word))
        .toList();
  }
  
  /// Algolia 쿼리 변환
  String toAlgoliaQuery() {
    if (isExactMatch) {
      return '"$text"';
    }
    
    var query = keywords.join(' ');
    
    // 포함 단어
    if (includeWords != null && includeWords!.isNotEmpty) {
      query += ' ${includeWords!.map((w) => '+$w').join(' ')}';
    }
    
    // 제외 단어
    if (excludeWords != null && excludeWords!.isNotEmpty) {
      query += ' ${excludeWords!.map((w) => '-$w').join(' ')}';
    }
    
    return query;
  }
  
  /// Firestore 쿼리용 (제한적)
  String toFirestoreQuery() {
    // Firestore는 전문 검색 미지원, prefix 매칭만 가능
    return text.toLowerCase();
  }
  
  /// 쿼리 검증
  bool get isValid {
    if (text.trim().isEmpty) return false;
    if (text.length > 200) return false; // 최대 길이
    if (maxWords != null && keywords.length > maxWords!) return false;
    return true;
  }
  
  /// 쿼리 복잡도
  int get complexity {
    var score = keywords.length;
    if (isExactMatch) score += 2;
    if (includeWords != null) score += includeWords!.length;
    if (excludeWords != null) score += excludeWords!.length;
    return score;
  }
  
  @override
  List<Object?> get props => [
    text,
    keywords,
    isExactMatch,
    language,
    type,
    includeWords,
    excludeWords,
    site,
    maxWords,
  ];
  
  SearchQuery copyWith({
    String? text,
    List<String>? keywords,
    bool? isExactMatch,
    String? language,
    SearchQueryType? type,
    List<String>? includeWords,
    List<String>? excludeWords,
    String? site,
    int? maxWords,
  }) {
    return SearchQuery(
      text: text ?? this.text,
      keywords: keywords ?? this.keywords,
      isExactMatch: isExactMatch ?? this.isExactMatch,
      language: language ?? this.language,
      type: type ?? this.type,
      includeWords: includeWords ?? this.includeWords,
      excludeWords: excludeWords ?? this.excludeWords,
      site: site ?? this.site,
      maxWords: maxWords ?? this.maxWords,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'keywords': keywords,
      'isExactMatch': isExactMatch,
      'language': language,
      'type': type.name,
      'includeWords': includeWords,
      'excludeWords': excludeWords,
      'site': site,
      'maxWords': maxWords,
    };
  }
  
  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      text: json['text'],
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'])
          : null,
      isExactMatch: json['isExactMatch'] ?? false,
      language: json['language'],
      type: SearchQueryType.values.byName(json['type'] ?? 'normal'),
      includeWords: json['includeWords'] != null
          ? List<String>.from(json['includeWords'])
          : null,
      excludeWords: json['excludeWords'] != null
          ? List<String>.from(json['excludeWords'])
          : null,
      site: json['site'],
      maxWords: json['maxWords'],
    );
  }
}

/// 검색 쿼리 타입
enum SearchQueryType {
  normal('일반 검색'),
  advanced('고급 검색'),
  voice('음성 검색'),
  image('이미지 검색');
  
  final String label;
  const SearchQueryType(this.label);
}
```

### AlgoliaResult Model

**주요 필드:**
- `objectId`: Algolia 오브젝트 ID
- `data`: Map<String, dynamic> - 원본 데이터
- `highlightResult`: Map<String, dynamic> - 하이라이트 결과
- `rankingInfo`: int? - 랭킹 정보
- `score`: double? - 관련성 점수

**Factory 메서드:**
- `fromSnapshot(AlgoliaObjectSnapshot)`: Algolia 스냅샷에서 생성

**변환 메서드:**
- `toSearchResult()`: SearchResult 모델로 변환

**헬퍼 메서드:**
- `_determineType()`: 데이터 필드 기반 타입 결정
  - postId/optionA → post
  - userId/email → user
  - chatId/participantIds → chat
  - commentId → comment
- `_extractTitle()`: title, displayName, userName, question 순서로 추출
- `_extractImageUrls()`: 단일/멀티/A-B 이미지 URL 통합 추출
- `_calculateRelevance()`: score 또는 rankingInfo 기반 관련성 계산 (기본값 0.5)
- `_extractDateTime()`: String/int/Timestamp 다양한 형식 날짜 파싱
- `_extractTags()`: tags 또는 categories 필드에서 태그 목록 추출

**Equatable props**: objectId, data, highlightResult, rankingInfo, score

## 🧪 테스트 전략

### 테스트 범위
- **SearchResult Model**: 관련성 판단, 인기도 계산, JSON 직렬화
- **SearchFilter Model**: 페이지 번호 계산, 필터 활성화 감지
- **SearchHistory Model**: 중복 제거, 시간 기반 정렬
- **SearchQuery Model**: 키워드 추출, 쿼리 검증
- **AlgoliaResult Model**: 타입 결정, SearchResult 변환

### 검증 포인트
- Equatable 동작 검증
- JSON 직렬화/역직렬화 정확성
- 비즈니스 규칙 준수
- 경계값 처리

## 📝 마이그레이션 체크리스트

- [ ] SearchResult 모델 구현
  - [ ] 기본 필드 정의
  - [ ] 비즈니스 규칙 메서드
  - [ ] JSON 직렬화
- [ ] SearchFilter 모델 구현
  - [ ] 필터 옵션 정의
  - [ ] 페이지네이션 로직
  - [ ] 필터 검증
- [ ] SearchHistory 모델 구현
  - [ ] searches_model.dart 이동
  - [ ] Firestore 변환 메서드
  - [ ] 메타데이터 추가
- [ ] SearchQuery 모델 구현
  - [ ] 키워드 추출 로직
  - [ ] 쿼리 변환 메서드
  - [ ] 검증 규칙
- [ ] AlgoliaResult 모델 구현
  - [ ] Algolia 스냅샷 변환
  - [ ] SearchResult 매핑
  - [ ] 타입 결정 로직
- [ ] 테스트 작성
  - [ ] 각 모델별 단위 테스트
  - [ ] Equatable 동작 검증
  - [ ] JSON 직렬화 테스트

---

*Domain Models는 검색 기능의 핵심 비즈니스 엔티티를 정의합니다.*