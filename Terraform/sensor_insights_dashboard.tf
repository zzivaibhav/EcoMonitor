# # IoT Sensor Data Insights Dashboard for EcoMonitor

# # CloudWatch Dashboard for IoT Sensor Data Analytics
# resource "aws_cloudwatch_dashboard" "ecomonitor_sensor_insights" {
#   dashboard_name = "EcoMonitor-Sensor-Data-Insights"

#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "text"
#         x      = 0
#         y      = 0
#         width  = 24
#         height = 5

#         properties = {
#           markdown = "# 🌍 **EcoMonitor Environmental Data Dashboard**\n\n### **Real-time IoT Sensor Monitoring & Analytics**\n\n---\n\n| 🌡️ **Temperature** | 💧 **Humidity** | 🏭 **Air Quality** | 🫁 **CO2 Levels** |\n|:---:|:---:|:---:|:---:|\n| Thermal monitoring | Moisture levels | AQI monitoring | Air quality |\n| 18-35°C optimal | 30-90% range | 0-150 scale | 300-1500 ppm |\n\n📡 **Live data from IoT sensors** • **Updates every 5 minutes** • **Health-based categorization**\n\n---"
#         }
#       },
#       # Current Environmental Status - Single Value Displays
#       {
#         type   = "metric"
#         x      = 0
#         y      = 5
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "TemperatureReading", "SensorType", "Temperature", "DeviceId", "temp_sensor_01"]
#           ]
#           view    = "singleValue"
#           region  = "us-east-1"
#           title   = "🌡️ Current Temperature"
#           period  = 300
#           stat    = "Average"
#           sparkline = true
#           setPeriodToTimeRange = true
#         }
#       },
#       {
#         type   = "metric"
#         x      = 6
#         y      = 5
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "HumidityReading", "SensorType", "Humidity", "DeviceId", "humidity_sensor_01"]
#           ]
#           view    = "singleValue"
#           region  = "us-east-1"
#           title   = "💧 Current Humidity"
#           period  = 300
#           stat    = "Average"
#           sparkline = true
#           setPeriodToTimeRange = true
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 5
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "AQIReading", "SensorType", "AQI", "DeviceId", "aqi_sensor_01"]
#           ]
#           view    = "singleValue"
#           region  = "us-east-1"
#           title   = "🏭 Current AQI"
#           period  = 300
#           stat    = "Average"
#           sparkline = true
#           setPeriodToTimeRange = true
#         }
#       },
#       {
#         type   = "metric"
#         x      = 18
#         y      = 5
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "CO2Reading", "SensorType", "CO2", "DeviceId", "co2_sensor_01"]
#           ]
#           view    = "singleValue"
#           region  = "us-east-1"
#           title   = "🫁 Current CO2"
#           period  = 300
#           stat    = "Average"
#           sparkline = true
#           setPeriodToTimeRange = true
#         }
#       },
#       # Temperature Time Series with Color Zones
#       {
#         type   = "metric"
#         x      = 0
#         y      = 9
#         width  = 12
#         height = 8

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "TemperatureReading", "SensorType", "Temperature", "DeviceId", "temp_sensor_01", { "color": "#FF6B6B" }]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🌡️ Temperature Trends - Real-time Analysis"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 15
#               max = 40
#             }
#           }
#           annotations = {
#             horizontal = [
#               {
#                 label = "Heat Alert"
#                 value = 35
#                 color = "#FF4444"
#               },
#               {
#                 label = "Optimal Range"
#                 value = 25
#                 color = "#4CAF50"
#               },
#               {
#                 label = "Cold Alert"
#                 value = 18
#                 color = "#2196F3"
#               }
#             ]
#           }
#         }
#       },
#       # Humidity Time Series with Color Zones
#       {
#         type   = "metric"
#         x      = 12
#         y      = 9
#         width  = 12
#         height = 8

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "HumidityReading", "SensorType", "Humidity", "DeviceId", "humidity_sensor_01", { "color": "#4FC3F7" }]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "💧 Humidity Levels - Environmental Monitoring"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 20
#               max = 100
#             }
#           }
#           annotations = {
#             horizontal = [
#               {
#                 label = "High Humidity"
#                 value = 90
#                 color = "#FF9800"
#               },
#               {
#                 label = "Optimal Range"
#                 value = 60
#                 color = "#4CAF50"
#               },
#               {
#                 label = "Low Humidity"
#                 value = 30
#                 color = "#FFC107"
#               }
#             ]
#           }
#         }
#       },
#       # AQI Stacked Chart with Health Categories
#       {
#         type   = "metric"
#         x      = 0
#         y      = 17
#         width  = 12
#         height = 8

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "AQIReading", "SensorType", "AQI", "DeviceId", "aqi_sensor_01", { "color": "#9C27B0" }],
#             [".", "GoodAQI", ".", ".", ".", ".", { "color": "#4CAF50", "label": "Good (0-50)" }],
#             [".", "ModerateAQI", ".", ".", ".", ".", { "color": "#FFEB3B", "label": "Moderate (51-100)" }],
#             [".", "UnhealthyAQI", ".", ".", ".", ".", { "color": "#FF5722", "label": "Unhealthy (101-150)" }]
#           ]
#           view    = "timeSeries"
#           stacked = true
#           region  = "us-east-1"
#           title   = "🏭 Air Quality Index - Health Categories"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 0
#               max = 200
#             }
#           }
#         }
#       },
#       # CO2 Levels with Thresholds
#       {
#         type   = "metric"
#         x      = 12
#         y      = 17
#         width  = 12
#         height = 8

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "CO2Reading", "SensorType", "CO2", "DeviceId", "co2_sensor_01", { "color": "#795548" }]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🫁 CO2 Concentration - Air Quality Assessment"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 300
#               max = 1600
#             }
#           }
#           annotations = {
#             horizontal = [
#               {
#                 label = "Poor Air Quality"
#                 value = 1500
#                 color = "#F44336"
#               },
#               {
#                 label = "Moderate"
#                 value = 1000
#                 color = "#FF9800"
#               },
#               {
#                 label = "Good Air Quality"
#                 value = 600
#                 color = "#4CAF50"
#               }
#             ]
#           }
#         }
#       },
#       # Environmental Health Summary Bar Chart
#       {
#         type   = "metric"
#         x      = 0
#         y      = 25
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "GoodConditions", "HealthCategory", "Good", { "color": "#4CAF50" }],
#             [".", "ModerateConditions", ".", "Moderate", { "color": "#FF9800" }],
#             [".", "UnhealthyConditions", ".", "Unhealthy", { "color": "#F44336" }]
#           ]
#           view    = "timeSeries"
#           stacked = true
#           region  = "us-east-1"
#           title   = "📊 Environmental Health Distribution"
#           period  = 300
#           stat    = "Sum"
#         }
#       },
#       # Sensor Activity Monitoring
#       {
#         type   = "metric"
#         x      = 8
#         y      = 25
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "SensorActivity", "SensorType", "Temperature", { "color": "#FF6B6B" }],
#             [".", ".", ".", "Humidity", { "color": "#4FC3F7" }],
#             [".", ".", ".", "AQI", { "color": "#9C27B0" }],
#             [".", ".", ".", "CO2", { "color": "#795548" }]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "📡 Sensor Activity & Data Transmission"
#           period  = 300
#           stat    = "Sum"
#         }
#       },
#       # Alert Summary
#       {
#         type   = "metric"
#         x      = 16
#         y      = 25
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "TemperatureAlert", "AlertType", "Temperature", { "color": "#FF4444" }],
#             [".", "HumidityAlert", ".", "Humidity", { "color": "#2196F3" }],
#             [".", "AQIAlert", ".", "AQI", { "color": "#9C27B0" }],
#             [".", "CO2Alert", ".", "CO2", { "color": "#8D6E63" }]
#           ]
#           view    = "timeSeries"
#           stacked = true
#           region  = "us-east-1"
#           title   = "🚨 Environmental Alerts Summary"
#           period  = 300
#           stat    = "Sum"
#         }
#       },

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "HumidityReading", "SensorType", "Humidity", "DeviceId", "humidity_sensor_01"]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "💧 Humidity Readings (%)"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 25
#               max = 95
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 3
#         width  = 6
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "AQIReading", "SensorType", "AQI", "DeviceId", "aqi_sensor_01"]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🏭 Air Quality Index"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 0
#               max = 160
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 18
#         y      = 3
#         width  = 6
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "CO2Reading", "SensorType", "CO2", "DeviceId", "co2_sensor_01"]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🫁 CO2 Levels (ppm)"
#           period  = 300
#           stat    = "Average"
#           yAxis = {
#             left = {
#               min = 250
#               max = 1600
#             }
#           }
#         }
#       },
#       {
#         type   = "metric"
#         x      = 0
#         y      = 9
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "TemperatureSensorActive", "SensorType", "Temperature"],
#             [".", "HumiditySensorActive", "SensorType", "Humidity"],
#             [".", "AQISensorActive", "SensorType", "AQI"],
#             [".", "CO2SensorActive", "SensorType", "CO2"]
#           ]
#           view    = "timeSeries"
#           stacked = true
#           region  = "us-east-1"
#           title   = "📊 Sensor Activity (Active Readings/5min)"
#           period  = 300
#           stat    = "Sum"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 8
#         y      = 9
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "HighTemperatureAlert", "SensorType", "Temperature"],
#             [".", "LowTemperatureAlert", ".", "."],
#             [".", "HighHumidityAlert", "SensorType", "Humidity"],
#             [".", "LowHumidityAlert", ".", "."]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "⚠️ Environmental Alerts"
#           period  = 300
#           stat    = "Sum"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 16
#         y      = 9
#         width  = 8
#         height = 6

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "UnhealthyAirAlert", "SensorType", "AQI"],
#             [".", "GoodAirQuality", ".", "."],
#             [".", "HighCO2Alert", "SensorType", "CO2"],
#             [".", "ExcellentAirQuality", ".", "."]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🚨 Air Quality Alerts"
#           period  = 300
#           stat    = "Sum"
#         }
#       },
#       {
#         type   = "log"
#         x      = 0
#         y      = 15
#         width  = 12
#         height = 8

