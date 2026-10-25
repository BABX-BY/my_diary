# MyDiary

แอปพลิเคชันบันทึกเรื่องราวประจำวันสำหรับผู้ที่อยากเก็บความทรงจำ ความรู้สึก และช่วงเวลาดี ๆ ไว้ในที่เดียว พัฒนาด้วย Flutter โดยออกแบบให้ใช้งานง่าย อ่านสบาย และรองรับการจัดเก็บข้อมูลหลายรูปแบบตามเนื้อหาของ HW5

> **Project:** MyDiary
> **Version:** 1.0.0
> **Platform:** Android, iOS, Web, Windows, macOS และ Linux ตามความพร้อมของ Flutter

## จุดเด่นของแอป

- ระบบสมัครสมาชิกและเข้าสู่ระบบด้วย Firebase Authentication
- ระบบลืมรหัสผ่านผ่านอีเมล
- สร้าง แก้ไข และลบบันทึกส่วนตัว
- ระบุชื่อเรื่อง เนื้อหา วันที่ และอารมณ์ของวันนั้น
- ค้นหาบันทึกจากชื่อเรื่อง
- แสดงคำคมประจำวันจาก REST API และบันทึกคำคมเป็นไดอารี่ได้
- จัดเก็บข้อมูลแบบ Local ด้วย SQLite
- จัดเก็บข้อมูลแบบ Cloud ด้วย Cloud Firestore
- แยกข้อมูลของผู้ใช้แต่ละบัญชีด้วย `userId`
- มีหน้า Pokémon สำหรับสาธิตการเรียกข้อมูลจาก API
- มีหน้าแนะนำข้อมูลผู้พัฒนา
- รองรับ Empty State, Loading State และข้อความแจ้งข้อผิดพลาด
- UI โทน Pastel Sky Blue + Pink รองรับหน้าจอขนาดเล็กและการเปิด Keyboard

## ภาพรวมการทำงาน

```text
ผู้ใช้
  │
  ├── Login / Register / Forgot Password
  │        └── Firebase Authentication
  │
  └── MainPage
       ├── บันทึกส่วนตัว       └── SQLite
       ├── เกี่ยวกับนักพัฒนา
       ├── Pokémon             └── REST API
       ├── บันทึกออนไลน์       └── REST API
       └── Cloud Diary         └── Cloud Firestore
```

## เทคโนโลยีที่ใช้

- **Flutter / Dart** — พัฒนาแอปแบบ Cross-platform
- **Firebase Authentication** — สมัครสมาชิก เข้าสู่ระบบ และรีเซ็ตรหัสผ่าน
- **Cloud Firestore** — จัดเก็บบันทึกบน Cloud
- **SQLite ผ่าน sqflite** — จัดเก็บบันทึกในเครื่อง
- **HTTP** — เชื่อมต่อ REST API
- **Material 3** — Component และ Theme ของ UI

## โครงสร้างไฟล์สำคัญ

```text
lib/
├── main.dart                    # จุดเริ่มต้นแอปและ MaterialApp
├── theme/app_theme.dart          # Theme สีและ Component กลางของแอป
├── login_page.dart               # AuthGate, Login และ Register
├── forgot_password_page.dart     # รีเซ็ตรหัสผ่าน
├── firestore_diary.dart          # รายการบันทึกบน Firestore
├── firestore_form_page.dart      # ฟอร์มบันทึกบน Firestore
├── firestore_service.dart        # Firestore CRUD และ user filtering
├── database_helper.dart          # SQLite CRUD
├── api_service.dart              # ฟังก์ชันเรียก REST API
├── models/diary.dart             # Model ของบันทึก
└── screens/
    ├── main_page.dart            # Navigation หลัก
    ├── diary_list_page.dart      # บันทึกส่วนตัวจาก SQLite
    ├── add_diary_page.dart       # เพิ่ม/แก้ไขบันทึก SQLite
    ├── api_diaty_page.dart       # บันทึกผ่าน REST API
    ├── api_form_page.dart        # ฟอร์ม REST API
    ├── pokedek_list_page.dart    # รายการ Pokémon
    └── about_page.dart            # ข้อมูลผู้พัฒนา
```

## การติดตั้งและใช้งาน

### สิ่งที่ต้องมี

