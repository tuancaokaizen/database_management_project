BEGIN;

CREATE SCHEMA IF NOT EXISTS customer;
CREATE SCHEMA IF NOT EXISTS store;
CREATE SCHEMA IF NOT EXISTS product;
CREATE SCHEMA IF NOT EXISTS sale;

-- 1. GEOGRAPHY
CREATE TABLE IF NOT EXISTS geography (
    ward_id TEXT PRIMARY KEY,
    ward_name TEXT NOT NULL,
    population INTEGER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. PRODUCT SCHEMA
CREATE TABLE IF NOT EXISTS product.product (
    id TEXT PRIMARY KEY,
    name TEXT,
    type TEXT CHECK (type IN ('Medicine', 'Supplement')),
    unit TEXT,
    cost_price INTEGER,
    retail_price INTEGER,
    vat DECIMAL(5,2),
    status TEXT DEFAULT 'active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product.product_medicine (
    product_id TEXT PRIMARY KEY REFERENCES product.product(id),
    specialty_disease TEXT,
    is_prescription BOOLEAN,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS product.product_supplement (
    product_id TEXT PRIMARY KEY REFERENCES product.product(id),
    primary_function TEXT,
    brand TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. STORE SCHEMA
CREATE TABLE IF NOT EXISTS store.employee (
    employee_id TEXT PRIMARY KEY,
    name TEXT,
    degree TEXT,
    phone_number TEXT,
    address TEXT,
    store_code TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS store.store (
    code TEXT PRIMARY KEY,
    name TEXT,
    address TEXT,
    ward_id TEXT REFERENCES geography(ward_id),
    manager_id TEXT REFERENCES store.employee(employee_id),
    manager_name TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. CUSTOMER SCHEMA
CREATE TABLE IF NOT EXISTS customer.customer (
    id TEXT PRIMARY KEY,
    full_name TEXT,
    phone_number TEXT UNIQUE,
    ward_name_id TEXT REFERENCES geography(ward_id),
    address TEXT,
    year_of_birth INTEGER,
    gender TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. SALE SCHEMA
CREATE TABLE IF NOT EXISTS sale.invoice (
    id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES customer.customer(id),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(15,2),
    store_code TEXT REFERENCES store.store(code),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE store.employee
ADD CONSTRAINT fk_employee_store
FOREIGN KEY (store_code) REFERENCES store.store(code);

COMMIT;