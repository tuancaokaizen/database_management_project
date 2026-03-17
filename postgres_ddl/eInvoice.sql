CREATE TABLE public.einvoice
(
    id             uuid        NOT NULL,
    invoice_header varchar(10) NOT NULL,
    invoice_symbol varchar(6)  NOT NULL,
    invoice_date   timestamptz(0) NOT NULL,
    created_date   timestamptz(0) NOT NULL,
    modified_date  timestamptz(0) NOT NULL,
    CONSTRAINT einvoice_pkey PRIMARY KEY (id),
    CONSTRAINT einvoice_invoice_header_unique UNIQUE (invoice_header)
);

-- Index snake_case
CREATE INDEX idx_einvoice_invoice_date ON public.einvoice (invoice_date);