INSERT INTO public."Customer" (
    "Id",
    "CustomerCode",
    "CustomerName",
    "CustomerAddress",
    "CustomerType",
    "Phone",
    "CreatedDate",
    "ModifiedDate"
)
SELECT
    gen_random_uuid(), -- Tạo ID duy nhất
    'CUS' || LPAD(s.id::text, 7, '0'), -- Mã KH: CUS0000001 -> CUS0001000
    -- Kết hợp ngẫu nhiên Họ + Tên đệm + Tên
    (ARRAY['Nguyễn ', 'Trần ', 'Lê ', 'Phạm ', 'Hoàng ', 'Huỳnh ', 'Phan ', 'Vũ ', 'Đặng ', 'Bùi '])[floor(random() * 10 + 1)] ||
    (ARRAY['Văn ', 'Thị ', 'Minh ', 'Anh ', 'Đức ', 'Hồng ', 'Tuấn ', 'Ngọc ', 'Quang ', 'Phương '])[floor(random() * 10 + 1)] ||
    (ARRAY['Anh', 'Bình', 'Chi', 'Dũng', 'Em', 'Giang', 'Hương', 'Khánh', 'Linh', 'Nam', 'Oanh', 'Phúc', 'Quân', 'Sơn', 'Tâm', 'Uyên', 'Vinh', 'Xuân', 'Yến', 'Zơn'])[floor(random() * 20 + 1)],
    -- Địa chỉ ngẫu nhiên tại các thành phố lớn
    (ARRAY['Quận 1, TP.HCM', 'Quận Cầu Giấy, Hà Nội', 'Quận Hải Châu, Đà Nẵng', 'Quận Ninh Kiều, Cần Thơ', 'TP. Thủ Đức, TP.HCM', 'Quận Ba Đình, Hà Nội', 'Quận Bình Thạnh, TP.HCM'])[floor(random() * 7 + 1)],
    -- Loại khách hàng
    (ARRAY['RETAIL', 'WHOLESALE', 'VIP', 'MEMBER'])[floor(random() * 4 + 1)],
    -- Số điện thoại (09 + 8 chữ số ngẫu nhiên)
    '09' || LPAD(floor(random() * 100000000)::text, 8, '0'),
    -- Ngày tạo ngẫu nhiên trong 2 năm qua
    NOW() - (random() * interval '730 days'),
    NOW()
FROM generate_series(1, 1000) AS s(id);