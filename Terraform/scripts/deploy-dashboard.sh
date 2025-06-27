#!/bin/bash

# EcoMonitor Dashboard Deployment Script
# This script helps deploy and manage the CloudWatch dashboard for EcoMonitor

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REGION="us-east-1"
DASHBOARD_NAME="EcoMonitor-Data-Pipeline"
TERRAFORM_DIR="/Users/vaibhav_patel/Documents/EcoMonitor/Terraform"

echo -e "${BLUE}🚀 EcoMonitor Dashboard Deployment Script${NC}"
echo "================================================="

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if AWS CLI is installed and configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_status "AWS CLI is configured"
}

# Check if Terraform is installed
check_terraform() {
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    print_status "Terraform is available"
}

# Deploy infrastructure with Terraform
deploy_terraform() {
    print_info "Deploying EcoMonitor infrastructure..."
    
    cd "$TERRAFORM_DIR"
    
    print_info "Initializing Terraform..."
    terraform init
    
    print_info "Planning deployment..."
    terraform plan -out=tfplan
    
    print_info "Applying changes..."
    terraform apply tfplan
    
    print_status "Infrastructure deployed successfully"
}

# Check if dashboard exists
check_dashboard() {
    if aws cloudwatch get-dashboard --dashboard-name "$DASHBOARD_NAME" --region "$REGION" &> /dev/null; then
        print_status "Dashboard '$DASHBOARD_NAME' exists"
        return 0
    else
        print_warning "Dashboard '$DASHBOARD_NAME' does not exist"
        return 1
    fi
}

# Get dashboard URL
get_dashboard_url() {
    local url="https://${REGION}.console.aws.amazon.com/cloudwatch/home?region=${REGION}#dashboards:name=${DASHBOARD_NAME}"
    echo "$url"
}

# Check Lambda function status
check_lambda_functions() {
    print_info "Checking Lambda functions..."
    
    local functions=("s3_to_dynamo_processor" "temperature_sensor_simulator" "humidity_sensor_simulator" "aqi_sensor_simulator" "co2_sensor_simulator")
    
    for func in "${functions[@]}"; do
        if aws lambda get-function --function-name "$func" --region "$REGION" &> /dev/null; then
            print_status "Lambda function '$func' is deployed"
        else
            print_warning "Lambda function '$func' not found"
        fi
    done
}

# Check S3 bucket
check_s3_bucket() {
    local bucket="ecomonitor-raw-b01006432"
    if aws s3 ls "s3://$bucket" &> /dev/null; then
        print_status "S3 bucket '$bucket' exists"
        local count=$(aws s3 ls "s3://$bucket" --recursive | wc -l)
        print_info "S3 bucket contains $count objects"
    else
        print_warning "S3 bucket '$bucket' not found"
    fi
}

# Check DynamoDB table
check_dynamodb_table() {
    local table="ecomonitor_processed_data"
    if aws dynamodb describe-table --table-name "$table" --region "$REGION" &> /dev/null; then
        print_status "DynamoDB table '$table' exists"
        local count=$(aws dynamodb scan --table-name "$table" --select "COUNT" --region "$REGION" --query 'Count' --output text)
        print_info "DynamoDB table contains $count items"
    else
        print_warning "DynamoDB table '$table' not found"
    fi
}

# Show recent Lambda logs
show_recent_logs() {
    print_info "Fetching recent Lambda logs..."
    
    local log_group="/aws/lambda/s3_to_dynamo_processor"
    
    if aws logs describe-log-groups --log-group-name-prefix "$log_group" --region "$REGION" &> /dev/null; then
        print_info "Recent log entries from $log_group:"
        aws logs filter-log-events \
            --log-group-name "$log_group" \
            --region "$REGION" \
            --start-time $(date -d '1 hour ago' +%s)000 \
            --filter-pattern '[SUCCESS]' \
            --query 'events[0:5].[timestamp,message]' \
            --output table
    else
        print_warning "Log group not found: $log_group"
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    - Deploy the full infrastructure using Terraform"
    echo "  check     - Check the status of all components"
    echo "  status    - Show dashboard and component status"
    echo "  logs      - Show recent processing logs"
    echo "  url       - Display dashboard URL"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy   # Deploy everything"
    echo "  $0 check    # Check system status"
    echo "  $0 url      # Get dashboard URL"
}

# Main script logic
case "${1:-status}" in
    "deploy")
        print_info "Starting full deployment..."
        check_aws_cli
        check_terraform
        deploy_terraform
        sleep 10  # Wait for resources to be ready
        print_status "Deployment completed!"
        print_info "Dashboard URL: $(get_dashboard_url)"
        ;;
    
    "check"|"status")
        print_info "Checking EcoMonitor system status..."
        check_aws_cli
        echo ""
        check_dashboard
        echo ""
        check_lambda_functions
        echo ""
        check_s3_bucket
        echo ""
        check_dynamodb_table
        echo ""
        print_info "Dashboard URL: $(get_dashboard_url)"
        ;;
    
    "logs")
        check_aws_cli
        show_recent_logs
        ;;
    
    "url")
        echo "$(get_dashboard_url)"
        ;;
    
    "help"|"--help"|"-h")
        show_help
        ;;
    
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

print_status "Script completed successfully!"
