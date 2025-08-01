import 'package:flutter/material.dart';
import '../models/versus_box_size_data.dart';
import '../services/versus_box_size_calculator.dart';
import '../widgets/versus_notification_box.dart';
import '../notification_overlay.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '/posts/in_put_post_image/in_put_post_image_model.dart';
import '/app_state.dart';

/// 투표 알림 사이즈 바인딩 시스템 사용 예제
/// 
/// 질문 작성 페이지에서 생성된 사이즈 데이터를 투표 알림에
/// 일관되게 적용하는 방법을 보여줍니다.
class VotingSystemExample {
  
  /// 예제 1: 질문 작성 페이지에서 사이즈 데이터 캡처
  /// 
  /// 이 메서드는 질문 작성 완료 시 호출되어야 합니다.
  static VersusBoxSizeData? captureFromQuestionPage(
    BuildContext context,
    AppState appState,
    InPutPostImageModel model,
  ) {
    try {
      // VersusBoxSizeCalculator를 사용하여 현재 상태 캡처
      final sizeData = VersusBoxSizeCalculator.captureCurrentSizes(
        context,
        appState,
        model,
      );
      
      if (sizeData != null) {
        debugPrint('✅ 사이즈 데이터 캡처 성공:');
        debugPrint('   레이아웃: ${sizeData.layoutType}');
        debugPrint('   A박스: ${sizeData.originalSizeA}');
        debugPrint('   B박스: ${sizeData.originalSizeB}');
        debugPrint('   화면너비: ${sizeData.screenWidth}');
        debugPrint('   이미지: A=${sizeData.hasImageA}, B=${sizeData.hasImageB}');
      } else {
        debugPrint('⚠️ 사이즈 데이터 캡처 실패 (이미지가 없거나 에러 발생)');
      }
      
      return sizeData;
    } catch (e) {
      debugPrint('❌ 사이즈 데이터 캡처 중 에러: $e');
      return null;
    }
  }
  
