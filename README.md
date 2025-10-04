
# wpf-updates (GitHub Pages + Releases)

Kho lưu trữ **JSON cập nhật** cho ứng dụng WPF của bạn. Cấu hình này dùng:
- **GitHub Pages** để public file: `docs/latest.json` (HTTPS hợp lệ: `https://<user>.github.io/<repo>/latest.json`)
- **GitHub Releases** để chứa file cài đặt `.exe`
- **GitHub Actions** tự động tạo/ghi đè `docs/latest.json` mỗi khi bạn tạo **Release** (tag `vX.Y.Z`) và đính kèm installer

> **UpdateChecker** trong WPF cần trỏ đến JSON này, ví dụ:
>
> ```csharp
> private const string UpdateUrl = "https://<tài-khoản>.github.io/wpf-updates/latest.json";
> ```

---

## 1) Cách dùng nhanh (khuyên dùng — **tự động**)
1. **Tạo repo** trên GitHub, ví dụ tên `wpf-updates` (Public).
2. **Push** toàn bộ nội dung thư mục này lên nhánh `main`.
3. Vào **Settings → Pages**, chọn:
   - *Source*: **Deploy from a branch**
   - *Branch*: **main**, *Folder*: **/docs**
4. Vào **Settings → Actions → General → Workflow permissions**, bật **Read and write permissions**.
5. Mỗi lần phát hành bản mới:
   - Vào **Releases** → **Draft a new release**
   - *Tag version*: `v1.2.3` (bắt buộc dạng `vX.Y.Z`)
   - Đính kèm **installer .exe** (được build bằng Inno Setup)
   - **Publish release**
6. **Workflow sẽ chạy** → tạo/ghi đè `docs/latest.json` với:
   - `version` lấy từ tag (bỏ chữ `v`),
   - `releaseDate` lấy từ `published_at`,
   - `downloadUrl` trỏ đến asset `.exe` bạn vừa đính kèm,
   - `sha256` tính từ file `.exe`.
7. URL JSON cố định:
   ```
   https://<tài-khoản>.github.io/<repo>/latest.json
   ```

> Từ giờ **chỉ cần tạo Release + đính kèm .exe** → UpdateChecker sẽ tự thấy bản mới.

---

## 2) Cách thủ công (tuỳ chọn)
Nếu không muốn dùng Actions, bạn có thể tự tạo installer, tự tính SHA256 và tự sửa `docs/latest.json`. Xem script mẫu tại `scripts/release-wpf-github.ps1`.

---

## 3) Mẫu `latest.json`
```json
{
  "version": "1.0.0",
  "releaseDate": "2025-10-04T00:00:00Z",
  "notes": "Ghi chú phát hành",
  "downloadUrl": "https://github.com/<user>/<repo>/releases/download/v1.0.0/YourInstaller-1.0.0-setup.exe",
  "sha256": "abc123..."
}
```

---

## 4) Lưu ý
- Bắt buộc tag dạng **`vX.Y.Z`** để workflow hiểu đúng version.
- Asset **.exe** bắt buộc phải đính kèm vào release.
- Nếu nhánh *main* là nhánh bảo vệ, bạn cần cho phép workflow push file `docs/latest.json` (hoặc dùng nhánh riêng cho Pages).
- WPF `UpdateChecker` nên **verify SHA256** đúng với trường `sha256` trong JSON (bộ mã đã hỗ trợ).

Chúc build vui vẻ!
