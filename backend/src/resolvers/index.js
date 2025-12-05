// backend/src/resolvers/index.js
const Query = require('./Query');
const Mutation = require('./Mutation');
const typeResolvers = require('./typeResolvers');

module.exports = {
  ...Query,
  ...Mutation,
  ...typeResolvers
};