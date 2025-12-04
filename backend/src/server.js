// backend/src/server.js
const { ApolloServer } = require('apollo-server');
const { PubSub } = require('graphql-subscriptions');

// Données mockées temporaires
const mockData = {
  restaurants: [
    {
      id: "1",
      name: "Pizza Napoli",
      cuisine: "Italien",
      rating: 4.5,
      deliveryTime: 25,
      isOpen: true
    },
    {
      id: "2", 
      name: "Sushi Zen",
      cuisine: "Japonais", 
      rating: 4.7,
      deliveryTime: 35,
      isOpen: true
    }
  ]
};

// Schema GraphQL de base
const typeDefs = `
  type Query {
    restaurants: [Restaurant!]!
    restaurant(id: ID!): Restaurant
  }

  type Restaurant {
    id: ID!
    name: String!
    cuisine: String!
    rating: Float!
    deliveryTime: Int!
    isOpen: Boolean!
  }
`;

// Résolveurs de base
const resolvers = {
  Query: {
    restaurants: () => mockData.restaurants,
    restaurant: (_, { id }) => mockData.restaurants.find(r => r.id === id)
  }
};

// Créer le serveur
const server = new ApolloServer({
  typeDefs,
  resolvers,
  introspection: true,
  playground: true
});

// Démarrer sur le port 4001 👈 CHANGEMENT ICI
server.listen({ port: 4001 }).then(({ url }) => {
  console.log(`🚀 Serveur GraphQL Livriny prêt à: ${url}`);
  console.log(`🔗 Accédez au Playground: ${url}`);
});