package com.tuancao.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.io.Serializable;

public class EInvoice implements Serializable {
    @JsonProperty("Id") public String Id;
    @JsonProperty("InvoiceHeader") public String InvoiceHeader;
    @JsonProperty("InvoiceSymbol") public String InvoiceSymbol;
    @JsonProperty("InvoiceDate") public String InvoiceDate;

    public EInvoice() {}
}