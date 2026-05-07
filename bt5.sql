-- 1. Giải pháp kiến trúc: Sức mạnh của Scalar Subquery trong mệnh đề SELECT
-- Bản chất của vấn đề: Đúng như "nỗi đau kỹ thuật" đã nêu, các hàm gộp (Aggregate Functions) như AVG(), SUM() mặc định sẽ gom nhóm (collapse) nhiều dòng dữ liệu thành một dòng kết quả duy nhất. Nếu bạn gọi hàm AVG(price) ở truy vấn ngoài cùng, SQL bắt buộc bạn phải dùng GROUP BY cho title. Điều này dẫn đến việc hệ thống sẽ tính giá trung bình của... chính khóa học đó (hoàn toàn vô nghĩa), thay vì tính trung bình của toàn bộ các khóa học trên hệ thống.

-- Vai trò của Scalar Subquery (Truy vấn con đơn trị): Đây là một câu truy vấn độc lập, có đặc điểm là luôn trả về chính xác 1 giá trị duy nhất (1 dòng, 1 cột). Ví dụ: (SELECT AVG(price) FROM Courses) sẽ chạy và sinh ra một con số duy nhất, giả sử là 400000.

-- Cơ chế giải quyết bài toán "Vừa chi tiết, vừa tổng quan":

-- Khi bạn đặt một Scalar Subquery vào bên trong mệnh đề SELECT, SQL Engine sẽ xử lý nó trước và coi kết quả trả về như một hằng số (constant value) được đính kèm vào mỗi dòng của truy vấn bên ngoài.

-- Truy vấn cha bên ngoài vẫn thực hiện nhiệm vụ quét qua từng dòng một cách chi tiết (xuất ra title, price của Khóa A, Khóa B...).

-- Tại mỗi dòng, nó sẽ lấy giá trị price của dòng đó trừ đi cái "hằng số tổng quan" vừa được tính ra từ Subquery. Nhờ vậy, cấu trúc dữ liệu chi tiết của bảng không hề bị phá vỡ hay gom gộp, mà bạn vẫn có được con số vĩ mô để thực hiện phép đối chiếu chéo.

-- 2. Thực thi (Viết câu lệnh SQL hoàn chỉnh)
-- Áp dụng đúng kiến trúc trên, chúng ta sẽ đặt câu lệnh tính trung bình vào trong cặp dấu ngoặc đơn () ngay tại mệnh đề SELECT để tạo thành cột Price_Difference.

-- Đoạn code thực thi:
SELECT 
    title, 
    price, 
    price - (SELECT AVG(price) FROM Courses) AS Price_Difference
FROM Courses;