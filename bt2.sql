-- 1. Phân tích Kiến trúc dữ liệu
-- "Derived Table" (Bảng dẫn xuất) là gì? Bảng dẫn xuất thực chất là một bảng ảo (virtual table) được tạo ra tạm thời từ tập kết quả của một câu truy vấn con (Subquery) nằm bên trong mệnh đề FROM. Bảng này chỉ tồn tại trong bộ nhớ (RAM) ở thời điểm truy vấn chính đang chạy và sẽ bị hủy ngay lập tức sau khi có kết quả trả về.

-- Tại sao chuẩn SQL lại bắt buộc Derived Table phải có Alias (Bí danh)?

-- Nguyên tắc định danh thực thể: Trong mô hình cơ sở dữ liệu quan hệ (Relational Database), bất kỳ một đối tượng nào đóng vai trò là "nguồn cung cấp dữ liệu" (như Table hay View) đều bắt buộc phải có một cái tên duy nhất.

-- Tham chiếu và xử lý mơ hồ (Ambiguity Resolution): Khi bạn dùng SELECT SUM(total_spent) ở truy vấn cha, SQL Engine cần biết cột total_spent này được lấy từ bảng nào. Nếu bạn muốn kết nối (JOIN) bảng ảo này với các bảng vật lý khác trong DB, hệ thống cũng cần một cái tên cụ thể để tham chiếu (ví dụ: AliasName.total_spent). Nếu không có bí danh, bộ phân tích cú pháp (SQL Parser) sẽ mất phương hướng và từ chối thực thi để tránh các lỗi logic tiềm ẩn.

-- 2. Thực thi (Viết lại câu lệnh SQL)
-- Để vá lỗi này, bạn chỉ cần thực hiện một thao tác cực kỳ đơn giản: Đặt cho Derived Table một cái tên (Alias) ở ngay sau dấu đóng ngoặc đơn ) của truy vấn con. Bạn có thể dùng từ khóa AS hoặc không có từ khóa AS đều được.

-- Đoạn code sửa lỗi:

SELECT SUM(total_spent)
FROM (
    SELECT student_id, SUM(amount) as total_spent
    FROM Payments
    GROUP BY student_id
    HAVING SUM(amount) > 10000000
) AS vip_students;