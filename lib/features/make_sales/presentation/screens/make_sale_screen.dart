import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../bloc/make_sale_bloc.dart';
import '../../bloc/make_sale_event.dart';
import '../../bloc/make_sale_state.dart';
import '../widgets/sale_product_card.dart';
import '../widgets/make_sale_widgets.dart';

class MakeSaleScreen extends StatefulWidget {
  final int shopId;
  const MakeSaleScreen({super.key, required this.shopId});

  @override
  State<MakeSaleScreen> createState() => _MakeSaleScreenState();
}

class _MakeSaleScreenState extends State<MakeSaleScreen> {
  bool _isProcessing = false;
  double _currentZoom = 0.0;

  void _openScanner(BuildContext context) {
    final bloc = context.read<MakeSaleBloc>();
    final controller = MobileScannerController(
      formats: [BarcodeFormat.code128, BarcodeFormat.ean13, BarcodeFormat.ean8],
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (scannerContext, setModalState) => Scaffold(
            appBar: AppBar(
              title: const Text('Scan SKU'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  await controller.stop();
                  if (scannerContext.mounted) Navigator.pop(scannerContext);
                },
              ),
            ),
            body: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) async {
                    if (_isProcessing) return;
                    final code = capture.barcodes.first.rawValue;
                    if (code != null) {
                      _isProcessing = true;
                      await controller.stop();
                      if (!scannerContext.mounted) return;
                      bloc.add(SearchSaleProducts(code));
                      Navigator.pop(scannerContext);
                      _isProcessing = false;
                    }
                  },
                ),
                // Scanner Overlay
                Center(
                  child: Container(
                    width: 280, height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Zoom Control
                Positioned(
                  bottom: 50, left: 0, right: 0,
                  child: Center(
                    child: SegmentedButton<double>(
                      segments: const [
                        ButtonSegment(value: 0.0, label: Text('1x')),
                        ButtonSegment(value: 0.2, label: Text('2.5x')),
                      ],
                      selected: {_currentZoom},
                      onSelectionChanged: (newSelection) {
                        setModalState(() => _currentZoom = newSelection.first);
                        controller.setZoomScale(_currentZoom);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) => Future.delayed(const Duration(milliseconds: 200), () => controller.dispose()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Make Sale")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                const SizedBox(height: 8),
                SaleSearchHeader(
                  onSearch: (val) => context.read<MakeSaleBloc>().add(SearchSaleProducts(val)),
                  onScanTap: () => _openScanner(context),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<MakeSaleBloc, MakeSaleState>(
                    builder: (context, state) {
                      if (state is MakeSaleLoading) return const Center(child: CircularProgressIndicator());
                      if (state is MakeSaleLoaded) {
                        if (state.filteredProducts.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }
                        return ListView.builder(
                          // Fixed: EdgeInsets constructor fix
                          padding: const EdgeInsets.only(bottom: 120),
                          itemCount: state.filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = state.filteredProducts[index];
                            return SaleProductCard(
                              product: product,
                              onAdd: () => context.read<MakeSaleBloc>().add(AddProductToCart(product)),
                            );
                          },
                        );
                      }
                      return const Center(child: Text("Search or scan a product"));
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bottom Cart Bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BlocBuilder<MakeSaleBloc, MakeSaleState>(
              builder: (context, state) {
                if (state is MakeSaleLoaded && state.cartItems.isNotEmpty) {
                  return SaleCartSummary(
                    itemCount: state.cartItems.length,
                    totalAmount: state.totalAmount,
                    onCheckout: () {
                      // We can implement the PIN verification here later
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}