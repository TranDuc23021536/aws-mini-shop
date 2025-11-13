const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
        'Content-Type': 'application/json'
    };

    try {
        const httpMethod = event.httpMethod || 'GET';
        
        // Lay userId
        let userId = 'guest';
        if (event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.claims) {
            userId = event.requestContext.authorizer.claims.sub;
        }
        
        // POST: Tao don hang
        if (httpMethod === 'POST') {
            const body = JSON.parse(event.body);
            const { items, shippingAddress, totalAmount } = body;
            
            if (!items || items.length === 0) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({
                        success: false,
                        error: 'Cart is empty'
                    })
                };
            }
            
            const order = {
                orderId: `order-${Date.now()}`,
                userId,
                items,
                totalAmount: totalAmount || items.reduce((sum, item) => sum + (item.price * item.quantity), 0),
                shippingAddress: shippingAddress || {},
                status: 'pending',
                createdAt: new Date().toISOString()
            };
            
            const params = {
                TableName: 'Orders',
                Item: order
            };
            
            await dynamodb.put(params).promise();
            
            // Xoa gio hang
            const deleteCartParams = {
                TableName: 'Cart',
                Key: { userId }
            };
            
            await dynamodb.delete(deleteCartParams).promise();
            
            return {
                statusCode: 201,
                headers,
                body: JSON.stringify({
                    success: true,
                    message: 'Order created successfully',
                    order
                })
            };
        }
        
        // GET: Lay lich su don hang
        if (httpMethod === 'GET') {
            const params = {
                TableName: 'Orders',
                IndexName: 'UserOrdersIndex',
                KeyConditionExpression: 'userId = :userId',
                ExpressionAttributeValues: {
                    ':userId': userId
                },
                ScanIndexForward: false
            };
            
            const result = await dynamodb.query(params).promise();
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    success: true,
                    count: result.Items.length,
                    orders: result.Items
                })
            };
        }
        
        if (httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers,
                body: ''
            };
        }
        
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Method not allowed' })
        };
        
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                success: false,
                error: error.message
            })
        };
    }
};
