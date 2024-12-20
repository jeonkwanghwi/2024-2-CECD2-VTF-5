import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/question.dart';
import '../services/recording_service.dart';
import './recordingServiceProvider.dart';

final questionProvider = StateNotifierProvider<QuestionNotifier, QuestionModel?>(
  (ref) {
    print("questionProvider 초기화됨");
    return QuestionNotifier(ref)..fetchInitialData();
  },
);

class QuestionNotifier extends StateNotifier<QuestionModel?> {
  final Ref ref;


  QuestionNotifier(this.ref) : super(null){
    print("QuestionNotifier 초기화됨");
  }

  int? _selectedIndex;
  int? get selectedIndex => _selectedIndex;

  Future<void> fetchInitialData() async {
    print("fetchInitialData() 호출됨"); // 초기화 로그
    print("State in Provider: ${state?.questions}"); // 상태 업데이트 로그
    try {
      // recordingService를 사용해 서버에서 데이터 가져오기
      final recordingService = ref.read(recordingServiceProvider);
      print("reSP");
      final questionModel = await recordingService.sendResponsesToServer();
      print("sRTS");

      // 상태 업데이트
      state = questionModel;
      print("Updated State in Provider: ${state?.questions}");
    } catch (e) {
      // 오류 발생 시 기본 데이터 설정
      //state = QuestionModel(questions: ["서버 데이터를 불러올 수 없습니다."]);
      state=null;
      print("Error fetching questions: $e");
    }
  }

  void selectQuestion(int index) {
    _selectedIndex = index;
    print('실행됨');
  }

  String? getSelectedQuestion() {
    if (state == null || _selectedIndex == null) return null;
    return getQuestion(_selectedIndex!);
  }

  String getQuestion(int index) {
    if (state == null || index < 0 || index >= state!.questions.length) {
      return "질문이 없습니다.";
    }
    return state!.questions[index];
  }

  void resetState() {
    _selectedIndex = null; // 선택된 질문 초기화
    state = null; // 상태를 초기화
    print("Question state has been reset.");
  }
}
