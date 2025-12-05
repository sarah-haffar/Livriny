// backend/src/resolvers/typeResolvers.js
const typeResolvers = {
  Restaurant: {
    menu: (parent) => parent.menuItems || [],
    isFavorite: (parent, _, { db, userId }) => {
      const user = db.users.find(u => u.id === userId);
      return user ? user.favorites.includes(parent.id) : false;
    }
  },
  
  Order: {
    restaurant: (parent, _, { db }) => {
      return db.restaurants.find(r => r.id === parent.restaurantId);
    },
    
    driver: (parent, _, { db }) => {
      if (!parent.driverId) return null;
      return db.drivers.find(d => d.id === parent.driverId);
    }
  },
  
  Cart: {
    restaurant: (parent, _, { db }) => {
      if (!parent.restaurantId) return null;
      return db.restaurants.find(r => r.id === parent.restaurantId);
    }
  },
  
  User: {
    favorites: (parent, _, { db }) => {
      return db.restaurants.filter(r => 
        parent.favorites.includes(r.id)
      );
    }
  },
  
  Dashboard: {
    activeOrders: (parent) => parent.activeOrders || [],
    recentOrders: (parent) => parent.recentOrders || [],
    favoriteRestaurants: (parent) => parent.favoriteRestaurants || [],
    cart: (parent) => parent.cart,
    notifications: (parent) => parent.notifications || []
  }
};

module.exports = typeResolvers;