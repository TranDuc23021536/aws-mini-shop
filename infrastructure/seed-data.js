const AWS = require('aws-sdk');

// Cấu hình AWS
AWS.config.update({ 
    region: 'ap-southeast-1'
});

const dynamodb = new AWS.DynamoDB.DocumentClient();

// Dữ liệu mẫu sản phẩm
const sampleProducts = [
    {
        productId: 'prod-001',
        name: 'iPhone 15 Pro Max',
        price: 29990000,
        description: 'Smartphone cao cấp với chip A17 Pro, camera 48MP, màn hình 6.7 inch Super Retina XDR',
        image: 'https://cdn.tgdd.vn/Products/Images/42/305658/iphone-15-pro-max-blue-thumbnew-600x600.jpg',
        category: 'Điện thoại',
        stock: 50,
        brand: 'Apple',
        rating: 4.8,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-002',
        name: 'MacBook Air M3',
        price: 28990000,
        description: 'Laptop siêu mỏng nhẹ, chip M3 mạnh mẽ, pin 18 giờ, màn hình Liquid Retina 13.6 inch',
        image: 'https://cdn.tgdd.vn/Products/Images/44/322826/apple-macbook-air-13-inch-m3-2024-16gb-256gb-thumb-600x600.jpg',
        category: 'Laptop',
        stock: 30,
        brand: 'Apple',
        rating: 4.9,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-003',
        name: 'AirPods Pro 2',
        price: 5990000,
        description: 'Tai nghe không dây chống ồn chủ động, chip H2, sạc MagSafe',
        image: 'https://cdn.tgdd.vn/Products/Images/54/289780/tai-nghe-bluetooth-airpods-pro-2-usb-c-charge-apple-mqd83-thumb-600x600.jpg',
        category: 'Phụ kiện',
        stock: 100,
        brand: 'Apple',
        rating: 4.7,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-004',
        name: 'iPad Pro 12.9 M2',
        price: 26990000,
        description: 'Máy tính bảng chuyên nghiệp với chip M2, màn hình Liquid Retina XDR',
        image: 'https://cdn.tgdd.vn/Products/Images/522/285067/ipad-pro-129-m2-wifi-cellular-gray-thumb-600x600.jpg',
        category: 'Tablet',
        stock: 25,
        brand: 'Apple',
        rating: 4.8,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-005',
        name: 'Samsung Galaxy S24 Ultra',
        price: 27990000,
        description: 'Flagship Android với bút S-Pen, camera 200MP, Snapdragon 8 Gen 3',
        image: 'https://cdn.tgdd.vn/Products/Images/42/319952/samsung-galaxy-s24-ultra-grey-thumbnew-600x600.jpg',
        category: 'Điện thoại',
        stock: 40,
        brand: 'Samsung',
        rating: 4.7,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-006',
        name: 'Dell XPS 13',
        price: 24990000,
        description: 'Laptop doanh nhân cao cấp, Intel Core i7 thế hệ 13, màn hình 13.4 inch FHD+',
        image: 'https://cdn.tgdd.vn/Products/Images/44/308174/dell-xps-13-9340-ultra-7-155h-thumb-600x600.jpg',
        category: 'Laptop',
        stock: 20,
        brand: 'Dell',
        rating: 4.6,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-007',
        name: 'Sony WH-1000XM5',
        price: 8990000,
        description: 'Tai nghe chống ồn hàng đầu, âm thanh Hi-Res, pin 30 giờ',
        image: 'https://cdn.tgdd.vn/Products/Images/54/313175/tai-nghe-bluetooth-sony-wh-1000xm5-den-thumb-1-600x600.jpg',
        category: 'Phụ kiện',
        stock: 60,
        brand: 'Sony',
        rating: 4.9,
        createdAt: new Date().toISOString()
    },
    {
        productId: 'prod-008',
        name: 'Apple Watch Series 9',
        price: 10990000,
        description: 'Đồng hồ thông minh với chip S9, màn hình luôn bật, tính năng sức khỏe toàn diện',
        image: 'https://cdn.tgdd.vn/Products/Images/7077/309066/apple-watch-s9-gps-41mm-vien-nhom-day-cao-su-thumb-den-600x600.jpg',
        category: 'Phụ kiện',
        stock: 45,
        brand: 'Apple',
        rating: 4.8,
        createdAt: new Date().toISOString()
    }
];

// Hàm seed dữ liệu
async function seedProducts() {
    console.log('🌱 Starting seed data...\n');
    
    for (const product of sampleProducts) {
        const params = {
            TableName: 'Products',
            Item: product
        };
        
        try {
            await dynamodb.put(params).promise();
            console.log(`✅ Added: ${product.name} (${product.productId})`);
        } catch (error) {
            console.error(`❌ Error adding ${product.name}:`, error.message);
        }
    }
    
    console.log('\n🎉 Seed data completed!');
    console.log(`📊 Total products added: ${sampleProducts.length}`);
}

// Chạy seed
seedProducts().catch(console.error);