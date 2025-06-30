# Favorite Habits Feature

## Overview

Fitur Favorite Habits memungkinkan pengguna untuk menandai habit tertentu sebagai favorit dan melihat semua habit favorit dalam halaman terpisah.

## Features Implemented

### 1. Model Updates

- Menambahkan field `isFavorite` (boolean) ke `HabitModel`
- Field ini disimpan di database (Supabase) dan local storage (Hive)
- Default value adalah `false` untuk habit baru

### 2. UI Components

- **Favorite Icon**: Tombol heart di setiap habit item
  - Empty heart (♡) untuk habit yang belum difavoritkan
  - Filled heart (♥) dengan warna pink untuk habit favorit
- **Favorite Habits Page**: Halaman terpisah yang menampilkan semua habit favorit

### 3. Navigation

- Menambahkan menu "Favorites" di sidebar navigation
- Route `/favorites` menuju ke halaman favorite habits
- Index 5 di sidebar untuk navigasi

### 4. Controller Methods

- `toggleFavorite(String habitId)`: Toggle status favorit habit
- `favoriteHabits`: Getter untuk mendapatkan semua habit favorit
- Update method `updateHabit` untuk menangani perubahan field isFavorite

### 5. Repository Updates

- Field `isFavorite` ditambahkan di method `createHabit`
- Default value `false` untuk habit baru
- Support untuk update field isFavorite melalui Supabase

## File Changes

### New Files

- `lib/presentation/pages/favorite_habits_screen.dart`

### Modified Files

- `lib/data/models/habit_model.dart` - Added isFavorite field
- `lib/data/models/habit_model.g.dart` - Regenerated Hive adapter
- `lib/presentation/controllers/habit_controller.dart` - Added favorite methods
- `lib/presentation/widgets/home/habit_item.dart` - Added favorite button
- `lib/presentation/widgets/home/habit_list.dart` - Added favorite toggle callback
- `lib/presentation/widgets/sidebar_navigation.dart` - Added favorites menu
- `lib/presentation/services/navigation_service.dart` - Added favorites route
- `lib/data/repositories/habit_repository.dart` - Updated createHabit method
- `lib/main.dart` - Added favorites route and import

## How to Use

### For Users

1. **Mark as Favorite**: Klik icon heart di setiap habit untuk menandai sebagai favorit
2. **View Favorites**: Klik menu "Favorites" di sidebar untuk melihat semua habit favorit
3. **Unmark Favorite**: Klik icon heart yang sudah terisi untuk menghapus dari favorit

### For Developers

1. **Toggle Favorite**:

   ```dart
   await habitController.toggleFavorite(habitId);
   ```

2. **Get Favorite Habits**:

   ```dart
   List<HabitModel> favorites = habitController.favoriteHabits;
   ```

3. **Check if Habit is Favorite**:
   ```dart
   bool isFavorite = habit.isFavorite;
   ```

## Database Schema

Field `is_favorite` (boolean) ditambahkan ke tabel `habit` di Supabase dengan default value `false`.

## UI/UX Considerations

- Icon favorite menggunakan warna pink (#E91E63) untuk konsistensi visual
- Halaman favorites menampilkan empty state ketika belum ada habit favorit
- Jumlah habit favorit ditampilkan di halaman favorites
- Responsif design untuk desktop dan mobile

## Future Enhancements

- Sort favorite habits by priority atau last completion
- Add favorite habits to quick access widget
- Notification untuk reminder favorite habits
- Export/import favorite habits
