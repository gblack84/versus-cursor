# 📚 Versus Space 프로젝트 통합 문서화 인덱스

> 전체 프로젝트 문서화 진행 상황을 추적하고 관리하는 중앙 대시보드

## 📊 프로젝트 메타정보

| 항목 | 상태 | 상세 |
|------|------|------|
| **프로젝트명** | Versus Space | Flutter 기반 소셜 미디어 앱 |
| **총 디렉토리 수** | 52개 | /lib 하위 모든 디렉토리 |
| **문서화 완료** | 21개 | /lib/actions ✅, /lib/auth ✅, /lib/auth/firebase_auth ✅, /lib/backend ✅, /lib/backend/algolia ✅, /lib/backend/api_requests ✅, /lib/backend/firebase ✅, /lib/backend/firebase_storage ✅, /lib/backend/schema ✅, /lib/backend/schema/util ✅, /lib/components ✅, /lib/components/chat ✅, /lib/components/chat/vote_card ✅, /lib/components/navigation ✅, /lib/components/notifications ✅, /lib/components/notifications/constants ✅, /lib/components/notifications/models ✅, /lib/components/notifications/utils ✅, /lib/components/notifications/widgets ✅, /lib/core ✅, /lib/core/nav ✅ |
| **문서화 진행률** | 40.4% | (21/52) |
| **네이밍 컨벤션** | camelCase | 768개 필드 마이그레이션 완료 |
| **최종 업데이트** | 2025-08-22 | - |

## 🎯 문서화 목표

- ✅ 모든 디렉토리에 정확한 README.md 작성
- ✅ 실제 코드와 100% 일치하는 문서
- ✅ camelCase 네이밍 컨벤션 준수
- ✅ 검증 스크립트 통과 (check_naming.sh, validate_docs.sh)

## 📈 문서화 진행 대시보드

### 범례
- ✅ **완료**: 문서화 완료 및 검증 통과
- 🔄 **진행중**: 현재 작업 중
- ⚠️ **업데이트 필요**: snake_case → camelCase 변환 필요
- ❌ **미작업**: 아직 시작하지 않음

### /lib 루트 레벨
| 디렉토리 | 상태 | README | 검증 | 비고 |
|----------|------|--------|------|------|
| `/lib` | ❌ | ❌ | - | 전체 lib 구조 문서 필요 |
| `/lib/actions` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/auth` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/backend` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/components` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/core` | ✅ | ✅ | ✅ | 2025-08-22 완료 |
| `/lib/createaccount` | ❌ | 있음 | - | - |
| `/lib/custom_code` | ❌ | 있음 | - | - |
| `/lib/design_system` | ❌ | 있음 | - | - |
| `/lib/etc` | ❌ | 있음 | - | - |
| `/lib/login` | ❌ | 있음 | - | - |
| `/lib/models` | ❌ | 있음 | - | - |
| `/lib/pages` | ❌ | 있음 | - | 우선순위 높음 |
| `/lib/posts` | ❌ | 있음 | - | - |
| `/lib/providers` | ❌ | 있음 | - | - |
| `/lib/services` | ❌ | 있음 | - | 우선순위 높음 |
| `/lib/shared` | ❌ | 있음 | - | - |
| `/lib/testpage_select` | ❌ | 있음 | - | - |
| `/lib/utils` | ❌ | 있음 | - | - |
| `/lib/widgets` | ❌ | 있음 | - | - |

### 하위 디렉토리 상세 (52개)

#### /lib/auth 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/auth/firebase_auth` | ✅ | ✅ | ✅ |

#### /lib/backend 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/backend/algolia` | ✅ | ✅ | ✅ |
| `/lib/backend/api_requests` | ✅ | ✅ | ✅ |
| `/lib/backend/firebase` | ✅ | ✅ | ✅ |
| `/lib/backend/firebase_storage` | ✅ | ✅ | ✅ |
| `/lib/backend/schema` | ✅ | ✅ | ✅ |
| `/lib/backend/schema/util` | ✅ | ✅ | ✅ |

#### /lib/components 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/components/chat` | ✅ | ✅ | ✅ |
| `/lib/components/chat/vote_card` | ✅ | ✅ | ✅ |
| `/lib/components/navigation` | ✅ | ✅ | ✅ |
| `/lib/components/notifications` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/constants` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/models` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/utils` | ✅ | ✅ | ✅ |
| `/lib/components/notifications/widgets` | ✅ | ✅ | ✅ |

#### /lib/core 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/core/nav` | ✅ | ✅ | ✅ |

