package com.tuancao.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.File;

public class ConfigReader {
    private static final String CONFIG_PATH = "../src/database_config.json";

    public static JsonNode getKafkaConfig() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        JsonNode root = mapper.readTree(new File(CONFIG_PATH));
        return root.get("kafka_config");
    }
}