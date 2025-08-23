# 📱 Phone Create Account - 전화번호 계정 생성 페이지

> Firebase Phone Authentication을 사용한 전화번호 기반 계정 생성 화면

## 📋 개요

`phone_creat_account` 디렉토리는 Versus Space 앱의 전화번호 기반 계정 생성 화면을 구현합니다. 사용자가 전화번호를 입력하여 SMS 인증을 통해 새 계정을 생성할 수 있는 대체 인증 방식을 제공합니다. 이메일 계정 생성의 보완 옵션으로 더 빠르고 간편한 가입 프로세스를 제공합니다.

### 주요 기능
- 국가 코드 및 전화번호 입력
- 전화번호 형식 자동 포맷팅 (MaskTextInputFormatter)
- SMS 인증 코드 발송
- Firebase Phone Authentication 통합
- 이메일 계정 생성 페이지와의 연동

## 🎯 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `phone_creat_account_widget.dart`, `phone_creat_account_model.dart`
- ✅ **위젯/모델 접미사**: 역할을 명확히 구분

### 클래스명
- ✅ **PascalCase 사용**: `PhoneCreatAccountWidget`, `PhoneCreatAccountModel`
- ✅ **Widget/Model 접미사**: 컴포넌트 타입 명시

### 필드 및 메서드
- ✅ **camelCase 사용**: `codeCuntryTextController`, `phoneNumberTextController`
- ✅ **FocusNode 패턴**: `codeCuntryFocusNode`, `phoneNumberFocusNode`
- ⚠️ **오타 존재**: `codeCuntry` → `codeCountry` (Country 철자 오류)

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. PhoneCreatAccountWidget (532줄)

**역할**: 전화번호 입력 UI 및 SMS 인증 요청 처리

**라우팅 정보**:
```dart
static String routeName = 'PhoneCreatAccount';
static String routePath = '/phoneCreatAccount';
```

**Props**:
```dart
final String? phoneNumberParam;  // 전달받은 전화번호 (선택적)
```

**UI 구조**:
- **AppBar**: 뒤로가기 버튼 + "Back" 텍스트 + 로고 이미지
- **메인 컨테이너**: 최대 너비 570px (반응형)
- **헤더 섹션**:
  - "Phone Login" 제목
  - 안내 메시지 텍스트
- **입력 필드 섹션**:
  - 국가 코드 입력 (너비 70px, 최대 4자)
  - 전화번호 입력 (확장형, 최대 12자)
- **액션 버튼**:
  - "Send Code" 버튼 (조건부 활성화)

**주요 위젯 구조**:
```dart
Scaffold
├── AppBar
│   ├── AppIconButton (뒤로가기)
│   ├── Row
│   │   ├── Text ("Back")
│   │   └── Image (로고)
└── Container (maxWidth: 570)
    └── Column
        ├── Text (제목: "Phone Login")
        ├── Text (설명: "Please enter your phone number...")
        ├── Row (입력 필드)
        │   ├── TextFormField (국가 코드, width: 70)
        │   └── Expanded
        │       └── TextFormField (전화번호)
        └── AppButtonWidget ("Send Code")
```

### 2. PhoneCreatAccountModel (32줄)

**역할**: 상태 관리 및 입력 포맷팅

**상태 필드**:
```dart
// 국가 코드 필드
FocusNode? codeCuntryFocusNode;
TextEditingController? codeCuntryTextController;
MaskTextInputFormatter codeCuntryMask;  // +### 형식
String? Function(BuildContext, String?)? codeCuntryTextControllerValidator;

// 전화번호 필드
FocusNode? phoneNumberFocusNode;
TextEditingController? phoneNumberTextController;
String? Function(BuildContext, String?)? phoneNumberTextControllerValidator;
```

**입력 포맷팅**:
```dart
// 국가 코드: +### 형식 (예: +82, +1)
codeCuntryMask = MaskTextInputFormatter(mask: '+###');

// 전화번호: 숫자만 허용
FilteringTextInputFormatter.allow(RegExp('[0-9]'))
```

## 🔄 전화번호 인증 프로세스

### 1. 입력 단계
```dart
// 국가 코드 입력 (자동 포맷팅)
TextFormField(
  controller: _model.codeCuntryTextController,
  inputFormatters: [_model.codeCuntryMask],  // +### 형식
  maxLength: 4,
  autofillHints: [AutofillHints.telephoneNumberCountryCode],
)

// 전화번호 입력 (숫자만)
TextFormField(
  controller: _model.phoneNumberTextController,
  maxLength: 12,
  keyboardType: TextInputType.phone,
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp('[0-9]'))
  ],
)
```

### 2. 유효성 검사
```dart
// 입력 필드 체크
if ((_model.codeCuntryTextController.text != '') &&
    (_model.phoneNumberTextController.text != ''))

// 전화번호 조합
final phoneNumberVal = 
  '${_model.codeCuntryTextController.text}${_model.phoneNumberTextController.text}';

// 포맷 검증
if (phoneNumberVal.isEmpty || !phoneNumberVal.startsWith('+')) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Phone Number is required and has to start with +.'))
  );
  return;
}
```

