INSERT INTO public."Product" (
    "ProductId",
    "ItemCode",
    "ItemName",
    "CategoryCode",
    "TypeCode",
    "BrandCode",
    "SellPrice",
    "StockPrice"
)
SELECT
    gen_random_uuid(), -- Tạo ID ngẫu nhiên
    'MED' || LPAD(s.id::text, 7, '0'), -- Mã thuốc: MED0000001, MED0000002...
    (ARRAY[
         'Paracetamol 500mg', 'Amoxicillin 250mg', 'Vitamin C 1000mg', 'Panadol Extra',
     'Efferalgan 500mg', 'Augmentin 625mg', 'Decolgen Forte', 'Strepsils Cool',
     'Gaviscon Dual Action', 'Berberin 50mg', 'Hapacol 150', 'Nexium 40mg',
     'Telfast 180mg', 'Singulair 10mg', 'Voltaren Emulgel', 'Cezil 10mg',
     'Boganic', 'Otrivin 0.1%', 'Salonpas Patch', 'Deep Heat'
         ])[floor(random() * 20 + 1)] || ' - Lô ' || s.id, -- Tên thuốc ngẫu nhiên kèm số lô
    (ARRAY['KHANGSINH', 'GIAMDAU', 'VITAMIN', 'TIEUHOA', 'HOHAP'])[floor(random() * 5 + 1)],
    (ARRAY['VIEN_NEN', 'VIEN_SUI', 'SIRO', 'KEM_BOI', 'TIEM'])[floor(random() * 5 + 1)],
    (ARRAY['DHG', 'TRAFACO', 'PFIZER', 'GSK', 'SANOFI'])[floor(random() * 5 + 1)],
    (random() * (500000 - 10000) + 10000)::int, -- Giá bán từ 10k đến 500k
    (random() * (8000 - 5000) + 5000)::int      -- Giá gốc (tượng trưng)
FROM generate_series(1, 100) AS s(id);