# Alfred Habit Tracker (v1.1)

Alfred 1.1 is a modern habit tracker app built with Flutter and powered by Supabase for persistent storage and user authentication.

## Features
- ✅ **User Authentication** - Secure sign up, sign in, and password reset
- ✅ **Personal Habit Lists** - Each user has their own private habits
- ✅ Add new habits by name
- ✅ View a list of all habits with persistent storage
- ✅ Check or uncheck (undo) a habit for the present day
- ✅ Real-time streak tracking (increments when checked, decrements when unchecked, never below zero)
- ✅ Interactive streak dashboard showing all habits and their current streaks
- ✅ Modern, colorful UI with smooth animations
- ✅ Persistent data storage with Supabase
- ✅ Error handling and loading states
- ✅ Refresh functionality
- ✅ User profile management and sign out

## Architecture
The app follows a clean, organized structure:

```
lib/
├── main.dart                    # App entry point and auth wrapper
├── models/
│   └── habit.dart              # Habit data model with user support
├── services/
│   ├── auth_service.dart       # Authentication operations
│   └── habit_service.dart      # Database operations (user-scoped)
├── screens/
│   ├── auth_screen.dart        # Sign in/Sign up screen
│   └── habit_tracker_screen.dart  # Main app screen
└── widgets/
    └── streak_dashboard.dart   # Reusable dashboard widget
```

## Technology Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL + Auth)
- **Database:** Real-time synchronization with Row Level Security
- **Authentication:** Supabase Auth with email/password
- **State Management:** StatefulWidget with async operations and StreamBuilder

## How it Works
- Users must sign up/sign in to access their habits
- All habits are stored in a Supabase PostgreSQL database with user isolation
- Row Level Security ensures users can only see their own data
- Real-time updates when habits are added, modified, or deleted
- Streaks are tracked persistently across app sessions
- Automatic timestamps for creation and updates
- Secure session management with automatic refresh

## Getting Started

### Prerequisites
1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Create a [Supabase](https://supabase.com) account and project

### Setup
1. **Clone and setup dependencies:**
   ```bash
   flutter pub get
   ```

2. **Initial database setup:**
   - Go to your Supabase project dashboard
   - Navigate to SQL Editor
   - Run the SQL script from the original setup (create tables, etc.)

3. **Enable authentication:**
   - In Supabase dashboard, go to Authentication → Settings
   - Configure your app's URL settings
   - Run the `supabase_auth_update.sql` script to add user authentication to habits table

4. **Configure Supabase:**
   - Get your project URL and anon key from Supabase dashboard
   - Copy `.env.example` to `.env`:
     ```bash
     cp .env.example .env
     ```
   - Edit `.env` and replace with your actual credentials:
     ```
     SUPABASE_URL=your_actual_supabase_url
     SUPABASE_ANON_KEY=your_actual_anon_key
     ```

5. **Run the app:**
   ```bash
   flutter run
   ```

### Testing
Run the test suite:
```bash
flutter test
```

## Database Schema
The app uses a `habits` table with user authentication:
- `id` - Auto-incrementing primary key
- `name` - Habit name (text)
- `streak` - Current streak count (integer)
- `checked_today` - Whether checked today (boolean)
- `user_id` - User ID (UUID, foreign key to auth.users)
- `created_at` - Creation timestamp
- `updated_at` - Last modification timestamp

## Security
- **Environment Variables** - API keys stored in `.env` file (excluded from git)
- **Row Level Security (RLS)** - Users can only access their own habits
- **Authentication Required** - All operations require valid user session
- **Secure Session Management** - Automatic token refresh and logout
- **Input Validation** - Email and password validation on client and server
- **No Hardcoded Secrets** - Credentials loaded from environment variables

### Important Security Notes:
- **Never commit `.env` to version control**
- The `.env` file is automatically ignored by git
- Use `.env.example` as a template for other developers
- Supabase anon key is safe to use client-side (designed for public access)
- Always use Row Level Security policies in production

## Roadmap
- **v1.0:** ✅ Habit tracking, streaks, persistent storage, modern UI
- **v1.1:** ✅ User authentication and personal habit lists
- **v1.2:** 📊 Analytics, habit history, and streak statistics
- **v1.3:** 🔔 Push notifications and reminders
- **v1.4:** 📱 Mobile app optimizations and offline support
- **v2.0:** 🤖 AI-powered habit recommendations and insights

---
Alfred is an iterative project building towards a fully autonomous personal agent. Stay tuned for more features!