  /// 예제 2: 투표 알림 표시 (사이즈 데이터 포함)
  /// 
  /// 캡처된 사이즈 데이터를 사용하여 일관된 크기의 투표 알림 표시
  static void showVotingWithSizeData(
    BuildContext context,
    VersusBoxSizeData sizeData, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    bool showDebugInfo = false,
  }) {
    NotificationOverlay.showVoting(
      context,
      question: question,
      optionA: optionA,
      optionB: optionB,
      imageUrlA: imageUrlA,
      imageUrlB: imageUrlB,
      sizeData: sizeData, // 👈 핵심: 캡처된 사이즈 데이터 전달
      showDebugInfo: showDebugInfo,
      onVote: (selectedOption) {
        debugPrint('🗳️ 투표: $selectedOption 선택됨');
        
        // 실제 앱에서는 여기서 투표 결과를 서버에 전송
        // await submitVote(selectedOption);
        
        // 투표 완료 후 알림 자동 사라짐
      },
      onDismiss: () {
        debugPrint('❌ 투표 알림 닫힘');
      },
    );
  }
  
  /// 예제 3: 투표 결과 표시
  /// 
  /// 투표 완료 후 결과를 보여주는 알림
  static void showVotingResults(
    BuildContext context,
    VersusBoxSizeData sizeData, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    required double votePercentageA,
    required double votePercentageB,
    required int voteCountA,
    required int voteCountB,
    bool showDebugInfo = false,
  }) {
    NotificationOverlay.showVoting(
      context,
      question: '$question - 투표 결과',
      optionA: optionA,
      optionB: optionB,
      imageUrlA: imageUrlA,
      imageUrlB: imageUrlB,
      sizeData: sizeData,
      showResults: true, // 👈 결과 표시 모드
      votePercentageA: votePercentageA,
      votePercentageB: votePercentageB,
      voteCountA: voteCountA,
      voteCountB: voteCountB,
      showDebugInfo: showDebugInfo,
      onVote: (_) {}, // 결과 모드에서는 투표 불가
      onDismiss: () {
        debugPrint('📊 투표 결과 알림 닫힘');
      },
    );
  }
  
  /// 예제 4: 사이즈 데이터 없이 기본 크기로 표시
  /// 
  /// 질문 작성 데이터가 없는 경우의 fallback 방식
  static void showVotingWithoutSizeData(
    BuildContext context, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
  }) {
    NotificationOverlay.showVoting(
      context,
      question: question,
      optionA: optionA,
      optionB: optionB,
      imageUrlA: imageUrlA,
      imageUrlB: imageUrlB,
      // sizeData 제공하지 않음 → 기본 크기 사용
      onVote: (selectedOption) {
        debugPrint('🗳️ 기본 크기 투표: $selectedOption');
      },
    );
  }
  
  /// 예제 5: 직접 VersusNotificationBox 사용
  /// 
  /// 커스텀 레이아웃에서 박스를 직접 사용하는 방법
  static Widget buildCustomVotingLayout(
    BuildContext context,
    VersusBoxSizeData sizeData, {
    required String titleA,
    required String titleB,
    String? imageUrlA,
    String? imageUrlB,
    Function(String)? onVote,
    bool showDebugInfo = false,
  }) {
    return VersusNotificationBoxBuilder.buildBoxPair(
      context: context,
      sizeData: sizeData,
      titleA: titleA,
      titleB: titleB,
      imageUrlA: imageUrlA,
      imageUrlB: imageUrlB,
      onTapA: onVote != null ? () => onVote('A') : null,
      onTapB: onVote != null ? () => onVote('B') : null,
      showDebugInfo: showDebugInfo,
    );
  }
  
  /// 예제 6: 테스트용 샘플 데이터 생성
  /// 
  /// 개발/테스트용 샘플 사이즈 데이터
  static VersusBoxSizeData createSampleSizeData(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return VersusBoxSizeData(
      layoutType: LayoutType.horizontal,
      aspectRatioA: 1.5, // 가로형 이미지
      aspectRatioB: 0.75, // 세로형 이미지
      originalSizeA: const Size(200, 133), // 1.5 비율
      originalSizeB: const Size(150, 200), // 0.75 비율
      screenWidth: screenWidth,
      createdAt: DateTime.now(),
      hasImageA: true,
      hasImageB: true,
    );
  }
  
  /// 예제 7: 다양한 레이아웃 타입 테스트
  /// 
  /// 각 레이아웃 타입별 테스트 데이터
  static List<VersusBoxSizeData> createTestSizeData(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    
    return [
      // 가로 배치 (둘 다 세로형 이미지)
      VersusBoxSizeData(
        layoutType: LayoutType.horizontal,
        aspectRatioA: 0.8,
        aspectRatioB: 0.75,
        originalSizeA: const Size(160, 200),
        originalSizeB: const Size(150, 200),
        screenWidth: screenWidth,
        createdAt: now,
        hasImageA: true,
        hasImageB: true,
      ),
      
      // 세로 배치 (둘 다 가로형 이미지)
      VersusBoxSizeData(
        layoutType: LayoutType.vertical,
        aspectRatioA: 1.6,
        aspectRatioB: 1.8,
        originalSizeA: const Size(320, 200),
        originalSizeB: const Size(360, 200),
        screenWidth: screenWidth,
        createdAt: now,
        hasImageA: true,
        hasImageB: true,
      ),
      
      // 단일 이미지
      VersusBoxSizeData(
        layoutType: LayoutType.single,
        aspectRatioA: 1.0,
        aspectRatioB: null,
        originalSizeA: const Size(250, 250),
        originalSizeB: Size.zero,
        screenWidth: screenWidth,
        createdAt: now,
        hasImageA: true,
        hasImageB: false,
      ),
      
      // 혼합형 (가로 + 세로)
      VersusBoxSizeData(
        layoutType: LayoutType.horizontal,
        aspectRatioA: 1.8, // 가로형
        aspectRatioB: 0.6, // 세로형
        originalSizeA: const Size(360, 200),
        originalSizeB: const Size(120, 200),
        screenWidth: screenWidth,
        createdAt: now,
        hasImageA: true,
        hasImageB: true,
      ),
    ];
  }
  
  /// 예제 8: 디버그 정보 포함 테스트
  /// 
  /// 개발 시 크기 정보를 확인하기 위한 디버그 모드
  static void showDebugVoting(BuildContext context) {
    final sampleData = createSampleSizeData(context);
    
    // 디버그 정보 출력
    debugPrint('\n🔧 디버그 투표 알림 테스트');
    debugPrint('원본 데이터: $sampleData');
    
    // 투표용 크기 계산 및 출력
    final votingSizes = VersusBoxSizeCalculator.calculateVotingSize(
      sampleData,
      context,
    );
    debugPrint('투표용 크기: $votingSizes');
    debugPrint('성능 정보: ${votingSizes.performanceInfo}\n');
    
    // 디버그 정보 표시된 투표 알림
    showVotingWithSizeData(
      context,
      sampleData,
      question: '🔧 디버그 테스트: 어떤 것이 더 나은가요?',
      optionA: '옵션 A (가로형)',
      optionB: '옵션 B (세로형)',
      imageUrlA: 'https://picsum.photos/300/200',
      imageUrlB: 'https://picsum.photos/200/300',
      showDebugInfo: true, // 👈 디버그 정보 표시
    );
  }
}

