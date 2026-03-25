package com.tuancao.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.io.Serializable;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Orders implements Serializable {
    @JsonProperty("OrderId") public String OrderId;
    @JsonProperty("OrderCode") public String OrderCode;
    @JsonProperty("ShopCode") public String ShopCode;
    @JsonProperty("CustomerCode") public String CustomerCode;
    @JsonProperty("OrderStatus") public Integer OrderStatus;

    @JsonProperty("CreatedDate") public String CreatedDate;
    @JsonProperty("ModifiedDate") public String ModifiedDate;

    @JsonProperty("InvoiceHeader") public String InvoiceHeader;
    @JsonProperty("EInvoice") public EInvoice EInvoice;
    @JsonProperty("OrderItems") public List<OrderItem> OrderItems;

    public Orders() {}
}