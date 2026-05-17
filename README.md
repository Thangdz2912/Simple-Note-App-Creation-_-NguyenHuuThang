# lap5_simple

# Simple Note App - Ứng Dụng Ghi Chú Đơn Giản

Một ứng dụng Flutter đơn giản để tạo, chỉnh sửa, xem và xóa các ghi chú. Ứng dụng sử dụng SQLite để lưu trữ dữ liệu và Provider để quản lý trạng thái.

---


---

## ✨ Tính Năng

- ✅ **Tạo ghi chú mới** - Nhập tiêu đề và nội dung ghi chú
- ✅ **Chỉnh sửa ghi chú** - Cập nhật tiêu đề và nội dung
- ✅ **Xóa ghi chú** - Xóa ghi chú đã lưu với xác nhận
- ✅ **Lưu trữ dữ liệu** - Sử dụng SQLite để lưu trữ bền vững
- ✅ **Giao diện thân thiện** - Thiết kế Material Design 3
- ✅ **Quản lý trạng thái** - Sử dụng Provider Pattern
- ✅ **Hiển thị thời gian** - Thời gian tạo và cập nhật mỗi ghi chú

---

## 📁 Cấu Trúc Dự Án

```
lib/
├── main.dart                          # Điểm khởi đầu của ứng dụng
├── database/
│   └── database_helper.dart           # Xử lý tất cả các hoạt động cơ sở dữ liệu
├── models/
│   └── note.dart                      # Mô hình dữ liệu Note
├── providers/
│   └── note_provider.dart             # Quản lý trạng thái ghi chú
├── screens/
│   ├── home_screen.dart               # Màn hình chính - Danh sách ghi chú
│   └── note_editor_screen.dart        # Màn hình tạo/chỉnh sửa ghi chú
└── widgets/
    └── note_card.dart                 # Widget hiển thị từng ghi chú
```

---

## 🔧 Các Thành Phần

### 1. **main.dart** - Điểm Khởi Đầu Ứng Dụng

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

**Chức năng:**
- Khởi tạo Flutter binding trước khi chạy ứng dụng
- Cấu hình MultiProvider để cung cấp NoteProvider
- Thiết lập theme Material Design 3 với màu sắc Deep Purple
- Tắt debug banner

**Các công cụ sử dụng:**
- `MultiProvider` - Cung cấp nhiều provider
- `ChangeNotifierProvider` - Tạo NoteProvider singleton
- `MaterialApp` - Cấu hình ứng dụng Material Design

---

### 2. **models/note.dart** - Mô Hình Dữ Liệu

Lớp `Note` đại diện cho một ghi chú với các thuộc tính:
- `id` (int?, tùy chọn) - ID duy nhất, được tạo bởi cơ sở dữ liệu
- `title` (String) - Tiêu đề ghi chú
- `content` (String) - Nội dung ghi chú
- `createdAt` (DateTime) - Ngày giờ tạo ghi chú
- `updatedAt` (DateTime) - Ngày giờ cập nhật lần cuối

**Các phương thức quan trọng:**

| Phương thức | Mô tả |
|-------------|-------|
| `fromMap()` | Chuyển đổi Map từ cơ sở dữ liệu thành object Note |
| `toMap()` | Chuyển đổi object Note thành Map để lưu cơ sở dữ liệu |
| `copyWith()` | Tạo bản copy của Note với các field có thể thay đổi |

**Ví dụ:**
```dart
// Tạo note mới
final note = Note(
  title: 'Công việc hôm nay',
  content: 'Hoàn thành project Flutter',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Cập nhật một số field
final updatedNote = note.copyWith(
  title: 'Công việc hôm nay - Updated',
  updatedAt: DateTime.now(),
);
```

---

### 3. **database/database_helper.dart** - Quản Lý Cơ Sở Dữ Liệu

Lớp này sử dụng mẫu **Singleton** để đảm bảo chỉ có một kết nối cơ sở dữ liệu duy nhất.

**Cấu trúc bảng Database:**
```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
```

**Các Phương Thức CRUD:**

| Phương thức | Mô tả | Tham số | Trả về |
|-------------|-------|--------|--------|
| `insertNote()` | Thêm ghi chú mới | `Note` | `int` (ID mới) |
| `getAllNotes()` | Lấy tất cả ghi chú | - | `List<Note>` |
| `getNoteById()` | Lấy 1 ghi chú theo ID | `int id` | `Note?` |
| `updateNote()` | Cập nhật ghi chú | `Note` | `int` (số hàng thay đổi) |
| `deleteNote()` | Xóa ghi chú | `int id` | `int` (số hàng xóa) |

**Đặc điểm:**
- Lưu trữ dữ liệu tại `getApplicationDocumentsDirectory()/notes.db`
- Sắp xếp ghi chú theo `updatedAt DESC` (mới nhất trước)
- Xử lý ngày giờ ở định dạng ISO 8601

**Ví dụ sử dụng:**
```dart
final dbHelper = DatabaseHelper();
final allNotes = await dbHelper.getAllNotes();
final newId = await dbHelper.insertNote(note);
await dbHelper.deleteNote(id);
```

