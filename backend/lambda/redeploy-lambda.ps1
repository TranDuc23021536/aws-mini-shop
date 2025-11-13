# Script deploy lai Lambda voi dependencies

$region = "ap-southeast-1"
$roleArn = "arn:aws:iam::557433908403:role/MiniShop-Lambda-Role"

Write-Host "Re-deploying Lambda with dependencies..." -ForegroundColor Green

function Deploy-Lambda {
    param(
        [string]$FunctionName,
        [string]$Handler
    )
    
    Write-Host "`nDeploying $FunctionName..." -ForegroundColor Cyan
    
    # Tao file zip bao gom ca node_modules
    $jsFile = $Handler.Split('.')[0] + ".js"
    
    # Tao thu muc tam
    $tempDir = "temp-$FunctionName"
    if (Test-Path $tempDir) {
        Remove-Item $tempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    
    # Copy file JS
    Copy-Item $jsFile -Destination $tempDir
    
    # Copy node_modules
    if (Test-Path "node_modules") {
        Copy-Item "node_modules" -Destination $tempDir -Recurse
    }
    
    # Tao zip
    $zipFile = "$FunctionName.zip"
    if (Test-Path $zipFile) {
        Remove-Item $zipFile
    }
    
    Compress-Archive -Path "$tempDir\*" -DestinationPath $zipFile
    
    # Update Lambda
    Write-Host "Uploading code..." -ForegroundColor Yellow
    aws lambda update-function-code `
        --function-name $FunctionName `
        --zip-file "fileb://$zipFile" `
        --region $region | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success!" -ForegroundColor Green
    } else {
        Write-Host "Failed!" -ForegroundColor Red
    }
    
    # Don dep
    Remove-Item $tempDir -Recurse -Force
    Remove-Item $zipFile
}

# Deploy lai tat ca
Deploy-Lambda -FunctionName "MiniShop-Products" -Handler "products.handler"
Deploy-Lambda -FunctionName "MiniShop-Cart" -Handler "cart.handler"
Deploy-Lambda -FunctionName "MiniShop-Orders" -Handler "orders.handler"

Write-Host "`nAll Lambda functions redeployed!" -ForegroundColor Green
Write-Host "Please test again on AWS Console" -ForegroundColor Yellow