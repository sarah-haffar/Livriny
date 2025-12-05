// backend/src/data/mockData.js
const fs = require('fs');
const path = require('path');
const { v4: uuidv4 } = require('uuid');


const mockData = {
  // ============ RESTAURANTS ============
  restaurants: [
    {
      id: "1",
      name: "Pizza Napoli",
      cuisine: "Italien",
      rating: 4.5,
      deliveryTime: 25,
      isOpen: true,
      address: "123 Rue de la Pizza, 75001 Paris",
      imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
      minOrder: 15.0,
      latitude: 48.8566,
      longitude: 2.3522,
      menu: [
        { id: "p1", name: "Pizza Margherita", description: "Tomate, mozzarella fraîche, basilic", price: 12.5, category: "Pizzas", available: true },
        { id: "p2", name: "Pizza 4 Fromages", description: "Mozzarella, gorgonzola, parmesan, chèvre", price: 14.5, category: "Pizzas", available: true },
        { id: "p3", name: "Tiramisu", description: "Dessert italien classique", price: 6.0, category: "Desserts", available: true },
        { id: "p4", name: "Pâtes Carbonara", description: "Spaghetti, œuf, pancetta, pecorino", price: 13.5, category: "Pâtes", available: true }
      ]
    },
    {
      id: "2",
      name: "Sushi Zen",
      cuisine: "Japonais",
      rating: 4.7,
      deliveryTime: 35,
      isOpen: true,
      address: "456 Avenue du Sushi, 75002 Paris",
      imageUrl: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351",
      minOrder: 20.0,
      latitude: 48.8570,
      longitude: 2.3530,
      menu: [
        { id: "s1", name: "Maki Saumon (6 pièces)", description: "Saumon frais, riz, algue nori", price: 8.5, category: "Sushis", available: true },
        { id: "s2", name: "California Roll (8 pièces)", description: "Saumon, avocat, concombre, mayonnaise", price: 9.5, category: "Sushis", available: true },
        { id: "s3", name: "Edamame", description: "Fèves de soja salées à la vapeur", price: 4.5, category: "Entrées", available: true },
        { id: "s4", name: "Sashimi Saumon (8 pièces)", description: "Tranches de saumon frais", price: 12.0, category: "Sushis", available: true }
      ]
    },
    {
      id: "3",
      name: "Burger House",
      cuisine: "Américain",
      rating: 4.3,
      deliveryTime: 20,
      isOpen: true,
      address: "789 Boulevard du Burger, 75003 Paris",
      imageUrl: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd",
      minOrder: 12.0,
      latitude: 48.22,
      longitude: 2.112,
      menu: [
        { id: "b1", name: "Classic Burger", description: "Steak haché 150g, salade, tomate, oignon", price: 10.5, category: "Burgers", available: true },
        { id: "b2", name: "Cheese Burger", description: "Steak haché, cheddar fondu, bacon croustillant", price: 12.5, category: "Burgers", available: true },
        { id: "b3", name: "Frites Maison", description: "Frites coupées à la main", price: 4.5, category: "Accompagnements", available: true },
        { id: "b4", name: "Milkshake Vanille", description: "Glace vanille, lait, sirop de vanille", price: 5.5, category: "Boissons", available: true }
      ]
    },
    {
      id: "4",
      name: "Crêperie Bretonne",
      cuisine: "Français",
      rating: 4.6,
      deliveryTime: 30,
      isOpen: true,
      address: "101 Rue de la Crêpe, 75004 Paris",
      imageUrl: "https://images.unsplash.com/photo-1562376552-0d160a2f238d",
      minOrder: 10.0,
      latitude: 59.8570,
      longitude: 3.3530,
      menu: [
        { id: "c1", name: "Crêpe Complète", description: "Jambon, fromage, œuf", price: 7.5, category: "Crêpes Salées", available: true },
        { id: "c2", name: "Crêpe Nutella", description: "Nutella, banane, amandes effilées", price: 6.5, category: "Crêpes Sucrées", available: true },
        { id: "c3", name: "Galette Saucisse", description: "Galette de sarrasin, saucisse de Toulouse", price: 8.5, category: "Crêpes Salées", available: true }
      ]
    }
  ],

  // ============ UTILISATEURS ============
  users: [
    { id: "user1", name: "Jean Dupont", email: "jean@example.com", phone: "06 12 34 56 78", address: "10 Rue de l'Exemple, 75015 Paris", favorites: ["1", "2"], createdAt: "2024-01-01T10:00:00Z" },
    { id: "user2", name: "Marie Martin", email: "marie@example.com", phone: "06 98 76 54 32", address: "20 Avenue des Tests, 75016 Paris", favorites: ["3"], createdAt: "2024-01-02T14:30:00Z" }
  ],

  // ============ COMMANDES ============
  orders: [],
  // ============ PANIERS ============
  carts: {},
  // ============ LIVREURS ============
  drivers: [],
  // ============ NOTIFICATIONS ============
  notifications: {},
  // ============ COUPONS ============
  coupons: [],

  // ======== UTILITAIRES ========
  getUserCart(userId) {
    return this.carts[userId] || {
      items: [],
      subtotal: 0,
      deliveryFee: 0,
      tax: 0,
      total: 0,
      restaurantId: null
    };
  },

  calculateCartTotals(cart) {
    cart.subtotal = cart.items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    cart.deliveryFee = cart.subtotal > 25 ? 0 : 2.5;
    cart.tax = cart.subtotal * 0.10;
    cart.total = cart.subtotal + cart.deliveryFee + cart.tax;
    return cart;
  },

  generateOrderId() {
    return `order_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  },

  getRestaurantByMenuItem(itemId) {
    return this.restaurants.find(r => r.menu.some(i => i.id === itemId));
  },

  // ======== PERSISTENCE ========
  readDB() {
    if (!fs.existsSync(dbPath)) return this;
    const raw = fs.readFileSync(dbPath, 'utf-8');
    const data = JSON.parse(raw);
    Object.assign(this, data);
    return this;
  },

  saveDB() {
    fs.writeFileSync(dbPath, JSON.stringify(this, null, 2));
  }
};

module.exports = mockData;
