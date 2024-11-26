# Printer Info Flutter App

**Printer Info** - Bu dastur Windows tizimida o‘rnatilgan printerlar ro‘yxatini ko‘rsatadi. Dastur printerlar haqida asosiy ma'lumotlarni olish va ko‘rsatish imkonini beradi, masalan, printer nomi, port nomi, drayver nomi va holati.

## Talablar

- **Flutter SDK**: 3.0 yoki undan yuqori versiya
- **Windows** tizimi

## O‘rnatish

1. **Flutter loyihasini yaratish va o‘rnatish:**
   Dasturga kerakli kutubxonalarni o‘rnatish uchun, avvalo `pubspec.yaml` faylida quyidagi kutubxonalarni qo‘shing:

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     ffi: ^2.0.1
     win32: ^3.0.1