### 3. SMS 코드 발송
```dart
await authManager.beginPhoneAuth(
  context: context,
  phoneNumber: phoneNumberVal,
  onCodeSent: (context) async {
    // PIN 코드 입력 페이지로 이동
    context.goNamedAuth(
      PhonelogeinpincodeWidget.routeName,
      context.mounted,
      queryParameters: {
        'phoneNumberParam': serializeParam(phoneNumberVal, ParamType.String),
      },
    );
  },
);
```

### 4. Firebase Phone Auth 상태 처리
```dart
// initState에서 Phone Auth 상태 변경 감지
authManager.handlePhoneAuthStateChanges(context);
```

## 🎨 UI/UX 특징

### 테마 적용
- **배경색**: 
  - Scaffold: `primaryBackground`
  - AppBar: 흰색 (`Colors.white`)
  - 메인 컨테이너: 밝은 회색 (`#ECECEC`)
- **입력 필드 스타일**:
  - 배경: 흰색
  - 테두리: 2px, 둥근 모서리 (12px)
  - 포커스 색상: Primary 색상
  - 에러 색상: Error 색상

### 입력 필드 디자인
```dart
InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppTheme.of(context).alternate, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: AppTheme.of(context).primary, width: 2.0),
    borderRadius: BorderRadius.circular(12.0),
  ),
  filled: true,
  fillColor: Colors.white,
)
```

### 버튼 스타일
```dart
AppButtonOptions(
  width: 270.0,
  height: 50.0,
  color: Colors.black,  // 검은색 배경
  textStyle: ... color: Colors.white,  // 흰색 텍스트
  elevation: 10.0,  // 그림자 효과
  disabledColor: AppTheme.of(context).secondaryText,  // 비활성화 색상
)
```

### 반응형 디자인
- 최대 너비 570px 제한
- 국가 코드: 고정 너비 70px
- 전화번호: Expanded로 나머지 공간 활용

## 🌍 국제화 (i18n)

### 주요 번역 키
```dart
'qgyftxro' - "Back"
'gwbbszpy' - "Phone Login"
'xv3gqx8x' - "Please enter your phone number..."
'3rvgi38u' - "+Code"
'kna6yami' - "Your Phone Number..."
'npd3p5vi' - "Enter your Phone Number..."
'pqidvgqu' - "Send Code"
```

## 🔗 네비게이션 연결

### 진입 경로
- `/createAccount` (CreateAccountWidget) → "Create Account With Phone" 버튼 클릭

### 네비게이션 플로우
```dart
// 이메일 계정 생성으로 돌아가기
context.pushNamed(CreateAccountWidget.routeName);

// SMS 코드 발송 후 PIN 입력 페이지로 이동
context.goNamedAuth(
  PhonelogeinpincodeWidget.routeName,
  context.mounted,
  queryParameters: {
    'phoneNumberParam': serializeParam(phoneNumberVal, ParamType.String),
  },
  ignoreRedirect: true,
);
```

## 📱 위젯 트리 구조

```
Scaffold
├── AppBar
│   ├── leading: AppIconButton (뒤로가기)
│   ├── title: Row
│   │   ├── Text ("Back")
│   │   └── ClipRRect
│   │       └── Image.asset (로고)
│   └── centerTitle: false
└── body: Align (top-center)
    └── Container (maxWidth: 570px)
        └── Column
            ├── Padding
            │   └── Text ("Phone Login")
            ├── Padding
            │   └── Text (설명)
            ├── Container (height: 100px)
            │   └── Row
            │       ├── Container (width: 70px)
            │       │   └── TextFormField (국가 코드)
            │       └── Expanded
            │           └── TextFormField (전화번호)
            └── Padding
                └── AppButtonWidget ("Send Code")
```

## 🔒 보안 고려사항

1. **전화번호 검증**:
   - 국가 코드 필수 (+로 시작)
   - 숫자만 입력 가능
   - 최대 길이 제한 (국가코드 4자, 번호 12자)

2. **Firebase Phone Auth**:
   - SMS 인증 코드 발송
   - 자동 재시도 방지
   - 세션 관리

3. **입력 보안**:
   - 자동 완성 힌트 제공 (보안 키체인 활용)
   - 숫자 전용 키보드 강제
   - 입력 포맷 검증

## 🐛 알려진 이슈

1. **오타**: `codeCuntry` → `codeCountry` (Country 철자)
2. **버튼 활성화 로직**: 조건문이 반대로 되어 있음
   - 현재: 필드가 채워지면 버튼 비활성화
   - 수정 필요: 필드가 비어있으면 버튼 비활성화
3. **에러 메시지**: 영어로만 표시됨 (i18n 필요)

## 📈 개선 제안

1. **입력 개선**:
   - 국가 코드 드롭다운 선택기 추가
   - 전화번호 자동 포맷팅 (하이픈 추가)
   - 실시간 유효성 검사

2. **UX 개선**:
   - 로딩 상태 표시
   - SMS 재발송 타이머
   - 에러 처리 개선

3. **보안 강화**:
   - Rate limiting (재시도 제한)
   - 캡차 통합
   - 악용 방지 메커니즘

4. **코드 품질**:
   - `codeCuntry` 오타 수정
   - 버튼 활성화 로직 수정
   - 유효성 검사 함수 추가

## 📝 변경 이력

- **2025-08-23**: README 전면 재작성 (코드 분석 기반)
- **2025-08-22**: 초기 생성
- **2025-07-03**: FlutterFlow에서 Native Flutter로 마이그레이션

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-23  
**작성**: AI Assistant