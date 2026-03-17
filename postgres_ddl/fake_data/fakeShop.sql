INSERT INTO public."Shop" (
    "Id",
    "ShopCode",
    "ShopName",
    "ShopAddress",
    "ShopType",
    "IsActive",
    "ShopOpenDate",
    "CreatedDate",
    "ModifiedDate"
)
SELECT
    gen_random_uuid(),
    -- Tạo ShopCode 5 ký tự: S0001, S0002...
    'S' || LPAD(s.id::text, 4, '0'),
    -- Tên cửa hàng
    (ARRAY['Nhà Thuốc ', 'Tiệm Thuốc ', 'Pharmacy ', 'Dược Phẩm '])[floor(random() * 4 + 1)] ||
    (ARRAY['An Tâm', 'Bình Minh', 'Sao Mai', 'Việt Pháp', 'Long Châu', 'Pharmacity', 'Mỹ Châu', 'Eco', 'Số ', 'Tâm Đức'])[floor(random() * 10 + 1)] ||
    CASE WHEN s.id % 2 = 0 THEN ' - Chi nhánh ' || s.id ELSE '' END,
    -- Địa chỉ ngẫu nhiên
    (ARRAY['Số ', 'Hẻm ', 'Mặt tiền đường '])[floor(random() * 3 + 1)] || floor(random() * 500 + 1) || ' ' ||
    (ARRAY['Lý Tự Trọng', 'Cách Mạng Tháng 8', 'Nguyễn Huệ', 'Trần Hưng Đạo', 'Hai Bà Trưng', 'Lê Lợi', 'Điện Biên Phủ'])[floor(random() * 7 + 1)] ||
    (ARRAY[', Quận 1, TP.HCM', ', Hoàn Kiếm, Hà Nội', ', Ninh Kiều, Cần Thơ', ', Hải Châu, Đà Nẵng', ', Biên Hòa, Đồng Nai'])[floor(random() * 5 + 1)],
    -- Loại hình shop
    (ARRAY['RETAIL', 'WHOLESALE', 'CLINIC'])[floor(random() * 3 + 1)],
    -- Trạng thái hoạt động (90% là True)
    (random() > 0.1),
    -- Ngày mở cửa ngẫu nhiên từ 5 năm trước đến nay
    NOW() - (random() * interval '1825 days'),
    NOW() - interval '10 days',
    NOW()
FROM generate_series(1, 50) AS s(id);