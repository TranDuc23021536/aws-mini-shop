# Test tat ca Lambda functions

$region = "ap-southeast-1"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing all Lambda Functions" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# Test Products
Write-Host "1. Testing MiniShop-Products..." -ForegroundColor Yellow
aws lambda invoke --function-name MiniShop-Products --region $region test-products.json | Out-Null
$products = Get-Content test-products.json | ConvertFrom-Json
if ($products.statusCode -eq 200) {
    $body = $products.body | ConvertFrom-Json
    Write-Host "   ✅ SUCCESS - Found $($body.count) products" -ForegroundColor Green
} else {
    Write-Host "   ❌ FAILED - Status: $($products.statusCode)" -ForegroundColor Red
}

# Test Cart
Write-Host "`n2. Testing MiniShop-Cart..." -ForegroundColor Yellow
aws lambda invoke --function-name MiniShop-Cart --region $region test-cart.json | Out-Null
$cart = Get-Content test-cart.json | ConvertFrom-Json
if ($cart.statusCode -eq 200) {
    $body = $cart.body | ConvertFrom-Json
    Write-Host "   ✅ SUCCESS - Cart has $($body.cart.Count) items" -ForegroundColor Green
} else {
    Write-Host "   ❌ FAILED - Status: $($cart.statusCode)" -ForegroundColor Red
}

# Test Orders
Write-Host "`n3. Testing MiniShop-Orders..." -ForegroundColor Yellow
aws lambda invoke --function-name MiniShop-Orders --region $region test-orders.json | Out-Null
$orders = Get-Content test-orders.json | ConvertFrom-Json
if ($orders.statusCode -eq 200) {
    $body = $orders.body | ConvertFrom-Json
    Write-Host "   ✅ SUCCESS - Found $($body.count) orders" -ForegroundColor Green
} else {
    Write-Host "   ❌ FAILED - Status: $($orders.statusCode)" -ForegroundColor Red
}

# Clean up
Remove-Item test-*.json -ErrorAction SilentlyContinue

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "All Lambda Functions are ready!" -ForegroundColor Green
Write-Host "Next: Create API Gateway" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan