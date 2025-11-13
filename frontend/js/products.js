// Products page logic

let products = [];

// Format currency VND
function formatPrice(price) {
    return new Intl.NumberFormat('vi-VN', {
        style: 'currency',
        currency: 'VND'
    }).format(price);
}

// Render products
function renderProducts(products) {
    const grid = document.getElementById('products-grid');
    grid.innerHTML = '';

    products.forEach(product => {
        const card = document.createElement('div');
        card.className = 'product-card';
        
        card.innerHTML = `
            <img src="${product.image}" alt="${product.name}" class="product-image" onerror="this.src='https://via.placeholder.com/300x300?text=No+Image'">
            <div class="product-info">
                <div class="product-category">${product.category || 'Sản phẩm'}</div>
                <h3 class="product-name">${product.name}</h3>
                <p class="product-description">${product.description || ''}</p>
                <div class="product-price">${formatPrice(product.price)}</div>
                <div class="product-stock">Còn ${product.stock || 0} sản phẩm</div>
                <button class="add-to-cart-btn" onclick="addToCart('${product.productId}')" ${product.stock === 0 ? 'disabled' : ''}>
                    ${product.stock === 0 ? 'Hết hàng' : 'Thêm vào giỏ'}
                </button>
            </div>
        `;
        
        grid.appendChild(card);
    });
}

// Add to cart
async function addToCart(productId) {
    try {
        const result = await API.cart.add(productId, 1);
        alert('Đã thêm vào giỏ hàng!');
        updateCartCount();
    } catch (error) {
        alert('Không thể thêm vào giỏ hàng. Vui lòng thử lại.');
        console.error(error);
    }
}

// Update cart count
async function updateCartCount() {
    try {
        const result = await API.cart.get();
        const count = result.cart ? result.cart.length : 0;
        document.getElementById('cart-count').textContent = count;
    } catch (error) {
        console.error('Failed to update cart count:', error);
    }
}

// Load products
async function loadProducts() {
    const loading = document.getElementById('loading');
    const error = document.getElementById('error');
    
    try {
        loading.style.display = 'block';
        error.style.display = 'none';
        
        const result = await API.products.getAll();
        
        if (result.success && result.products) {
            products = result.products;
            renderProducts(products);
        } else {
            throw new Error('Invalid response format');
        }
    } catch (err) {
        console.error('Error loading products:', err);
        error.style.display = 'block';
    } finally {
        loading.style.display = 'none';
    }
}

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    loadProducts();
    updateCartCount();
});
