CREATE TABLE public."Customer"
(
    "Id"              uuid NOT NULL,
    "CustomerCode"    bpchar(10) NOT NULL,
    "CustomerName"    text NOT NULL,
    "CustomerAddress" text NULL,
    "CustomerType"    bpchar(10) NOT NULL,
    "Phone"           bpchar(10) NOT NULL,
    "CreatedDate"     timestamptz(0) NOT NULL,
    "ModifiedDate"    timestamptz(0) NOT NULL,
    CONSTRAINT "Customer_CustomerCode_key" UNIQUE ("CustomerCode"),
    CONSTRAINT "Customer_pkey" PRIMARY KEY ("Id")
);