---

### 4. **providers/note_provider.dart** - Quản Lý Trạng Thái

Lớp `NoteProvider` extends `ChangeNotifier` quản lý toàn bộ trạng thái ghi chú của ứng dụng.

**Thuộc tính:**
- `_notes` - Danh sách tất cả ghi chú (private)
- `_isLoading` - Trạng thái tải dữ liệu (private)

**Getter công khai:**
- `notes` - Lấy danh sách ghi chú
- `isLoading` - Kiểm tra đang tải hay không

**Các Phương Thức:**

| Phương thức | Mô tả | Tác vụ |
|-------------|-------|--------|
| `loadNotes()` | Tải tất cả ghi chú từ DB | Gọi `notifyListeners()` để cập nhật UI |
| `addNote()` | Thêm ghi chú mới | Lưu DB, thêm vào list, insert ở đầu |
| `updateNote()` | Cập nhật ghi chú | Lưu DB, cập nhật trong list |
| `deleteNote()` | Xóa ghi chú | Xóa khỏi DB, loại bỏ khỏi list |

**Quy trình:**
1. Gọi `DatabaseHelper` để thực hiện hoạt động DB
2. Cập nhật `_notes` list
3. Gọi `notifyListeners()` để thông báo cho UI widget cập nhật

**Ví dụ sử dụng trong Widget:**
```dart
Consumer<NoteProvider>(
  builder: (context, noteProvider, child) {
    return Text('Số ghi chú: ${noteProvider.notes.length}');
  },
)
```

---

### 5. **screens/home_screen.dart** - Màn Hình Chính

Màn hình hiển thị danh sách tất cả các ghi chú.

**Cấu trúc UI:**
- **AppBar** - Tiêu đề "Simple Notes" với màu Deep Purple
- **Body** - Danh sách ghi chú dùng `ListView.builder`
- **FloatingActionButton** - Nút + để tạo ghi chú mới

**Chức năng:**

| Phần tử | Chức năng |
|--------|----------|
| FAB (+) | Mở `NoteEditorScreen` để tạo ghi chú mới |
| Note Card | Nhấp để chỉnh sửa, vuốt hoặc bấm delete để xóa |
| Empty State | Hiển thị thông báo "No notes yet" khi danh sách trống |

**Quy trình tải dữ liệu:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  noteProvider.loadNotes(); // Tải ghi chú sau build
});
```

**Xử lý điều hướng:**
- Khi quay lại từ `NoteEditorScreen` với `result == true`, reload danh sách ghi chú
- Nhấn FAB -> Mở editor -> Lưu -> Trở về home -> Reload list

---

### 6. **screens/note_editor_screen.dart** - Màn Hình Chỉnh Sửa Ghi Chú

Màn hình tạo ghi chú mới hoặc chỉnh sửa ghi chú hiện có.

**Trạng thái:**
- `_isEditing` - True nếu chỉnh sửa ghi chú cũ, False nếu tạo mới
- `_isLoading` - Hiển thị loading khi đang lưu
- `_titleController` - Điều khiển input tiêu đề
- `_contentController` - Điều khiển input nội dung

**Quy trình:**

1. **Khởi tạo:**
   - Nếu nhận `note` tham số → chế độ chỉnh sửa
   - Nếu không nhận `note` → chế độ tạo mới
   - Điền dữ liệu vào các input nếu chỉnh sửa

2. **Xác thực:**
   - Kiểm tra tiêu đề không rỗng
   - Kiểm tra nội dung không rỗng
   - Hiển thị SnackBar thông báo lỗi

3. **Lưu:**
   - Gọi `NoteProvider.addNote()` hoặc `updateNote()`
   - Hiển thị thông báo thành công
   - Quay về với `Navigator.pop(context, true)`

4. **Cleanup:**
   - Giải phóng TextEditingController trong `dispose()`

---

### 7. **widgets/note_card.dart** - Widget Hiển Thị Ghi Chú

Widget hiển thị thông tin ghi chú trong danh sách chính.

**Giao diện:**
```
┌─────────────────────────────────┐
│ Tiêu Đề Ghi Chú         [Delete] │
├─────────────────────────────────┤
│ Nội dung ghi chú (2 dòng)...     │
│ Updated: 15/05/2026 14:30       │
└─────────────────────────────────┘
```

**Các phần tử:**
- **Tiêu đề** - Text 18sp, bold, tối đa 1 dòng
- **Nút delete** - Icon delete, kích hoạt xác nhận trước xóa
- **Nội dung** - Text grey 14sp, tối đa 2 dòng với ellipsis
- **Thời gian** - "Updated: dd/MM/yyyy HH:mm"

**Tương tác:**
- **onTap** - Nhấp vào card để chỉnh sửa
- **onDelete** - Nhấp delete icon -> xác nhận -> gọi callback xóa

**Dialog xác nhận xóa:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: 'Delete Note',
    content: 'Are you sure you want to delete this note?',
    actions: [Cancel, Delete]
  ),
)
```

---

## 🔄 Quy Trình Hoạt Động

### Sơ đồ luồng dữ liệu:

