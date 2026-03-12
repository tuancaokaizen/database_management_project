CREATE TABLE IF NOT EXISTS public."orderItems"
(
    "OrderDetailID" uuid NOT NULL,
    "OrderCode" character(50) NOT NULL,
    "ItemCode" character(10) NOT NULL,
    "UnitCode" integer,
    "Quantity" integer,
    "Price" integer,
    "TotalPrice" integer,
    "CreatedDate" date,
    "Modified" date,
    PRIMARY KEY ("OrderDetailID")
    );

COMMENT ON TABLE public."orderItems"
    IS 'Item of Orders';