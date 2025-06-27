# EcoMonitor Dashboard Setup Guide

## Overview
This guide will help you set up comprehensive monitoring dashboards for the EcoMonitor data pipeline that tracks data flow from S3 to DynamoDB.

## Architecture
```
IoT Sensors → S3 Bucket → Lambda Function → DynamoDB
     ↓              ↓            ↓              ↓
  Simulators   Raw Data      Processor    Processed Data
```

## Dashboard Components

### 1. CloudWatch Dashboard (AWS Native)
**File**: `cloudwatch-dashboard.json`
**Features**:
- Real-time data processing metrics
- S3 to DynamoDB transfer monitoring
- Lambda function performance
- Error tracking and alerts
- Sensor type breakdown

### 2. Grafana Dashboard (Advanced Analytics)
**File**: `data-pipeline-dashboard.json` 
**Features**:
- Advanced visualizations
- Custom metrics from Lambda
- Detailed error analysis
- Historical trending
- Log aggregation

## Deployment

### Option 1: Terraform Deployment (Recommended)
```bash
cd /Users/vaibhav_patel/Documents/EcoMonitor/Terraform
terraform plan
terraform apply
```

This will create:
- CloudWatch Dashboard: `EcoMonitor-Data-Pipeline`
- Log Groups with retention policies
- CloudWatch Alarms for error monitoring
- Custom metric filters

### Option 2: Manual CloudWatch Dashboard Setup
1. Go to AWS CloudWatch Console
2. Navigate to Dashboards
3. Click "Create dashboard"
4. Name it "EcoMonitor-Data-Pipeline"
5. Copy and paste the content from `cloudwatch-dashboard.json`

## Key Metrics Monitored

### Data Pipeline Metrics
| Metric | Description | Source |
|--------|-------------|---------|
| `DataProcessedSuccessfully` | Successful S3→DynamoDB transfers | Custom Lambda metric |
| `DataProcessingErrors` | Failed processing attempts | Custom Lambda metric |
| `S3FileNotFoundErrors` | Missing S3 files | Custom Lambda metric |
| `DynamoDBValidationErrors` | DynamoDB write failures | Custom Lambda metric |

### AWS Service Metrics
| Metric | Description | Service |
|--------|-------------|---------|
| `Lambda Invocations` | Function execution count | AWS Lambda |
| `Lambda Errors` | Function error count | AWS Lambda |
| `Lambda Duration` | Execution time | AWS Lambda |
| `DynamoDB ConsumedWriteCapacity` | Database write usage | DynamoDB |
| `S3 BucketSizeBytes` | Storage usage | S3 |
| `S3 NumberOfObjects` | File count | S3 |

### Sensor-Specific Metrics
- `TemperatureSensorDataProcessed`
- `HumiditySensorDataProcessed`
- `AqiSensorDataProcessed`
- `Co2SensorDataProcessed`

## Dashboard Sections

### 1. Overview Panel
- Data pipeline status
- Key performance indicators
- System health summary

### 2. Processing Metrics
- Transfer rate (files/minute)
- Success vs error ratio
- Processing latency

### 3. Storage Metrics
- S3 bucket growth
- DynamoDB item count
- Capacity utilization

### 4. Error Analysis
- Error breakdown by type
- Error rate trends
- Alert thresholds

### 5. Activity Logs
- Recent successful transfers
- Error details
- Processing timestamps

## Alerts Configuration

### Critical Alerts
- **Lambda Errors**: > 5 errors in 10 minutes
- **DynamoDB Throttling**: Any throttled requests
- **Processing Failures**: > 10% failure rate

### Warning Alerts
- **High Latency**: Processing time > 30 seconds
- **Capacity Usage**: DynamoDB writes > 80% capacity

## Accessing the Dashboard

### CloudWatch Dashboard URL
```
https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=EcoMonitor-Data-Pipeline
```

### Quick Actions
1. **View Recent Activity**: Check the "Recent Data Transfer Activity" log widget
2. **Monitor Errors**: Watch the "Error and Throttling Metrics" graph
3. **Track Volume**: Monitor S3 object count and DynamoDB item growth
4. **Performance**: Check Lambda duration and invocation rates

## Troubleshooting

### Common Issues

#### No Data Showing
1. Verify IoT sensors are running (`rate(5 minutes)` schedule)
2. Check S3 bucket for new files
3. Confirm Lambda function permissions

#### High Error Rates
1. Check CloudWatch Logs for specific errors
2. Verify DynamoDB table permissions
3. Check VPC configuration for Lambda

#### Missing Custom Metrics
1. Verify Lambda has CloudWatch permissions
2. Check custom metric namespace: `EcoMonitor/DataPipeline`
3. Review Lambda function logs for metric publication

### Log Analysis
Key log patterns to search for:
- `[SUCCESS]` - Successful data transfers
- `[ERROR]` - Processing errors
- `[DATA PIPELINE]` - Pipeline activity
- `[SENSOR TYPE]` - Sensor type detection

## Customization

### Adding New Metrics
1. Update `s3_to_dynamo.py` with new `put_custom_metric()` calls
2. Add corresponding widgets to dashboard JSON
3. Redeploy Lambda function

### Modifying Alerting
1. Edit alarm thresholds in `cloudwatch_dashboard.tf`
2. Update SNS topic subscriptions
3. Apply Terraform changes

## Cost Optimization

### CloudWatch Costs
- Log retention: 7-14 days for development
- Custom metrics: ~$0.30 per metric per month
- Dashboard: No additional cost

### Recommendations
- Use log sampling for high-volume environments
- Set appropriate log retention periods
- Monitor custom metric usage

## Security Considerations

- Dashboard access controlled by IAM policies
- Logs may contain sensitive sensor data
- Encrypt CloudWatch Logs if required
- Review metric data for PII

## Next Steps

1. Deploy the dashboard using Terraform
2. Set up SNS notifications for alerts
3. Configure log aggregation if needed
4. Create operational runbooks for common issues
5. Set up automated responses to critical alerts
