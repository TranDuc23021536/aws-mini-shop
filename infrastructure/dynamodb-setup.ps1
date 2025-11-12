# Script tạo DynamoDB tables cho Windows
# Sử dụng JSON file thay vì inline JSON để tránh lỗi parse

Write-Host "🚀 Starting DynamoDB setup..." -ForegroundColor Green

$region = "ap-southeast-1"

# Hàm tạo bảng Products
function Create-ProductsTable {
    Write-Host "📦 Creating table: Products" -ForegroundColor Yellow
    
    try {
        aws dynamodb create-table `
            --table-name Products `
            --attribute-definitions AttributeName=productId,AttributeType=S `
            --key-schema AttributeName=productId,KeyType=HASH `
            --billing-mode PAY_PER_REQUEST `
            --region $region `
            --tags Key=Project,Value=MiniShop Key=Environment,Value=Development
        
        Write-Host "✅ Table Products created successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to create table Products" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Hàm tạo bảng Orders
function Create-OrdersTable {
    Write-Host "📦 Creating table: Orders" -ForegroundColor Yellow
    
    # Tạo file JSON tạm cho GlobalSecondaryIndexes
    $gsiJson = @'
[
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
]
'@
    
    $gsiJson | Out-File -FilePath "gsi-orders.json" -Encoding UTF8
    
    try {
        aws dynamodb create-table `
            --table-name Orders `
            --attribute-definitions `
                AttributeName=orderId,AttributeType=S `
                AttributeName=userId,AttributeType=S `
            --key-schema AttributeName=orderId,KeyType=HASH `
            --global-secondary-indexes file://gsi-orders.json `
            --billing-mode PAY_PER_REQUEST `
            --region $region `
            --tags Key=Project,Value=MiniShop
        
        Write-Host "✅ Table Orders created successfully!" -ForegroundColor Green
        
        # Xóa file tạm
        Remove-Item "gsi-orders.json" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "❌ Failed to create table Orders" -ForegroundColor Red
        Write-Host $_.Exception.Message
        Remove-Item "gsi-orders.json" -ErrorAction SilentlyContinue
    }
}

# Hàm tạo bảng Cart
function Create-CartTable {
    Write-Host "📦 Creating table: Cart" -ForegroundColor Yellow
    
    try {
        aws dynamodb create-table `
            --table-name Cart `
            --attribute-definitions AttributeName=userId,AttributeType=S `
            --key-schema AttributeName=userId,KeyType=HASH `
            --billing-mode PAY_PER_REQUEST `
            --region $region `
            --tags Key=Project,Value=MiniShop
        
        Write-Host "✅ Table Cart created successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to create table Cart" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Tạo các bảng
Create-ProductsTable
Start-Sleep -Seconds 3

Create-OrdersTable
Start-Sleep -Seconds 3

Create-CartTable
Start-Sleep -Seconds 3

Write-Host "`n⏳ Waiting for tables to be active..." -ForegroundColor Yellow

aws dynamodb wait table-exists --table-name Products --region $region
aws dynamodb wait table-exists --table-name Orders --region $region
aws dynamodb wait table-exists --table-name Cart --region $region

Write-Host "🎉 All tables are ready!" -ForegroundColor Green
Write-Host "`n📋 List of tables:"

aws dynamodb list-tables --region $region --output table