# HabitVerse - Gamified Habit Tracker

HabitVerse adalah aplikasi Flutter yang membantu pengguna membentuk kebiasaan positif melalui gamifikasi. Setiap kebiasaan yang diselesaikan akan membuat karakter virtual mereka tumbuh dan berkembang.

## 🎯 Fitur Utama

### 🎮 Gamifikasi
- Karakter virtual berkembang berdasarkan konsistensi kebiasaan
- XP & level up system
- Badge, streak, dan reward
- Animasi dan feedback visual

### ✅ Kebiasaan Harian
- Tambah / ubah / hapus kebiasaan
- Checklist harian (habit tracker)
- Kategori kebiasaan (Health, Fitness, Learning, dll.)
- Reminder harian dengan notifikasi

### 📊 Statistik Progres
- Streak hari berturut-turut
- Kalender progres
- Grafik XP & level
- Analisis completion rate

### 👥 Komunitas (Coming Soon)
- Tambah teman
- Lihat kebiasaan publik mereka
- Leaderboard XP mingguan

### 🔐 Autentikasi
- Register / Login dengan JWT
- Secure storage untuk token
- Profile management

## 🛠️ Tech Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences + Secure Storage
- **Notifications**: Flutter Local Notifications
- **Charts**: FL Chart
- **Calendar**: Table Calendar
- **Animations**: Lottie

### Backend (Coming Soon)
- **Framework**: Hapi.js
- **Database**: MySQL
- **Authentication**: JWT
- **Validation**: Joi
- **ORM**: Knex.js

## 🚀 Cara Menjalankan

### Prerequisites
- Flutter SDK (3.6.0 atau lebih baru)
- Dart SDK
- Android Studio / VS Code
- Chrome browser (untuk web)

### Instalasi

1. Clone repository
```bash
git clone <repository-url>
cd habitverse
```

2. Install dependencies
```bash
flutter pub get
```

3. Jalankan aplikasi
```bash
# Untuk web
flutter run -d chrome

# Untuk Windows
flutter run -d windows

# Untuk Android (dengan emulator)
flutter run -d android

# Untuk iOS (dengan simulator)
flutter run -d ios
```
