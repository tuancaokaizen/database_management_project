package com.tuancao.job;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tuancao.model.OrderEvent;
import com.tuancao.utils.ConfigReader;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.kafka.sink.KafkaRecordSerializationSchema;
import org.apache.flink.connector.kafka.sink.KafkaSink;
import org.apache.flink.connector.kafka.sink.KafkaSinkBuilder;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.source.SourceFunction;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Random;
import java.util.UUID;

public class KafkaIngestionJob {
    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        ObjectMapper mapper = new ObjectMapper();

        JsonNode kafkaConfig = ConfigReader.getKafkaConfig();
        String brokers = kafkaConfig.get("bootstrap_servers").asText();
        String topic = kafkaConfig.get("order_topic").asText();

        KafkaSink<String> sink = KafkaSink.<String>builder()
                .setBootstrapServers(brokers)
                .setRecordSerializer(
                        KafkaRecordSerializationSchema.builder()
                                .setTopic(topic)
                                .setValueSerializationSchema(new SimpleStringSchema())
                                .build()
                )
                .build();

        DataStream<String> orderStream = env.addSource(new SourceFunction<String>() {
            private boolean running = true;
            private final Random r = new Random();

            @Override
            public void run(SourceContext<String> ctx) throws Exception {
                while (running) {
                    OrderEvent order = new OrderEvent();
                    order.OrderId = UUID.randomUUID().toString();
                    order.OrderCode = "ORD-" + r.nextInt(99999);
                    order.ShopCode = "SHOP_" + r.nextInt(50);
                    order.CreatedDate = LocalDateTime.now().toString();

                    order.EInvoice = new OrderEvent.EInvoice();
                    order.EInvoice.Id = UUID.randomUUID().toString();
                    order.EInvoice.InvoiceSymbol = "1C26TY";

                    order.OrderItems = new ArrayList<>();
                    for (int i = 0; i < r.nextInt(3) + 1; i++) {
                        OrderEvent.OrderItem item = new OrderEvent.OrderItem();
                        item.OrderItemId = UUID.randomUUID().toString();
                        item.ItemCode = "ITEM_" + r.nextInt(100);
                        item.Price = 50000.0 * r.nextDouble();
                        item.Quantity = r.nextInt(5) + 1;
                        order.OrderItems.add(item);
                    }

                    ctx.collect(mapper.writeValueAsString(order));
                    Thread.sleep(2000);
                }
            }

            @Override
            public void cancel() { running = false; }
        });

        orderStream.sinkTo(sink);
        env.execute("Pharmacy Order Ingestion to Kafka");
    }
}