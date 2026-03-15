package com.tuancao.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.InputStream;
import java.io.Serializable;

public class ConfigReader implements Serializable {
    private static final long serialVersionUID = 1L;
    private static final ObjectMapper mapper = new ObjectMapper();
    private static volatile JsonNode rootNode;

    private static synchronized void loadConfig() {
        if (rootNode != null) return;

        String fileName = "database_config.json";

        try (InputStream is = ConfigReader.class.getClassLoader().getResourceAsStream(fileName)) {

            if (is == null) {
                try (InputStream backupIs = Thread.currentThread().getContextClassLoader().getResourceAsStream(fileName)) {
                    if (backupIs == null) {
                        throw new RuntimeException("Not Found " + fileName + " in resources config");
                    }
                    rootNode = mapper.readTree(backupIs);
                }
            } else {
                rootNode = mapper.readTree(is);
            }

            System.out.println("ConfigReader: Load Config Successfully.");
        } catch (Exception e) {
            System.err.println("ConfigReader: Error Json File: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public static JsonNode getKafkaConfig() {
        if (rootNode == null) loadConfig();
        return rootNode.path("kafka_config");
    }

    public static JsonNode getRedisConfig() {
        if (rootNode == null) loadConfig();
        return rootNode.path("redis_config");
    }

    public static JsonNode getElasticConfig() {
        if (rootNode == null) loadConfig();
        return rootNode.path("elasticsearch_config");
    }
}