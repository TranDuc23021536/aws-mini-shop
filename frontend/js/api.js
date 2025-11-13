// API Configuration
const API_BASE_URL = 'https://cazx3lhgu0.execute-api.ap-southeast-1.amazonaws.com/prod';

// API Helper Functions
const API = {
    // GET request
    async get(endpoint) {
        try {
            const response = await fetch(`${API_BASE_URL}${endpoint}`);
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return await response.json();
        } catch (error) {
            console.error('API GET Error:', error);
            throw error;
        }
    },

    // POST request
    async post(endpoint, data) {
        try {
            const response = await fetch(`${API_BASE_URL}${endpoint}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return await response.json();
        } catch (error) {
            console.error('API POST Error:', error);
            throw error;
        }
    },

    // DELETE request
    async delete(endpoint) {
        try {
            const response = await fetch(`${API_BASE_URL}${endpoint}`, {
                method: 'DELETE'
            });
            if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
            return await response.json();
        } catch (error) {
            console.error('API DELETE Error:', error);
            throw error;
        }
    },

    // Products API
    products: {
        getAll: () => API.get('/products'),
        getById: (id) => API.get(`/products?productId=${id}`)
    },

    // Cart API
    cart: {
        get: () => API.get('/cart'),
        add: (productId, quantity) => API.post('/cart', { productId, quantity }),
        clear: () => API.delete('/cart')
    },

    // Orders API
    orders: {
        getAll: () => API.get('/orders'),
        create: (orderData) => API.post('/orders', orderData)
    }
};
