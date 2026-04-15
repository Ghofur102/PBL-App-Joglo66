# Flutter API Integration Guide untuk Copilot AI

## 📋 Konteks Awal
- Anda telah pull dari `branch main`
- Backend Laravel API sudah working (dashboard, list-field, list-booking endpoints)
- Database sudah seeded dengan data test
- Sanctum authentication sudah di-setup
- Anda berada di folder workspace: `E:\zami\pbl\app\PBL-App-Joglo66` (Flutter app)

## 🎯 Tujuan Integration
Mengintegrasikan 3 screens Flutter dengan API Laravel:
1. **Dashboard Admin Screen** - Tampilkan dashboard stats dari API
2. **List Booking Screen** - Tampilkan daftar booking dari API
3. **List Field Screen** - Tampilkan daftar lapangan dari API

## 📝 Langkah-Langkah yang Perlu Dikerjakan

### STEP 1: Create Dashboard Service
**Lokasi**: `lib/services/dashboard_service.dart`

**Yang perlu dibuat:**
- Static class `DashboardService` dengan 3 methods:
  1. `fetchDashboardData()` - GET `/api/admin/dashboard`, return Map dengan keys: name, slotTerisi, totalSlot, slotKosong, totalBooking
  2. `fetchFields()` - GET `/api/admin/list-field`, return List<Map> dengan field bookings
  3. `fetchBookings()` - GET `/api/admin/list-booking`, return Map dengan keys: 'today' dan 'upcoming'

**Detail Implementation:**
- Gunakan `flutter_dotenv` untuk ambil `API_BASE_URL` dan `API_TOKEN` dari `.env`
- Semua request pakai Bearer token authorization
- Handle timeout dengan 10 seconds
- Add logging dengan `print()`
- Proper error handling dengan try-catch dan rethrow

---

### STEP 2: Update Dashboard Admin Screen
**Lokasi**: `lib/screens/admin/dashboard_admin_screens.dart`

**Yang perlu diubah:**
- Convert dari StatelessWidget ke StatefulWidget
- Add state variables: `dashboardData`, `isLoading`, `errorMessage`
- Implement `initState()` yang call `_loadDashboardData()`
- Implement `_loadDashboardData()` method yang:
  - Call `DashboardService.fetchDashboardData()`
  - Update state dengan loading/error/success
  - Set default data jika error
- Update build() untuk tampilkan:
  - Loading indicator saat fetch
  - Error message dengan "Coba Lagi" button jika error
  - Data dinamis dari API (bukan hardcoded)

**UI Components yang sudah ada:**
- `HeaderSection` - untuk display dashboard stats
- `MenuGrid` - untuk menu items
- `HeaderOne` - untuk titles

---

### STEP 3: Update List Booking Screen
**Lokasi**: `lib/screens/admin/booking_field/list_booking_admin_screens.dart`

**Yang perlu diubah:**
- Convert ke StatefulWidget
- Add state: `todayBookings`, `upcomingBookings`, `isLoading`, `errorMessage`
- Implement `_loadBookingData()` yang call `DashboardService.fetchBookings()`
- Split response data ke `today` dan `upcoming` arrays
- Render menggunakan **CardsBooking component** (sudah ada di components)
- CardsBooking expect: `Map<String, String>` dengan keys: date, month, year, title, time, description
- Convert API response ke format yang dibutuhkan CardsBooking
- Add loading state, error handling, empty state

**Important:**
- Gunakan component yang sudah ada (`CardsBooking`, `HeaderOne`)
- Convert dynamic values to String dengan null-safe: `?.toString() ?? ''`

---

### STEP 4: Update List Field Screen
**Lokasi**: `lib/screens/admin/field/list_field_admin_screens.dart`

**Yang perlu diubah:**
- Convert ke StatefulWidget
- Add state: `todayFields`, `upcomingFields`, `isLoading`, `errorMessage`
- Call `DashboardService.fetchBookings()` (API list-field dan list-booking return same structure)
- Same implementation seperti list_booking_admin_screens
- Use **CardsBooking component** untuk consistency
- Add status color coding helper method

