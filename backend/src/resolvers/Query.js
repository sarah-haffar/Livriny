// backend/src/resolvers/Query.js
const Query = {
  restaurants: (_, { cuisine, isOpen }, { db }) => {
    let restaurants = db.restaurants;
    
    if (cuisine) {
      restaurants = restaurants.filter(r => 
        r.cuisine.toLowerCase() === cuisine.toLowerCase()
      );
    }
    
    if (isOpen !== undefined) {
      restaurants = restaurants.filter(r => r.isOpen === isOpen);
    }
    
    return restaurants;
  },
  
  restaurant: (_, { id }, { db }) => {
    const restaurant = db.restaurants.find(r => r.id === id);
    if (!restaurant) throw new Error('Restaurant non trouvé');
    return restaurant;
  },
  
  myCart: (_, __, { db, userId }) => {
    return db.getUserCart(userId);
  },
  
  myOrders: (_, { status }, { db, userId }) => {
    let orders = db.orders.filter(o => o.userId === userId);
    
    if (status) {
      orders = orders.filter(o => o.status === status);
    }
    
    return orders;
  },
  
  order: (_, { id }, { db, userId }) => {
    const order = db.orders.find(o => o.id === id && o.userId === userId);
    if (!order) throw new Error('Commande non trouvée');
    return order;
  },
  
  dashboard: (_, __, { db, userId }) => {
    const activeOrders = db.orders.filter(o => 
      o.userId === userId && 
      ['PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'ON_THE_WAY'].includes(o.status)
    );
    
    const recentOrders = db.orders
      .filter(o => o.userId === userId)
      .slice(0, 5);
    
    const user = db.users.find(u => u.id === userId);
    const favoriteRestaurants = user ? 
      db.restaurants.filter(r => user.favorites.includes(r.id)) : [];
    
    const cart = db.getUserCart(userId);
    const notifications = db.notifications[userId] || [];
    
    return {
      activeOrders,
      recentOrders,
      favoriteRestaurants,
      cart,
      notifications
    };
  },
  
  myProfile: (_, __, { db, userId }) => {
    const user = db.users.find(u => u.id === userId);
    if (!user) throw new Error('Utilisateur non trouvé');
    return user;
  }
};

module.exports = { Query };