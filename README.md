# Alfred Habit Tracker (v1.2)

Alfred 1.2 is a modern, beautifully designed habit tracker app built with Flutter and powered by Supabase for persistent storage and user authentication.

## ✨ Features
- 🔐 **User Authentication** - Secure sign up, sign in, and password reset
- 👤 **Personal Habit Lists** - Each user has their own private habits
- ➕ **Smart Habit Input** - Clean floating action button with expandable input field
- 📋 **Organized Habit Management** - Habits automatically sorted by streak count (highest first)
- ✅ **Daily Check-ins** - Check or uncheck habits for the current day
- 🔥 **Streak Tracking** - Real-time streak counting with fire emoji indicators
- 📊 **Top 4 Dashboard** - Beautiful grid displaying your best performing habits
- 🎨 **Modern UI Design** - Warm color palette with teal accents and cream backgrounds
- 💾 **Persistent Storage** - All data saved securely with Supabase
- 🔄 **Real-time Updates** - Instant synchronization across devices
- 🚫 **Error Handling** - Graceful error states and loading indicators
- 🔄 **Pull to Refresh** - Easy data refresh functionality

## 🎨 Design Features
- **Warm Color Palette** - Cream backgrounds (#FAF9F5) with teal accents (#2A9D8F)
- **Streak Dashboard** - Top 4 habits displayed in an elegant 2x2 grid
- **Visual Hierarchy** - Large streak numbers, fire emojis, and readable habit names
- **Responsive Layout** - Optimized for mobile devices with proper spacing
- **Smart Sorting** - Habits automatically ordered by performance
- **Clean Interface** - Minimal floating action button that expands when needed

## 🏗️ Architecture
The app follows a clean, organized structure:

```
lib/
├── main.dart                       # App entry point with theme configuration
├── config/
│   └── app_config.dart            # App configuration and constants
├── models/
│   ├── habit.dart                 # Core habit data model
│   └── user_profile.dart          # User profile management
├── services/
│   ├── auth_service.dart          # Authentication operations
│   ├── habit_service.dart         # Habit CRUD operations
│   ├── streak_service.dart        # Advanced streak logic and calculations
│   └── user_profile_service.dart  # User profile management
├── screens/
│   ├── auth_screen.dart           # Beautiful sign in/sign up interface
│   └── habit_tracker_screen.dart  # Main app with streak dashboard
├── widgets/
│   └── streak_dashboard.dart      # Reusable top 4 habits display
└── utils/
    └── date_utils.dart           # Date handling utilities
```

## 🛠️ Technology Stack
- **Frontend:** Flutter (Dart) with Material Design
- **Backend:** Supabase (PostgreSQL + Auth + Real-time)
- **Database:** PostgreSQL with Row Level Security
- **Authentication:** Supabase Auth with email/password
- **State Management:** StatefulWidget with async operations
- **UI/UX:** Custom theme with warm color palette and modern design

## 🚀 How it Works
1. **Secure Authentication** - Users sign up/sign in to access personal habits
2. **Smart Habit Management** - Add habits via floating action button with auto-capitalization
3. **Streak Dashboard** - Top 4 performing habits displayed prominently with fire emojis
4. **Automatic Sorting** - Habits reorder by streak count in real-time
5. **Daily Check-ins** - Simple tap to check/uncheck habits for the day
6. **Real-time Sync** - All changes synchronized instantly across devices
7. **Persistent Streaks** - Streak data maintained across app sessions

## 📱 Getting Started

### Prerequisites
- [Flutter](https://docs.flutter.dev/get-started/install) (latest stable version)
- [Supabase](https://supabase.com) account and project
- Android Studio or VS Code with Flutter extensions

### Setup Instructions

1. **Clone and install dependencies:**
   ```bash
   git clone <repository-url>
   cd alfred
   flutter pub get
   ```

2. **Database Setup:**
   ```bash
   # Run the migration script in your Supabase SQL Editor
   # File: supabase_v1.2_migration.sql
   ```

3. **Configure Environment:**
   ```bash
   # Create .env file with your Supabase credentials
   cp .env.example .env
   
   # Edit .env with your actual values:
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Development Commands
```bash
# Run tests
flutter test

# Run on specific device
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS

# Build for production
flutter build apk      # Android APK
flutter build ios      # iOS
flutter build web      # Web
```

## 🗄️ Database Schema

### Habits Table
```sql
CREATE TABLE habits (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  streak INTEGER DEFAULT 0,
  checked_today BOOLEAN DEFAULT false,
  last_checked_date TIMESTAMPTZ,
  user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Security Policies
- **Row Level Security (RLS)** enabled
- Users can only access their own habits
- Automatic user_id assignment on insert
- Secure session management

## 🔒 Security & Privacy
- **Environment Variables** - All API keys stored securely in `.env`
- **Row Level Security** - Database-level user isolation
- **Authentication Required** - All operations require valid session
- **No Data Leakage** - Users cannot see other users' habits
- **Secure Headers** - Proper CORS and security headers
- **Input Validation** - Client and server-side validation

## 🎯 Version History

### v1.2 (Current) - "Beautiful Design"
- ✅ Modern UI with warm color palette
- ✅ Streak dashboard with top 4 habits display
- ✅ Smart floating action button interface
- ✅ Automatic habit sorting by streak count
- ✅ Fire emoji streak indicators
- ✅ Enhanced visual hierarchy and spacing
- ✅ Improved user experience and accessibility

### v1.1 - "User Authentication"
- ✅ User authentication and personal habit lists
- ✅ Row Level Security implementation
- ✅ User profile management

### v1.0 - "Core Features"
- ✅ Basic habit tracking and streaks
- ✅ Persistent storage with Supabase
- ✅ Real-time synchronization

## 🚧 Roadmap

### v1.3 - "Analytics & Insights" (Next)
- 📊 Habit performance analytics
- 📈 Streak history and trends
- 🏆 Achievement system and milestones
- 📅 Calendar view of habit completion

### v1.4 - "Smart Features"
- 🔔 Push notifications and reminders
- 📱 Offline support and sync
- 🌙 Dark mode theme
- 🎯 Habit categories and tags

### v2.0 - "AI-Powered"
- 🤖 AI habit recommendations
- 📈 Predictive analytics
- 🎯 Personalized insights
- 🔄 Automated habit suggestions

---

**Alfred** is building towards a fully autonomous personal agent, one feature at a time. This habit tracker is the foundation for understanding user patterns and providing intelligent life management.

## 🤝 Contributing
Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## 📄 License
This project is part of the Alfred autonomous agent development initiative.