#         properties = {
#           query   = "SOURCE '/aws/lambda/temperature_sensor_simulator'\n| SOURCE '/aws/lambda/humidity_sensor_simulator'\n| fields @timestamp, @message\n| filter @message like /SENSOR/\n| parse @message \"* [*] *: *\" as emoji, sensor_type, label, data\n| sort @timestamp desc\n| limit 20"
#           region  = "us-east-1"
#           title   = "🌡️💧 Recent Temperature & Humidity Data"
#           view    = "table"
#         }
#       },
#       {
#         type   = "log"
#         x      = 12
#         y      = 15
#         width  = 12
#         height = 8

#         properties = {
#           query   = "SOURCE '/aws/lambda/aqi_sensor_simulator'\n| SOURCE '/aws/lambda/co2_sensor_simulator'\n| fields @timestamp, @message\n| filter @message like /SENSOR/\n| parse @message \"* [*] *: *\" as emoji, sensor_type, label, data\n| sort @timestamp desc\n| limit 20"
#           region  = "us-east-1"
#           title   = "🏭🫁 Recent Air Quality & CO2 Data"
#           view    = "table"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 0
#         y      = 23
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "TemperatureReading", "SensorType", "Temperature", "DeviceId", "temp_sensor_01"]
#           ]
#           view    = "singleValue"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🌡️ Current Temperature"
#           period  = 300
#           stat    = "Average"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 6
#         y      = 23
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "HumidityReading", "SensorType", "Humidity", "DeviceId", "humidity_sensor_01"]
#           ]
#           view    = "singleValue"
#           stacked = false
#           region  = "us-east-1"
#           title   = "💧 Current Humidity"
#           period  = 300
#           stat    = "Average"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 12
#         y      = 23
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "AQIReading", "SensorType", "AQI", "DeviceId", "aqi_sensor_01"]
#           ]
#           view    = "singleValue"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🏭 Current AQI"
#           period  = 300
#           stat    = "Average"
#         }
#       },
#       {
#         type   = "metric"
#         x      = 18
#         y      = 23
#         width  = 6
#         height = 4

