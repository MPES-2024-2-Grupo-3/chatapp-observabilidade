import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class AIService {
  static final FirebaseVertexAI _vertexInstance = FirebaseVertexAI.instanceFor(auth: FirebaseAuth.instance);
  static final generativeModel = _vertexInstance.generativeModel(model: 'gemini-2.0-flash');

  static Future<String> analyzeEmotion(String text) async {

    final prompt = [Content.text('Analyze the emotion of the following text and return a single-word classification: Happy, Sad, Angry, Fearful, Surprised, Neutral. Text: "$text"')];
    final response = await generativeModel.generateContent(prompt);
    return response.text ?? "Unknown";
  }
}