**Status colors mapping:**
- active = Colors.green
- waiting = Colors.orange
- cancelled = Colors.red
- finish = Colors.blue
- reschedule = Colors.purple

---

### STEP 5: Create/Update .env.example
**Lokasi**: `lib/.env.example` (jika belum ada, create new file)

**Content:**
```
API_BASE_URL=http://10.28.239.114:8000
API_TOKEN=your_api_token_here_generated_via_tinker
```

**Instructions for team:**
- Backend team harus generate token via: `php artisan tinker` → `$user = User::find(1);` → `$user->createToken('API Token')->plainTextToken;`
- Copy token ke `.env` file

---

## 🔧 Technical Details untuk AI

### API Response Format

**Dashboard Response:**
```json
{
  "success": true,
  "message": "Dashboard data retrieved successfully",
  "data": {
    "name": "Langworth PLC Arena",
    "slotTerisi": 0,
    "totalSlot": 14,
    "slotKosong": 14,
    "totalBooking": 0
  }
}
```

**List Booking/List Field Response:**
```json
{
  "success": true,
  "message": "Booking list retrieved successfully",
  "data": {
    "today": [
      {
        "id": 1,
        "date": "14",
        "month": "Apr",
        "year": "2026",
        "title": "Team Name (User Name)",
        "time": "19.00 - 21.00",
        "description": "Booking lapangan dengan durasi X jam",
        "status": "active"
      }
    ],
    "upcoming": [ ... ]
  }
}
```

### Error Handling Strategy
- Always set default/empty data saat error
- Show error message di UI dengan retry button
- Log errors ke console dengan `print('[ScreenName] Error: $e')`

### State Management Pattern
Use simple setState() pattern:
```dart
Future<void> _loadData() async {
  try {
    setState(() { isLoading = true; errorMessage = null; });
    final data = await DashboardService.fetchData();
    setState(() { 
      setState(() { 
        // update state variables
        isLoading = false;
      });
    });
  } catch (e) {
    setState(() { 
      errorMessage = e.toString();
      isLoading = false;
    });
  }
}
```

---

## ✅ Checklist Completion

Setelah semua selesai:

- [ ] `dashboard_service.dart` created dengan 3 methods
- [ ] `dashboard_admin_screens.dart` updated dengan API integration
- [ ] `list_booking_admin_screens.dart` updated dengan API integration + CardsBooking
- [ ] `list_field_admin_screens.dart` updated dengan API integration + CardsBooking
- [ ] `.env.example` created/updated
- [ ] No compilation errors (check dengan `flutter analyze`)
- [ ] Hot reload dan test di semua 3 screens
- [ ] Commit ke `features/api-integration` branch
- [ ] Push ke GitHub

---

## 📌 Important Notes

1. **Don't push sensitive data:**
   - Push `.env.example` saja, jangan `.env` dengan real token
   - Jangan push `api_test_screen.dart` atau debug files

2. **Use existing components:**
   - `HeaderSection` - untuk dashboard header
   - `CardsBooking` - untuk booking/field cards
   - `HeaderOne` - untuk section titles
   - `MenuGrid` - jangan diubah

3. **API Base URL:**
   - Development: `http://10.28.239.114:8000`
   - Ubah sesuai dengan server IP temanmu

4. **Token Management:**
   - Token perlu di-generate per user
   - Store di `.env` file atau secure storage (untuk production)

---

## 🆘 Troubleshooting

**Problem: API returns 401 Unauthorized**
- Check if token di `.env` benar
- Verify Bearer token format di Authorization header: `Bearer {token}`
- Token mungkin expired, generate baru via tinker

**Problem: Data tidak tampil di UI**
- Check `isLoading` logic
- Verify data structure dari API match dengan UI expectation
- Check console logs dengan `print()` statements

**Problem: CardsBooking error / type mismatch**
- Ensure Map<String, String> conversion dengan null-safe operator
- Convert semua values ke String: `value?.toString() ?? ''`

