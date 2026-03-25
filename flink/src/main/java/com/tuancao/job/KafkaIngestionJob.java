package com.tuancao.job;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.tuancao.model.OrderEvent;
import com.tuancao.utils.ConfigReader;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.RichSourceFunction;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

import java.time.LocalDateTime;
import java.util.*;

public class KafkaIngestionJob {

    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        JsonNode kafkaCfg = ConfigReader.getKafkaConfig();
        String brokers = kafkaCfg.path("bootstrap_servers").asText("localhost:9092");
        String topic = kafkaCfg.path("order_topic").asText("orders_topic");

        KafkaSink<String> sink = KafkaSink.<String>builder()
                .setBootstrapServers(brokers)
                .setRecordSerializer(
                        KafkaRecordSerializationSchema.builder()
                                .setTopic(topic)
                                .setValueSerializationSchema(new SimpleStringSchema())
                                .build()
                )
                .build();

        DataStream<String> orderStream = env.addSource(new DynamicRedisSource());

        orderStream.sinkTo(sink);
        env.execute("Kafka Simulate Data Orders");
    }

    public static class DynamicRedisSource extends RichSourceFunction<String> {
        private volatile boolean running = true;
        private transient JedisPool jedisPool;
        private transient ObjectMapper mapper;
        private final Random random = new Random();

        @Override
        public void open(Configuration parameters) {
            mapper = new ObjectMapper().registerModule(new JavaTimeModule());

            JsonNode redisCfg = ConfigReader.getRedisConfig();
            JedisPoolConfig poolConfig = new JedisPoolConfig();
            poolConfig.setMaxTotal(10);
            this.jedisPool = new JedisPool(poolConfig,
                    redisCfg.path("host").asText("localhost"),
                    redisCfg.path("port").asInt(6379));
        }

        @Override
        public void run(SourceContext<String> ctx) throws Exception {
            while (running) {
                try (Jedis jedis = jedisPool.getResource()) {
                    String shopCode = jedis.srandmember("sync:shops");
                    String customerCode = jedis.srandmember("sync:customers");

                    if (shopCode == null) {
                        Thread.sleep(3000);
                        continue;
                    }

                    OrderEvent order = new OrderEvent();
                    order.OrderId = UUID.randomUUID().toString();
                    order.OrderCode = "ORD-" + shopCode + "-" + System.currentTimeMillis();
                    order.ShopCode = shopCode;
                    order.CustomerCode = (customerCode != null) ? customerCode : "CUST-GUEST";
                    order.OrderStatus = 1;

                    order.DataSource = "STREAMING";
                    order.CreatedDate = LocalDateTime.now().toString();
                    order.ModifiedDate = order.CreatedDate;
                    order.InvoiceHeader = "INV" + String.format("%07d", random.nextInt(9999999));

                    order.EInvoice = new OrderEvent.EInvoice();
                    order.EInvoice.Id = UUID.randomUUID().toString();
                    order.EInvoice.InvoiceHeader = order.InvoiceHeader;
                    order.EInvoice.InvoiceSymbol = "1C26TY";
                    order.EInvoice.InvoiceDate = order.CreatedDate;

                    order.OrderItems = new ArrayList<>();
                    int itemsCount = random.nextInt(3) + 1;
                    double runningTotal = 0.0;

                    for (int i = 0; i < itemsCount; i++) {
                        String productCode = jedis.srandmember("sync:products");
                        if (productCode == null) continue;

                        Map<String, String> pInfo = jedis.hgetAll("product:info:" + productCode);

                        OrderEvent.OrderItem item = new OrderEvent.OrderItem();
                        item.OrderItemId = UUID.randomUUID().toString();
                        item.ItemCode = productCode;

                        item.Price = Double.parseDouble(pInfo.getOrDefault("SellPrice", "50000.0"));
                        item.Quantity = random.nextInt(5) + 1;
                        item.LineNum = i + 1;
                        item.IsPromotion = false;
                        item.Unit = pInfo.getOrDefault("Unit", "Hộp");

                        runningTotal += (item.Price * item.Quantity);
                        order.OrderItems.add(item);
                    }

                    order.TotalAmount = runningTotal;

                    ctx.collect(mapper.writeValueAsString(order));

                } catch (Exception e) {
                    System.err.println("Error in Source: " + e.getMessage());
                }

                Thread.sleep(2000);
            }
        }

        @Override
        public void cancel() { running = false; }

        @Override
        public void close() { if (jedisPool != null) jedisPool.close(); }
    }
}