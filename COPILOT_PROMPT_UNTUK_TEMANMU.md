## 🚀 COPILOT PROMPT UNTUK TEMANMU

Kamu bisa copy-paste ini ke Copilot Chat di VS Code temanmu:

---

```
Saya sedang mengerjakan Flutter project PBL-App-Joglo66. Status saat ini:
- Backend Laravel API sudah working (3 endpoints: /api/admin/dashboard, /api/admin/list-field, /api/admin/list-booking)
- Database sudah seeded dengan data test
- Sanctum authentication sudah setup
- Saya baru pull dari branch main

Saya butuh bantuan untuk integrate Flutter screens dengan backend API. Ada 3 screens yang perlu di-update:

## Project Setup
- Workspace: E:\zami\pbl\app\PBL-App-Joglo66 (Flutter app)
- Backend: E:\zami\pbl\web\PBL-Web-Joglo66 (Laravel API)
- Branch: features/api-integration (atau buat baru dari main)

## Yang Perlu Dikerjakan

### 1. Create Dashboard Service (lib/services/dashboard_service.dart)
Buatkan static service class yang:
- Fetch data dari 3 API endpoints (dashboard, list-field, list-booking)
- Gunakan flutter_dotenv untuk API_BASE_URL dan API_TOKEN dari .env
- Implement proper error handling dan timeout (10 seconds)
- Return data structure yang cocok untuk UI

Endpoints:
- GET /api/admin/dashboard → return: {name, slotTerisi, totalSlot, slotKosong, totalBooking}
- GET /api/admin/list-field → return: List of bookings
- GET /api/admin/list-booking → return: {today: [], upcoming: []}

### 2. Update Dashboard Screen (lib/screens/admin/dashboard_admin_screens.dart)
- Convert ke StatefulWidget
- Implement _loadDashboardData() yang call service di initState()
- Add loading indicator, error message, dan retry button
- Display data dinamis dari API (bukan hardcoded)
- Keep existing UI components: HeaderSection, MenuGrid

### 3. Update List Booking Screen (lib/screens/admin/booking_field/list_booking_admin_screens.dart)
- Convert ke StatefulWidget
- Implement _loadBookingData() yang split data ke today/upcoming
- Gunakan CardsBooking component (sudah ada) untuk render items
- Add loading state, error handling, empty state
- Convert API data format ke CardsBooking format (Map<String, String>)

### 4. Update List Field Screen (lib/screens/admin/field/list_field_admin_screens.dart)
- Similar structure seperti List Booking Screen
- Use CardsBooking component untuk consistency
- Add status color coding (active=green, waiting=orange, etc)
- Call same API endpoint (list-booking/list-field return same structure)

### 5. Create .env File
- Create lib/.env.example dengan API_BASE_URL dan API_TOKEN template
- Add instructions para generate token via Laravel tinker

## Reference Data Structure

Dashboard API Response:
{
  "success": true,
  "data": {
    "name": "Langworth PLC Arena",
    "slotTerisi": 0,
    "totalSlot": 14,
    "slotKosong": 14,
    "totalBooking": 0
  }
}

Booking List API Response:
{
  "success": true,
  "data": {
    "today": [
      {
        "id": 1,
        "date": "14",
        "month": "Apr",
        "year": "2026",
        "title": "Team Name (User Name)",
        "time": "19.00 - 21.00",
        "description": "Booking lapangan...",
        "status": "active"
      }
    ],
    "upcoming": [...]
  }
}

CardsBooking Component Expected Format:
Map<String, String> dengan keys: date, month, year, title, time, description

## Important Guidelines
1. Use existing components: HeaderSection, CardsBooking, HeaderOne, MenuGrid
2. Implement proper null-safety: convert dynamic values ke String dengan ?.toString() ?? ''
3. Add logging dengan print() untuk debugging
4. Handle all error cases (API error, timeout, null data)
5. DON'T push .env file dengan real token, hanya push .env.example
6. Bearer token format di Authorization header: "Bearer {token}"

Tolong buatkan step-by-step implementation untuk semua 4 tasks di atas!
```

---

## Atau Langsung Copy Task-nya Aja:

Kalau temanmu cukup copy task di bawah ini ke Copilot:

### Task untuk Copilot AI

```
Buatkan file: lib/services/dashboard_service.dart

Requirements:
- Static class DashboardService
- 3 static methods: fetchDashboardData(), fetchFields(), fetchBookings()
- Use flutter_dotenv untuk read API_BASE_URL dan API_TOKEN dari .env
- Handle 10 second timeout
- Add Bearer token authorization header
- Proper error handling dengan try-catch
- Add logging dengan print()
- Return proper data structures untuk setiap endpoint

API Endpoints:
- GET /api/admin/dashboard
- GET /api/admin/list-field  
- GET /api/admin/list-booking

Full implementation dengan semua methods!
```

Kemudian setelah itu, temanmu bisa memberi task:

```
Update file: lib/screens/admin/dashboard_admin_screens.dart

Change dari StatelessWidget ke StatefulWidget.

Add state variables:
- Map<String, dynamic>? dashboardData
- bool isLoading = true
- String? errorMessage

Implement _loadDashboardData() method yang:
1. Call DashboardService.fetchDashboardData()
2. Set state dengan loading/error/success
3. Default data jika error

Update build() untuk:
1. Show loading indicator saat isLoading == true
2. Show error message + retry button jika ada errorMessage
3. Display data dinamis dari API ke HeaderSection
4. Keep existing HeaderOne dan MenuGrid

Use Navigator/go_router untuk navigation ke detail screens.
```

---

## 📌 Pro Tips untuk Temanmu:

1. **Mulai dari Service dulu** - Tanya Copilot untuk create `dashboard_service.dart` completion
2. **Satu screen sekali** - Jangan request semua 3 screens sekaligus, bisa error
3. **Specific instructions** - Lebih specific instruction = lebih bagus hasil
4. **Test saat berjalan** - Hot reload dan test setiap kali ada perubahan
5. **Reference existing code** - Minta Copilot lihat component yang sudah ada

---

## ❓ Kalau Ada Error:

Temanmu bisa tanya Copilot dengan copy-paste error message:
```
Saya dapat error ini: [paste error message]
File: [nama file]
Baris mana: [line number]

Bisa difix?
```

---

## 📦 Final Checklist untuk Temanmu:

Setelah semua selesai:
```
✅ dashboard_service.dart - Created with 3 methods
✅ dashboard_admin_screens.dart - Updated with API integration
✅ list_booking_admin_screens.dart - Updated with API integration
✅ list_field_admin_screens.dart - Updated with API integration
✅ lib/.env.example - Created
✅ No compilation errors - Run flutter analyze
✅ Hot reload test - All 3 screens working
✅ Commit & push - ke branch features/api-integration
```

Good luck! 🚀
