-- Xóa bảng cũ nếu tồn tại
DROP TABLE IF EXISTS public."OrderItems";

CREATE TABLE public."OrderItems"
(
    "OrderItemId"   UUID          NOT NULL,
    "OrderCode"     VARCHAR(30)   NOT NULL,
    "ItemCode"      VARCHAR(10)   NOT NULL,
    "Price"         INT4          NULL,
    "LineNum"       INT4          NULL,
    "Quantity"      INT4          NULL,
    "IsPromotion"   BOOLEAN       NULL,
    "Unit"          TEXT          NULL,
    "CreatedDate"   TIMESTAMPTZ(0) NULL,
    "ModifiedDate"  TIMESTAMPTZ(0) NULL,
    CONSTRAINT "OrderItems_pkey" PRIMARY KEY ("OrderItemId")
);

-- Index cũng nên đặt tên theo format mới
CREATE INDEX "idx_OrderItems_CreatedDate" ON public."OrderItems" ("CreatedDate");
CREATE INDEX "idx_OrderItems_ItemCode"    ON public."OrderItems" ("ItemCode");
CREATE INDEX "idx_OrderItems_OrderCode"   ON public."OrderItems" ("OrderCode");