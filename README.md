# News App 
A simple, clean Flutter application for reading the latest news articles.

## Features

- **Clean UI**: Simple and easy-to-use interface
- **Latest News**: Fetches trending news from various sources
- **Detail View**: Read full articles with a clean reading experience
- **External Links**: Open original sources in your browser

## Getting Started

### Prerequisites

- Flutter (2.0 or later)
- Dart (2.12 or later)
- Android Studio / VS Code

### Installation

1. Clone this repository:
   ```
   git clone https://github.com/codemhax/news_app.git
   ```

2. Navigate to the project directory:
   ```
   cd news_app
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## Dependencies

- [connectivity_plus](https://pub.dev/packages/connectivity_plus): For checking internet connectivity
- [fluttertoast](https://pub.dev/packages/fluttertoast): For displaying toast messages
- [permission_handler](https://pub.dev/packages/permission_handler): For handling permissions
- [url_launcher](https://pub.dev/packages/url_launcher): For launching URLs in browser

## Project Structure

```
lib/
├── main.dart                # App entry point and main screen
├── Ferc/
│   └── get_news.dart        # News API integration
└── screen/
    └── detail_news.dart     # News detail screen
```

## Usage

- **Browse News**: Scroll through the list of trending news articles on the main screen
- **Read Article**: Tap on any article to view its full content
- **Open Source**: In the detail view, tap "Read full article" to open the original source in your browser
- **Refresh News**: Pull down to refresh or tap the refresh button in the app bar to get the latest news

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- News data provided by [News API](https://github.com/CodemHax/InShort-News-Api)
- Icons made by [Freepik](https://www.flaticon.com/authors/freepik) from [Flaticon](https://www.flaticon.com/)

---

Made with ❤️ using Flutter
