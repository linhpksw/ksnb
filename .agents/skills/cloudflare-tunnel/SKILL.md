---
name: cloudflare-tunnel
description: >-
  Manage Cloudflare Tunnel (try.cloudflare.com) and the local HTTP server to expose or unpublish
  the KTKS project to/from the internet. Use this skill whenever the user asks to start/turn on
  the tunnel, stop/turn off the tunnel, check tunnel status, or retrieve the public URL for sharing.
---

# Cloudflare Tunnel Management Skill

Kỹ năng này hướng dẫn AI Agent tự động quản lý vòng đời của **Cloudflare Quick Tunnel** (`trycloudflare.com`) kết hợp với **Local Python HTTP Server** để public ứng dụng ra ngoài Internet hoặc tắt kết nối an toàn.

---

## 🎯 Khi nào kích hoạt Skill này (Triggers)

Kích hoạt skill này khi người dùng có các yêu cầu:
- **Bật / Mở public**: *"bật tunnel"*, *"public dự án"*, *"chia sẻ link web"*, *"start tunnel"*, *"đưa lên internet"*.
- **Lấy link URL**: *"cho tôi xin url"*, *"link hiện tại là gì"*, *"url truy cập"*, *"get url"*.
- **Tắt / Dừng**: *"tắt tunnel"*, *"dừng public"*, *"stop tunnel"*, *"đóng kết nối"*.
- **Kiểm tra trạng thái**: *"tunnel có đang chạy không"*, *"kiểm tra tunnel"*, *"status"*.

---

## 🚀 Hướng dẫn thực hiện cho AI Agent

### Kịch bản 1: BẬT TUNNEL & LẤY URL TRUY CẬP (Start Tunnel)

Agent thực hiện theo 3 bước chuẩn xác sau:

#### Bước 1: Khởi chạy Python HTTP server ngầm
Dùng công cụ `run_command`:
- **CommandLine**: `python -m http.server 8000 --bind 127.0.0.1`
- **WaitMsBeforeAsync**: `1500`
- **IsDaemon**: `true`

#### Bước 2: Khởi chạy Cloudflare Tunnel ngầm
Dùng công cụ `run_command`:
- **CommandLine**: `& "C:\Program Files (x86)\cloudflared\cloudflared.exe" tunnel --url http://127.0.0.1:8000`
- **WaitMsBeforeAsync**: `8000`
- **IsDaemon**: `true`

#### Bước 3: Đọc file Log của tác vụ Tunnel để trích xuất URL
Khi bước 2 trả về `taskId` và `logUri` (ví dụ: `.../.system_generated/tasks/task-XYZ.log`), Agent dùng `view_file` để mở file log đó.
- Tìm dòng có chứa địa chỉ dạng:
  `https://<subdomain>.trycloudflare.com`
- Kiểm tra tính sẵn sàng bằng `Invoke-WebRequest -Uri "<url>" -UseBasicParsing`.

#### Bước 4: Trả lời người dùng
Báo cáo đã bật thành công và **BẮT BUỘC** hiển thị link Markdown có thể bấm được:
> 🔗 Link truy cập công khai của dự án:
> **[https://<subdomain>.trycloudflare.com](https://<subdomain>.trycloudflare.com)**

---

### Kịch bản 2: LẤY URL HIỆN TẠI HOẶC KIỂM TRA TRẠNG THÁI (Get URL / Status)

1. Agent gọi `manage_task` với `Action: "list"` để tìm tác vụ đang chạy của `cloudflared`.
2. Nếu tìm thấy task đang chạy: Mở `logUri` tương ứng bằng `view_file`, tìm dòng `https://*.trycloudflare.com` và gửi lại link cho người dùng.
3. Nếu không có task chạy trong phiên, kiểm tra cổng 8000 hoặc file log tạm thời bằng lệnh PowerShell:
   ```powershell
   Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue
   ```
   Nếu cả 2 đều tắt, thông báo cho người dùng rằng Tunnel hiện đang tắt và đề nghị bật lên nếu cần.

---

### Kịch bản 3: TẮT TUNNEL & DỪNG PUBLIC (Stop Tunnel)

1. Nếu Agent có các tác vụ nền đang chạy (từ `manage_task Action: "list"`), gọi `manage_task Action: "kill"` cho các tác vụ đó.
2. Để đảm bảo tất cả tiến trình được dọn dẹp triệt để trong Windows:
   Chạy lệnh dọn dẹp bằng PowerShell:
   ```powershell
   Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue | Stop-Process -Force;
   $conn = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Where-Object {$_.State -eq 'Listen'};
   if ($conn) { Stop-Process -Id $conn.OwningProcess -Force }
   ```
3. Thông báo cho người dùng:
   > Đã tắt Cloudflare Tunnel và dừng Server thành công. Dự án của bạn hiện đã được đưa về chế độ riêng tư (offline) và không còn truy cập được từ Internet.

---

## 🛠️ Helper Scripts tích hợp sẵn

Agent hoặc người dùng cũng có thể gọi trực tiếp các script sau:
- [start_tunnel.ps1](./scripts/start_tunnel.ps1): Khởi động server + tunnel và trả kết quả JSON.
- [stop_tunnel.ps1](./scripts/stop_tunnel.ps1): Dừng toàn bộ server và tunnel.
- [status_tunnel.ps1](./scripts/status_tunnel.ps1): Kiểm tra trạng thái và URL hiện tại.
