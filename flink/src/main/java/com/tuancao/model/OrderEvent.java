package com.tuancao.model;

import java.util.List;

public class OrderEvent {
    public String OrderId;
    public String OrderCode;
    public Integer OrderStatus;
    public String ShopCode;
    public String CustomerCode;
    public String InvoiceHeader;
    public String CreatedDate;
    public String ModifiedDate;
    public EInvoice EInvoice;
    public List<OrderItem> OrderItems;

    public static class EInvoice {
        public String Id;
        public String InvoiceHeader;
        public String InvoiceSymbol;
        public String InvoiceDate;
    }

    public static class OrderItem {
        public String OrderItemId;
        public String ItemCode;
        public Double Price;
        public Integer LineNum;
        public Integer Quantity;
        public Boolean IsPromotion;
        public String Unit;
    }
}