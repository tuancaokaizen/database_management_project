-- Xóa bảng cũ nếu tồn tại
DROP TABLE IF EXISTS public."Orders";

CREATE TABLE public."Orders"
(
    "OrderId"       UUID           NOT NULL,
    "OrderCode"     VARCHAR(30)    NOT NULL,
    "OrderStatus"   INT2           NULL,
    "ShopCode"      VARCHAR(5)     NULL,
    "CustomerCode"  VARCHAR(10)    NULL,
    "InvoiceHeader" VARCHAR(10)    NULL,
    "CreatedDate"   TIMESTAMPTZ(0) NOT NULL,
    "ModifiedDate"  TIMESTAMPTZ(0) NOT NULL,
    "Shipment"      INT2           NULL,
    "OrderType"     INT2           NULL,
    "OrderChannel"  INT2           NULL,
    CONSTRAINT "Orders_pkey" PRIMARY KEY ("OrderId"),
    CONSTRAINT "Orders_OrderCode_unique" UNIQUE ("OrderCode"),
    CONSTRAINT "Orders_InvoiceHeader_unique" UNIQUE ("InvoiceHeader")
);

-- Index với tên cột viết hoa
CREATE INDEX "idx_Orders_CreatedDate" ON public."Orders" ("CreatedDate");
CREATE INDEX "idx_Orders_CustomerCode" ON public."Orders" ("CustomerCode");
CREATE INDEX "idx_Orders_ShopCode" ON public."Orders" ("ShopCode");