CREATE TABLE public."Orders"
(
    "OrderId"       uuid NOT NULL,
    "OrderCode"     bpchar(30) NOT NULL,
    "OrderStatus"   int2 NULL,
    "ShopCode"      bpchar(5) NULL,
    "CustomerCode"  bpchar(10) NULL,
    "InvoiceHeader" bpchar(10) NULL,
    "CreatedDate"   timestamptz(0) NOT NULL,
    "ModifiedDate"  timestamptz(0) NOT NULL,
    "Shipment"      int2 NULL,
    "OrderType"     int2 NULL,
    "OrderChannel"  int2 NULL,
    CONSTRAINT "Orders_InvoiceHeader_key" UNIQUE ("InvoiceHeader"),
    CONSTRAINT "Orders_OrderCode_key" UNIQUE ("OrderCode"),
    CONSTRAINT "Orders_pkey" PRIMARY KEY ("OrderId")
);
CREATE INDEX idx_orders_created ON public."Orders" USING btree ("CreatedDate");
CREATE INDEX idx_orders_customer ON public."Orders" USING btree ("CustomerCode");
CREATE INDEX idx_orders_shop ON public."Orders" USING btree ("ShopCode");


ALTER TABLE public."Orders"
    ADD CONSTRAINT "Orders_CustomerCode_fkey" FOREIGN KEY ("CustomerCode") REFERENCES public."Customer" ("CustomerCode");
ALTER TABLE public."Orders"
    ADD CONSTRAINT "Orders_InvoiceHeader_fkey" FOREIGN KEY ("InvoiceHeader") REFERENCES public."EInvoice" ("InvoiceHeader");
ALTER TABLE public."Orders"
    ADD CONSTRAINT "Orders_ShopCode_fkey" FOREIGN KEY ("ShopCode") REFERENCES public."Shop" ("ShopCode");