- Flutter SDK ที่รองรับ Dart SDK `^3.12.2`
- Android Studio หรือ Xcode ตาม Platform ที่ต้องการรัน
- Firebase Project สำหรับ Authentication และ Firestore

### ขั้นตอนติดตั้ง

```bash
git clone <repository-url>
cd my_diary
flutter pub get
flutter run
```

หากต้องการตรวจสอบอุปกรณ์ที่พร้อมใช้งาน:

```bash
flutter devices
```

## การตั้งค่า Firebase

โปรเจกต์นี้ใช้ Firebase Authentication และ Cloud Firestore จึงต้องตั้งค่า Firebase ให้ตรงกับ Application ID ของโปรเจกต์ก่อนรันจริง

1. สร้าง Firebase Project ใน Firebase Console
2. เพิ่ม Android/iOS/Web App ตาม Platform ที่ต้องการ
3. เปิดใช้งาน **Authentication > Sign-in method > Email/Password**
4. สร้าง Cloud Firestore Database
5. วางไฟล์ configuration ของแต่ละ Platform ให้ถูกตำแหน่ง
6. ตรวจสอบ `lib/firebase_options.dart` ให้ตรงกับ Firebase Project
7. รันคำสั่ง `flutter pub get` และ `flutter run`

> ไม่ควรเปิด Firestore Security Rules เป็นสาธารณะในโปรเจกต์ใช้งานจริง ควรจำกัดการอ่านและเขียนด้วย `request.auth.uid` ให้ตรงกับ `userId` ของเอกสาร

## แนวทางการใช้งาน

1. สมัครสมาชิกด้วยอีเมลและรหัสผ่านอย่างน้อย 6 ตัวอักษร
2. เข้าสู่ระบบเพื่อไปยังหน้า MainPage
3. เลือกแท็บ **บันทึก** เพื่อเพิ่มหรือจัดการบันทึกในเครื่อง
4. เลือกแท็บ **Cloud** เพื่อจัดการบันทึกบน Firestore
5. ใช้ช่องค้นหาเพื่อค้นหาบันทึกจากชื่อเรื่อง
6. ใช้แท็บ **ออนไลน์** เพื่อดูและจัดการข้อมูลผ่าน REST API
7. หากลืมรหัสผ่าน ให้เลือกเมนู **ลืมรหัสผ่าน?** ที่หน้าเข้าสู่ระบบ

## แนวทางการออกแบบ UI

MyDiary ใช้แนวทาง **Modern, Minimal และ Cute** โดยเลือกใช้สี Pastel ที่สบายตา:

| รายการ | สี |
| --- | --- |
| สีหลัก | `#75A9F8` |
| สีรอง | `#F39BC5` |
| พื้นหลัง | `#F8FAFF` |
| Card | `#FFFFFF` |
| ตัวอักษรหลัก | `#26334D` |
| ตัวอักษรรอง | `#7B879C` |
| เส้นขอบ | `#E5EAF5` |

Theme ทั้งหมดถูกรวมไว้ใน `lib/theme/app_theme.dart` เพื่อให้ปรับสีและรูปแบบของแอปได้จากจุดเดียว

## คำสั่งสำหรับตรวจสอบโปรเจกต์

```bash
flutter analyze
flutter test
flutter build apk
```

คำสั่ง Build อาจใช้พื้นที่ดิสก์และเวลามากกว่าการรันแอปทั่วไป โดยเฉพาะ Android Build ครั้งแรก

## ขอบเขตของข้อมูล

- SQLite เหมาะสำหรับข้อมูลบันทึกภายในเครื่อง
- Firestore เหมาะสำหรับข้อมูลที่ต้องการซิงก์บน Cloud
- REST API ใช้สำหรับสาธิตการเชื่อมต่อและจัดการข้อมูลผ่านบริการภายนอก
- ระบบ Authentication เป็นตัวควบคุมสิทธิ์การเข้าใช้งาน
- ข้อมูลของผู้ใช้ควรถูกกรองด้วย `userId` ทั้งในระดับแอปและ Firestore Rules

## ผู้พัฒนา

**นายธีระวัฒน์ สีปัดขน**
รหัสนิสิต: **67011211113**
สาขาวิทยาการคอมพิวเตอร์ มหาวิทยาลัยมหาสารคาม

---

