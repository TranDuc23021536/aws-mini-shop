# Script tao IAM Role cho Lambda

Write-Host "Creating IAM Role for Lambda..." -ForegroundColor Green

# Tao trust policy
$trustPolicy = @{
    Version = "2012-10-17"
    Statement = @(
        @{
            Effect = "Allow"
            Principal = @{
                Service = "lambda.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    )
} | ConvertTo-Json -Depth 10 -Compress

Write-Host "Trust Policy:" -ForegroundColor Yellow
Write-Host $trustPolicy

# Tao role
Write-Host "`nCreating role..." -ForegroundColor Cyan
aws iam create-role --role-name MiniShop-Lambda-Role --assume-role-policy-document $trustPolicy

if ($LASTEXITCODE -eq 0) {
    Write-Host "Role created successfully!" -ForegroundColor Green
    
    # Cho AWS propagate (doi 5 giay)
    Write-Host "`nWaiting for role to propagate..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    # Attach policies
    Write-Host "`nAttaching CloudWatch Logs policy..." -ForegroundColor Cyan
    aws iam attach-role-policy --role-name MiniShop-Lambda-Role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    
    Write-Host "Attaching DynamoDB policy..." -ForegroundColor Cyan
    aws iam attach-role-policy --role-name MiniShop-Lambda-Role --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
    
    # Lay Role ARN
    Write-Host "`nGetting Role ARN..." -ForegroundColor Cyan
    $roleArn = aws iam get-role --role-name MiniShop-Lambda-Role --query 'Role.Arn' --output text
    
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host "IAM Role Setup Completed!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Role Name: MiniShop-Lambda-Role" -ForegroundColor White
    Write-Host "Role ARN: $roleArn" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Green
    
    Write-Host "`nSave this ARN for Lambda deployment!" -ForegroundColor Cyan
    
    # Luu ARN vao file
    $roleArn | Out-File -FilePath "lambda-role-arn.txt" -Encoding UTF8
    Write-Host "ARN saved to: lambda-role-arn.txt" -ForegroundColor Gray
    
} else {
    Write-Host "Failed to create role!" -ForegroundColor Red
    Write-Host "The role might already exist. Checking..." -ForegroundColor Yellow
    
    $roleArn = aws iam get-role --role-name MiniShop-Lambda-Role --query 'Role.Arn' --output text 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nRole already exists!" -ForegroundColor Green
        Write-Host "Role ARN: $roleArn" -ForegroundColor Yellow
        $roleArn | Out-File -FilePath "lambda-role-arn.txt" -Encoding UTF8
    }
}