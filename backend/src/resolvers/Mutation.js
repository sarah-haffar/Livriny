// backend/src/resolvers/Mutation.js
const Mutation = {
  addToCart: (_, { itemId, quantity }, { db, userId }) => {
    if (quantity <= 0) throw new Error('Quantité invalide');
    
    const restaurant = db.getRestaurantByMenuItem(itemId);
    if (!restaurant) throw new Error('Item non trouvé');
    
    const menuItem = restaurant.menu.find(item => item.id === itemId);
    if (!menuItem || !menuItem.available) {
      throw new Error('Item indisponible');
    }
    
    let cart = db.getUserCart(userId);
    
    if (cart.restaurantId && cart.restaurantId !== restaurant.id) {
      throw new Error('Vous ne pouvez commander que dans un restaurant à la fois');
    }
    
    const existingItem = cart.items.find(item => item.itemId === itemId);
    if (existingItem) {
      existingItem.quantity += quantity;
    } else {
      cart.items.push({
        itemId,
        name: menuItem.name,
        quantity,
        price: menuItem.price
      });
    }
    
    cart.restaurantId = restaurant.id;
    db.calculateCartTotals(cart);
    db.carts[userId] = cart;
    
    return cart;
  },
  
  updateCartItem: (_, { itemId, quantity }, { db, userId }) => {
    const cart = db.getUserCart(userId);
    
    const itemIndex = cart.items.findIndex(item => item.itemId === itemId);
    if (itemIndex === -1) throw new Error('Item non trouvé dans le panier');
    
    if (quantity <= 0) {
      cart.items.splice(itemIndex, 1);
    } else {
      cart.items[itemIndex].quantity = quantity;
    }
    
    if (cart.items.length === 0) {
      cart.restaurantId = null;
    }
    
    db.calculateCartTotals(cart);
    db.carts[userId] = cart;
    
    return cart;
  },
  
  removeFromCart: (_, { itemId }, { db, userId }) => {
    const cart = db.getUserCart(userId);
    
    cart.items = cart.items.filter(item => item.itemId !== itemId);
    
    if (cart.items.length === 0) {
      cart.restaurantId = null;
    }
    
    db.calculateCartTotals(cart);
    db.carts[userId] = cart;
    
    return cart;
  },
  
  clearCart: (_, __, { db, userId }) => {
    db.carts[userId] = {
      items: [],
      subtotal: 0,
      deliveryFee: 0,
      tax: 0,
      total: 0,
      restaurantId: null
    };
    
    return db.carts[userId];
  },
  
  placeOrder: (_, { input }, { db, userId }) => {
    const cart = db.getUserCart(userId);
    if (!cart || cart.items.length === 0) {
      throw new Error('Panier vide');
    }
    
    const restaurant = db.restaurants.find(r => r.id === input.restaurantId);
    if (!restaurant) {
      throw new Error('Restaurant non trouvé');
    }
    
    // Créer la commande
    const order = {
      id: db.generateOrderId(),
      userId,
      restaurantId: restaurant.id,
      items: cart.items.map(item => ({
        itemId: item.itemId,
        name: item.name,
        quantity: item.quantity,
        price: item.price
      })),
      subtotal: cart.subtotal,
      deliveryFee: cart.deliveryFee,
      tax: cart.tax,
      total: cart.total,
      status: 'PENDING',
      deliveryAddress: input.deliveryAddress,
      specialInstructions: input.specialInstructions,
      createdAt: new Date().toISOString(),
      estimatedDelivery: new Date(
        Date.now() + restaurant.deliveryTime * 60000
      ).toISOString()
    };
    
    // Sauvegarder
    db.orders.push(order);
    
    // Vider le panier
    db.carts[userId] = {
      items: [],
      subtotal: 0,
      deliveryFee: 0,
      tax: 0,
      total: 0,
      restaurantId: null
    };
    
    // Simulation paiement
    const paymentIntent = {
      id: `pi_${order.id}`,
      clientSecret: `cs_${Math.random().toString(36).substr(2, 9)}`,
      amount: order.total,
      currency: 'eur'
    };
    
    return {
      order,
      paymentIntent
    };
  },
  
  updateProfile: (_, { input }, { db, userId }) => {
    let user = db.users.find(u => u.id === userId);
    
    if (!user) {
      user = {
        id: userId,
        name: '',
        email: '',
        phone: '',
        address: '',
        favorites: []
      };
      db.users.push(user);
    }
    
    Object.assign(user, input);
    
    return user;
  }
};

module.exports = { Mutation };