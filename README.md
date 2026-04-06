# Finance Manager / Expense Tracker

A clean, modern fintech-style mobile application built with Flutter to help users track their income and expenses.

## Features
- **Transactions:** Add income and expenses dynamically with categories, amount, note, and date. Use intuitive swiping gestures to delete transactions.
- **Monthly Summary:** View beautiful, animated pie charts of your overall spending breakdown along with your total balance.
- **Visuals & Aesthetics:** Equipped with a sleek dark / light mode toggle. Vibrant fintech gradients to emphasize your financial statistics.
- **Local Storage:** Everything is neatly stored locally on your device ensuring ultimate privacy and no dependency on internet connection. 

## Tech Stack
- **Framework:** Flutter
- **State Management:** Riverpod (`flutter_riverpod`)
- **Local Database:** `shared_preferences`
- **Charts:** `fl_chart`
- **Typography:** `google_fonts`

## Setup Instructions

### Prerequisites
- Flutter SDK installed (3.x.x recommended)
- Android Studio or Xcode for emulator/simulator support

### Installation
1. Clone the repository: `git clone <your-repo-link>`
2. Navigate into your project directory: `cd expense_tracker`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`

## Building APK
To generate a release APK of this finance manager, run the following command in the project root:
```bash
flutter build apk --release
```
The APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.
