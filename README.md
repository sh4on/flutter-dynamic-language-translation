# Flutter Dynamic Language Translation

A Flutter application that demonstrates how to implement **real-time, batched language translation** for dynamic content (e.g., API responses) using Google Translate API and GetX.

## Features

*   **Dynamic Translation**: Automatically translates text from API responses (Product titles, descriptions, reviews, etc.).
*   **Smart Batching**: Uses a queue and debounce timer (100ms) to bundle multiple translation requests into a **single HTTP call**, saving API quota and improving performance.
*   **Reactive State Management**: Powered by **GetX** for seamless state updates across the app.
*   **Custom Widget**: `AutoTranslatedText` widget that can be used as a drop-in replacement for the standard `Text` widget.
*   **Language Persistence**: Easily scalable `LanguageController` that broadcasts language changes globally.

## How It Works

The project uses a **reactive, batched translation system** to handle dynamic language changes efficiently. Here is the step-by-step flow of what happens when you change the language:

### 1. User Changes Language
The user selects a new language (e.g., 'Spanish' / `es`) from the dropdown in the UI.

```dart
// my_home_page.dart
onChanged: (value) {
  if (value != null) {
    controller.changeLanguage(value);
  }
},
```

### 2. Controller Updates State
The `LanguageController` updates its observable `currentLanguage` variable.

```dart
// language_controller.dart
void changeLanguage(String lang) {
  currentLanguage.value = lang; // e.g., becomes 'es'
}
```

### 3. Widgets React Instantly
Every `AutoTranslatedText` widget on the screen is listening to the controller. When the language changes, they all "wake up" and request a translation for their specific text.

```dart
// auto_translated_text.dart
_langWorker = ever(_controller.currentLanguage, (String lang) {
  _updateTranslation(lang);
});
```

### 4. Service Batches Requests (The "Magic" Part)
Instead of sending 20 separate HTTP requests for 20 text widgets (which would be slow and costly), the `TranslationService` queues them.

1.  **Queueing**: Each widget calls `translate("Text", "es")`.
2.  **Debouncing**: The service waits for **100ms**.
3.  **Batching**: After 100ms, it takes all the text strings that requested translation and bundles them into **one single API call**.

```dart
// translation_service.dart
body: jsonEncode({
  'q': texts, // ["Title", "Description", "Brand", ...]
  'target': targetLanguage, // "es"
}),
```

### 5. API Returns Translations
Google Translate returns the list of translated strings in the same order.

### 6. UI Updates
The `TranslationService` distributes the translated strings back to the correct widgets. Each `AutoTranslatedText` updates its local state, causing the UI to update instantly.

## Architecture

*   **`LanguageController` (GetX)**: Manages the global selected language state.
*   **`TranslationService`**: Singleton service that handles API calls, queuing, and batching.
*   **`AutoTranslatedText`**: A smart widget that replaces `Text`. It handles the logic of listening to language changes and displaying the translated result.

## Setup

1.  Clone the repository.
2.  Create a `.env` file in the root directory and add your Google Cloud Translation API key:
    ```
    API_KEY=your_api_key_here
    ```
3.  Run `flutter pub get`.
4.  Run the app: `flutter run`.
