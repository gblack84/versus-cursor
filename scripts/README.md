# 🛠️ Scripts - 프로젝트 자동화 스크립트

## 📋 개요

Versus Space 프로젝트의 개발, 테스트, 문서화 작업을 자동화하는 Bash 스크립트 모음입니다. 코드 품질 검증, 문서 동기화, Flutter 멀티 디바이스 실행 등 반복적인 작업을 효율적으로 처리합니다.

### 디렉토리 상태
- **상태**: ✅ **유지 필요**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: 프로젝트 품질 관리 및 개발 효율성 향상
- **권장사항**: 정기적인 스크립트 실행으로 코드 품질 유지

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **스크립트 파일명** | snake_case + .sh | `check_naming.sh` |
| **함수명** | snake_case | `print_error()` |
| **변수명** | UPPER_SNAKE_CASE | `PROJECT_ROOT` |
| **세션/윈도우명** | kebab-case | `versus-flutter` |

참조: [NAMING_CONVENTION.md](../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
scripts/
├── check_naming.sh           # 전체 프로젝트 네이밍 컨벤션 검사
├── check_dir_naming.sh        # 특정 디렉토리 네이밍 검사
├── validate_docs.sh           # 전체 문서 품질 검증
├── validate_dir_docs.sh       # 특정 디렉토리 문서 검증
├── sync_docs.sh              # 코드-문서 동기화 관리
├── flutter_multi_device.sh   # Flutter 멀티 디바이스 실행
└── tmux_flutter_session.sh   # tmux 개발 환경 구성
```

## 🔧 주요 구성요소

### 1. 네이밍 컨벤션 검사 스크립트

#### check_naming.sh
**전체 프로젝트 네이밍 컨벤션 검사** (64줄)

```bash
# 사용법
./scripts/check_naming.sh [디렉토리]

# 검사 항목
- Dart 파일명 snake_case 확인
- Firestore 필드 camelCase 확인  
- 라우트명 camelCase 확인
- README 네이밍 컨벤션 참조 확인
```

#### check_dir_naming.sh
**특정 디렉토리 네이밍 검사** (161줄)

```bash
# 사용법
./scripts/check_dir_naming.sh lib/backend/schema

# 특징
- 색상 코드로 시각적 피드백
- 상세한 검사 결과 출력
- README.md 필수 섹션 검증
- 개선 권장사항 제공
```

### 2. 문서 검증 스크립트

#### validate_docs.sh
**전체 프로젝트 문서 검증** (132줄)

```bash
# 사용법
./scripts/validate_docs.sh

# 검사 항목
- 빈 README 파일 (20줄 미만)
- 중복 마이그레이션 문서
- 3개월 이상 미수정 문서
- 깨진 상대 경로 링크
- 필수 섹션 누락
```

#### validate_dir_docs.sh  
**특정 디렉토리 문서 검증** (262줄)

```bash
# 사용법
./scripts/validate_dir_docs.sh lib/services

# 문서 품질 등급
⭐⭐⭐⭐⭐ - 완벽 (오류 0, 경고 0)
⭐⭐⭐⭐ - 좋음 (오류 0, 경고 1-2)
⭐⭐⭐ - 보통 (오류 0, 경고 3+)
⭐⭐ - 미흡 (오류 1+)
```

검증 항목:
- README.md 존재 및 크기 (최소 20줄)
- 필수 섹션 확인 (개요, 네이밍 컨벤션, 주요 구성요소, 변경 이력)
- 코드 예시 포함 여부
- 링크 유효성 검사
- 문서 최신성 확인 (30일/90일 기준)

### 3. 문서 동기화 스크립트

#### sync_docs.sh
**코드-문서 동기화 관리** (152줄)

```bash
# 사용법
./scripts/sync_docs.sh [check|update]

# 기능
- 새 디렉토리 README 자동 생성
- 최근 변경 코드와 문서 동기화 확인
- 삭제된 파일 참조 검출
- 네이밍 컨벤션 참조 자동 추가
```

### 4. Flutter 개발 환경 스크립트

#### flutter_multi_device.sh
**Flutter 멀티 디바이스 실행** (141줄)

```bash
# 사용법
./scripts/flutter_multi_device.sh

# 기능
- 연결된 모든 디바이스 자동 감지
- tmux 세션으로 동시 실행
- 디바이스별 독립 pane 구성
- macOS 디바이스 자동 제외
- 타일 레이아웃 자동 적용
```

#### tmux_flutter_session.sh
**tmux 개발 환경 템플릿** (98줄)

```bash
# 사용법
./scripts/tmux_flutter_session.sh

# 생성되는 윈도우
0: main - 메인 개발 (에디터, 로그, 모니터링)
1: devices - 멀티 디바이스 실행 (4개 pane)
2: backend - Firebase Functions 개발
3: testing - 단위/통합 테스트
4: performance - 성능 프로파일링
```

## 🚀 사용 예시

### 디렉토리 문서화 워크플로우
```bash
# 1. 특정 디렉토리 네이밍 검사
./scripts/check_dir_naming.sh lib/services

# 2. 문서 검증
./scripts/validate_dir_docs.sh lib/services

# 3. 코드-문서 동기화 확인
./scripts/sync_docs.sh check

# 4. 필요시 동기화 업데이트
./scripts/sync_docs.sh update
```

### 멀티 디바이스 테스트
```bash
# Flutter 디바이스 확인
flutter devices

# 멀티 디바이스 실행
./scripts/flutter_multi_device.sh

# tmux 세션 관리
tmux ls                           # 세션 목록
tmux attach -t versus-flutter     # 세션 연결
Ctrl+a → d                        # 세션 분리
```

## 📊 스크립트 분류 및 상태

### 필수 유지 스크립트 ✅
| 스크립트 | 용도 | 중요도 | 사용 빈도 |
|----------|------|--------|-----------|
| `check_dir_naming.sh` | 디렉토리별 네이밍 검증 | ⭐⭐⭐⭐⭐ | 매일 |
| `validate_dir_docs.sh` | 디렉토리별 문서 검증 | ⭐⭐⭐⭐⭐ | 매일 |
| `flutter_multi_device.sh` | 멀티 디바이스 테스트 | ⭐⭐⭐⭐ | 주간 |
| `sync_docs.sh` | 코드-문서 동기화 | ⭐⭐⭐⭐ | 주간 |

### 선택적 유지 스크립트 ⚠️
| 스크립트 | 용도 | 중요도 | 권장사항 |
|----------|------|--------|----------|
| `check_naming.sh` | 전체 프로젝트 검사 | ⭐⭐⭐ | 월간 실행 |
| `validate_docs.sh` | 전체 문서 검증 | ⭐⭐⭐ | 릴리즈 전 |
| `tmux_flutter_session.sh` | 개발 환경 템플릿 | ⭐⭐ | 개인 설정으로 이동 고려 |

## ⚙️ 기술 요구사항

### 필수 도구
- **Bash 4.0+**: macOS/Linux 기본 쉘
- **Flutter SDK**: 2.0+ (디바이스 관리)
- **tmux**: 터미널 멀티플렉서 (선택)
- **Git**: 버전 관리

### 권한 설정
```bash
# 실행 권한 부여
chmod +x scripts/*.sh

# 전체 권한 확인
ls -la scripts/
```

## 🔍 검증 결과 기준

### 네이밍 컨벤션
- ✅ **통과**: 모든 규칙 준수
- ⚠️ **경고**: snake_case 필드 발견
- ❌ **실패**: 대문자 포함 파일명

### 문서 품질
- ⭐⭐⭐⭐⭐: 완벽 (20+ 섹션, 코드 예시, 최신)
- ⭐⭐⭐⭐: 좋음 (필수 섹션 포함)
- ⭐⭐⭐: 보통 (기본 요구사항 충족)
- ⭐⭐: 미흡 (개선 필요)
- ⭐: 매우 미흡 (즉시 수정 필요)

## 📝 변경 이력

### 2025-08-24: 통합 문서화
- 7개 스크립트 전체 분석 완료
- 필수/선택 스크립트 분류
- 사용 예시 및 워크플로우 문서화

### 2025-08-21: 네이밍 컨벤션 업데이트
- snake_case → camelCase 마이그레이션 반영
- 검사 패턴 업데이트

### 2025-07-XX: 초기 스크립트 생성
- 기본 검증 스크립트 구현
- tmux 통합 추가

## 🎯 개선 제안

### 단기 개선사항
1. **스크립트 통합**: check_naming.sh와 check_dir_naming.sh 통합
2. **JSON 출력**: CI/CD 통합을 위한 JSON 형식 결과
3. **설정 파일**: 검사 규칙 커스터마이징 지원

### 장기 개선사항
1. **GitHub Actions 통합**: PR 자동 검증
2. **대시보드**: 웹 기반 검증 결과 뷰어
3. **자동 수정**: 간단한 이슈 자동 수정 기능

## 🔗 관련 문서

### 프로젝트 문서
- [NAMING_CONVENTION.md](../NAMING_CONVENTION.md) - 네이밍 규칙
- [index_document.md](../index_document.md) - 전체 문서 인덱스
- [ARCHITECTURE.md](../ARCHITECTURE.md) - 시스템 아키텍처

### 외부 참조
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [tmux Manual](https://github.com/tmux/tmux/wiki)
- [Flutter CLI Documentation](https://docs.flutter.dev/reference/flutter-cli)

---

*이 디렉토리는 Versus Space 프로젝트의 품질 관리와 개발 효율성을 위한 필수 자동화 도구 모음입니다.*