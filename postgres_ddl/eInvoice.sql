-- Xóa bảng cũ nếu tồn tại
DROP TABLE IF EXISTS public."EInvoice";

CREATE TABLE public."EInvoice"
(
    "Id"            UUID           NOT NULL,
    "InvoiceHeader" VARCHAR(10)    NOT NULL,
    "InvoiceSymbol" VARCHAR(20)    NOT NULL, -- Tăng độ dài lên 20 để linh hoạt hơn
    "InvoiceDate"   TIMESTAMPTZ(0) NOT NULL,
    "CreatedDate"   TIMESTAMPTZ(0) NOT NULL,
    "ModifiedDate"  TIMESTAMPTZ(0) NOT NULL,
    CONSTRAINT "EInvoice_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "EInvoice_InvoiceHeader_unique" UNIQUE ("InvoiceHeader")
);

-- Index với tên cột viết hoa
CREATE INDEX "idx_EInvoice_InvoiceDate" ON public."EInvoice" ("InvoiceDate");
CREATE INDEX "idx_EInvoice_CreatedDate" ON public."EInvoice" ("CreatedDate");