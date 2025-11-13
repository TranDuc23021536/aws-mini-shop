# Script tao Cognito User Pool va Client cho Windows PowerShell

Write-Host "Creating Cognito setup..." -ForegroundColor Green

$region = "ap-southeast-1"

# Buoc 1: Tao User Pool
Write-Host "Creating User Pool..." -ForegroundColor Yellow

$createPoolCommand = "aws cognito-idp create-user-pool " +
    "--pool-name MiniShopUserPool " +
    "--policies `"PasswordPolicy={MinimumLength=8,RequireUppercase=false,RequireLowercase=true,RequireNumbers=true,RequireSymbols=false}`" " +
    "--auto-verified-attributes email " +
    "--username-attributes email " +
    "--region $region " +
    "--output json"

$userPoolJson = Invoke-Expression $createPoolCommand

if ($LASTEXITCODE -eq 0) {
    $userPool = $userPoolJson | ConvertFrom-Json
    $userPoolId = $userPool.UserPool.Id
    Write-Host "User Pool created: $userPoolId" -ForegroundColor Green
    
    $userPoolJson | Out-File -FilePath "cognito-user-pool.json" -Encoding UTF8
    
    # Buoc 2: Tao User Pool Client
    Write-Host "Creating User Pool Client..." -ForegroundColor Yellow
    
    $createClientCommand = "aws cognito-idp create-user-pool-client " +
        "--user-pool-id $userPoolId " +
        "--client-name MiniShopWebClient " +
        "--no-generate-secret " +
        "--explicit-auth-flows ALLOW_USER_PASSWORD_AUTH ALLOW_REFRESH_TOKEN_AUTH ALLOW_USER_SRP_AUTH " +
        "--region $region " +
        "--output json"
    
    $clientJson = Invoke-Expression $createClientCommand
    
    if ($LASTEXITCODE -eq 0) {
        $client = $clientJson | ConvertFrom-Json
        $clientId = $client.UserPoolClient.ClientId
        Write-Host "Client created: $clientId" -ForegroundColor Green
        
        $clientJson | Out-File -FilePath "cognito-client.json" -Encoding UTF8
        
        # Buoc 3: Tao file config
        Write-Host "Creating config file..." -ForegroundColor Yellow
        
        $configContent = @"
// AWS Cognito Configuration
const AWS_CONFIG = {
    region: '$region',
    userPoolId: '$userPoolId',
    userPoolClientId: '$clientId'
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = AWS_CONFIG;
}
"@
        
        $frontendPath = "..\frontend\js"
        if (-not (Test-Path $frontendPath)) {
            New-Item -ItemType Directory -Path $frontendPath -Force | Out-Null
        }
        
        $configContent | Out-File -FilePath "$frontendPath\aws-config.js" -Encoding UTF8
        
        Write-Host "Config saved to frontend/js/aws-config.js" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "Cognito setup completed!" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Cyan
        Write-Host "User Pool ID: $userPoolId" -ForegroundColor White
        Write-Host "Client ID: $clientId" -ForegroundColor White
        Write-Host "Region: $region" -ForegroundColor White
        Write-Host "================================================" -ForegroundColor Cyan
        
        Write-Host ""
        Write-Host "To test, run these commands:" -ForegroundColor Cyan
        Write-Host "# Sign up:" -ForegroundColor Gray
        Write-Host "aws cognito-idp sign-up --client-id $clientId --username test@example.com --password Test@1234 --region $region" -ForegroundColor White
        Write-Host ""
        Write-Host "# Confirm user:" -ForegroundColor Gray
        Write-Host "aws cognito-idp admin-confirm-sign-up --user-pool-id $userPoolId --username test@example.com --region $region" -ForegroundColor White
        Write-Host ""
        Write-Host "# Sign in:" -ForegroundColor Gray
        Write-Host "aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --client-id $clientId --auth-parameters USERNAME=test@example.com,PASSWORD=Test@1234 --region $region" -ForegroundColor White
        
    } else {
        Write-Host "Failed to create User Pool Client" -ForegroundColor Red
    }
    
} else {
    Write-Host "Failed to create User Pool" -ForegroundColor Red
}