/// 완전한 사용 예제
/// 
/// 실제 앱에서 질문 작성 → 투표 알림 → 결과 표시 전체 플로우
class CompleteVotingFlowExample extends StatefulWidget {
  const CompleteVotingFlowExample({Key? key}) : super(key: key);

  @override
  State<CompleteVotingFlowExample> createState() => _CompleteVotingFlowExampleState();
}

class _CompleteVotingFlowExampleState extends State<CompleteVotingFlowExample> {
  VersusBoxSizeData? _capturedSizeData;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('투표 시스템 예제'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 사이즈 데이터 캡처 시뮬레이션
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. 질문 작성 페이지 시뮬레이션',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('질문 작성 완료 시 사이즈 데이터가 캡처됩니다.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _capturedSizeData = VotingSystemExample.createSampleSizeData(context);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ 사이즈 데이터 캡처 완료!')),
                        );
                      },
                      child: const Text('사이즈 데이터 캡처'),
                    ),
                    if (_capturedSizeData != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '캡처된 데이터: ${_capturedSizeData!.layoutType}, '
                        'A: ${_capturedSizeData!.originalSizeA.width.toInt()}x${_capturedSizeData!.originalSizeA.height.toInt()}, '
                        'B: ${_capturedSizeData!.originalSizeB.width.toInt()}x${_capturedSizeData!.originalSizeB.height.toInt()}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 2. 투표 알림 테스트
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. 투표 알림 테스트',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('캡처된 사이즈 데이터로 일관된 크기의 투표 알림이 표시됩니다.'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _capturedSizeData != null ? () {
                              VotingSystemExample.showVotingWithSizeData(
                                context,
                                _capturedSizeData!,
                                question: '🎯 어떤 옵션이 더 좋나요?',
                                optionA: '옵션 A',
                                optionB: '옵션 B',
                                imageUrlA: 'https://picsum.photos/300/200',
                                imageUrlB: 'https://picsum.photos/200/300',
                              );
                            } : null,
                            child: const Text('사이즈 바인딩 투표'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              VotingSystemExample.showVotingWithoutSizeData(
                                context,
                                question: '📏 기본 크기로 표시되는 투표',
                                optionA: '옵션 A',
                                optionB: '옵션 B',
                                imageUrlA: 'https://picsum.photos/300/200',
                                imageUrlB: 'https://picsum.photos/200/300',
                              );
                            },
                            child: const Text('기본 크기 투표'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 3. 투표 결과 테스트
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3. 투표 결과 표시',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('투표 완료 후 결과를 동일한 크기로 표시합니다.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _capturedSizeData != null ? () {
                        VotingSystemExample.showVotingResults(
                          context,
                          _capturedSizeData!,
                          question: '투표 결과',
                          optionA: '옵션 A',
                          optionB: '옵션 B',
                          imageUrlA: 'https://picsum.photos/300/200',
                          imageUrlB: 'https://picsum.photos/200/300',
                          votePercentageA: 0.65,
                          votePercentageB: 0.35,
                          voteCountA: 13,
                          voteCountB: 7,
                        );
                      } : null,
                      child: const Text('투표 결과 표시'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 4. 디버그 테스트
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. 디버그 모드',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('개발 시 크기 정보를 확인할 수 있는 디버그 모드입니다.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        VotingSystemExample.showDebugVoting(context);
                      },
                      child: const Text('디버그 투표 테스트'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}