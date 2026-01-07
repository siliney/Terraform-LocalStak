# Day 1: Monitoring Setup

## Objective
Set up production-ready monitoring with Prometheus and Grafana for infrastructure and application metrics.

## Lab 1: Prometheus Configuration

### Step 1: Create Prometheus Config
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'localstack'
    static_configs:
      - targets: ['localstack:4566']
    metrics_path: '/_localstack/health'
```

### Step 2: Alert Rules
```yaml
# alert_rules.yml
groups:
- name: infrastructure_alerts
  rules:
  - alert: HighCPUUsage
    expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[2m])) * 100) > 80
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High CPU usage on {{ $labels.instance }}"
      description: "CPU usage is {{ $value }}% for more than 2 minutes"

  - alert: ServiceDown
    expr: up == 0
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "Service {{ $labels.job }} is down"
      description: "Service has been down for more than 1 minute"
```

### Step 3: Docker Compose for Monitoring
```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - ./alert_rules.yml:/etc/prometheus/alert_rules.yml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'

volumes:
  grafana_data:
```

## Commands to Run
```bash
# Start monitoring stack
docker-compose -f docker-compose.monitoring.yml up -d

# Access services
echo "Prometheus: http://localhost:9090"
echo "Grafana: http://localhost:3000 (admin/admin123)"
echo "Node Exporter: http://localhost:9100"

# Check metrics
curl http://localhost:9090/api/v1/query?query=up
```

## Validation
- [ ] Prometheus accessible at localhost:9090
- [ ] Grafana accessible at localhost:3000
- [ ] Node exporter metrics visible
- [ ] Alert rules loaded successfully
