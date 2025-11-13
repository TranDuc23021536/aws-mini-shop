# Script deploy Lambda functions

param(
    [Parameter(Mandatory=$true)]
    [string]$RoleArn
)

Write-Host "Deploying Lambda Functions..." -ForegroundColor Green
Write-Host "Role ARN: $RoleArn" -ForegroundColor Yellow

$region = "ap-southeast-1"
$runtime = "nodejs18.x"

function Deploy-LambdaFunction {
    param(
        [string]$FunctionName,
        [string]$Handler,
        [string]$CodeFile
    )
    
    Write-Host "`nDeploying $FunctionName..." -ForegroundColor Cyan
    
    # Tao file zip
    Compress-Archive -Path $CodeFile -DestinationPath "$FunctionName.zip" -Force
    
    # Kiem tra Lambda da ton tai chua
    $exists = aws lambda get-function --function-name $FunctionName --region $region 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Updating existing function..." -ForegroundColor Yellow
        aws lambda update-function-code --function-name $FunctionName --zip-file "fileb://$FunctionName.zip" --region $region | Out-Null
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Creating new function..." -ForegroundColor Yellow
        aws lambda create-function --function-name $FunctionName --runtime $runtime --role $RoleArn --handler $Handler --zip-file "fileb://$FunctionName.zip" --timeout 30 --memory-size 256 --region $region | Out-Null
        Start-Sleep -Seconds 3
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success: $FunctionName deployed!" -ForegroundColor Green
    } else {
        Write-Host "Error: Failed to deploy $FunctionName" -ForegroundColor Red
    }
    
    Remove-Item "$FunctionName.zip" -ErrorAction SilentlyContinue
}

# Deploy cac functions
Deploy-LambdaFunction -FunctionName "MiniShop-Products" -Handler "products.handler" -CodeFile "products.js"
Deploy-LambdaFunction -FunctionName "MiniShop-Cart" -Handler "cart.handler" -CodeFile "cart.js"
Deploy-LambdaFunction -FunctionName "MiniShop-Orders" -Handler "orders.handler" -CodeFile "orders.js"

Write-Host "`nAll Lambda functions deployed successfully!" -ForegroundColor Green
Write-Host "`nListing functions:" -ForegroundColor Cyan
aws lambda list-functions --region $region --query "Functions[?starts_with(FunctionName, 'MiniShop')].FunctionName" --output table