#         properties = {
#           metrics = [
#             ["EcoMonitor/SensorData", "CO2Reading", "SensorType", "CO2", "DeviceId", "co2_sensor_01"]
#           ]
#           view    = "singleValue"
#           stacked = false
#           region  = "us-east-1"
#           title   = "🫁 Current CO2"
#           period  = 300
#           stat    = "Average"
#         }
#       },
#       {
#         type   = "text"
#         x      = 0
#         y      = 27
#         width  = 24
#         height = 3

#         properties = {
#           markdown = "## 📈 Environmental Data Categories\n\n**Temperature**: 🟢 Cool (18-25°C) | 🟡 Warm (25-30°C) | 🔴 Hot (30-35°C)  \n**Humidity**: 🟢 Optimal (40-60%) | 🟡 High (60-75%) | 🔴 Very High (75-90%)  \n**AQI**: 🟢 Good (0-50) | 🟡 Moderate (51-100) | 🔴 Unhealthy (101-150)  \n**CO2**: 🟢 Excellent (<400ppm) | � Good (400-600ppm) | � Acceptable (600-1000ppm) | 🔴 High (>1000ppm)"
#         }
#       }
#     ]
#   })
# }

# # Custom Log Insights queries for better data extraction
# resource "aws_cloudwatch_query_definition" "temperature_analysis" {
#   name = "EcoMonitor/Temperature-Analysis"

