-- 1. Phân tích nguyên nhân gây lỗi
-- Bản chất toán học của toán tử =: Trong SQL, toán tử = là một toán tử so sánh đơn trị (scalar). Điều này có nghĩa là nó yêu cầu vế trái và vế phải đều phải là một giá trị duy nhất để có thể thực hiện phép so sánh (ví dụ: X = Y).

-- Khi kết hợp với Subquery: Toán tử = chỉ hợp lệ khi Subquery trả về chính xác 1 dòng và 1 cột (Single-row subquery).

-- Lý do hệ thống bị sập:

-- Ngày hôm qua: Giảng viên A (instructor_id = 5) có thể chỉ đang có 1 khóa học trên hệ thống. Subquery lúc đó trả về 1 kết quả duy nhất (ví dụ: 500000). Câu lệnh trở thành WHERE price = 500000, code chạy hoàn toàn bình thường.

-- Ngày hôm nay: Khi giảng viên A mở bán thêm 2 khóa học với giá khác nhau, Subquery không còn trả về 1 giá trị nữa mà trả về một tập hợp (set) gồm 3 giá trị (ví dụ: [500000, 300000, 700000]).

-- Kết luận: Hệ quản trị cơ sở dữ liệu không thể thực hiện phép toán price = [500000, 300000, 700000]. Nó không biết phải so sánh price với con số nào trong ba con số kia, dẫn đến sự mơ hồ về mặt logic. Do đó, hệ thống báo lỗi "Subquery returns more than 1 row" (Truy vấn con trả về nhiều hơn 1 dòng) và dừng thực thi.

-- 2. Thực thi (Viết lại câu lệnh SQL)
-- Để vá lỗi này và đảm bảo hệ thống chịu tải được mọi số lượng khóa học của ông A, chúng ta phải chuyển từ toán tử so sánh đơn trị (=) sang toán tử làm việc với tập hợp (IN).

-- Toán tử IN sẽ kiểm tra xem giá trị price của từng khóa học có nằm trong danh sách các mức giá được trả về từ Subquery hay không.

-- Đoạn code sửa lỗi:

SELECT title, price
FROM Courses
WHERE price IN (
    SELECT price 
    FROM Courses 
    WHERE instructor_id = 5
);