# Struktur Folder Lib

Proyek ini menggunakan arsitektur MVC (Model-View-Controller) dengan struktur folder sebagai berikut:

## 📁 Struktur Folder

```
lib/
├── main.dart                 # Entry point aplikasi
├── mvc_dao/                  # Data Access Objects
├── mvc_libs/                 # Libraries & Utilities
├── mvc_models/               # Data Models
├── mvc_services/             # Business Logic Services
├── plantdb/                  # Database Plant/Template Files
└── screens/                  # UI Screens/Pages
```

## 📝 Deskripsi Folder

### 1. `mvc_dao/` - Data Access Objects
Berisi class-class untuk mengakses database (SQLite) dan operasi CRUD:
- Database helper
- DAO (Data Access Object) untuk setiap tabel
- Query builder dan database utilities

### 2. `mvc_libs/` - Libraries & Utilities
Berisi helper functions, utilities, dan library custom:
- String helpers
- Date/time utilities
- Validation helpers
- Constants
- Custom widgets yang reusable

### 3. `mvc_models/` - Data Models
Berisi class model untuk representasi data:
- Entity models (sesuai dengan tabel database)
- DTO (Data Transfer Objects)
- Response models untuk API

### 4. `mvc_services/` - Business Logic Services
Berisi business logic dan services:
- Service layer untuk komunikasi dengan backend
- Business rules dan validations
- State management
- API integration

### 5. `plantdb/` - Database Plant/Template Files
Berisi file-file template database:
- SQL scripts untuk inisialisasi database
- Seed data
- Database migration files
- Database schema definitions

### 6. `screens/` - UI Screens/Pages
Berisi halaman-halaman UI aplikasi:
- Home screen
- Form screens
- List screens
- Detail screens
- Settings screens

## 🏗️ Arsitektur

Proyek ini menggunakan pola **MVC (Model-View-Controller)**:

- **Model** (`mvc_models/`): Representasi data dan struktur
- **View** (`screens/`): User Interface dan presentasi
- **Controller** (`mvc_services/`): Business logic dan koordinasi
- **DAO** (`mvc_dao/`): Data persistence layer
- **Libs** (`mvc_libs/`): Shared utilities dan helpers

## 📦 Dependencies Utama

- `sqflite`: Database SQLite lokal
- `http`: HTTP requests
- `image_picker`: Image selection
- `permission_handler`: Permission management
- `device_info_plus`: Device information
- `connectivity_plus`: Network connectivity
- `intl`: Internationalization

## 🎯 Best Practices

1. **Separation of Concerns**: Setiap folder memiliki tanggung jawab yang jelas
2. **Reusability**: Code yang reusable ditempatkan di `mvc_libs/`
3. **Maintainability**: Struktur yang terorganisir memudahkan maintenance
4. **Scalability**: Mudah untuk menambahkan fitur baru