#   log_group_names = [
#     "/aws/lambda/temperature_sensor_simulator"
#   ]

#   query_string = <<EOF
# fields @timestamp, @message
# | filter @message like /Temperature sensor data/
# | parse @message "Temperature sensor data: *" as data
# | parse data "{\"device_id\": \"*\", \"temperature\": *, \"unit\": \"*\", \"timestamp\": \"*\"}" as device_id, temperature, unit, timestamp
# | stats avg(temperature), min(temperature), max(temperature), count() by bin(1h)
# | sort @timestamp desc
# EOF
# }

# resource "aws_cloudwatch_query_definition" "humidity_analysis" {
#   name = "EcoMonitor/Humidity-Analysis"

#   log_group_names = [
#     "/aws/lambda/humidity_sensor_simulator"
#   ]

#   query_string = <<EOF
# fields @timestamp, @message
# | filter @message like /Humidity sensor data/
# | parse @message "Humidity sensor data: *" as data
# | parse data "{\"device_id\": \"*\", \"humidity\": *, \"unit\": \"*\", \"timestamp\": \"*\"}" as device_id, humidity, unit, timestamp
# | stats avg(humidity), min(humidity), max(humidity), count() by bin(1h)
# | sort @timestamp desc
# EOF
# }

# resource "aws_cloudwatch_query_definition" "aqi_analysis" {
#   name = "EcoMonitor/AQI-Analysis"

#   log_group_names = [
#     "/aws/lambda/aqi_sensor_simulator"
#   ]

#   query_string = <<EOF
# fields @timestamp, @message
# | filter @message like /AQI sensor data/
# | parse @message "AQI sensor data: *" as data
# | parse data "{\"device_id\": \"*\", \"aqi\": *, \"category\": \"*\", \"timestamp\": \"*\"}" as device_id, aqi, category, timestamp
# | stats avg(aqi), min(aqi), max(aqi), count() by category, bin(1h)
# | sort @timestamp desc
# EOF
# }

# resource "aws_cloudwatch_query_definition" "co2_analysis" {
#   name = "EcoMonitor/CO2-Analysis"

#   log_group_names = [
#     "/aws/lambda/co2_sensor_simulator"
#   ]

#   query_string = <<EOF
# fields @timestamp, @message
# | filter @message like /CO2 sensor data/
# | parse @message "CO2 sensor data: *" as data
# | parse data "{\"device_id\": \"*\", \"co2\": *, \"unit\": \"*\", \"category\": \"*\", \"timestamp\": \"*\"}" as device_id, co2, unit, category, timestamp
# | stats avg(co2), min(co2), max(co2), count() by category, bin(1h)
# | sort @timestamp desc
# EOF
# }

# resource "aws_cloudwatch_query_definition" "environmental_overview" {
#   name = "EcoMonitor/Environmental-Overview"

#   log_group_names = [
#     "/aws/lambda/temperature_sensor_simulator",
#     "/aws/lambda/humidity_sensor_simulator",
#     "/aws/lambda/aqi_sensor_simulator",
#     "/aws/lambda/co2_sensor_simulator"
#   ]

#   query_string = <<EOF
# fields @timestamp, @message, @log
# | filter @message like /sensor data/
# | parse @log "/aws/lambda/*" as sensor_type
# | stats count() by sensor_type, bin(30m)
# | sort @timestamp desc
# EOF
# }

# # Output the sensor insights dashboard URL
# output "sensor_insights_dashboard_url" {
#   value = "https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.ecomonitor_sensor_insights.dashboard_name}"
#   description = "URL to access the EcoMonitor Sensor Data Insights Dashboard"
# }
