# Tài liệu Authentication & Security Flow

Tài liệu này mô tả chi tiết cách thức hoạt động của hệ thống Authentication (Xác thực), Authorization (Phân quyền), JWT và luồng Đăng ký/Đăng nhập trong project backend `lmh.web`.

## 1. Tổng quan Công nghệ

Project sử dụng **Spring Security** kết hợp với **JWT (JSON Web Token)** và **OAuth2** để bảo mật ứng dụng.

- **Authentication**: Xác thực người dùng thông qua Username/Password hoặc OAuth2 (Google...).
- **Authorization**: Phân quyền dựa trên Role (trong code hiện tại là `ROLE_USER`, v.v.).
- **Token Management**: Sử dụng cặp Access Token và Refresh Token. Refresh Token được lưu trữ trong **Redis**.
- **Security Config**: Cấu hình trong class `SecurityConfig`.

## 2. Luồng Đăng ký & Đăng nhập

### 2.1. Đăng ký (Native)
**Endpoint**: `POST /api/auth/register`

1.  **Client** gửi thông tin đăng ký (username, password, email, name...).
2.  **`AuthenticationController`** nhận request và gọi `AuthenticationService.register`.
3.  **`AuthenticationService`**:
    *   Kiểm tra `username` hoặc `email` đã tồn tại chưa. Nếu có -> Ném lỗi.
    *   Mã hóa mật khẩu bằng `BCryptPasswordEncoder`.
    *   Tạo `User` mới với trạng thái `enable = false` (chưa kích hoạt).
    *   Tạo một `VerificationToken` (UUID) và lưu vào database.
    *   Gửi email chứa link xác thực (kèm token) đến email người dùng.
4.  **Xác thực Email** (`GET /api/auth/verify?token=...`):
    *   Người dùng click link trong email.
    *   Hệ thống kiểm tra token hợp lệ và chưa hết hạn.
    *   Cập nhật `User.enable = true`.
    *   Xóa token xác thực.

### 2.2. Đăng nhập (Native)
**Endpoint**: `POST /api/auth/login`

1.  **Client** gửi Username/Email và Password.
2.  **`AuthenticationService.login`**:
    *   Tìm user trong database.
    *   Kiểm tra user có đang `enable` không.
    *   So khớp password (đã mã hóa).
3.  **Tạo Token**:
    *   Nếu thông tin đúng, hệ thống tạo **Access Token** (ngắn hạn) và **Refresh Token** (dài hạn).
    *   **Refresh Token** được lưu vào **Redis** để quản lý phiên đăng nhập và khả năng thu hồi (revoke).
4.  **Response**: Trả về cả 2 token cho Client.

### 2.3. Đăng nhập qua OAuth2 (Google)
**Luồng**:
1.  Người dùng login qua Google.
2.  Nếu thành công, **`CustomSuccessHandler`** được kích hoạt.
3.  **`CustomSuccessHandler`**:
    *   Lấy thông tin email, name từ Google profile.
    *   Kiểm tra email trong DB. Nếu chưa có -> Tự động tạo User mới.
    *   Tạo Access Token và Refresh Token cho user này.
    *   Redirect trình duyệt về Frontend URL kèm theo token trên query param (ví dụ: `frontendUrl/auth/google-callback?accessToken=...`).

## 3. Cơ chế hoạt động của JWT

Hệ thống sử dụng thư viện `Nimbus JOSE + JWT`.

### 3.1. Cấu trúc Token
Token được ký bằng thuật toán **HS512** với một `SIGNER_KEY` bí mật.

*   **Access Token Claims**:
    *   `sub`: Username.
    *   `iss`: Issuer ("LMH").
    *   `scope`: Role của user (ví dụ: "USER").
    *   `id`: User ID.
    *   `email`: Email.
    *   `exp`: Thời gian hết hạn.
    *   `jti`: UUID (ID của token).

*   **Refresh Token Claims**:
    *   Chứa ít thông tin hơn, chủ yếu là `sub`, `scope` và thời gian hết hạn dài hơn.

### 3.2. Validation (Xác thực Token)
Project implement một **`CustomJwtDecoder`** để can thiệp vào quá trình xác thực JWT mặc định của Spring Security Resource Server.

1.  Khi có request gửi kèm Bearer Token:
    *   **`CustomJwtDecoder`** gọi `AuthenticationService.introspect(token)`.
    *   **`AuthenticationService.verifiedToken`**:
        *   Parse token và verify chữ ký (signature) với `SIGNER_KEY`.
        *   Kiểm tra thời gian hết hạn (`exp`).
        *   **Check Blacklist**: Kiểm tra xem ID của token (`jti`) có nằm trong bảng `InvalidToken` không (trường hợp user đã logout).
2.  Nếu token hợp lệ, `NimbusJwtDecoder` sẽ decode token thành object `Jwt`.
3.  **`JwtAuthenticationConverter`** chuyển đổi claim `scope` thành danh sách `GrantedAuthority` (có prefix `ROLE_`) để Spring Security sử dụng cho việc phân quyền.

## 4. Bảo mật & Phân quyền (Security & Permissions)

### 4.1. Cấu hình (`SecurityConfig`)
*   **CSRF**: Disabled (`AbstractHttpConfigurer::disable`).
*   **CORS**: Cấu hình để cho phép các domain frontend (localhost, web.app) gọi API.
*   **Authorize Requests**:
    *   Cấu hình hiện tại đang cho phép **TẤT CẢ** các request (`.anyRequest().permitAll()`).
    *   *Lưu ý: Các dòng code yêu cầu xác thực (`.anyRequest().authenticated()`) hiện đang bị comment. Điều này có nghĩa là hiện tại API đang **KHÔNG** yêu cầu login để gọi.*
    *   Khi enable lại bảo mật: Các API công khai (login, register...) được `permitAll`, còn lại yêu cầu `authenticated()`.

### 4.2. Logout & Token Revocation
**Endpoint**: `POST /api/auth/logout`

1.  Client gửi request logout kèm token.
2.  Hệ thống xác thực token.
3.  **Xóa Refresh Token** tương ứng khỏi **Redis**.
4.  **Blacklist Access Token**: Lưu ID (`jti`) và thời gian hết hạn của Access Token vào bảng `invalid_tokens`. Các request sau đó dùng token này sẽ bị từ chối bởi `CustomJwtDecoder`.

### 4.3. Refresh Token Flow
**Endpoint**: `POST /api/auth/refresh`

1.  Dùng khi Access Token hết hạn nhưng Refresh Token còn hạn.
2.  Client gửi Refresh Token.
3.  Hệ thống verify Refresh Token và kiểm tra sự tồn tại trong **Redis**.
4.  Nếu khớp: Xóa Refresh Token cũ trong Redis, tạo cặp Access/Refresh Token mới và trả về.

## 5. Các Component Quan trọng

| Component | Vai trò |
| :--- | :--- |
| `SecurityConfig` | Cấu hình chính của Spring Security. |
| `AuthenticationController` | API endpoints cho auth. |
| `AuthenticationServiceImpl` | Logic cốt lõi: login, register, generate token, verify token. |
| `CustomJwtDecoder` | Middleware giải mã và kiểm tra tính hợp lệ của token (bao gồm check hết hạn và blacklist). |
| `CustomSuccessHandler` | Xử lý logic sau khi login OAuth2 thành công. |
| `RedisService` | Lưu trữ và quản lý Refresh Token. |
| `InvalidTokenRepository` | Lưu trữ các token đã bị hủy (logout) để chặn sử dụng lại. |
