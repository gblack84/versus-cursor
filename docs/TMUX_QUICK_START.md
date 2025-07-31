# tmux 빠른 시작 가이드 (Quick Start)

## 🎯 현재 상태 확인하기

tmux 세션에 있는지 확인하는 방법:
- 화면 하단에 녹색/파란색 상태바가 보이면 tmux 안에 있습니다
- 예: `[0] 0:main* 1:devices 2:backend 3:testing 4:performance`

## ⌨️ 필수 단축키 (Ctrl+a를 먼저 누르고)

### 기본 조작
| 단축키 | 설명 |
|--------|------|
| `Ctrl+a` → `d` | 세션 분리 (tmux는 계속 실행됨) |
| `Ctrl+a` → `?` | 모든 단축키 보기 |

### 윈도우 이동
| 단축키 | 설명 |
|--------|------|
| `Ctrl+a` → `0` | main 윈도우 |
| `Ctrl+a` → `1` | devices 윈도우 |
| `Ctrl+a` → `2` | backend 윈도우 |
| `Ctrl+a` → `3` | testing 윈도우 |
| `Ctrl+a` → `4` | performance 윈도우 |

### 패널 이동
| 단축키 | 설명 |
|--------|------|
| `Alt` + `←` | 왼쪽 패널로 |
| `Alt` + `→` | 오른쪽 패널로 |
| `Alt` + `↑` | 위 패널로 |
| `Alt` + `↓` | 아래 패널로 |

## 🚀 Flutter 명령어 (앱이 실행 중일 때)

| 키 | 설명 |
|----|------|
| `r` | Hot Reload (빠른 새로고침) |
| `R` | Hot Restart (전체 재시작) |
| `q` | 앱 종료 |
| `p` | 성능 오버레이 표시/숨기기 |

## 📱 자주 사용하는 시나리오

### 1. 멀티 디바이스 실행
```bash
# 터미널에서
fdev
```

### 2. 개발 환경 시작
```bash
# 터미널에서
tmux-versus
```

### 3. 세션에서 나갔다가 다시 연결
```bash
# 세션 분리 (tmux 안에서)
Ctrl+a d

# 다시 연결 (터미널에서)
tmux attach
# 또는
tma versus-flutter
```

### 4. 특정 디바이스에서만 실행
```bash
# devices 윈도우로 이동
Ctrl+a 1

# 빈 패널에서
flutter run -d macos
```

## 🆘 문제 해결

### "no sessions" 에러가 나올 때
```bash
# 새로 시작
fdev
# 또는
tmux-versus
```

### 키가 안 먹을 때
1. `Ctrl+a`를 먼저 누르셨나요?
2. tmux 안에 있나요? (하단 상태바 확인)

### 세션이 꼬였을 때
```bash
# 모든 세션 종료하고 새로 시작
tmux kill-server
fdev
```

## 💡 Pro Tips

1. **마우스 사용 가능**: 패널 클릭으로 이동, 드래그로 크기 조절
2. **복사/붙여넣기**: 마우스로 텍스트 선택 후 복사
3. **전체화면**: `Ctrl+a` → `z` (토글)

---

더 자세한 내용은 [전체 가이드](TMUX_FLUTTER_GUIDE.md)를 참고하세요.