#### /lib/createaccount 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/createaccount/create_account` | ❌ | 있음 | - |
| `/lib/createaccount/phoneauth` | ❌ | 있음 | - |
| `/lib/createaccount/phoneauth/phone_creat_account` | ❌ | 있음 | - |
| `/lib/createaccount/phoneauth/phonelogeinpincode` | ❌ | 있음 | - |
| `/lib/createaccount/phonemaximum` | ❌ | 있음 | - |
| `/lib/createaccount/popup_timer_email` | ❌ | 있음 | - |

#### /lib/custom_code 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/custom_code/actions` | ❌ | 있음 | - |
| `/lib/custom_code/widgets` | ❌ | 있음 | - |

#### /lib/design_system 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/design_system/components` | ❌ | 있음 | - |
| `/lib/design_system/tokens` | ❌ | 있음 | - |
| `/lib/design_system/utils` | ❌ | 있음 | - |

#### /lib/etc 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/etc/blankppp` | ❌ | 있음 | - |
| `/lib/etc/phoneloginpincode` | ❌ | 있음 | - |
| `/lib/etc/tags_labels` | ❌ | 있음 | - |
| `/lib/etc/testalgoria` | ❌ | 있음 | - |
| `/lib/etc/testdivider` | ❌ | 있음 | - |
| `/lib/etc/vsmark` | ❌ | 있음 | - |

#### /lib/login 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/login/forgot_password` | ❌ | 있음 | - |
| `/lib/login/login_page` | ❌ | 있음 | - |
| `/lib/login/start_page` | ❌ | 있음 | - |

#### /lib/pages 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/pages/chat` | ❌ | 있음 | - |
| `/lib/pages/chat/ai_chat_v2` | ❌ | 있음 | - |
| `/lib/pages/chat/chat_detail_v2` | ❌ | 있음 | - |
| `/lib/pages/chat/chat_list` | ❌ | 있음 | - |
| `/lib/pages/chat/chat_search` | ❌ | 있음 | - |
| `/lib/pages/chat/constants` | ❌ | 있음 | - |
| `/lib/pages/chat/friends_list` | ❌ | 있음 | - |
| `/lib/pages/chat/services` | ❌ | 있음 | - |
| `/lib/pages/home` | ❌ | 있음 | - |
| `/lib/pages/image_viewer` | ❌ | 있음 | - |
| `/lib/pages/jop` | ❌ | 있음 | - |
| `/lib/pages/jop/agrred_select` | ❌ | 있음 | - |
| `/lib/pages/jop/expertise_select` | ❌ | 있음 | - |
| `/lib/pages/jop/hobbies_select` | ❌ | 있음 | - |
| `/lib/pages/notifications_list` | ❌ | 있음 | - |
| `/lib/pages/pro_image_editor` | ❌ | 있음 | - |
| `/lib/pages/profile` | ❌ | 있음 | - |
| `/lib/pages/search` | ❌ | 있음 | - |
| `/lib/pages/thumbnail_selection` | ❌ | 있음 | - |
| `/lib/pages/user_info` | ❌ | 있음 | - |
| `/lib/pages/user_info/character_detail_page` | ❌ | 있음 | - |
| `/lib/pages/user_info/language_selector` | ❌ | 있음 | - |
| `/lib/pages/user_info_input` | ❌ | 있음 | - |

#### /lib/posts 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/posts/in_put_post_image` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/components` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/constants` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/delegates` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/helpers` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/models` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/services` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/utils` | ❌ | 있음 | - |
| `/lib/posts/in_put_post_image/widgets` | ❌ | 있음 | - |

#### /lib/services 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/services/ai_moderation` | ❌ | 있음 | - |
| `/lib/services/ai_moderation/constants` | ❌ | 있음 | - |
| `/lib/services/ai_moderation/models` | ❌ | 있음 | - |
| `/lib/services/ai_moderation/text_moderation` | ❌ | 있음 | - |
| `/lib/services/cache` | ❌ | 있음 | - |

#### /lib/shared 하위
| 디렉토리 | 상태 | README | 검증 |
|----------|------|--------|------|
| `/lib/shared/constants` | ❌ | 있음 | - |
| `/lib/shared/services` | ❌ | 있음 | - |

