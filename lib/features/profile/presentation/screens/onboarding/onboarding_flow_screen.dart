import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/interests_provider.dart';
import '/features/profile/domain/models/interest.dart';

/// 온보딩 플로우 화면
///
/// **Clean Architecture v4.0 준수**:
/// - Provider 패턴으로 상태 관리
/// - UseCase 통해 비즈니스 로직 처리
/// - 3단계 온보딩 플로우 통합 (언어 → 전문분야 → 취미)
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'onboarding_flow';
  static String routePath = '/onboarding';

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 언어 선택 상태
  String? _selectedLanguage;

  // 전문분야 선택 상태
  final List<String> _selectedExpertise = [];

  // 취미 선택 상태
  final List<String> _selectedHobbies = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final interestsProvider = context.read<InterestsProvider>();

    // 1. 전문분야를 Interest 객체로 변환 후 추가
    for (final expertise in _selectedExpertise) {
      final interest = Interest(
        id: expertise.toLowerCase().replaceAll(' ', '_'),
        name: expertise,
        category: 'expertise',
        weight: 0.5,
        selectedAt: DateTime.now(),
      );
      interestsProvider.addInterest(interest);
    }

    // 2. 취미를 Interest 객체로 변환 후 추가
    for (final hobby in _selectedHobbies) {
      final interest = Interest(
        id: hobby.toLowerCase().replaceAll(' ', '_'),
        name: hobby,
        category: 'hobby',
        weight: 0.5,
        selectedAt: DateTime.now(),
      );
      interestsProvider.addInterest(interest);
    }

    // 3. 관심사 저장
    final success = await interestsProvider.saveInterests(widget.userId);

    // 4. 온보딩 완료 처리
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('온보딩이 완료되었습니다'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
        // TODO: 온보딩 완료 후 메인 화면으로 이동
        // 언어 설정은 ProfileEditScreen 또는 Settings에서 변경 가능
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(interestsProvider.errorMessage ?? '저장 실패'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getText('onboarding' /* 온보딩 */),
          style: AppTheme.of(context).headlineSmall,
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // 진행 상황 인디케이터
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildStepIndicator(0, '언어'),
                _buildStepConnector(0),
                _buildStepIndicator(1, '전문분야'),
                _buildStepConnector(1),
                _buildStepIndicator(2, '취미'),
              ],
            ),
          ),

          // 온보딩 단계별 화면
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLanguageStep(),
                _buildExpertiseStep(),
                _buildHobbiesStep(),
              ],
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text(
                        AppLocalizations.of(context).getText('previous' /* 이전 */),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    child: Text(
                      _currentStep == 2
                          ? AppLocalizations.of(context).getText('complete' /* 완료 */)
                          : AppLocalizations.of(context).getText('next' /* 다음 */),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isActive
                ? AppTheme.of(context).primary
                : AppTheme.of(context).secondaryBackground,
            border: Border.all(
              color: AppTheme.of(context).primary,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.of(context).primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.of(context).bodySmall.override(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted
            ? AppTheme.of(context).primary
            : AppTheme.of(context).secondaryBackground,
      ),
    );
  }

  Widget _buildLanguageStep() {
    final languages = ['한국어', 'English', 'Español', 'Français', '日本語', '中文'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).getText('select_language' /* 언어를 선택하세요 */),
            style: AppTheme.of(context).headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).getText('language_description' /* 앱에서 사용할 언어를 선택해주세요 */),
            style: AppTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 24),
          ...languages.map((lang) => RadioListTile<String>(
                title: Text(lang),
                value: lang,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              )),
        ],
      ),
    );
  }

  Widget _buildExpertiseStep() {
    final expertiseOptions = [
      '기술/개발',
      '디자인',
      '비즈니스',
      '마케팅',
      '교육',
      '의료',
      '법률',
      '예술',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).getText('select_expertise' /* 전문 분야를 선택하세요 */),
            style: AppTheme.of(context).headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).getText('expertise_description' /* 최대 4개까지 선택 가능합니다 */),
            style: AppTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: expertiseOptions.map((option) {
              final isSelected = _selectedExpertise.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedExpertise.length < 4) {
                      _selectedExpertise.add(option);
                    } else if (!selected) {
                      _selectedExpertise.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHobbiesStep() {
    final hobbiesOptions = [
      '운동',
      '독서',
      '음악',
      '영화',
      '여행',
      '요리',
      '게임',
      '사진',
      '그림',
      '춤',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).getText('select_hobbies' /* 취미를 선택하세요 */),
            style: AppTheme.of(context).headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).getText('hobbies_description' /* 최대 8개까지 선택 가능합니다 */),
            style: AppTheme.of(context).bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hobbiesOptions.map((option) {
              final isSelected = _selectedHobbies.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedHobbies.length < 8) {
                      _selectedHobbies.add(option);
                    } else if (!selected) {
                      _selectedHobbies.remove(option);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedLanguage != null;
      case 1:
        return _selectedExpertise.isNotEmpty;
      case 2:
        return _selectedHobbies.isNotEmpty;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep == 2) {
      _completeOnboarding();
    } else {
      _nextStep();
    }
  }
}
