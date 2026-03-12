CREATE TABLE public.orders
(
    "OrderId"         uuid NOT NULL,
    "OrderCode"       bpchar(50) NOT NULL,
    "ShopCode"        bpchar(5) NULL,
    "OrderStatus"     int4 NULL,
    "CreatedDate"     date NULL,
    "ModifiedDate"    date NULL,
    "TransactionDate" date NULL,
    "CustomerCode"    bpchar(10) NULL,
    CONSTRAINT pk_orders PRIMARY KEY ("OrderId"),
    CONSTRAINT uq_order_code UNIQUE ("OrderCode")
);
CREATE INDEX idx_order_code ON public.orders USING btree ("OrderCode", "CreatedDate");
CREATE INDEX idx_orders_created_date ON public.orders USING btree ("CreatedDate");
CREATE INDEX idx_orders_modified_date ON public.orders USING btree ("ModifiedDate");

ALTER TABLE public.orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY ("CustomerCode") REFERENCES public.customer ("CustomerCode");
ALTER TABLE public.orders
    ADD CONSTRAINT fk_orders_shop FOREIGN KEY ("ShopCode") REFERENCES public.shop ("ShopCode");