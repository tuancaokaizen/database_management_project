package com.tuancao.job;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.serialization.SimpleStringSchema;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.connectors.elasticsearch7.ElasticsearchSink;
import org.apache.flink.streaming.connectors.elasticsearch.ElasticsearchSinkFunction;
import org.apache.flink.streaming.connectors.elasticsearch.RequestIndexer;
import org.apache.flink.streaming.connectors.elasticsearch.ActionRequestFailureHandler;
import org.apache.http.HttpHost;
import org.elasticsearch.action.ActionRequest;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.client.Requests;
import org.elasticsearch.common.xcontent.XContentType;

import java.util.ArrayList;
import java.util.List;

public class KafkaToElasticsearchJob {
    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        env.enableCheckpointing(5000);

        KafkaSource<String> source = KafkaSource.<String>builder()
                .setBootstrapServers("kafka:29092")
                .setTopics("orders_topic")
                .setGroupId("flink_consumer_group")
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new SimpleStringSchema())
                .build();

        DataStream<String> kafkaStream = env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka Source");

        List<HttpHost> httpHosts = new ArrayList<>();
        httpHosts.add(new HttpHost("elasticsearch", 9200, "http"));

        ElasticsearchSinkFunction<String> sinkFunction = new ElasticsearchSinkFunction<String>() {
            @Override
            public void process(String element, org.apache.flink.api.common.functions.RuntimeContext ctx, RequestIndexer indexer) {
                IndexRequest request = Requests.indexRequest()
                        .index("orders_index")
                        .source(element, XContentType.JSON);
                indexer.add(request);
            }
        };

        ElasticsearchSink.Builder<String> esSinkBuilder = new ElasticsearchSink.Builder<>(httpHosts, sinkFunction);

        esSinkBuilder.setFailureHandler(new ActionRequestFailureHandler() {
            @Override
            public void onFailure(ActionRequest action, Throwable throwable, int restStatusCode, RequestIndexer indexer) throws Throwable {
                if (throwable.getMessage() != null && throwable.getMessage().contains("Unable to parse response body")) {
                    System.out.println("Warning: Ignored ES response parsing error. Data write was likely successful.");
                } else {
                    throw throwable;
                }
            }
        });

        esSinkBuilder.setBulkFlushMaxActions(1);

        kafkaStream.addSink(esSinkBuilder.build()).name("Elasticsearch Sink");

        env.execute("Kafka Sink Orders To Elasticsearch");
    }
}