CREATE TABLE public.order_items
(
    order_item_id uuid        NOT NULL,
    order_code    varchar(30) NOT NULL,
    item_code     varchar(10) NOT NULL,
    price         int4 NULL,
    line_num      int4 NULL,
    quantity      int4 NULL,
    is_promotion  bool NULL,
    unit          text NULL,
    created_date  timestamptz(0) NULL,
    modified_date timestamptz(0) NULL,
    CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id)
);

-- Index viết thường toàn bộ
CREATE INDEX idx_order_items_created_date ON public.order_items (created_date);
CREATE INDEX idx_order_items_item_code ON public.order_items (item_code);
CREATE INDEX idx_order_items_order_code ON public.order_items (order_code);