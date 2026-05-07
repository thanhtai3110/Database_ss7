-- 1. Khám nghiệm tử thi: Cạm bẫy của Boolean Logic và NULL
-- Trong SQL, NULL không phải là số 0 hay chuỗi rỗng. Nó mang ý nghĩa là "Unknown" (Không xác định / Không biết). Vì hệ quản trị cơ sở dữ liệu (như MySQL, SQL Server) sử dụng logic 3 trạng thái (Three-Valued Logic: TRUE, FALSE, UNKNOWN), nên mọi phép toán so sánh với NULL đều trả về UNKNOWN.

-- Khi bạn viết WHERE id NOT IN (1, 2, NULL), hệ thống sẽ phân giải biểu thức này thành một chuỗi các mệnh đề AND như sau:
-- (id != 1) AND (id != 2) AND (id != NULL)

-- Giả sử chúng ta đang xét khóa học có id = 3:

-- (3 != 1) -> Trả về TRUE

-- (3 != 2) -> Trả về TRUE

-- (3 != NULL) -> Trả về UNKNOWN (Vì bạn không thể biết 3 có khác một giá trị "không xác định" hay không).

-- Kết quả của toàn bộ biểu thức logic sẽ là: TRUE AND TRUE AND UNKNOWN.
-- Trong toán học Boolean của SQL, phép AND có chứa UNKNOWN sẽ cho ra kết quả cuối cùng là UNKNOWN.

-- Tại sao truy vấn lại sụp đổ? Mệnh đề WHERE chỉ chấp nhận và giữ lại các dòng có kết quả kiểm tra là chính xác TRUE. Vì kết quả bị đánh giá là UNKNOWN đối với TẤT CẢ các khóa học, SQL Engine sẽ loại bỏ toàn bộ dữ liệu, dẫn đến bảng kết quả trả về 0 dòng.

-- 2. Giải pháp kiến trúc
-- Để code sống sót qua các đợt rác dữ liệu NULL sau này nếu bạn vẫn muốn dùng NOT IN, bạn bắt buộc phải "làm sạch" tập kết quả của Subquery trước khi nó được truyền ra cho truy vấn bên ngoài.

-- Giải pháp là bạn phải vá thêm mệnh đề WHERE course_id IS NOT NULL ngay bên trong Subquery. Điều này đảm bảo tập hợp trả về chỉ chứa các ID hợp lệ, loại bỏ triệt để mầm mống UNKNOWN gây sập logic.

-- 3. Thực thi (Viết lại câu lệnh SQL)
-- Bạn có hai cách để vá lỗi này.

-- Cách 1: Vá lỗi trực tiếp trên code cũ (Giữ lại NOT IN)


SELECT * FROM Courses
WHERE id NOT IN (
    SELECT course_id 
    FROM Enrollments 
    WHERE course_id IS NOT NULL -- Tấm khiên chống rác dữ liệu
);
-- Cách 2: Chuyển sang dùng NOT EXISTS (Khuyên dùng - An toàn tuyệt đối)

-- Như đã phân tích ở bài toán trước, NOT EXISTS sử dụng Correlated Subquery và đối chiếu trực tiếp giữa 2 bảng. Nó không tạo ra một tập hợp danh sách để so sánh IN / NOT IN, do đó nó hoàn toàn "miễn nhiễm" với lỗi logic do NULL gây ra. Đây là best practice cho trường hợp này:


SELECT c.* FROM Courses c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Enrollments e 
    WHERE e.course_id = c.id
);
-- Đoạn code dùng NOT EXISTS này vừa đảm bảo hiệu năng tốt hơn, vừa an toàn tuyệt đối với mọi loại dữ liệu rác, giúp team Tech tự tin chạy chiến dịch Black Friday.