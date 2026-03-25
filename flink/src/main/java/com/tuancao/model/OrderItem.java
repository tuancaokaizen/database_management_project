package com.tuancao.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.io.Serializable;

public class OrderItem implements Serializable {
    @JsonProperty("OrderItemId") public String OrderItemId;
    @JsonProperty("ItemCode") public String ItemCode;
    @JsonProperty("Price") public Double Price;
    @JsonProperty("Quantity") public Integer Quantity;
    @JsonProperty("LineNum") public Integer LineNum;
    @JsonProperty("IsPromotion") public Boolean IsPromotion;
    @JsonProperty("Unit") public String Unit;

    public OrderItem() {}
}