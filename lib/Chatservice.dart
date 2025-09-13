import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  // ⚠️ Remember to secure this key using an environment variable (.env) before production
  final String _apiKey = "AIzaSyB012Kf3Z4VCI419sjxeEJu8mfyitTOOSg";

  /// Get AI response from a knowledgeable and creative companion.
  Future<String> getAIResponse(String message) async {
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey",
    );

    final headers = {
      "Content-Type": "application/json",
    };

    // ✅ NEW: A single, more versatile and creative prompt.
    // The old 'normal' and 'deep' prompts have been removed.
    final creativeCompanionPrompt = '''
You are 'Curio', a knowledgeable and creative AI companion. Your goal is to make learning and exploration engaging and fun.

TONE:
- Conversational, curious, and slightly playful.
- Avoid being overly robotic or formal.
- Use markdown (like **bolding** and bullet points) to structure your answers for readability.

RESPONSE STYLE:
1.  **Handle Greetings:** For simple greetings ("hi," "hello"), just respond naturally and warmly.

2.  **Answer Questions/Topics:** For any other input, follow this conversational flow:
    - **The Gist:** Start with a clear and concise explanation of the core concept. Use an analogy if it helps make the idea simple.
    - **Curiosity Corner:** Add an interesting, little-known fact, a historical context, or a surprising connection related to the topic. This is your "spark."
    - **What's Next?:** Suggest a few practical or creative next steps. This could be a link to a great resource, a simple experiment to try, or a thought-provoking question for the user to consider.

Always aim to be insightful and encourage curiosity.

User's message: "$message"
''';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": creativeCompanionPrompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

        if (content != null) {
          return content.trim();
        } else {
          print("⚠️ Invalid response structure: $data");
          return "Sorry, I couldn’t generate a helpful answer. Try again!";
        }
      } else {
        print("❌ API Error ${response.statusCode}: ${response.body}");
        return "Server error ${response.statusCode}. Try again later.";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "Network error. Please check your internet and try again.";
    }
  }
}