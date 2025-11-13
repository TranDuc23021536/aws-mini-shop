const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'GET,POST,DELETE,OPTIONS',
        'Content-Type': 'application/json'
    };

    try {
        const httpMethod = event.httpMethod || 'GET';
        
        // Lay userId (tam thoi dung guest)
        let userId = 'guest';
        if (event.requestContext && event.requestContext.authorizer && event.requestContext.authorizer.claims) {
            userId = event.requestContext.authorizer.claims.sub;
        }
        
        // GET: Lay gio hang
        if (httpMethod === 'GET') {
            const params = {
                TableName: 'Cart',
                Key: { userId }
            };
            
            const result = await dynamodb.get(params).promise();
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    success: true,
                    cart: result.Item ? result.Item.items : []
                })
            };
        }
        
        // POST: Them san pham vao gio
        if (httpMethod === 'POST') {
            const body = JSON.parse(event.body);
            const { productId, quantity } = body;
            
            if (!productId || !quantity) {
                return {
                    statusCode: 400,
                    headers,
                    body: JSON.stringify({
                        success: false,
                        error: 'productId and quantity are required'
                    })
                };
            }
            
            // Lay thong tin san pham
            const productParams = {
                TableName: 'Products',
                Key: { productId }
            };
            
            const productResult = await dynamodb.get(productParams).promise();
            
            if (!productResult.Item) {
                return {
                    statusCode: 404,
                    headers,
                    body: JSON.stringify({
                        success: false,
                        error: 'Product not found'
                    })
                };
            }
            
            const product = productResult.Item;
            
            const cartItem = {
                productId,
                name: product.name,
                price: product.price,
                image: product.image,
                quantity: parseInt(quantity),
                addedAt: new Date().toISOString()
            };
            
            // Lay gio hang hien tai
            const cartParams = {
                TableName: 'Cart',
                Key: { userId }
            };
            
            const cartResult = await dynamodb.get(cartParams).promise();
            let items = cartResult.Item ? cartResult.Item.items : [];
            
            // Kiem tra san pham da co trong gio chua
            const existingItemIndex = items.findIndex(item => item.productId === productId);
            
            if (existingItemIndex >= 0) {
                items[existingItemIndex].quantity += parseInt(quantity);
            } else {
                items.push(cartItem);
            }
            
            // Luu lai gio hang
            const updateParams = {
                TableName: 'Cart',
                Key: { userId },
                UpdateExpression: 'SET items = :items, updatedAt = :updatedAt',
                ExpressionAttributeValues: {
                    ':items': items,
                    ':updatedAt': new Date().toISOString()
                },
                ReturnValues: 'ALL_NEW'
            };
            
            const updateResult = await dynamodb.update(updateParams).promise();
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    success: true,
                    message: 'Product added to cart',
                    cart: updateResult.Attributes.items
                })
            };
        }
        
        // DELETE: Xoa gio hang
        if (httpMethod === 'DELETE') {
            const params = {
                TableName: 'Cart',
                Key: { userId }
            };
            
            await dynamodb.delete(params).promise();
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    success: true,
                    message: 'Cart cleared'
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
