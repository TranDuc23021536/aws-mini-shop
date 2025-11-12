# Tạo bảng Products
Write-Host "Creating Products table..." -ForegroundColor Yellow
aws dynamodb create-table --table-name Products --attribute-definitions AttributeName=productId,AttributeType=S --key-schema AttributeName=productId,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ap-southeast-1

Start-Sleep -Seconds 5

# Tạo bảng Cart
Write-Host "Creating Cart table..." -ForegroundColor Yellow
aws dynamodb create-table --table-name Cart --attribute-definitions AttributeName=userId,AttributeType=S --key-schema AttributeName=userId,KeyType=HASH --billing-mode PAY_PER_REQUEST --region ap-southeast-1

Start-Sleep -Seconds 5

# Tạo file JSON cho Orders GSI
@'
{
    "TableName": "Orders",
    "AttributeDefinitions": [
        {
            "AttributeName": "orderId",
            "AttributeType": "S"
        },
        {
            "AttributeName": "userId",
            "AttributeType": "S"
        }
    ],
    "KeySchema": [
        {
            "AttributeName": "orderId",
            "KeyType": "HASH"
        }
    ],
    "GlobalSecondaryIndexes": [
        {
            "IndexName": "UserOrdersIndex",
            "KeySchema": [
                {
                    "AttributeName": "userId",
                    "KeyType": "HASH"
                }
            ],
            "Projection": {
                "ProjectionType": "ALL"
            }
        }
    ],
    "BillingMode": "PAY_PER_REQUEST"
}
'@ | Out-File -FilePath "orders-table.json" -Encoding UTF8

# Tạo bảng Orders
Write-Host "Creating Orders table..." -ForegroundColor Yellow
aws dynamodb create-table --cli-input-json file://orders-table.json --region ap-southeast-1

# Dọn dẹp
Remove-Item "orders-table.json"

Write-Host "Done! Waiting for tables..." -ForegroundColor Green
aws dynamodb wait table-exists --table-name Products --region ap-southeast-1
aws dynamodb wait table-exists --table-name Orders --region ap-southeast-1
aws dynamodb wait table-exists --table-name Cart --region ap-southeast-1

Write-Host "All tables created successfully!" -ForegroundColor Green
aws dynamodb list-tables --region ap-southeast-1 --output table