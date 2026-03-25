import os
import random
import re
from faker import Faker

fake = Faker('vi_VN')

FOLDER_NAME = "postgres_ddl"
FILE_NAME = "import_postgre.sql"
FILE_PATH = os.path.join(FOLDER_NAME, FILE_NAME)

NUM_PRODUCTS = 100
NUM_STORES = 50
NUM_CUSTOMERS = 5000
EMPS_PER_STORE = 10

raw_data = """1Đặc khu Côn Đảo2Phường An Đông3Phường An Hội Đông4Phường An Hội Tây5Phường An Khánh6Phường An Lạc7Phường An Nhơn8Phường An Phú9Phường An Phú Đông10Phường Bà Rịa11Phường Bàn Cờ12Phường Bảy Hiền13Phường Bến Cát14Phường Bến Thành15Phường Bình Cơ16Phường Bình Dương17Phường Bình Đông18Phường Bình Hòa19Phường Bình Hưng Hòa20Phường Bình Lợi Trung21Phường Bình Phú22Phường Bình Quới23Phường Bình Tân24Phường Bình Tây25Phường Bình Thạnh26Phường Bình Thới27Phường Bình Tiên28Phường Bình Trị Đông29Phường Bình Trưng30Phường Cát Lái31Phường Cầu Kiệu32Phường Cầu Ông Lãnh33Phường Chánh Hiệp34Phường Chánh Hưng35Phường Chánh Phú Hòa36Phường Chợ Lớn37Phường Chợ Quán38Phường Dĩ An39Phường Diên Hồng40Phường Đông Hòa41Phường Đông Hưng Thuận42Phường Đức Nhuận43Phường Gia Định44Phường Gò Vấp45Phường Hạnh Thông46Phường Hiệp Bình47Phường Hòa Bình48Phường Hòa Hưng49Phường Hòa Lợi50Phường Khánh Hội51Phường Lái Thiêu52Phường Linh Xuân53Phường Long Bình54Phường Long Hương55Phường Long Nguyên56Phường Long Phước57Phường Long Trường58Phường Minh Phụng59Phường Nhiêu Lộc60Phường Phú An61Phường Phú Định62Phường Phú Lâm63Phường Phú Lợi64Phường Phú Mỹ65Phường Phú Nhuận66Phường Phú Thạnh67Phường Phú Thọ68Phường Phú Thọ Hòa69Phường Phú Thuận70Phường Phước Long71Phường Phước Thắng72Phường Rạch Dừa73Phường Sài Gòn74Phường Tam Bình75Phường Tam Long76Phường Tam Thắng77Phường Tăng Nhơn Phú78Phường Tân Bình79Phường Tân Định80Phường Tân Đông Hiệp81Phường Tân Hải82Phường Tân Hiệp83Phường Tân Hòa84Phường Tân Hưng85Phường Tân Khánh86Phường Tân Mỹ87Phường Tân Phú88Phường Tân Phước89Phường Tân Sơn90Phường Tân Sơn Hòa91Phường Tân Sơn Nhất92Phường Tân Sơn Nhì93Phường Tân Tạo94Phường Tân Thành95Phường Tân Thới Hiệp96Phường Tân Thuận97Phường Tân Uyên98Phường Tây Nam99Phường Tây Thạnh100Phường Thạnh Mỹ Tây101Phường Thông Tây Hội102Phường Thới An103Phường Thới Hòa104Phường Thủ Dầu Một105Phường Thủ Đức106Phường Thuận An107Phường Thuận Giao108Phường Trung Mỹ Tây109Phường Vĩnh Hội110Phường Vĩnh Tân111Phường Vũng Tàu112Phường Vườn Lài113Phường Xóm Chiếu114Phường Xuân Hòa115Xã An Long116Xã An Nhơn Tây117Xã An Thới Đông118Xã Bà Điểm119Xã Bàu Bàng120Xã Bàu Lâm121Xã Bắc Tân Uyên122Xã Bình Chánh123Xã Bình Châu124Xã Bình Giã125Xã Bình Hưng126Xã Bình Khánh127Xã Bình Lợi128Xã Bình Mỹ129Xã Cần Giờ130Xã Châu Đức131Xã Châu Pha132Xã Củ Chi133Xã Dầu Tiếng134Xã Đất Đỏ135Xã Đông Thạnh136Xã Hiệp Phước137Xã Hòa Hiệp138Xã Hòa Hội139Xã Hóc Môn140Xã Hồ Tràm141Xã Hưng Long142Xã Kim Long143Xã Long Điền144Xã Long Hải145Xã Long Hòa146Xã Long Sơn147Xã Minh Thạnh148Xã Ngãi Giao149Xã Nghĩa Thành150Xã Nhà Bè151Xã Nhuận Đức152Xã Phú Giáo153Xã Phú Hòa Đông154Xã Phước Hải155Xã Phước Hòa156Xã Phước Thành157Xã Tân An Hội158Xã Tân Nhựt159Xã Tân Vĩnh Lộc160Xã Thái Mỹ161Xã Thanh An162Xã Thạnh An163Xã Thường Tân164Xã Trừ Văn Thố165Xã Vĩnh Lộc166Xã Xuân Sơn167Xã Xuân Thới Sơn168Xã Xuyên Mộc"""

