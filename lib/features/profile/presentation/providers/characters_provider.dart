import 'package:flutter/foundation.dart';
import '../../domain/usecases/characters/get_user_character_usecase.dart';
import '../../domain/usecases/characters/set_user_character_usecase.dart';
import '../../domain/usecases/characters/get_available_characters_usecase.dart';
import '../../domain/models/character.dart';

/// 캐릭터/아바타 선택 Provider
///
/// **책임**:
/// - 사용자 캐릭터 상태 관리
/// - 사용 가능한 캐릭터 목록 관리
/// - UseCase를 통한 비즈니스 로직 실행
class CharactersProvider extends ChangeNotifier {
  final GetUserCharacterUseCase _getUserCharacterUseCase;
  final SetUserCharacterUseCase _setUserCharacterUseCase;
  final GetAvailableCharactersUseCase _getAvailableCharactersUseCase;

  Character? _currentCharacter;
  List<Character> _availableCharacters = [];
  bool _isLoading = false;
  String? _errorMessage;

  CharactersProvider({
    required GetUserCharacterUseCase getUserCharacterUseCase,
    required SetUserCharacterUseCase setUserCharacterUseCase,
    required GetAvailableCharactersUseCase getAvailableCharactersUseCase,
  })  : _getUserCharacterUseCase = getUserCharacterUseCase,
        _setUserCharacterUseCase = setUserCharacterUseCase,
        _getAvailableCharactersUseCase = getAvailableCharactersUseCase;

  // Getters
  Character? get currentCharacter => _currentCharacter;
  List<Character> get availableCharacters => _availableCharacters;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 사용자 현재 캐릭터 로드
  Future<void> loadUserCharacter(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getUserCharacterUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _currentCharacter = null;
      },
      (character) {
        _currentCharacter = character;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 사용자 캐릭터 설정
  Future<void> setUserCharacter(String userId, String characterId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _setUserCharacterUseCase.execute(
      userId: userId,
      characterId: characterId,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (character) {
        _currentCharacter = character;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 사용 가능한 캐릭터 목록 로드
  Future<void> loadAvailableCharacters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getAvailableCharactersUseCase.execute();

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
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
