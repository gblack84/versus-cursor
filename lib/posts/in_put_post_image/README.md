# In Put Post Image Module

## 개요 (Overview)
이 모듈은 Versus Space 앱의 핵심 기능인 이미지 기반 A/B 콘텐츠 생성을 담당합니다. 사용자가 두 개의 이미지(A vs B)를 선택, 편집, 업로드하고 텍스트 설명을 추가하여 게시물을 작성할 수 있습니다.

## 주요 기능 (Key Features)
- 📸 **멀티 이미지 선택**: wechat_assets_picker를 이용한 갤러리 접근 (최대 4개)
- ✏️ **이미지 편집**: ProImageEditor를 통한 고급 편집 기능
- 🔄 **스마트 레이아웃**: 이미지 비율에 따른 자동 레이아웃 조정
- 🛡️ **AI 콘텐츠 검열**: Gemini AI, Cloud Vision API, Perspective API를 통한 다단계 검열
- 💾 **Firebase 통합**: Storage에 이미지 업로드 및 Firestore 데이터 저장
- 🎯 **타겟 오디언스**: AI 기반 사용자 매칭 및 타겟팅
- 🔔 **실시간 알림**: 투표 요청 알림 시스템

## 디렉토리 구조 (Directory Structure)

```
in_put_post_image/
├── README.md                    # 이 문서
├── in_put_post_image_model.dart # 페이지 상태 관리
├── in_put_post_image_widget.dart # 메인 페이지 위젯
│
├── components/                  # 재사용 가능한 UI 컴포넌트
│   ├── base_media_selection_box.dart      # 미디어 박스 기본 클래스
│   ├── media_selection_box_single.dart    # 단일 이미지 박스
│   ├── media_selection_box_multi.dart     # 멀티 이미지 박스
│   └── ...
│
├── services/                    # 비즈니스 로직 서비스
│   ├── image_upload_orchestrator_v2.dart  # 업로드/검열 총괄
│   ├── image_moderation_service.dart      # 이미지 검열
│   ├── perspective_api_service.dart       # 텍스트 검열
│   └── ...
│
├── helpers/                     # 유틸리티 및 헬퍼 클래스
│   ├── aspect_ratio_analyzer.dart         # 이미지 비율 분석
│   ├── dynamic_box_calculator.dart        # 박스 크기 계산
│   └── ...
│
├── widgets/                     # 복합 기능 위젯
│   ├── media_selection_flow_widget.dart   # 이미지 선택 플로우
│   ├── media_editor_widget.dart           # 편집기 래퍼
│   └── ...
│
├── constants/                   # 상수 정의
├── delegates/                   # 커스텀 델리게이트
└── utils/                       # 공통 유틸리티
```

## 주요 플로우 (Main Flow)

### 1. 이미지 선택 프로세스
```
사용자 클릭 → MediaSelectionFlow → wechat_assets_picker → 
이미지 검열 → 승인/거부 → Firebase Upload → UI 업데이트
```

### 2. 이미지 편집 프로세스
```
편집 버튼 클릭 → MediaEditor → ProImageEditor → 
편집 완료 → 재업로드 → 검열 → UI 업데이트
```

### 3. AI 검열 프로세스 (다단계)
- **1단계 - 이미지**: Cloud Vision API → 선정성, 폭력성 등 체크
- **2단계 - AI 검증**: Gemini AI → 논리성, 적절성 검증
- **3단계 - 텍스트**: Perspective API → 유해성 점수 분석
- **결과 처리**: 거부 시 구체적인 이유 표시 (한국어)

### 4. 게시물 생성 및 알림 플로우
```
다음 버튼 클릭 → 이미지 업로드 + AI 검증 → 
타겟 오디언스 설정 → Firestore 저장 → 
Cloud Functions 트리거 → AI 사용자 매칭 → 
알림 생성 및 전송
```

## 주요 상호작용 (Key Interactions)

### InPutPostImageWidget ↔ Services
- `ImageUploadOrchestratorV2`를 통해 업로드/검열 처리
- 결과에 따라 UI 상태 업데이트

### MediaSelectionBox ↔ AppState
- 선택된 이미지는 AppState에 저장
- File 객체와 Firebase URL 모두 관리

### 스마트 레이아웃 시스템
- `AspectRatioAnalyzer`: 이미지 비율 분석
- `DynamicBoxCalculator`: 최적 박스 크기 계산
- 자동으로 가로/세로 레이아웃 전환

## 중요 사항 (Important Notes)

### 상태 관리
- `InPutPostImageModel`: 페이지 로컬 상태
- `AppState`: 전역 상태 (이미지, 텍스트 등)
- 두 상태의 동기화가 중요함

### 검열 정책
- 이미지와 텍스트 모두 검열
- 부적절한 콘텐츠는 구체적인 이유와 함께 거부
- 편집 후에도 재검열 실시

### 성능 최적화
- 이미지 리사이징 (display: 800px, thumbnail: 150px)
- 병렬 업로드로 속도 향상
- 메모리 캐시 활용

### UI/UX 규칙
- A박스는 필수, B박스는 선택적
- + 아이콘: B박스가 숨겨진 상태에서만 표시
- 이미지 없이는 다음 단계 진행 불가

## 개발 시 주의사항

1. **이미지 파일 관리**: URL과 File 객체를 모두 다루므로 혼동 주의
2. **비동기 처리**: 업로드/검열은 시간이 걸리므로 로딩 상태 관리 필수
3. **에러 처리**: 네트워크 오류, 검열 실패 등 다양한 시나리오 고려
4. **메모리 관리**: 대용량 이미지 처리 시 메모리 누수 주의
5. **AI 검열**: 토큰 사용량 모니터링 및 비용 관리
6. **타겟팅**: 개인정보 보호 및 타겟 정확도 균형

## 최근 주요 업데이트

### 2025-07-15~16: AI 검열 시스템 고도화
- Gemini AI API 통합으로 콘텐츠 적절성 검증
- Genkit Framework 도입으로 AI 시스템 통합 관리
- 다단계 검열 프로세스 구축 (이미지 → AI → 텍스트)
- 토큰 사용량 추적 시스템 구현

### 2025-07-13: 대규모 코드베이스 최적화
- 10단계 체계적 리팩토링 완료
- 메모리 누수 수정 및 성능 최적화
- 컴포넌트 분리 및 재사용성 향상
- 중앙 집중식 상수 관리 시스템 구축

### 2025-07-14: 텍스트 필드 UI/UX 개선
- 중앙 집중식 필드 스타일 관리 (FieldStyles)
- 실시간 문자 카운터 개선
- 유효성 검사 UX 향상

### 2025-07-09: 스마트 레이아웃 시스템
- 이미지 비율 자동 분석
- 동적 박스 크기 계산
- 가로/세로 레이아웃 자동 전환

## 관련 문서
- [Components 상세 문서](./components/README.md)
- [Services 상세 문서](./services/README.md)
- [Helpers 상세 문서](./helpers/README.md)
- [Widgets 상세 문서](./widgets/README.md)
- [Constants 상세 문서](./constants/README.md)
- [Delegates 상세 문서](./delegates/README.md)
- [Utils 상세 문서](./utils/README.md)