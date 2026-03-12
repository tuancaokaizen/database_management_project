CREATE TABLE IF NOT EXISTS public.orders
(
    "OrderId" uuid NOT NULL,
    "OrderCode" character(50) NOT NULL,
    "ShopCode" character(5),
    "OrderStatus" integer,
    "CreatedDate" date,
    "ModifiedDate" date,
    "TransactionDate" date,
    "CustomerCode" character(10),
    PRIMARY KEY ("OrderId"),
    CONSTRAINT "OrderCode" UNIQUE ("OrderCode")
    );

COMMENT ON TABLE public.orders
    IS 'Order Table';

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

CREATE TABLE IF NOT EXISTS public.shop
(
    "Id" uuid NOT NULL,
    "ShopCode" character(5) NOT NULL,
    "ShopName" character(100),
    "ShopStatus" integer,
    "OpenDate" date,
    PRIMARY KEY ("Id"),
    CONSTRAINT "ShopCode" UNIQUE ("ShopCode")
    );

CREATE TABLE IF NOT EXISTS public.customer
(
    "Id" uuid NOT NULL,
    "CustomerCode" character(10) NOT NULL,
    "CustomerName" character(20),
    "Address" character(100),
    "FirstBuyDate" date,
    "CustomerPhone" character(10),
    PRIMARY KEY ("Id"),
    CONSTRAINT "CustomerCode" UNIQUE ("CustomerCode")
    );

COMMENT ON TABLE public.customer
    IS 'Customer Table';

CREATE TABLE IF NOT EXISTS public.products
(
    "Id" uuid NOT NULL,
    "ItemCode" character(10) NOT NULL,
    "ItemName" character(100),
    "CategoryCode" character(10),
    "Stockprice" integer,
    "Price" integer,
    CONSTRAINT "Id" PRIMARY KEY ("Id"),
    CONSTRAINT "ItemCode" UNIQUE ("ItemCode")
    );

ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT "ShopCode" FOREIGN KEY ("ShopCode")
    REFERENCES public.shop ("ShopCode") MATCH SIMPLE
    ON UPDATE NO ACTION
       ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public.orders
    ADD CONSTRAINT "CustomerCode" FOREIGN KEY ("CustomerCode")
    REFERENCES public.customer ("CustomerCode") MATCH SIMPLE
    ON UPDATE NO ACTION
       ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."orderItems"
    ADD CONSTRAINT "OrderCode" FOREIGN KEY ("OrderCode")
    REFERENCES public.orders ("OrderCode") MATCH SIMPLE
    ON UPDATE NO ACTION
       ON DELETE NO ACTION
    NOT VALID;


ALTER TABLE IF EXISTS public."orderItems"
    ADD CONSTRAINT "ItemCode" FOREIGN KEY ("ItemCode")
    REFERENCES public.products ("ItemCode") MATCH SIMPLE
    ON UPDATE NO ACTION
       ON DELETE NO ACTION
    NOT VALID;

END;