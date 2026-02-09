# Dokumentasi Layar (Screens)

Direktori ini berisi layar antarmuka pengguna (UI) aplikasi. Setiap file sesuai dengan layar atau halaman tertentu dalam alur aplikasi.

## Deskripsi File

| Nama File | Deskripsi |
|---|---|
| `scr_assignment_content.dart` | **Layar Detail Tugas**: Menampilkan detail tugas tertentu (SPK). Memungkinkan pengguna melihat informasi tugas dan memilih untuk "Menyelesaikan" atau "Menunda" tugas tersebut. |
| `scr_assignment_list.dart` | **Layar Daftar Tugas**: Menampilkan daftar semua tugas yang diberikan kepada pengguna. Mengambil data dari database SQLite lokal dan menyediakan navigasi ke detail tugas. |
| `scr_execution_form.dart` | **Layar Formulir Eksekusi**: Formulir yang digunakan saat menyelesaikan atau menunda tugas. Mengharuskan pengguna memasukkan catatan dan mengambil foto sebagai bukti kerja sebelum menyimpan status ke database lokal. |
| `scr_initial_sync.dart` | **Layar Sinkronisasi Awal**: Layar yang ditampilkan setelah login untuk melakukan sinkronisasi data awal. Mengunduh SPK (tugas), riwayat Kesehatan Tanaman, dan data Tanaman dari server ke perangkat lokal. |
| `scr_login.dart` | **Layar Login**: Titik masuk aplikasi. Menyediakan antarmuka pengguna untuk login, menampilkan animasi dan latar belakang gradien. |
| `scr_plant_health.dart` | **Layar Kesehatan Tanaman**: Layar untuk memantau kesehatan tanaman. Memvisualisasikan pohon dalam tata letak kisi heksagonal, memungkinkan pengguna memilih pohon dan memperbarui status kesehatannya. |
| `scr_plant_reposition.dart` | **Layar Reposisi Tanaman**: Mirip dengan layar Kesehatan Tanaman, layar ini memungkinkan pengguna mengelola reposisi tanaman (sensus) menggunakan visualisasi kisi heksagonal. |
| `scr_sync_action.dart` | **Layar Aksi Sinkronisasi**: Pusat sinkronisasi utama untuk mengunggah data lokal ke server. Menangani pengunggahan batch Eksekusi Tugas, Kesehatan Tanaman, Reposisi, dan Log Audit. |

## Subdirektori

### `sync/`
Berisi kelas pembantu dan widget khusus untuk layar `scr_sync_action.dart`.
- `sync_models.dart`: Model data untuk batch sinkronisasi.
- `sync_service.dart`: Logika layanan untuk mengambil data dari SQLite dan mengirimkannya ke server.
- `sync_widgets.dart`: Komponen UI yang digunakan di layar sinkronisasi (misalnya, bilah progres, kartu status).

### `widgets/`
Berisi komponen UI yang dapat digunakan kembali di berbagai layar untuk menjaga konsistensi dan mengurangi duplikasi kode.
- `w_assigment_detail.dart`: Widget untuk tampilan detail tugas.
- `w_general.dart`: Widget tujuan umum (tombol, gaya teks, bilah aplikasi).
- `w_login.dart`: Widget khusus untuk layar login.
- `w_plant_health.dart`: Widget untuk layar kesehatan tanaman.
- `w_popup_action.dart`: Dialog popup untuk tindakan tugas.
- `w_popup_health.dart`: Dialog popup untuk pembaruan kesehatan.
- `w_popup_reposition.dart`: Dialog popup untuk pembaruan reposisi.
- `w_reposition.dart`: Widget untuk layar reposisi.
- `w_task_exec.dart`: Widget terkait tampilan eksekusi tugas.
