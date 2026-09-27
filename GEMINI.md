# Quy tắc làm việc với Git — Tự động Commit & Push sau mỗi lần chỉnh sửa

## 📌 Nguyên tắc bắt buộc

### 1. KHÔNG tạo file backup thủ công
- **Tuyệt đối không** tạo các file có đuôi `.bak`, `.backup`, `.old`, `.orig`, `.tmp`, hay các bản sao tên kiểu `file_v1.html`, `file_copy.html`, v.v.
- Git đã đảm nhiệm toàn bộ vai trò quản lý lịch sử phiên bản — không cần file backup riêng.

---

### 2. Tự động commit & push SAU MỖI lần chỉnh sửa

Sau **mỗi lần** thực hiện bất kỳ thao tác chỉnh sửa nào (tạo file mới, sửa nội dung, xóa file, đổi tên), agent **phải** thực hiện đủ 3 bước sau trước khi báo cáo hoàn thành:

```powershell
# Bước 1: Stage toàn bộ thay đổi trong thư mục hiện tại
git add .

# Bước 2: Commit với message mô tả ngắn gọn việc vừa làm
git commit -m "<loại>: <mô tả ngắn gọn bằng tiếng Việt hoặc tiếng Anh>"

# Bước 3: Push lên remote repository
git push
```

> **Lưu ý:** Lệnh `git add .` sẽ stage **toàn bộ thay đổi trong toàn bộ thư mục dự án**, không giới hạn theo file vừa sửa.

---

### 3. Quy tắc viết commit message

Dùng định dạng Conventional Commits:

| Prefix | Khi nào dùng |
|--------|-------------|
| `feat:` | Thêm tính năng mới |
| `fix:` | Sửa lỗi |
| `refactor:` | Tái cấu trúc code, không thêm/sửa tính năng |
| `style:` | Chỉnh CSS, giao diện, font chữ, màu sắc |
| `docs:` | Cập nhật tài liệu, chú thích |
| `chore:` | Dọn dẹp file, cấu hình dự án |
| `content:` | Cập nhật nội dung dữ liệu (text, JSON, HTML tĩnh) |

**Ví dụ commit message hợp lệ:**
```
feat: thêm bộ lọc tìm kiếm theo trạng thái dự án
fix: sửa lỗi hiển thị ngày tháng sai định dạng
style: điều chỉnh màu header bảng danh sách
content: cập nhật danh sách phòng ban Q3/2026
chore: xóa các file .bak cũ không cần thiết
```

---

### 4. Xử lý khi push thất bại

Nếu `git push` thất bại do remote có thay đổi mới hơn, agent phải:

```powershell
# Pull với rebase để tránh merge commit không cần thiết
git pull --rebase origin <tên_nhánh_hiện_tại>

# Sau đó push lại
git push
```

Nếu có conflict, agent phải **báo cáo ngay cho người dùng** thay vì tự ý giải quyết.

---

### 5. Kiểm tra trạng thái git trước khi bắt đầu làm việc

Trước khi thực hiện chỉnh sửa, agent nên chạy:

```powershell
git status
git log --oneline -5
```

Để xác nhận:
- Không có uncommitted changes còn sót từ phiên làm việc trước.
- Nhánh hiện tại là đúng nhánh cần làm việc.

---

### 6. Không commit file nhạy cảm hoặc không cần thiết

Đảm bảo `.gitignore` đã loại trừ:
- File tạm hệ thống: `Thumbs.db`, `.DS_Store`, `desktop.ini`
- Thư mục build/cache: `node_modules/`, `__pycache__/`, `.cache/`
- File môi trường: `.env`, `*.env.local`
- File backup cũ (nếu còn sót): `*.bak`, `*.backup`, `*.old`

Nếu chưa có `.gitignore`, agent nên tạo file phù hợp trước khi commit đầu tiên.

---

## ✅ Checklist sau mỗi lần chỉnh sửa

Trước khi thông báo hoàn thành với người dùng, agent tự kiểm tra:

- [ ] Đã thực hiện xong thay đổi yêu cầu
- [ ] **KHÔNG** tạo bất kỳ file `.bak` hay backup nào
- [ ] Đã chạy `git add .`
- [ ] Đã chạy `git commit -m "..."` với message mô tả rõ ràng
- [ ] Đã chạy `git push` thành công
- [ ] Không có file nhạy cảm bị commit nhầm
