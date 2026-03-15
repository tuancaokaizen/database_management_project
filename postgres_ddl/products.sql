CREATE TABLE public."Product"
(
    "ProductId"    uuid NOT NULL,
    "ItemCode"     bpchar(10) NOT NULL,
    "ItemName"     text NOT NULL,
    "CategoryCode" bpchar(10) NOT NULL,
    "TypeCode"     bpchar(10) NOT NULL,
    "BrandCode"    bpchar(10) NOT NULL,
    "SellPrice"    int4 NOT NULL,
    "StockPrice"   int4 NOT NULL,
    CONSTRAINT "Product_ItemCode_key" UNIQUE ("ItemCode"),
    CONSTRAINT "Product_pkey" PRIMARY KEY ("ProductId")
);