## 📝 완료된 문서화 상세

### ✅ /lib/backend/api_requests (2025-08-22 완료)

#### 분석 결과
| 항목 | 발견 사항 | 조치 |
|------|----------|------|
| **코드 분석** | 3개 파일 (189줄 + 580줄 + 5줄) | HTTP API 클라이언트 구현 확인 |
| **문서 작성** | README 382줄 작성 | API 요청 관리 상세 문서화 |
| **네이밍 컨벤션** | 100% camelCase 준수 | ✅ 검증 통과 |

#### 구현된 기능
- **ApiManager**: 싱글톤 패턴 HTTP 클라이언트 매니저
- **모든 HTTP 메서드 지원**: GET, POST, PUT, PATCH, DELETE
- **다양한 바디 타입**: JSON, TEXT, Form URL Encoded, Multipart
- **EncoderGroup**: 비디오 인코딩 서비스 통합 (GCS 업로드 URL 생성, 인코딩 요청)
- **SearchAlgoliaCall**: Algolia 검색 직접 호출
- **캐싱 메커니즘**: ApiCallOptions 기반 응답 캐싱
- **스트리밍 API 지원**: 대용량 파일 및 실시간 데이터
- **Bearer 토큰 인증**: 자동 헤더 추가

#### 주요 클래스
- `ApiManager`: HTTP 요청 관리 싱글톤
- `ApiCallOptions`: 요청 옵션 캡슐화 (Equatable)
- `ApiCallResponse`: 표준화된 응답 래퍼
- `ApiPagingParams`: 페이지네이션 파라미터

#### 검증 결과
```bash
✅ check_naming.sh - PASSED (모든 네이밍 컨벤션 통과)
✅ validate_docs.sh - PASSED (api_requests 디렉토리 문제 없음)
```

### ✅ /lib/backend/algolia (2025-08-22 완료)

#### 분석 결과
| 항목 | 발견 사항 | 조치 |
|------|----------|------|
| **코드 분석** | 2개 파일 (88줄 + 68줄) | Algolia 검색 통합 구현 확인 |
| **문서 작성** | README 244줄 작성 | 검색 기능 상세 문서화 |
| **네이밍 컨벤션** | 100% camelCase 준수 | ✅ 검증 통과 |

#### 구현된 기능
- **AppAlgoliaManager**: 싱글톤 패턴 검색 매니저
- **텍스트 검색**: 키워드 기반 검색
- **위치 기반 검색**: 좌표 및 반경 설정
- **하이브리드 검색**: 텍스트 + 위치 조합
- **캐싱 메커니즘**: AlgoliaQueryParams 기반 메모리 캐시
- **데이터 직렬화**: 다양한 타입 변환 지원 (int, double, DateTime, LatLng, Color, DocumentReference)

#### 주요 설정
```dart
const kAlgoliaApplicationId = '0GAS0MPT9Z';
const kAlgoliaApiKey = '123e265bbab0702b220a66a59f22ab8e';
```

#### 검증 결과
```bash
✅ check_naming.sh - PASSED (모든 네이밍 컨벤션 통과)
✅ validate_docs.sh - PASSED (algolia 디렉토리 문제 없음)
```

### ✅ /lib/actions (2025-08-22 완료)

#### 분석 결과
| 항목 | 발견 사항 | 조치 |
|------|----------|------|
| **코드 분석** | actions.dart 파일 14줄 | 1개 함수만 구현 확인 |
| **문서 불일치** | 기존 README 522줄, 9개 액션 문서화 | 실제 코드와 불일치 |
| **수정 작업** | 새 README 185줄 작성 | 실제 구현 반영 |
| **네이밍 컨벤션** | 100% camelCase 준수 | ✅ 검증 통과 |

#### 실제 구현된 기능
```dart
Future selectedLanguage(BuildContext context, {String? language,}) async
```
- 사용자 언어 설정 업데이트 기능
- Firebase Firestore 연동
- currentUserReference 활용

#### 미구현 액션 (문서에만 존재했던 것들)
- ❌ 로그아웃 액션
- ❌ 계정 삭제 액션
- ❌ 이미지 업로드 액션
- ❌ 게시물 생성 액션
- ❌ 친구 추가 액션
- ❌ 투표 액션
- ❌ 네비게이션 액션
- ❌ 클립보드 복사 액션
- ❌ 공유 액션

