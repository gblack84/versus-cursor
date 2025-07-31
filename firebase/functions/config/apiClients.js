/**
 * 외부 API 클라이언트 초기화
 * Vision API, Gemini AI 등의 클라이언트 설정
 */

const functions = require("firebase-functions");
const vision = require("@google-cloud/vision");
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");

// Vision API 클라이언트
const visionClient = new vision.ImageAnnotatorClient();

// API 키 설정
const PERSPECTIVE_API_KEY = process.env.PERSPECTIVE_API_KEY || functions.config().perspective?.api_key;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || functions.config().gemini?.api_key;

// Gemini AI 모델 초기화 (LangChain)
let geminiModel = null;
if (GEMINI_API_KEY) {
  geminiModel = new ChatGoogleGenerativeAI({
    apiKey: GEMINI_API_KEY,
    modelName: "gemini-pro",
    temperature: 0.3,
    maxOutputTokens: 1000,
  });
}

// API URLs
const PERSPECTIVE_API_URL = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

module.exports = {
  visionClient,
  geminiModel,
  PERSPECTIVE_API_KEY,
  GEMINI_API_KEY,
  PERSPECTIVE_API_URL
};