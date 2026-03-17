package com.tuancao.job;

import com.fasterxml.jackson.databind.JsonNode;
import com.tuancao.utils.ConfigReader;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.table.api.*;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;

import static org.apache.flink.table.api.Expressions.$;

public class KafkaToPostgresJob {

    public static void main(String[] args) throws Exception {

        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        EnvironmentSettings settings = EnvironmentSettings.newInstance().inStreamingMode().build();
        StreamTableEnvironment tableEnv = StreamTableEnvironment.create(env, settings);

        JsonNode kafka = ConfigReader.getKafkaConfig();
        JsonNode pg = ConfigReader.getPostgresConfig();

        String pgUrl = String.format("jdbc:postgresql://%s:%s/%s",
                pg.path("host").asText("postgres"),
                pg.path("port").asText("5432"),
                pg.path("database").asText("database_management"));

        String pgUser = pg.path("user").asText("databaseteam");
        String pgPass = pg.path("password").asText("databaseteam123");
        String bootstrapServers = kafka.path("bootstrap_servers").asText("kafka:29092");

        tableEnv.executeSql(
                "CREATE TABLE kafka_orders_source (" +
                        "  OrderId STRING, OrderCode STRING, ShopCode STRING, CustomerCode STRING, " +
                        "  OrderStatus INT, CreatedDate TIMESTAMP(3), ModifiedDate TIMESTAMP(3), InvoiceHeader STRING, " +
                        "  EInvoice ROW<Id STRING, InvoiceHeader STRING, InvoiceSymbol STRING, InvoiceDate TIMESTAMP(3)>," +
                        "  OrderItems ARRAY<ROW<OrderItemId STRING, ItemCode STRING, Price DOUBLE, Quantity INT, LineNum INT, IsPromotion BOOLEAN, Unit STRING>>" +
                        ") WITH (" +
                        "  'connector' = 'kafka', 'topic' = 'orders_topic', " +
                        "  'properties.bootstrap.servers' = '" + bootstrapServers + "', " +
                        "  'properties.group.id' = 'flink-orders-consumer', " +
                        "  'scan.startup.mode' = 'earliest-offset', " +
                        "  'format' = 'json', 'json.ignore-parse-errors' = 'true', 'json.timestamp-format.standard' = 'ISO-8601'" +
                        ")"
        );

        String jdbcOptions = String.format("'connector'='jdbc','url'='%s','username'='%s','password'='%s'", pgUrl, pgUser, pgPass);

        tableEnv.executeSql(
                "CREATE TABLE sink_orders (" +
                        "  order_id STRING, order_code STRING, order_status SMALLINT, shop_code STRING, " +
                        "  customer_code STRING, invoice_header STRING, created_date TIMESTAMP(3), modified_date TIMESTAMP(3), " +
                        "  PRIMARY KEY (order_id) NOT ENFORCED" +
                        ") WITH (" + jdbcOptions + ", 'table-name'='orders')"
        );

        tableEnv.executeSql(
                "CREATE TABLE sink_einvoice (" +
                        "  id STRING, invoice_header STRING, invoice_symbol STRING, invoice_date TIMESTAMP(3), " +
                        "  created_date TIMESTAMP(3), modified_date TIMESTAMP(3), " +
                        "  PRIMARY KEY (id) NOT ENFORCED" +
                        ") WITH (" + jdbcOptions + ", 'table-name'='einvoice')"
        );

        tableEnv.executeSql(
                "CREATE TABLE sink_order_items (" +
                        "  order_item_id STRING, order_code STRING, item_code STRING, price INT, " +
                        "  line_num INT, quantity INT, is_promotion BOOLEAN, unit STRING, " +
                        "  created_date TIMESTAMP(3), modified_date TIMESTAMP(3), " +
                        "  PRIMARY KEY (order_item_id) NOT ENFORCED" +
                        ") WITH (" + jdbcOptions + ", 'table-name'='order_items')"
        );

        StatementSet statementSet = tableEnv.createStatementSet();
        Table sourceTable = tableEnv.from("kafka_orders_source");

        statementSet.addInsert("sink_orders", sourceTable.select(
                $("OrderId").as("order_id"),
                $("OrderCode").as("order_code"),
                $("OrderStatus").cast(DataTypes.SMALLINT()).as("order_status"),
                $("ShopCode").as("shop_code"),
                $("CustomerCode").as("customer_code"),
                $("InvoiceHeader").as("invoice_header"),
                $("CreatedDate").as("created_date"),
                $("ModifiedDate").as("modified_date")
        ));

        statementSet.addInsert("sink_einvoice", sourceTable.filter($("EInvoice").isNotNull()).select(
                $("EInvoice").get("Id").as("id"),
                $("EInvoice").get("InvoiceHeader").as("invoice_header"),
                $("EInvoice").get("InvoiceSymbol").as("invoice_symbol"),
                $("EInvoice").get("InvoiceDate").as("invoice_date"),
                $("CreatedDate").as("created_date"),
                $("ModifiedDate").as("modified_date")
        ));

        statementSet.addInsertSql(
                "INSERT INTO sink_order_items " +
                        "SELECT " +
                        "  t.OrderItemId AS order_item_id, " +
                        "  OrderCode AS order_code, " +
                        "  t.ItemCode AS item_code, " +
                        "  CAST(t.Price AS INT) AS price, " +
                        "  t.LineNum AS line_num, " +
                        "  t.Quantity AS quantity, " +
                        "  t.IsPromotion AS is_promotion, " +
                        "  t.Unit AS unit, " +
                        "  CreatedDate AS created_date, " +
                        "  ModifiedDate AS modified_date " +
                        "FROM kafka_orders_source CROSS JOIN UNNEST(OrderItems) AS t"
        );

        statementSet.execute();
    }
}