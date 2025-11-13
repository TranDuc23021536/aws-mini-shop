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
        
        if (httpMethod === 'GET') {
            // Neu co productId trong query string, lay 1 san pham
            if (event.queryStringParameters && event.queryStringParameters.productId) {
                const productId = event.queryStringParameters.productId;
                
                const params = {
                    TableName: 'Products',
                    Key: { productId }
                };
                
                const result = await dynamodb.get(params).promise();
                
                if (!result.Item) {
                    return {
                        statusCode: 404,
                        headers,
                        body: JSON.stringify({
                            success: false,
                            message: 'Product not found'
                        })
                    };
                }
                
                return {
                    statusCode: 200,
                    headers,
                    body: JSON.stringify({
                        success: true,
                        product: result.Item
                    })
                };
            }
            
            // Lay tat ca san pham
            const params = {
                TableName: 'Products'
            };
            
            const result = await dynamodb.scan(params).promise();
            
            return {
                statusCode: 200,
                headers,
                body: JSON.stringify({
                    success: true,
                    count: result.Items.length,
                    products: result.Items
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
            body: JSON.stringify({ 
                success: false,
                error: 'Method not allowed' 
            })
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
