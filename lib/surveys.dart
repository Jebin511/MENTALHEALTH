import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SurveyDialog extends StatefulWidget {
  const SurveyDialog({super.key});

  @override
  State<SurveyDialog> createState() => _SurveyDialogState();
}

class _SurveyDialogState extends State<SurveyDialog> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  int _totalScore = 0;

  final Map<String, int?> _answers = {
    'q1_nervous': null, 'q2_control_worry': null, 'q3_worry_toomuch': null,
    'q4_trouble_relaxing': null, 'q5_restless': null, 'q6_annoyed': null, 'q7_afraid': null,
  };

  final _questionKeys = [
    'q1_nervous', 'q2_control_worry', 'q3_worry_toomuch', 'q4_trouble_relaxing',
    'q5_restless', 'q6_annoyed', 'q7_afraid'
  ];

  final _questions = {
    'q1_nervous': 'Feeling nervous, anxious, or on edge?', 'q2_control_worry': 'Not being able to stop or control worrying?',
    'q3_worry_toomuch': 'Worrying too much about different things?', 'q4_trouble_relaxing': 'Having trouble relaxing?',
    'q5_restless': 'Being so restless that it is hard to sit still?', 'q6_annoyed': 'Becoming easily annoyed or irritable?',
    'q7_afraid': 'Feeling afraid, as if something awful might happen?',
  };

  final _options = [
    {'text': 'Not at all', 'score': 0}, {'text': 'Several days', 'score': 1},
    {'text': 'More than half the days', 'score': 2}, {'text': 'Nearly every day', 'score': 3},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submitSurvey() async {
    setState(() => _isLoading = true);
    _totalScore = _answers.values.fold(0, (sum, item) => sum + (item ?? 0));
    final surveyData = Map<String, dynamic>.from(_answers);
    surveyData['user_id'] = Supabase.instance.client.auth.currentUser!.id;
    surveyData['total_score'] = _totalScore;

    try {
      await Supabase.instance.client.from('gad7_surveys').insert(surveyData);
      if (mounted) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToNextPage() {
    // Page 0 is welcome, questions start at page 1.
    // The question key index is therefore _currentPage - 1.
    final currentQuestionKey = _questionKeys[_currentPage - 1];
    if (_answers[currentQuestionKey] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option.')),
      );
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.purple[300]),
          const SizedBox(height: 24),
          const Text(
            'Welcome!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s start with a quick check-in to understand your current state of well-being. This will only take a moment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPage() {
    String resultText;
    String emoji;
    if (_totalScore <= 4) {
      resultText = "Your results indicate minimal anxiety. That's great! Keep up with healthy habits.";
      emoji = '😊';
    } else if (_totalScore <= 9) {
      resultText = "Your results indicate mild anxiety. Consider exploring some of our mindfulness exercises.";
      emoji = '🙂';
    } else if (_totalScore <= 14) {
      resultText = "Your results indicate moderate anxiety. It might be helpful to connect with one of our counselors.";
      emoji = '😐';
    } else {
      resultText = "Your results indicate severe anxiety. We strongly recommend speaking with a counselor soon.";
      emoji = '😟';
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text('Thank You!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 16),
          Text(
            resultText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _questionKeys.length + 2;
    final isLastQuestionPage = _currentPage == _questionKeys.length;

    return Dialog(
      backgroundColor: const Color(0xFFF3E5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: 500,
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_currentPage > 0 && _currentPage < totalPages - 1)
                LinearProgressIndicator(
                  value: (_currentPage) / _questionKeys.length,
                  backgroundColor: Colors.purple[100],
                  color: const Color(0xFF957DAD),
                ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: totalPages,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildWelcomePage();
                    if (index == totalPages - 1) return _buildResultsPage();
                    final questionKey = _questionKeys[index - 1];
                    return SurveyPageContent(
                      question: _questions[questionKey]!,
                      options: _options,
                      groupValue: _answers[questionKey],
                      onChanged: (value) {
                        setState(() => _answers[questionKey] = value);
                        if (!isLastQuestionPage) {
                          Future.delayed(const Duration(milliseconds: 400), _goToNextPage);
                        }
                      },
                    );
                  },
                ),
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  // --- THE FIX IS HERE ---
                  onPressed: () {
                    if (_currentPage == 0) { // On the Welcome page
                      // Directly animate to the next page without validation
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else if (isLastQuestionPage) { // On the Last question page
                      _submitSurvey();
                    } else if (_currentPage == totalPages - 1) { // On the Results page
                      Navigator.pop(context);
                    } else { // In the middle of the questions
                      _goToNextPage();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF957DAD),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: Text(
                    _currentPage == 0
                        ? 'Begin'
                        : (_currentPage == totalPages - 1
                            ? 'Done'
                            : (isLastQuestionPage ? 'See Results' : 'Next')),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyPageContent extends StatelessWidget {
  final String question;
  final List<Map<String, Object>> options;
  final int? groupValue;
  final ValueChanged<int?> onChanged;

  const SurveyPageContent({
    super.key,
    required this.question,
    required this.options,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Over the last two weeks, how often have you been bothered by:",
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A148C)),
          ),
          const SizedBox(height: 16),
          ...options.map((option) => RadioListTile<int>(
                title: Text(option['text'] as String),
                value: option['score'] as int,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF6A1B9A),
                contentPadding: EdgeInsets.zero,
              )),
        ],
      ),
    );
  }
}