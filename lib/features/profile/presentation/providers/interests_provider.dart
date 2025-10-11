import 'package:flutter/foundation.dart';
import '../../domain/usecases/interests/get_user_interests_usecase.dart';
import '../../domain/usecases/interests/update_user_interests_usecase.dart';
import '../../domain/models/interest.dart';

/// 관심사 Provider
///
/// **책임**:
/// - 관심사 선택 상태 관리
/// - 제약사항 검증 (expertise ≤4, hobbies ≤8)
/// - UseCase를 통한 관심사 업데이트
class InterestsProvider extends ChangeNotifier {
  final GetUserInterestsUseCase _getUserInterestsUseCase;
  final UpdateUserInterestsUseCase _updateUserInterestsUseCase;

  List<Interest> _interests = [];
  bool _isLoading = false;
  String? _errorMessage;

  InterestsProvider({
    required GetUserInterestsUseCase getUserInterestsUseCase,
    required UpdateUserInterestsUseCase updateUserInterestsUseCase,
  })  : _getUserInterestsUseCase = getUserInterestsUseCase,
        _updateUserInterestsUseCase = updateUserInterestsUseCase;

  // Getters
  List<Interest> get interests => _interests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 카테고리별 관심사 조회
  List<Interest> getInterestsByCategory(String category) {
    return _interests.where((i) => i.category == category).toList();
  }

  /// 전문 분야 개수
  int get expertiseCount =>
      _interests.where((i) => i.category == 'expertise').length;

  /// 취미 개수
  int get hobbiesCount =>
      _interests.where((i) => i.category == 'hobby').length;

  /// 관심사 로드
  Future<void> loadInterests(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getUserInterestsUseCase.execute(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _interests = [];
      },
      (interests) {
        _interests = interests;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 관심사 추가
  void addInterest(Interest interest) {
    // 제약사항 확인
    if (interest.category == 'expertise' && expertiseCount >= 4) {
      _errorMessage = '전문 분야는 최대 4개까지 선택 가능합니다.';
      notifyListeners();
      return;
    }

    if (interest.category == 'hobby' && hobbiesCount >= 8) {
      _errorMessage = '취미는 최대 8개까지 선택 가능합니다.';
      notifyListeners();
      return;
    }

    _interests.add(interest);
    _errorMessage = null;
    notifyListeners();
  }

  /// 관심사 제거
  void removeInterest(String interestId) {
    _interests.removeWhere((i) => i.id == interestId);
    _errorMessage = null;
    notifyListeners();
  }

  /// 관심사 저장
  Future<bool> saveInterests(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Interest를 expertise/hobbies로 분리
    final expertise = _interests
        .where((i) => i.category == 'expertise')
        .map((i) => i.name)
        .toList();
    final hobbies = _interests
        .where((i) => i.category == 'hobby')
        .map((i) => i.name)
        .toList();

    final result = await _updateUserInterestsUseCase.execute(
      userId: userId,
      expertise: expertise,
      hobbies: hobbies,
    );

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _errorMessage = null;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// 관심사 초기화
  void clearInterests() {
    _interests = [];
    _errorMessage = null;
    notifyListeners();
  }
}
