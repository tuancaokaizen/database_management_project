CREATE TABLE public."OrderItems"
(
    "OrderItemId"  uuid NOT NULL,
    "OrderCode"    bpchar(30) NOT NULL,
    "ItemCode"     bpchar(10) NOT NULL,
    "Price"        int4 NULL,
    "LineNum"      int4 NULL,
    "Quantity"     int4 NULL,
    "IsPromotion"  bool NULL,
    "Unit"         text NULL,
    "CreatedDate"  timestamptz(0) NULL,
    "ModifiedDate" timestamptz(0) NULL,
    CONSTRAINT "OrderItems_pkey" PRIMARY KEY ("OrderItemId")
);
CREATE INDEX idx_orderitems_created ON public."OrderItems" USING btree ("CreatedDate");
CREATE INDEX idx_orderitems_item ON public."OrderItems" USING btree ("ItemCode");
CREATE INDEX idx_orderitems_order ON public."OrderItems" USING btree ("OrderCode");

ALTER TABLE public."OrderItems"
    ADD CONSTRAINT "OrderItems_ItemCode_fkey" FOREIGN KEY ("ItemCode") REFERENCES public."Product" ("ItemCode");
ALTER TABLE public."OrderItems"
    ADD CONSTRAINT "OrderItems_OrderCode_fkey" FOREIGN KEY ("OrderCode") REFERENCES public."Orders" ("OrderCode");