ward_list = [w.strip() for w in re.findall(r'[^\d]+', raw_data) if w.strip()]
ward_ids = [f"W{str(i+1).zfill(3)}" for i in range(len(ward_list))]
ward_map = dict(zip(ward_ids, ward_list))

SUPPLEMENT_BRANDS = [
    'Blackmores (Úc)', 'Healthy Care (Úc)', 'DHC (Nhật Bản)', 'Orihiro (Nhật Bản)',
    'Shiseido (Nhật Bản)', 'Nature Bounty (Mỹ)', 'Kirkland Signature (Mỹ)',
    'Solgar (Mỹ)', 'Swisse (Úc)', 'Sanofi (Pháp)', 'Meiji (Nhật Bản)',
    'Fancl (Nhật Bản)', 'Puritan Pride (Mỹ)', 'Now Foods (Mỹ)',
    'Bio-Island (Úc)', 'Traphaco (Việt Nam)', 'DHG Pharma (Việt Nam)',
    'Sao Thái Dương (Việt Nam)', 'Bidiphar (Việt Nam)', 'GNC (Mỹ)'
]

SUPPLEMENT_FUNCTIONS = [
    'Bổ sung Vitamin', 'Hỗ trợ xương khớp', 'Tăng cường đề kháng',
    'Bổ mắt', 'Hỗ trợ tiêu hóa', 'Đẹp da & Tóc', 'Bổ não',
    'Hỗ trợ giấc ngủ', 'Giảm cân an toàn', 'Tăng cường sinh lực',
    'Hỗ trợ gan', 'Canxi cho bé', 'DHA cho bà bầu'
]

def gen_phone():
    return f"0{random.choice(['3','5','7','8','9'])}{random.randint(10000000, 99999999)}"

def escape_sql(val):
    return str(val).replace("'", "''")

def gen_vietnamese_name(gender='Nam'):
    raw_name = fake.name_male() if gender == 'Nam' else fake.name_female()

    prefixes = ['Ông', 'Bà', 'Quý ông', 'Quý bà', 'Quý cô', 'Anh', 'Chị', 'Cô']

    name_parts = raw_name.split()
    if name_parts[0] in prefixes:
        return " ".join(name_parts[1:])
    return raw_name

