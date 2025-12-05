// backend/src/data/mockData.js
const { v4: uuidv4 } = require('uuid');

const mockData = {
  // ============ RESTAURANTS ============
  restaurants: [
    {
      id: "1",
      name: "Pizza Napoli",
      cuisine: "Italien",
      rating: 4.5,
      deliveryTime: 25, // minutes
      isOpen: true,
      address: "123 Rue de la Pizza, 75001 Paris",
      imageUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38",
      minOrder: 15.00,
      menuItems: [
        {
          id: "p1",
          name: "Pizza Margherita",
          description: "Tomate, mozzarella fraîche, basilic",
          price: 12.50,
          category: "Pizzas",
          available: true
        },
        {
          id: "p2",
          name: "Pizza 4 Fromages",
          description: "Mozzarella, gorgonzola, parmesan, chèvre",
          price: 14.50,
          category: "Pizzas",
          available: true
        },
        {
          id: "p3",
          name: "Tiramisu",
          description: "Dessert italien classique",
          price: 6.00,
          category: "Desserts",
          available: true
        },
        {
          id: "p4",
          name: "Pâtes Carbonara",
          description: "Spaghetti, œuf, pancetta, pecorino",
          price: 13.50,
          category: "Pâtes",
          available: true
        }
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
      minOrder: 20.00,
      menuItems: [
        {
          id: "s1",
          name: "Maki Saumon (6 pièces)",
          description: "Saumon frais, riz, algue nori",
          price: 8.50,
          category: "Sushis",
          available: true
        },
        {
          id: "s2",
          name: "California Roll (8 pièces)",
          description: "Saumon, avocat, concombre, mayonnaise",
          price: 9.50,
          category: "Sushis",
          available: true
        },
        {
          id: "s3",
          name: "Edamame",
          description: "Fèves de soja salées à la vapeur",
          price: 4.50,
          category: "Entrées",
          available: true
        },
        {
          id: "s4",
          name: "Sashimi Saumon (8 pièces)",
          description: "Tranches de saumon frais",
          price: 12.00,
          category: "Sushis",
          available: true
        }
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
      minOrder: 12.00,
      menuItems: [
        {
          id: "b1",
          name: "Classic Burger",
          description: "Steak haché 150g, salade, tomate, oignon",
          price: 10.50,
          category: "Burgers",
          available: true
        },
        {
          id: "b2",
          name: "Cheese Burger",
          description: "Steak haché, cheddar fondu, bacon croustillant",
          price: 12.50,
          category: "Burgers",
          available: true
        },
        {
          id: "b3",
          name: "Frites Maison",
          description: "Frites coupées à la main",
          price: 4.50,
          category: "Accompagnements",
          available: true
        },
        {
          id: "b4",
          name: "Milkshake Vanille",
          description: "Glace vanille, lait, sirop de vanille",
          price: 5.50,
          category: "Boissons",
          available: true
        }
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
      minOrder: 10.00,
      menuItems: [
        {
          id: "c1",
          name: "Crêpe Complète",
          description: "Jambon, fromage, œuf",
          price: 7.50,
          category: "Crêpes Salées",
          available: true
        },
        {
          id: "c2",
          name: "Crêpe Nutella",
          description: "Nutella, banane, amandes effilées",
          price: 6.50,
          category: "Crêpes Sucrées",
          available: true
        },
        {
          id: "c3",
          name: "Galette Saucisse",
          description: "Galette de sarrasin, saucisse de Toulouse",
          price: 8.50,
          category: "Crêpes Salées",
          available: true
        }
      ]
    }
  ],

  // ============ UTILISATEURS ============
  users: [
    {
      id: "user1",
      name: "Jean Dupont",
      email: "jean@example.com",
      phone: "06 12 34 56 78",
      address: "10 Rue de l'Exemple, 75015 Paris",
      favorites: ["1", "2"], // IDs des restaurants favoris
      createdAt: "2024-01-01T10:00:00Z"
    },
    {
      id: "user2",
      name: "Marie Martin",
      email: "marie@example.com",
      phone: "06 98 76 54 32",
      address: "20 Avenue des Tests, 75016 Paris",
      favorites: ["3"],
      createdAt: "2024-01-02T14:30:00Z"
    }
  ],

  // ============ COMMANDES ============
  orders: [
    {
      id: "order1",
      userId: "user1",
      restaurantId: "1",
      items: [
        { 
          itemId: "p1", 
          name: "Pizza Margherita", 
          quantity: 2, 
          price: 12.50 
        },
        { 
          itemId: "p3", 
          name: "Tiramisu", 
          quantity: 1, 
          price: 6.00 
        }
      ],
      subtotal: 31.00, // 2x12.50 + 6.00
      deliveryFee: 2.50,
      tax: 3.10, // 10% de TVA
      total: 36.60,
      status: "DELIVERED",
      deliveryAddress: "10 Rue de l'Exemple, 75015 Paris",
      createdAt: "2024-01-15T19:30:00Z",
      estimatedDelivery: "2024-01-15T20:00:00Z",
      deliveredAt: "2024-01-15T19:55:00Z"
    },
    {
      id: "order2",
      userId: "user1",
      restaurantId: "2",
      items: [
        { 
          itemId: "s1", 
          name: "Maki Saumon (6 pièces)", 
          quantity: 1, 
          price: 8.50 
        },
        { 
          itemId: "s2", 
          name: "California Roll (8 pièces)", 
          quantity: 1, 
          price: 9.50 
        }
      ],
      subtotal: 18.00,
      deliveryFee: 3.00, // Plus loin
      tax: 1.80,
      total: 22.80,
      status: "PREPARING",
      deliveryAddress: "10 Rue de l'Exemple, 75015 Paris",
      createdAt: "2024-01-20T12:45:00Z",
      estimatedDelivery: "2024-01-20T13:30:00Z"
    },
    {
      id: "order3",
      userId: "user2",
      restaurantId: "3",
      items: [
        { 
          itemId: "b2", 
          name: "Cheese Burger", 
          quantity: 1, 
          price: 12.50 
        },
        { 
          itemId: "b3", 
          name: "Frites Maison", 
          quantity: 1, 
          price: 4.50 
        }
      ],
      subtotal: 17.00,
      deliveryFee: 2.00,
      tax: 1.70,
      total: 20.70,
      status: "ON_THE_WAY",
      deliveryAddress: "20 Avenue des Tests, 75016 Paris",
      createdAt: "2024-01-20T13:00:00Z",
      estimatedDelivery: "2024-01-20T13:25:00Z",
      driverId: "driver1"
    }
  ],

  // ============ PANNES ============
  // Structure: { userId: cartObject }
  carts: {
    "user1": {
      items: [
        { 
          itemId: "b1", 
          name: "Classic Burger", 
          quantity: 1, 
          price: 10.50 
        },
        { 
          itemId: "b3", 
          name: "Frites Maison", 
          quantity: 2, 
          price: 4.50 
        }
      ],
      subtotal: 19.50, // 10.50 + (2x4.50)
      deliveryFee: 2.50,
      tax: 1.95,
      total: 23.95,
      restaurantId: "3" // Pour vérifier qu'on ne mélange pas les restaurants
    }
  },

  // ============ LIVREURS ============
  drivers: [
    {
      id: "driver1",
      name: "Marc Livreur",
      phone: "06 11 22 33 44",
      isAvailable: false,
      currentOrderId: "order3",
      rating: 4.8,
      vehicle: "Vélo électrique"
    },
    {
      id: "driver2",
      name: "Sophie Coursier",
      phone: "06 55 66 77 88",
      isAvailable: true,
      rating: 4.9,
      vehicle: "Scooter"
    }
  ],

  // ============ NOTIFICATIONS ============
  notifications: {
    "user1": [
      {
        id: "notif1",
        type: "ORDER_CONFIRMED",
        title: "Commande confirmée",
        message: "Votre commande #order2 a été confirmée par Sushi Zen",
        read: false,
        createdAt: "2024-01-20T12:50:00Z"
      },
      {
        id: "notif2",
        type: "ORDER_ON_THE_WAY",
        title: "Votre commande est en route",
        message: "Marc Livreur vient de prendre votre commande #order3",
        read: true,
        createdAt: "2024-01-20T13:05:00Z"
      }
    ]
  },

  // ============ COUPONS ============
  coupons: [
    {
      code: "BIENVENUE10",
      discount: 10, // pourcentage
      minOrder: 20.00,
      validUntil: "2024-12-31T23:59:59Z",
      usedCount: 5
    },
    {
      code: "LIVRAISONOFFERTE",
      discount: 100, // pourcentage sur la livraison seulement
      discountType: "DELIVERY",
      minOrder: 15.00,
      validUntil: "2024-02-29T23:59:59Z",
      usedCount: 2
    }
  ]
};

// Fonctions utilitaires
mockData.getUserCart = function(userId) {
  return this.carts[userId] || {
    items: [],
    subtotal: 0,
    deliveryFee: 0,
    tax: 0,
    total: 0,
    restaurantId: null
  };
};

mockData.calculateCartTotals = function(cart) {
  cart.subtotal = cart.items.reduce((sum, item) => 
    sum + (item.price * item.quantity), 0
  );
  
  // Frais de livraison basiques
  cart.deliveryFee = cart.subtotal > 25 ? 0 : 2.50;
  
  // TVA 10%
  cart.tax = cart.subtotal * 0.10;
  
  cart.total = cart.subtotal + cart.deliveryFee + cart.tax;
  
  return cart;
};

mockData.generateOrderId = function() {
  return `order_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
};

mockData.getRestaurantByMenuItem = function(itemId) {
  return this.restaurants.find(restaurant =>
    restaurant.menuItems.some(item => item.id === itemId)
  );
};

module.exports = mockData;