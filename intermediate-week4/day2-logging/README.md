# Day 2: Logging & Observability

## Objective
Implement centralized logging with ELK stack (Elasticsearch, Logstash, Kibana) for comprehensive observability.

## Lab 2: ELK Stack Setup

### Step 1: ELK Stack Configuration
```yaml
# docker-compose.elk.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.8.0
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5044:5044"
    environment:
      - "LS_JAVA_OPTS=-Xmx256m -Xms256m"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

  filebeat:
    image: docker.elastic.co/beats/filebeat:8.8.0
    user: root
    volumes:
      - ./filebeat/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - logstash

volumes:
  elasticsearch_data:
```

### Step 2: Logstash Pipeline
```ruby
# logstash/pipeline/logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  if [fields][logtype] == "terraform" {
    grok {
      match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}" }
    }
    
    date {
      match => [ "timestamp", "ISO8601" ]
    }
  }
  
  if [fields][logtype] == "localstack" {
    json {
      source => "message"
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "devops-logs-%{+YYYY.MM.dd}"
  }
}
```

### Step 3: Filebeat Configuration
```yaml
# filebeat/filebeat.yml
filebeat.inputs:
- type: container
  paths:
    - '/var/lib/docker/containers/*/*.log'
  processors:
  - add_docker_metadata:
      host: "unix:///var/run/docker.sock"

output.logstash:
  hosts: ["logstash:5044"]

logging.level: info
```

## Commands to Run
```bash
# Create directories
mkdir -p logstash/pipeline filebeat

# Start ELK stack
docker-compose -f docker-compose.elk.yml up -d

# Check services
curl http://localhost:9200/_cluster/health
echo "Kibana: http://localhost:5601"

# Generate test logs
docker run --rm alpine echo "Test log message"
```

## Validation
- [ ] Elasticsearch accessible at localhost:9200
- [ ] Kibana accessible at localhost:5601
- [ ] Logstash processing logs
- [ ] Filebeat collecting container logs
- [ ] Logs visible in Kibana