def generate_sql():
    sql = []

    for w_id, name in ward_map.items():
        sql.append(f"INSERT INTO geography (ward_id, ward_name, population) VALUES ('{w_id}', '{name}', {random.randint(100000, 990000)});")

    for i in range(1, NUM_PRODUCTS + 1):
        p_id = f"ITEM{str(i).zfill(5)}"
        p_type = random.choice(['Medicine', 'Supplement'])
        cost = random.randint(10, 500) * 1000
        retail = int(cost * random.uniform(1.2, 1.5))
        vat = random.choice([5.0, 8.0, 10.0])

        sql.append(f"INSERT INTO product.product (id, name, type, unit, cost_price, retail_price, vat, status) "
                   f"VALUES ('{p_id}', 'Sản phẩm {i}', '{p_type}', 'Viên', {cost}, {retail}, {vat}, 'active');")

        if p_type == 'Medicine':
            sql.append(f"INSERT INTO product.product_medicine (product_id, specialty_disease, is_prescription) "
                       f"VALUES ('{p_id}', '{random.choice(['Tiêu hóa', 'Giảm đau', 'Hô hấp', 'Tim mạch', 'Cơ xương khớp'])}', {random.choice(['true', 'false'])});")
        else:
            func = random.choice(SUPPLEMENT_FUNCTIONS)
            brand = random.choice(SUPPLEMENT_BRANDS)
            sql.append(f"INSERT INTO product.product_supplement (product_id, primary_function, brand) "
                       f"VALUES ('{p_id}', '{func}', '{brand}');")

    emp_records = []
    for eid in range(1, (NUM_STORES * EMPS_PER_STORE) + 1):
        emp_id_str = f"EMP{str(eid).zfill(5)}"
        gender = random.choice(['Nam', 'Nữ'])
        name = gen_vietnamese_name(gender)
        phone = gen_phone()
        emp_ward_name = random.choice(ward_list)
        sql.append(f"INSERT INTO store.employee (employee_id, name, degree, phone_number, address) "
                   f"VALUES ('{emp_id_str}', '{escape_sql(name)}', 'Dược sĩ', '{phone}', '{escape_sql(emp_ward_name)}');")
        emp_records.append({"id": emp_id_str, "name": name})

    for s_code in range(1, NUM_STORES + 1):
        s_id = f"SHOP{str(s_code).zfill(3)}"
        store_ward_id = random.choice(ward_ids)
        store_ward_name = ward_map[store_ward_id]
        manager_index = (s_code - 1) * EMPS_PER_STORE
        manager = emp_records[manager_index]

        sql.append(f"INSERT INTO store.store (code, name, address, ward_id, manager_id, manager_name) "
                   f"VALUES ('{s_id}', 'Nhà thuốc số {s_code}', '{escape_sql(store_ward_name)}', '{store_ward_id}', '{manager['id']}', '{escape_sql(manager['name'])}');")

        for j in range(EMPS_PER_STORE):
            e_idx = manager_index + j
            target_emp_id = emp_records[e_idx]['id']
            sql.append(f"UPDATE store.employee SET store_code = '{s_id}' WHERE employee_id = '{target_emp_id}';")

    used_phones = set()
    for i in range(1, NUM_CUSTOMERS + 1):
        c_id = f"CUS{str(i).zfill(6)}"
        gender = random.choice(['Nam', 'Nữ'])
        full_name = gen_vietnamese_name(gender)
        phone = gen_phone()
        while phone in used_phones: phone = gen_phone()
        used_phones.add(phone)
        c_ward_id = random.choice(ward_ids)
        sql.append(f"INSERT INTO customer.customer (id, full_name, phone_number, ward_name_id, address, year_of_birth, gender) "
                   f"VALUES ('{c_id}', '{escape_sql(full_name)}', '{phone}', '{c_ward_id}', '{escape_sql(ward_map[c_ward_id])}', {random.randint(1970, 2005)}, '{gender}');")

    return sql

if not os.path.exists(FOLDER_NAME): os.makedirs(FOLDER_NAME)
with open(FILE_PATH, 'w', encoding='utf-8') as f:
    f.write("BEGIN;\n\n")
    f.write("SET CONSTRAINTS ALL DEFERRED;\n\n")
    for line in generate_sql(): f.write(line + "\n")
    f.write("\nCOMMIT;")

print(f"File đã lưu tại: {FILE_PATH}")