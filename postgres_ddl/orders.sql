CREATE TABLE public.orders
(
    order_id       uuid        NOT NULL,
    order_code     varchar(30) NOT NULL,
    order_status   int2 NULL,
    shop_code      varchar(5) NULL,
    customer_code  varchar(10) NULL,
    invoice_header varchar(10) NULL,
    created_date   timestamptz(0) NOT NULL,
    modified_date  timestamptz(0) NOT NULL,
    shipment       int2 NULL,
    order_type     int2 NULL,
    order_channel  int2 NULL,
    CONSTRAINT orders_pkey PRIMARY KEY (order_id),
    CONSTRAINT orders_order_code_unique UNIQUE (order_code),
    CONSTRAINT orders_invoice_header_unique UNIQUE (invoice_header)
);

-- Index viết thường toàn bộ
CREATE INDEX idx_orders_created_date ON public.orders (created_date);
CREATE INDEX idx_orders_customer_code ON public.orders (customer_code);
CREATE INDEX idx_orders_shop_code ON public.orders (shop_code);