```
┌─────────────────────────────────────────────────┐
│          Home Screen (Danh sách)                │
│  - Hiển thị ListView của NoteCard               │
│  - Có nút FAB để tạo ghi chú mới               │
└──────────────────┬──────────────────────────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
   [Nhấp FAB]          [Nhấp Note Card]
   (Tạo mới)              (Chỉnh sửa)
        │                     │
        └──────────┬──────────┘
                   │
                   ▼
    ┌──────────────────────────────┐
    │  Note Editor Screen          │
    │  - Input: Tiêu đề, Nội dung  │
    │  - Nút Save/Cancel           │
    └────────────┬─────────────────┘
                 │
         ┌───────┴────────┐
         │                │
      [Save]           [Cancel]
         │                │
         ▼                ▼
    ┌─────────┐      Quay lại
    │NoteProvider
    │- addNote()
    │- updateNote()
    │         │
    │         ▼
    │  ┌───────────────────┐
    │  │ DatabaseHelper    │
    │  │ - insert/update   │
    │  │ - SQLite DB       │
    │  └───────────────────┘
    │         │
    │         ▼
    │   notifyListeners()
    │         │
    │         ▼
    │    UI Update
    └─────────────────────
```

### Ví dụ: Tạo ghi chú mới

1. Người dùng nhấp **FAB (+)** trên HomeScreen
2. Điều hướng đến `NoteEditorScreen` (mode tạo mới)
3. Nhập tiêu đề: "Học Flutter"
4. Nhập nội dung: "Hôm nay học Provider Pattern"
5. Nhấp **Save**
6. `NoteEditorScreen` gọi `noteProvider.addNote(title, content)`
7. `NoteProvider` tạo object `Note` mới với `DateTime.now()`
8. Gọi `dbHelper.insertNote(note)` để lưu vào SQLite
9. Thêm ghi chú vào `_notes` list
10. Gọi `notifyListeners()` để thông báo cho UI
11. Quay về `HomeScreen` → danh sách cập nhật tự động

---

## 📱 Hướng Dẫn Sử Dụng

### Tạo Ghi Chú Mới
1. Nhấp nút **+** (FAB) ở góc dưới bên phải
2. Nhập **Tiêu đề** ghi chú
3. Nhập **Nội dung** ghi chú
4. Nhấp **Save** để lưu

### Chỉnh Sửa Ghi Chú
1. Nhấp vào ghi chú trong danh sách
2. Chỉnh sửa **Tiêu đề** hoặc **Nội dung**
3. Nhấp **Save** để lưu thay đổi

### Xóa Ghi Chú
1. Nhấp **Delete** (icon thùng rác) trên ghi chú
2. Xác nhận xóa trong dialog
3. Ghi chú sẽ bị xóa vĩnh viễn

---

## 🛠️ Công Nghệ Sử Dụng

### Framework & Thư Viện
| Tên | Phiên bản | Mục đích |
|-----|----------|---------|
| **Flutter** | Latest | Framework phát triển ứng dụng |
| **Provider** | ^6.0.0+ | Quản lý trạng thái (State Management) |
| **sqflite** | ^2.0.0+ | SQLite database cho Flutter |
| **path_provider** | ^2.0.0+ | Lấy đường dẫn thư mục của ứng dụng |
| **intl** | ^0.18.0+ | Định dạng ngày giờ theo locale |

### Kiến Trúc

**Mô hình kiến trúc sử dụng:**
- **MVVM + Provider Pattern** - Model-View-ViewModel với Provider
- **Repository Pattern** - DatabaseHelper làm Repository
- **Singleton Pattern** - Một instance duy nhất của DatabaseHelper

**Luồng dữ liệu:**
```
UI Layer (Screens & Widgets)
         ↓
State Management Layer (Provider)
         ↓
Repository Layer (DatabaseHelper)
         ↓
Data Layer (SQLite Database)
```

### Material Design 3
- Sử dụng `ColorScheme.fromSeed()` với màu Deep Purple
- `useMaterial3: true` - Bật Material Design 3
- Responsive UI với `Flexible`, `Expanded`

---

## 📊 Dữ Liệu & Lưu Trữ

### Vị trí lưu trữ
- **Android**: `/data/data/<package_name>/files/notes.db`
- **iOS**: `NSDocumentDirectory/notes.db`

### Định dạng lưu DateTime
- Sử dụng **ISO 8601 format**: `2026-05-15T14:30:00.000`
- Chuyển đổi: `DateTime.parse()` và `toIso8601String()`

---

## 🎯 Tổng Kết

Ứng dụng **Simple Note App** là một ví dụ hoàn chỉnh về:
- ✅ Quản lý trạng thái với Provider
- ✅ Lưu trữ dữ liệu với SQLite
- ✅ Kiến trúc ứng dụng sạch (Clean Architecture)
- ✅ Xử lý UI/UX tốt
- ✅ CRUD operations hoàn tất

Mã nguồn được tổ chức rõ ràng, dễ bảo trì và mở rộng!

---

**Tác giả:** Flutter Developer  
**Ngày cập nhật:** 17/05/2026  
**Phiên bản:** 1.0.0
