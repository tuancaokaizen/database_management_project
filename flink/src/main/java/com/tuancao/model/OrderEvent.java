package com.tuancao.model;

import java.util.List;

public class OrderEvent {
    public String OrderId;
    public String OrderCode;
    public String ShopCode;
    public String CustomerCode;
    public Integer OrderStatus;
    public String CreatedDate;
    public String ModifiedDate;
    public String InvoiceHeader;
    public String DataSource;
    public Double TotalAmount;

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
        public Integer Quantity;
        public Integer LineNum;
        public Boolean IsPromotion;
        public String Unit;
    }
}