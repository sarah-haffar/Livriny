// lib/screens/checkout_screen.dart - VERSION COMPLÈTE CORRIGÉE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/cart.dart';
import '../services/graphql_service.dart';
import '../widgets/checkout_step_indicator.dart';
import '../widgets/payment_method_card.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Données du formulaire
  String _deliveryAddress = '';
  String? _specialInstructions;
  String _paymentMethod = 'card';
  String _cardNumber = '';
  String _cardExpiry = '';
  String _cardCvc = '';
  String _cardHolder = '';

  // Pour paiement en espèces
  String _cashAmount = '';
  bool _exactAmount = true;
  final TextEditingController _cashAmountController = TextEditingController();

  // Étapes du checkout
  final List<String> _steps = [
    'Panier',
    'Livraison',
    'Paiement',
    'Confirmation',
  ];

  @override
  void initState() {
    super.initState();
    _cashAmountController.addListener(() {
      setState(() {
        _cashAmount = _cashAmountController.text;
      });
    });
  }

  @override
  void dispose() {
    _cashAmountController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showOrderSummary(BuildContext context, CartModel cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Récapitulatif de commande',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Détails de la commande
              _buildSummaryRow(
                  'Date', DateTime.now().toString().substring(0, 16)),
              _buildSummaryRow('N° Commande',
                  '#${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}'),
              _buildSummaryRow(
                  'Adresse',
                  _deliveryAddress.isNotEmpty
                      ? _deliveryAddress
                      : 'Non spécifiée'),
              _buildSummaryRow(
                  'Instructions',
                  _specialInstructions?.isNotEmpty == true
                      ? _specialInstructions!
                      : 'Aucune'),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Articles
              const Text(
                'Articles',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...cart.items.values
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.item.name} x${item.quantity}'),
                            Text('${item.totalPrice.toStringAsFixed(2)}TND'),
                          ],
                        ),
                      ))
                  .toList(),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${cart.totalWithFees.toStringAsFixed(2)}TND',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B0000),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('FERMER'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Dans _CheckoutScreenState class, ajoutez cette méthode
  String _getRestaurantId(CartModel cart) {
    // Essayer mainRestaurantId d'abord
    if (cart.mainRestaurantId != null && cart.mainRestaurantId!.isNotEmpty) {
      return cart.mainRestaurantId!;
    }

    // Si pas de restaurantId dans les items, utiliser un ID fixe pour tester
    print(
        '⚠️ Aucun restaurantId trouvé dans les items, utilisation ID par défaut');

    // ID par défaut pour tester - À REMPLACER par l'ID réel plus tard
    return '1'; // ou 'restaurant_1' selon votre schéma

    // Alternative: extraire du contexte si vous avez un restaurant sélectionné
    // final restaurantProvider = Provider.of<RestaurantProvider>(context, listen: false);
    // return restaurantProvider.selectedRestaurant?.id ?? '1';
  }

  // Valider le paiement en espèces
  bool _validateCashPayment(CartModel cart) {
    if (_paymentMethod != 'cash') return true;

    if (_exactAmount) return true;

    if (_cashAmount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir le montant que vous donnerez'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final cashValue = double.tryParse(_cashAmount);
    if (cashValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant invalide'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (cashValue < cart.totalWithFees) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Montant insuffisant. Il manque ${(cart.totalWithFees - cashValue).toStringAsFixed(2)}TND'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final items = cart.items.values.toList();

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: const Color(0xFF8B0000),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Votre panier est vide',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text('Ajoutez des articles pour passer commande'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B0000),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retour aux restaurants'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Indicateur d'étapes
          CheckoutStepIndicator(
            currentStep: _currentStep,
            steps: _steps,
          ),

          // Contenu des étapes
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Étape 1: Panier
                _buildCartStep(cart),

                // Étape 2: Livraison
                _buildDeliveryStep(),

                // Étape 3: Paiement
                _buildPaymentStep(cart),

                // Étape 4: Confirmation
                _buildConfirmationStep(cart),
              ],
            ),
          ),

          // Boutons de navigation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8B0000),
                        side: const BorderSide(color: Color(0xFF8B0000)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('RETOUR'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 10),
                Expanded(
                  child: Mutation(
                    options: MutationOptions(
                      document: gql(GraphQLService.placeOrderMutation),
                      onCompleted: (data) {
                        print('=== MUTATION COMPLÉTÉE ===');
                        print('Data reçue: $data');

                        if (data != null) {
                          final result = data['placeOrder'];
                          print('Result placeOrder: $result');

                          if (result != null) {
                            final order = result['order'];
                            final paymentIntent = result['paymentIntent'];

                            if (order != null && order['id'] != null) {
                              print('✅ Commande réussie!');
                              print('ID commande: ${order['id']}');
                              print('Statut: ${order['status']}');
                              print('Total: ${order['total']}');

                              if (paymentIntent != null) {
                                print(
                                    'Payment Intent ID: ${paymentIntent['id']}');
                                print(
                                    'Client Secret: ${paymentIntent['clientSecret']}');
                              }

                              // Vider le panier
                              cart.clear();

                              // Afficher message de succès
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Commande #${order['id']} confirmée!'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 3),
                                ),
                              );

                              _nextStep();
                            } else {
                              print('❌ Commande échouée - order est null');
                              print('Résultat complet: $result');

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erreur lors de la commande'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                        print('========================\n');
                      },
                      onError: (error) {
                        // Log détaillé de l'erreur
                        print('Erreur GraphQL détaillée:');
                        print('Type: ${error.runtimeType}');
                        print(
                            'Message: ${error.toString()}'); // Utiliser toString() au lieu de .message

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Erreur réseau: ${error.toString()}'), // Ici aussi
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                    builder: (runMutation, result) {
                      return ElevatedButton(
                        onPressed: () async {
                          // AJOUTEZ 'async' ici
                          print('=== BOUTON PRESSÉ - Étape $_currentStep ===');

                          if (_currentStep == 2) {
                            print('1. Début étape paiement');

                            // 1. Valider le paiement
                            if (!_validateCashPayment(cart)) {
                              return;
                            }

                            // 2. Vérifier adresse
                            if (_deliveryAddress.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Adresse de livraison requise'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // 3. VÉRIFICATION CRITIQUE - quel article avez-vous ?
                            print('=== VÉRIFICATION ARTICLE ===');
                            print('Article ID: ${items.first.item.id}');
                            print('Article nom: ${items.first.item.name}');
                            print('============================');

                            // 4. Préparer les données
                            final restaurantId = '3'; // Burger House
                            final itemId = items.first.item.id.toString();

                            // VÉRIFIER que c'est bien "b1" (Classic Burger)
                            if (itemId != 'p1') {
                              print(
                                  '❌ ATTENTION: Vous avez "$itemId" au lieu de "b1"');
                              print(
                                  'Vous avez peut-être ajouté un mauvais article');
                            }

                            final input = {
                              'input': {
                                'restaurantId': restaurantId,
                                'items': [
                                  {
                                    'itemId': itemId,
                                    'quantity': items.first.quantity,
                                  }
                                ],
                                'deliveryAddress': _deliveryAddress.trim(),
                                'specialInstructions':
                                    _specialInstructions?.trim() ?? '',
                              },
                            };

                            print('=== DONNÉES FINALES ===');
                            print(
                                'Restaurant: Burger House (ID: $restaurantId)');
                            print(
                                'Article: ${items.first.item.name} (ID: $itemId)');
                            print('========================');

                            try {
                              // 5. AJOUTER D'ABORD AU PANIER SERVEUR (NOUVEAU)
                              print('1/2 - Ajout au panier serveur...');

                              final addResult =
                                  await GraphQLService.client.mutate(
                                MutationOptions(
                                  document:
                                      gql(GraphQLService.addToCartMutation),
                                  variables: {
                                    'itemId': itemId,
                                    'quantity': items.first.quantity,
                                  },
                                ),
                              );

                              print(
                                  '✅ Panier serveur mis à jour: ${addResult.data}');

                              // 6. Attendre un peu
                              await Future.delayed(
                                  const Duration(milliseconds: 500));

                              // 7. PASSER COMMANDE
                              print('2/2 - Passage de commande...');
                              runMutation(input);
                            } catch (e) {
                              print('❌ Erreur: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else if (_currentStep == 0) {
                            _nextStep();
                          } else if (_currentStep == 1) {
                            if (_deliveryAddress.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez saisir une adresse'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              _nextStep();
                            }
                          } else if (_currentStep == 3) {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }

                          print('=== FIN BOUTON PRESSÉ ===\n');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: Colors.grey,
                          // Ajouter un feedback visuel
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: result?.isLoading == true
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'TRAITEMENT...',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : Text(
                                _currentStep == 2
                                    ? 'CONFIRMER ET PAYER'
                                    : _currentStep == 3
                                        ? 'RETOUR À L\'ACCUEIL'
                                        : 'SUIVANT',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartStep(CartModel cart) {
    final items = cart.items.values.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre commande',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Liste des articles
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 20),
            itemBuilder: (context, index) {
              final item = items[index];
              return Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item.item.category,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.totalPrice.toStringAsFixed(2)}TND',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          // Récapitulatif des prix
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildPriceRow('Sous-total', cart.totalPrice),
                const SizedBox(height: 8),
                _buildPriceRow('Frais de livraison', cart.deliveryFee),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildPriceRow(
                  'Total',
                  cart.totalWithFees,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de livraison',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Adresse de livraison
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Adresse de livraison*',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir une adresse';
                }
                return null;
              },
              onChanged: (value) {
                _deliveryAddress = value;
              },
            ),

            const SizedBox(height: 20),

            // Instructions spéciales
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Instructions spéciales (optionnel)',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
                helperText: 'Ex: Sonner 2 fois, laisser devant la porte, etc.',
              ),
              maxLines: 3,
              onChanged: (value) {
                _specialInstructions = value;
              },
            ),

            const SizedBox(height: 30),

            // Heure de livraison estimée
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF8B0000)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Livraison estimée',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '30-45 minutes',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep(CartModel cart) {
    final total = cart.totalWithFees;
    final cashValue = double.tryParse(_cashAmount) ?? 0;
    final change = cashValue - total;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moyen de paiement',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Options de paiement
          PaymentMethodCard(
            icon: Icons.credit_card,
            title: 'Carte bancaire',
            isSelected: _paymentMethod == 'card',
            onTap: () => setState(() => _paymentMethod = 'card'),
          ),

          const SizedBox(height: 12),

          PaymentMethodCard(
            icon: Icons.paypal,
            title: 'PayPal',
            isSelected: _paymentMethod == 'paypal',
            onTap: () => setState(() => _paymentMethod = 'paypal'),
          ),

          const SizedBox(height: 12),

          PaymentMethodCard(
            icon: Icons.money,
            title: 'À la livraison',
            subtitle: 'Payer en espèces à la livraison',
            isSelected: _paymentMethod == 'cash',
            onTap: () => setState(() => _paymentMethod = 'cash'),
          ),

          // Section pour le paiement en espèces
          if (_paymentMethod == 'cash') ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF8B0000).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paiement en espèces',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B0000),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Montant exact ou monnaie à rendre
                  Row(
                    children: [
                      Expanded(
                        child: _buildCashOption(
                          title: 'Montant exact',
                          subtitle: '${total.toStringAsFixed(2)}TND',
                          isSelected: _exactAmount,
                          onTap: () => setState(() {
                            _exactAmount = true;
                            _cashAmountController.clear();
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCashOption(
                          title: 'Avoir de la monnaie',
                          subtitle: 'Le livreur rendra la monnaie',
                          isSelected: !_exactAmount,
                          onTap: () => setState(() => _exactAmount = false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (!_exactAmount) ...[
                    const Text(
                      'Montant que vous donnerez',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _cashAmountController,
                      decoration: InputDecoration(
                        labelText: 'Ex: 50.00',
                        prefixIcon: const Icon(Icons.euro_symbol),
                        border: const OutlineInputBorder(),
                        suffixText: 'TND',
                        helperText: 'Pour que le livreur prépare la monnaie',
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    // Calcul de la monnaie à rendre
                    if (_cashAmount.isNotEmpty && cashValue > 0)
                      _buildChangeCalculation(change, cashValue, total),
                  ],
                ],
              ),
            ),
          ],

          if (_paymentMethod == 'card') ...[
            const SizedBox(height: 30),
            const Text(
              'Informations de la carte',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Formulaire de carte
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Numéro de carte',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _cardNumber = value,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date d\'expiration (MM/AA)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _cardExpiry = value,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'CVV',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _cardCvc = value,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Titulaire de la carte',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _cardHolder = value,
            ),
          ],

          const SizedBox(height: 30),

          // Sécurité des paiements
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paiement sécurisé',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Vos données sont cryptées et sécurisées',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8B0000).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8B0000) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF8B0000) : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeCalculation(
      double change, double cashAmount, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: change >= 0 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total de la commande:'),
              Text('${total.toStringAsFixed(2)}TND'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Montant donné:'),
              Text('${cashAmount.toStringAsFixed(2)}TND'),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                change >= 0 ? 'Monnaie à rendre:' : 'Montant insuffisant:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? Colors.green : Colors.red,
                ),
              ),
              Text(
                '${change.abs().toStringAsFixed(2)}TND',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: change >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          if (change < 0) ...[
            const SizedBox(height: 8),
            Text(
              'Veuillez augmenter le montant',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmationStep(CartModel cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Animation/Icon de succès
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Commande confirmée !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Votre commande a été passée avec succès',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),

          const SizedBox(height: 40),

          // Résumé de la commande
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.access_time, color: Color(0xFF8B0000)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Livraison estimée',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('30-45 minutes'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF8B0000)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Adresse de livraison',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_deliveryAddress.isNotEmpty
                              ? _deliveryAddress
                              : 'Non spécifiée'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.payment, color: Color(0xFF8B0000)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Moyen de paiement',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_paymentMethod == 'card'
                              ? 'Carte bancaire'
                              : _paymentMethod == 'paypal'
                                  ? 'PayPal'
                                  : _exactAmount
                                      ? 'Espèces (montant exact)'
                                      : 'Espèces (monnaie à rendre)'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildPriceRow('Total', cart.totalWithFees, isTotal: true),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Boutons d'action
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Naviguer vers l'écran de récapitulatif
                  _showOrderSummary(context, cart);
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('VOIR LE RÉCAPITULATIF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B0000),
                  side: const BorderSide(color: Color(0xFF8B0000)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // Naviguer vers l'écran de tracking
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingScreen(
                        orderId:
                            'CMD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8, 13)}',
                        orderStatus: 'En préparation',
                        restaurantName:
                            'Burger House', // À remplacer par le nom réel
                        restaurantAddress:
                            '123 Rue du Burger, Paris', // À remplacer
                        deliveryAddress: _deliveryAddress.isNotEmpty
                            ? _deliveryAddress
                            : 'Adresse non spécifiée',
                        orderTotal: cart.totalWithFees,
                        estimatedDelivery:
                            DateTime.now().add(const Duration(minutes: 30)),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.track_changes),
                label: const Text('SUIVRE MA COMMANDE'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B0000),
                  side: const BorderSide(color: Color(0xFF8B0000)),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          '${amount.toStringAsFixed(2)}TND',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF8B0000) : Colors.black,
          ),
        ),
      ],
    );
  }
}