#### 검증 결과
```bash
✅ check_naming.sh - PASSED (모든 네이밍 컨벤션 통과)
✅ validate_docs.sh - PASSED (문서 구조 검증 통과)
```

### ✅ /lib/auth/firebase_auth (2025-08-22 완료)

#### 분석 결과
| 항목 | 발견 사항 | 조치 |
|------|----------|------|
| **코드 분석** | 9개 인증 관련 파일 | 다양한 인증 방식 구현 확인 |
| **문서 작성** | README 233줄 작성 | 모든 인증 방식 상세 문서화 |
| **네이밍 컨벤션** | 100% camelCase 준수 | ✅ 검증 통과 |

#### 구현된 인증 방식
- **이메일/비밀번호**: 계정 생성, 로그인, 비밀번호 재설정
- **Google OAuth**: 웹/모바일 지원
- **Apple Sign In**: nonce 기반 보안 구현
- **GitHub OAuth**: 팝업 방식
- **전화번호**: SMS 코드 검증
- **익명 인증**: 임시 계정 생성
- **JWT 토큰**: 커스텀 토큰 인증

#### 주요 클래스 및 기능
- `FirebaseAuthManager`: 모든 인증 방식 통합 관리
- `auth_util.dart`: 현재 사용자 정보 전역 접근
- `VersusSpaceFirebaseUser`: Firebase User 래핑
- `FirebasePhoneAuthManager`: 전화번호 인증 전용 관리

#### 검증 결과
```bash
✅ check_naming.sh - PASSED (모든 네이밍 컨벤션 통과)
✅ validate_docs.sh - PASSED (lib/auth/firebase_auth 디렉토리 문제 없음)
```

### ✅ /lib/auth (2025-08-22 완료)

#### 분석 결과
| 항목 | 발견 사항 | 조치 |
|------|----------|------|
| **코드 분석** | 2개 추상 클래스 파일 | 인증 시스템 아키텍처 정의 |
| **문서 작성** | README 372줄 작성 | firebase_auth와 통합 문서화 |
| **네이밍 컨벤션** | 100% camelCase 준수 | ✅ 검증 통과 |

