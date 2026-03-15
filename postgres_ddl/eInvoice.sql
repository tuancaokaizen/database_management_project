CREATE TABLE public."EInvoice"
(
    "Id"            uuid NOT NULL,
    "InvoiceHeader" bpchar(10) NOT NULL,
    "InvoiceSymbol" bpchar(6) NOT NULL,
    "InvoiceDate"   timestamptz(0) NOT NULL,
    "CreatedDate"   timestamptz(0) NOT NULL,
    "ModifiedDate"  timestamptz(0) NOT NULL,
    CONSTRAINT "EInvoice_InvoiceHeader_key" UNIQUE ("InvoiceHeader"),
    CONSTRAINT "EInvoice_pkey" PRIMARY KEY ("Id")
);
CREATE INDEX idx_einvoice_date ON public."EInvoice" USING btree ("InvoiceDate");