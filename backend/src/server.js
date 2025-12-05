// backend/src/server.js
const { ApolloServer } = require('apollo-server');
const fs = require('fs');
const path = require('path');

// 1. Lire le schéma GraphQL
const typeDefs = fs.readFileSync(
  path.join(__dirname, 'schema/schema.graphql'),
  'utf8'
);

// 2. Importer les résolveurs
const resolvers = require('./resolvers');

// 3. Importer les données
const mockData = require('./data/mockData');

// 4. Créer le serveur
const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: ({ req }) => ({
    userId: req.headers.authorization || 'user1',
    db: mockData
  }),
  introspection: true,
  playground: true
});

// 5. Démarrer
server.listen({ port: 4001 }).then(({ url }) => {
  console.log(`🚀 FoodExpress Server prêt à: ${url}`);
  console.log('✅ Structure modulaire propre !');
});