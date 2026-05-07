-- 1. Bảo vệ quan điểm: Cơ chế 'Short-circuit' và sự vượt trội của NOT EXISTS
-- Để hiểu tại sao bạn B thắng, chúng ta cần so sánh cách Database Engine xử lý hai toán tử này dưới hệ thống:

-- Tại sao NOT IN (của bạn A) lại là "ác mộng" về hiệu năng?

-- Cơ chế của IN/NOT IN là quét toàn bộ Subquery từ trong ra ngoài một lần duy nhất. Nó sẽ gom TẤT CẢ các ID trong bảng Payments (năm 2024) và lưu vào một danh sách tạm thời (temporary list) trên bộ nhớ (RAM).

-- Sau đó, hệ thống sẽ lấy từng ID của 5 triệu học viên đi đối chiếu rà soát với toàn bộ danh sách khổng lồ kia. Việc này ngốn cực kỳ nhiều tài nguyên CPU và Memory.

-- Lưu ý chết người: Nếu bảng Payments vô tình chứa dù chỉ 1 giá trị NULL trong cột student_id, toàn bộ mệnh đề NOT IN sẽ thất bại (trả về UNKNOWN), dẫn đến truy vấn không xuất ra bất kỳ kết quả nào.

-- Tại sao NOT EXISTS (của bạn B) lại chiến thắng với cơ chế 'Short-circuit'?

-- Khác với NOT IN trả về giá trị thực tế, EXISTS/NOT EXISTS chỉ quan tâm đến logic Boolean (Đúng/Sai). Liệu dữ liệu có tồn tại hay không?

-- Nó hoạt động theo cơ chế Truy vấn lồng tương quan (Correlated Subquery): Truy vấn bên ngoài sẽ quét qua từng hàng (từng học viên) ở bảng Students. Với mỗi học viên, truy vấn con bên trong bảng Payments sẽ được gọi ra chạy một lần.

-- Sự kỳ diệu của Short-circuit (Dừng sớm): Ngay khi Database Engine tìm thấy một (và chỉ một) dòng dữ liệu của học viên đó trong bảng Payments năm 2024, nó lập tức kết luận là EXISTS = TRUE (nghĩa là NOT EXISTS = FALSE). Hệ thống sẽ ngắt ngang (short-circuit), dừng ngay việc quét các dòng tiếp theo của học viên đó trong bảng Payments và chuyển luôn sang xét học viên tiếp theo.

-- Hệ thống không cần tạo danh sách tạm, tốn rất ít RAM và tốc độ quét (đặc biệt nếu kết hợp với Indexing) là cực kỳ chớp nhoáng.

-- 2. Thực thi: Viết câu lệnh SQL hoàn chỉnh
-- Dưới đây là câu lệnh áp dụng kỹ thuật Correlated Subquery với NOT EXISTS.

-- (Tip tối ưu: Ở mệnh đề WHERE của bảng Payments, thay vì dùng hàm YEAR(payment_date) = 2024 sẽ làm mất tác dụng của Index (Non-SARGable), chúng ta nên dùng khoảng thời gian >=, < để Database có thể tận dụng tối đa sức mạnh của Index, quét cực nhanh trên 5 triệu records).


SELECT s.email
FROM Students s
WHERE NOT EXISTS (
    SELECT 1 
    FROM Payments p
    WHERE p.student_id = s.id 
      AND p.payment_date >= '2024-01-01' 
      AND p.payment_date < '2025-01-01'
);
-- Giải thích cú pháp thực thi:

-- SELECT 1: Trong mệnh đề EXISTS, Database không quan tâm bạn SELECT cột gì (dù bạn để SELECT * hay SELECT id thì Engine cũng sẽ tự động tối ưu hóa). Tuy nhiên, dùng SELECT 1 là một quy ước ngầm chuẩn mực nhất để biểu thị rằng "Tôi chỉ cần kiểm tra xem có dòng dữ liệu nào tồn tại không, không cần trích xuất giá trị thực tế".

-- p.student_id = s.id: Đây chính là điểm neo tạo nên Correlated Subquery. Subquery bị phụ thuộc vào giá trị s.id truyền vào từ truy vấn cha ở bên ngoài.