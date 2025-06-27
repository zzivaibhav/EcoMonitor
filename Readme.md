# EcoMonitor - IoT Environmental Monitoring System

This is the project for monitoring the sensor data from the facilities.

## Architecture Overview
```
IoT Sensors → S3 Storage → Lambda Processor → DynamoDB → CloudWatch Dashboard
     ↓              ↓            ↓              ↓              ↓
  Simulators    Raw Data      Data Clean    Processed      Visualization
                              & Transform      Data
```

## Key Features
- **IoT Sensor Simulation**: Temperature, Humidity, AQI, and CO2 sensors
- **Data Pipeline**: Automated S3 to DynamoDB data processing
- **Real-time Monitoring**: CloudWatch dashboards with custom metrics
- **Error Handling**: Comprehensive error tracking and SNS notifications
- **Scalable Infrastructure**: AWS serverless architecture

## Dashboard Monitoring
The project includes comprehensive CloudWatch dashboards that visualize:
- **Data Transfer Metrics**: S3 → DynamoDB processing rates
- **Sensor Activity**: Individual sensor type monitoring
- **Error Analysis**: Processing failures and system health
- **Performance Metrics**: Lambda execution times and throughput
- **Storage Analytics**: S3 bucket growth and DynamoDB capacity usage

## Setup Instructions

### Prerequisites
- AWS CLI configured
- Terraform installed
- AWS account with appropriate permissions

### Deployment
```bash
cd Terraform/
terraform init
terraform plan
terraform apply
```

### Configuration
Set IOT_ENDPOINT in the Lambda environment variables to your AWS IoT endpoint (without https://).
Find this in AWS Console: IoT Core > Settings > Endpoint.

### Accessing the Dashboard
After deployment, access your monitoring dashboard at:
```
https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=EcoMonitor-Data-Pipeline
```

## Project Structure
```
├── Terraform/
│   ├── cloudwatch_dashboard.tf    # Dashboard configuration
│   ├── lambda.tf                  # Lambda functions
│   ├── s3.tf                      # S3 bucket setup
│   ├── Dynamo.tf                  # DynamoDB table
│   ├── data cleaner/              # Data processing scripts
│   ├── IoT devices/               # Sensor simulators
│   └── provisioning/dashboards/   # Dashboard templates
```

## Monitoring & Alerts
- **Real-time Processing**: Track data flow from S3 to DynamoDB
- **Error Notifications**: SNS alerts for processing failures
- **Performance Monitoring**: Lambda execution metrics
- **Custom Metrics**: Sensor-specific data tracking

For detailed dashboard setup and customization, see: `Terraform/provisioning/dashboards/README.md`


