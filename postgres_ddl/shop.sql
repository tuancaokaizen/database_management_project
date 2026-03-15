CREATE TABLE public."Shop"
(
    "Id"           uuid NOT NULL,
    "ShopCode"     bpchar(5) NOT NULL,
    "ShopName"     text NOT NULL,
    "ShopAddress"  text NOT NULL,
    "ShopType"     bpchar(10) NULL,
    "IsActive"     bool NOT NULL,
    "ShopOpenDate" timestamptz(0) NOT NULL,
    "CreatedDate"  timestamptz(0) NOT NULL,
    "ModifiedDate" timestamptz(0) NOT NULL,
    CONSTRAINT "Shop_ShopCode_key" UNIQUE ("ShopCode"),
    CONSTRAINT "Shop_pkey" PRIMARY KEY ("Id")
);
CREATE INDEX idx_shop_open ON public."Shop" USING btree ("ShopOpenDate");