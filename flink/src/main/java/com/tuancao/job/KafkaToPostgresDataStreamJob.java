package com.tuancao.job;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tuancao.model.Orders;
import com.tuancao.model.OrderItem;
import com.tuancao.utils.ConfigReader;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.api.common.typeinfo.TypeHint;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import org.apache.flink.api.java.tuple.Tuple2;
import org.apache.flink.connector.jdbc.JdbcConnectionOptions;
import org.apache.flink.connector.jdbc.JdbcExecutionOptions;
import org.apache.flink.connector.jdbc.JdbcSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.util.Collector;

import java.sql.Timestamp;
import java.time.OffsetDateTime;

public class KafkaToPostgresDataStreamJob {

    public static void main(String[] args) throws Exception {
        StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);
        env.enableCheckpointing(5000);

        JsonNode rootCfg = ConfigReader.getKafkaConfig();
        JsonNode kafkaCfg = rootCfg.path("kafka_config");
        JsonNode pgCfg = rootCfg.path("db_datamanagement_test");

        KafkaSource<String> source = KafkaSource.<String>builder()
                .setBootstrapServers(kafkaCfg.path("bootstrap_servers").asText("kafka:29092"))
                .setTopics(kafkaCfg.path("order_topic").asText("orders_topic"))
                .setGroupId(kafkaCfg.path("group_id").asText("flink-orders-ds"))
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new SimpleStringSchema())
                .build();

        // 3. Parse JSON Stream
        DataStream<Orders> mainStream = env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka Source")
                .flatMap((String value, Collector<Orders> out) -> {
                    ObjectMapper mapper = new ObjectMapper();
                    mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
                    try {
                        out.collect(mapper.readValue(value, Orders.class));
                    } catch (Exception e) {
                        System.err.println("Skip record. Parse error: " + e.getMessage());
                    }
                }, TypeInformation.of(Orders.class));

        // 4. JDBC Shared Options
        JdbcExecutionOptions execOpt = JdbcExecutionOptions.builder()
                .withBatchSize(1000).withBatchIntervalMs(200).withMaxRetries(5).build();

        JdbcConnectionOptions connOpt = new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withUrl(String.format("jdbc:postgresql://%s:%s/%s?stringtype=unspecified",
                        pgCfg.path("host").asText("postgres"),
                        pgCfg.path("port").asText("5432"),
                        pgCfg.path("database").asText("database_management")))
                .withDriverName("org.postgresql.Driver")
                .withUsername(pgCfg.path("user").asText("databaseteam"))
                .withPassword(pgCfg.path("password").asText("databaseteam123"))
                .build();

        mainStream.addSink(JdbcSink.sink(
                "INSERT INTO \"Orders\" (\"OrderId\", \"OrderCode\", \"OrderStatus\", \"ShopCode\", \"CustomerCode\", \"InvoiceHeader\", \"CreatedDate\", \"ModifiedDate\") " +
                        "VALUES (CAST(? AS UUID), ?, ?, ?, ?, ?, ?, ?) " +
                        "ON CONFLICT (\"OrderId\") DO UPDATE SET \"OrderStatus\" = EXCLUDED.\"OrderStatus\", \"ModifiedDate\" = EXCLUDED.\"ModifiedDate\"",
                (ps, o) -> {
                    ps.setString(1, o.OrderId);
                    ps.setString(2, o.OrderCode);
                    ps.setShort(3, (short) (o.OrderStatus != null ? o.OrderStatus : 0));
                    ps.setString(4, o.ShopCode);
                    ps.setString(5, o.CustomerCode);
                    ps.setString(6, o.InvoiceHeader);
                    ps.setTimestamp(7, safeTimestampOrNow(o.CreatedDate));
                    ps.setTimestamp(8, safeTimestampOrNow(o.ModifiedDate));
                }, execOpt, connOpt
        )).name("Sink Orders");

        mainStream.filter(o -> o.EInvoice != null)
                .addSink(JdbcSink.sink(
                        "INSERT INTO \"EInvoice\" (\"Id\", \"InvoiceHeader\", \"InvoiceSymbol\", \"InvoiceDate\", \"CreatedDate\", \"ModifiedDate\") " +
                                "VALUES (CAST(? AS UUID), ?, ?, ?, ?, ?) ON CONFLICT (\"Id\") DO NOTHING",
                        (ps, o) -> {
                            ps.setString(1, o.EInvoice.Id);
                            ps.setString(2, o.EInvoice.InvoiceHeader);
                            ps.setString(3, o.EInvoice.InvoiceSymbol);
                            ps.setTimestamp(4, safeTimestampOrNow(o.EInvoice.InvoiceDate));
                            ps.setTimestamp(5, safeTimestampOrNow(o.CreatedDate));
                            ps.setTimestamp(6, safeTimestampOrNow(o.ModifiedDate));
                        }, execOpt, connOpt
                )).name("Sink EInvoice");

        mainStream.flatMap((Orders order, Collector<Tuple2<Orders, OrderItem>> out) -> {
                    if (order.OrderItems != null) {
                        for (OrderItem item : order.OrderItems) {
                            out.collect(Tuple2.of(order, item));
                        }
                    }
                }, TypeInformation.of(new TypeHint<Tuple2<Orders, OrderItem>>() {}))
                .addSink(JdbcSink.sink(
                        "INSERT INTO \"OrderItems\" (\"OrderItemId\", \"OrderCode\", \"ItemCode\", \"Price\", \"LineNum\", \"Quantity\", \"IsPromotion\", \"Unit\", \"CreatedDate\", \"ModifiedDate\") " +
                                "VALUES (CAST(? AS UUID), ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT (\"OrderItemId\") DO NOTHING",
                        (ps, t) -> {
                            Orders o = t.f0;
                            OrderItem i = t.f1;
                            ps.setString(1, i.OrderItemId);
                            ps.setString(2, o.OrderCode);
                            ps.setString(3, i.ItemCode);
                            ps.setInt(4, i.Price != null ? i.Price.intValue() : 0);
                            ps.setInt(5, i.LineNum != null ? i.LineNum : 0);
                            ps.setInt(6, i.Quantity != null ? i.Quantity : 0);
                            ps.setBoolean(7, i.IsPromotion != null && i.IsPromotion);
                            ps.setString(8, i.Unit);
                            ps.setTimestamp(9, safeTimestampOrNow(o.CreatedDate));
                            ps.setTimestamp(10, safeTimestampOrNow(o.ModifiedDate));
                        }, execOpt, connOpt
                )).name("Sink OrderItems");

        env.execute("Kafka Sinks Orders to Postgres");
    }

    private static Timestamp safeTimestampOrNow(String dateStr) {
        long now = System.currentTimeMillis();
        if (dateStr == null || dateStr.trim().isEmpty()) {
            return new Timestamp(now);
        }
        try {
            return Timestamp.valueOf(OffsetDateTime.parse(dateStr).toLocalDateTime());
        } catch (Exception e) {
            try {
                return Timestamp.valueOf(dateStr);
            } catch (Exception ex) {
                return new Timestamp(now);
            }
        }
    }
}