#### 아키텍처 구성
- **AuthManager**: 추상 인증 매니저 + 9개 인증 방식 Mixin
- **BaseAuthUserProvider**: 사용자 정보 추상화 인터페이스
- **firebase_auth/**: Firebase 구현체 (7개 인증 방식 완전 구현)

#### 인증 방식 지원 현황
- ✅ **구현 완료** (7개): 이메일, Google, Apple, GitHub, 전화번호, 익명, JWT
- ⚠️ **인터페이스만 정의** (2개): Facebook, Microsoft

#### 검증 결과
```bash
✅ check_naming.sh - PASSED (모든 네이밍 컨벤션 통과)
✅ validate_docs.sh - PASSED (lib/auth 디렉토리 문제 없음)
```

## 🎯 우선순위 작업 목록

### 높은 우선순위 (핵심 비즈니스 로직)
1. **`/lib/backend`** - Firebase 연동 및 데이터 모델
2. **`/lib/services`** - 핵심 서비스 레이어
3. **`/lib/pages`** - 주요 화면 구성

### 중간 우선순위 (UI/UX 관련)
4. **`/lib/components`** - 재사용 컴포넌트
5. **`/lib/design_system`** - 디자인 토큰 및 스타일
6. **`/lib/posts`** - 게시물 관련 기능

### 낮은 우선순위 (보조 기능)
7. **`/lib/auth`** - 인증 관련
8. **`/lib/utils`** - 유틸리티 함수
9. **`/lib/etc`** - 기타 테스트 페이지

## 🔧 검증 도구 사용법

### check_naming.sh
```bash
# 전체 프로젝트 검사
./scripts/check_naming.sh

# 특정 디렉토리만 검사
./scripts/check_naming.sh /lib/backend
```

### validate_docs.sh
```bash
# 전체 문서 검증
./scripts/validate_docs.sh

# 특정 디렉토리 문서 검증
./scripts/validate_docs.sh /lib/services
```

## 📊 진행 통계

| 구분 | 수량 | 백분율 |
|------|------|--------|
| **전체 디렉토리** | 52 | 100% |
| **✅ 완료** | 21 | 40.4% |
| **🔄 진행중** | 0 | 0% |
| **⚠️ 업데이트 필요** | 0 | 0% |
| **❌ 미작업** | 31 | 59.6% |

## 📅 작업 이력

| 날짜 | 디렉토리 | 작업자 | 상태 | 비고 |
|------|----------|--------|------|------|
| 2025-08-22 | `/lib/actions` | AI Assistant | ✅ 완료 | 문서-코드 불일치 해결, camelCase 적용 |
| 2025-08-22 | `/lib/auth/firebase_auth` | AI Assistant | ✅ 완료 | 9개 인증 방식 문서화, 233줄 README 작성 |
| 2025-08-22 | `/lib/auth` | AI Assistant | ✅ 완료 | 통합 인증 시스템 문서화, 372줄 README 작성 |
| 2025-08-22 | `/lib/backend/algolia` | AI Assistant | ✅ 완료 | Algolia 검색 통합 문서화, 244줄 README 작성 |
| 2025-08-22 | `/lib/backend/api_requests` | AI Assistant | ✅ 완료 | HTTP API 클라이언트 문서화, 382줄 README 작성 |
| 2025-08-22 | `/lib/backend/firebase` | AI Assistant | ✅ 완료 | Firebase 초기화 문서화, 250줄 README 작성 |
| 2025-08-22 | `/lib/backend/firebase_storage` | AI Assistant | ✅ 완료 | Firebase Storage 통합 문서화, 257줄 README 작성 |
| 2025-08-22 | `/lib/backend/schema/util` | AI Assistant | ✅ 완료 | 스키마 유틸리티 문서화, 404줄 README 작성 |
| 2025-08-22 | `/lib/backend/schema` | AI Assistant | ✅ 완료 | Firestore 데이터 모델 문서화, 435줄 README 작성 |
| 2025-08-22 | `/lib/backend` | AI Assistant | ✅ 완료 | 백엔드 통합 레이어 문서화, 475줄 README 작성, 6개 하위 모듈 통합 |
| 2025-08-22 | `/lib/components/chat` | AI Assistant | ✅ 완료 | 채팅 컴포넌트 문서화, 491줄 README 작성 |
| 2025-08-22 | `/lib/components/chat/vote_card` | AI Assistant | ✅ 완료 | 투표 카드 컴포넌트 문서화, 489줄 README 작성 |
| 2025-08-22 | `/lib/components/navigation` | AI Assistant | ✅ 완료 | 네비게이션 컴포넌트 문서화, 369줄 README 작성 |
| 2025-08-22 | `/lib/components/notifications/constants` | AI Assistant | ✅ 완료 | 알림 상수 문서화, 430줄 README 작성 |
| 2025-08-22 | `/lib/components/notifications/models` | AI Assistant | ✅ 완료 | 알림 모델 문서화, 397줄 README 작성 |
| 2025-08-22 | `/lib/components/notifications/utils` | AI Assistant | ✅ 완료 | 적응형 텍스트 유틸리티 문서화, 527줄 README 작성 |
| 2025-08-22 | `/lib/components/notifications/widgets` | AI Assistant | ✅ 완료 | 알림 UI 위젯 문서화, 597줄 README 작성 |
| 2025-08-22 | `/lib/components/notifications` | AI Assistant | ✅ 완료 | 전체 알림 시스템 통합 문서화, 616줄 README 작성 |
| 2025-08-22 | `/lib/components` | AI Assistant | ✅ 완료 | 컴포넌트 라이브러리 통합 문서화, 452줄 README 작성 |
| 2025-08-22 | `/lib/core/nav` | AI Assistant | ✅ 완료 | GoRouter 내비게이션 시스템 문서화, 426줄 README 작성 |
| 2025-08-22 | `/lib/core` | AI Assistant | ✅ 완료 | 핵심 유틸리티 라이브러리 통합 문서화, 474줄 README 작성, nav 하위 디렉토리 통합 |

## 🚀 다음 단계

1. `/lib/services` 디렉토리 분석 및 문서화 (우선순위 높음)
2. `/lib/pages` 디렉토리 분석 및 문서화 (우선순위 높음)
3. `/lib/components` 디렉토리 분석 및 문서화
4. 각 하위 디렉토리 순차적 작업
5. 전체 검증 스크립트 실행
6. 최종 보고서 작성

---

*이 문서는 프로젝트 문서화 진행 상황을 추적하는 마스터 인덱스입니다.*
*최종 업데이트: 2025-08-22*