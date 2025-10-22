import 'package:flutter/foundation.dart';
import '../../domain/usecases/characters/get_available_characters_usecase.dart';
import '../../domain/models/character.dart';

/// 캐릭터/아바타 선택 Provider
///
/// **책임**:
/// - 사용 가능한 캐릭터 목록 관리
/// - UseCase를 통한 비즈니스 로직 실행
class CharactersProvider extends ChangeNotifier {
  final GetAvailableCharactersUseCase _getAvailableCharactersUseCase;

  List<Character> _availableCharacters = [];
  bool _isLoading = false;
  String? _errorMessage;

  CharactersProvider({
    required GetAvailableCharactersUseCase getAvailableCharactersUseCase,
  }) : _getAvailableCharactersUseCase = getAvailableCharactersUseCase;

  // Getters
  List<Character> get availableCharacters => _availableCharacters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 사용 가능한 캐릭터 목록 로드
  Future<void> loadAvailableCharacters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAvailableCharactersUseCase.execute();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _availableCharacters = [];
      },
      (characters) {
        _availableCharacters = characters;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
