import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../models/cart.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItem menuItem;
  final int initialQuantity;
  final bool isRestaurantOpen;
  final Function(int)? onQuantityChanged; // <-- réintroduit

  const MenuItemCard({
    super.key,
    required this.menuItem,
    this.initialQuantity = 0,
    this.isRestaurantOpen = true,
    this.onQuantityChanged,
  });



  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> {
  late int _quantity;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    if (_quantity == 0) return;

    final cart = Provider.of<CartModel>(context, listen: false);
    cart.addItem(
      widget.menuItem,
      _quantity,
      specialInstructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
    );

    // Réinitialiser quantité et instructions
    setState(() {
      _quantity = 0;
      _instructionsController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.menuItem.name} ajouté au panier !'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.menuItem.available && widget.isRestaurantOpen;
    final bordeauxColor = const Color(0xFF8B0000);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom et disponibilité
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.menuItem.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (!isAvailable)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      !widget.menuItem.available ? 'Indisponible' : 'Fermé',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            if (widget.menuItem.description != null &&
                widget.menuItem.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.menuItem.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Catégorie et prix
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bordeauxColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: bordeauxColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.menuItem.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: bordeauxColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.menuItem.price.toStringAsFixed(2)}TND',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: bordeauxColor,
                  ),
                ),
              ],
            ),

            // Instructions spéciales
            if (isAvailable) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  hintText: 'Instructions spéciales (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
              ),
            ],

            // Boutons quantité + Ajouter
            if (isAvailable) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: _decrementQuantity,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      shape: const CircleBorder(),
                    ),
                    icon: Icon(
                      Icons.remove,
                      color: _quantity > 0 ? bordeauxColor : Colors.grey,
                    ),
                  ),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _incrementQuantity,
                    style: IconButton.styleFrom(
                      backgroundColor: bordeauxColor,
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _quantity > 0 ? _addToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bordeauxColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Ajouter'),
                  ),
                ],
              ),
            ],

            if (!isAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.menuItem.available
                      ? 'Ce restaurant est actuellement fermé'
                      : 'Cet article n\'est pas disponible pour le moment',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
