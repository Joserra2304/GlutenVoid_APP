import 'package:flutter/material.dart';
import '../../service/barcode_scanner_service.dart';
import '../widget/bottom_app_bar.dart';
import '../widget/loading_animation.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '../../controller/product_controller.dart';
import '../../model/product_model.dart';

import 'product_view_model.dart';
export 'product_view_model.dart';

class ProductViewWidget extends StatefulWidget {
  const ProductViewWidget({super.key});

  @override
  State<ProductViewWidget> createState() => _ProductViewWidgetState();
}

class _ProductViewWidgetState extends State<ProductViewWidget> {
  late ProductViewModel _model;
  late final ProductController productController;
  late final BarcodeScannerService barcodeScannerService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  bool isLoading = true;
  bool isMore = true;
  bool loadingMore = false;
  bool isSearchToolVisible = false;
  String currentFilter = "";
  int currentPage = 1;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProductViewModel());
    productController = ProductController();
    _loadProducts();
    barcodeScannerService = BarcodeScannerService((String barcode) async {
      final productDetails = await productController.fetchProductByBarcode(barcode);
      if (productDetails != null) {
        goToProductDetails(productDetails);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto no encontrado.')));
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<ProductModel> fetchedProducts =
      await productController.fetchGlutenFreeProducts();
      setState(() {
        // Eliminar productos sin nombre y duplicados
        final uniqueTitles = <String>{};
        _products = fetchedProducts.where((product) => product.name.isNotEmpty && uniqueTitles.add(product.name)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los productos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los productos: $e')),
      );
    }
  }

  void _loadMoreProducts() async {
    if (!isMore || loadingMore) return;
    setState(() {
      loadingMore = true;
    });

    try {
      List<ProductModel> moreProducts = [];
      int nextPage = currentPage + 1;

      if (currentFilter.isEmpty) {
        moreProducts =
        await productController.fetchGlutenFreeProducts(page: nextPage);
      } else if (currentFilter == 'filter_store') {
        moreProducts = await productController.fetchProductsByStore(
            _searchController.text.trim(),
            page: nextPage);
      } else if (currentFilter == 'filter_category') {
        moreProducts = await productController.fetchProductsByCategory(
            _searchController.text.trim(),
            page: nextPage);
      }

      if (moreProducts.isEmpty) {
        setState(() {
          isMore = false;
        });
      } else {
        setState(() {
          currentPage = nextPage;
          final uniqueTitles = <String>{};
          _products.addAll(moreProducts.where((product) => product.name.isNotEmpty && uniqueTitles.add(product.name)));
        });
      }
    } catch (e) {
      print('Error al cargar más productos: $e');
    } finally {
      setState(() {
        loadingMore = false;
      });
    }
  }

  void _toggleSearchBar(String filterType) {
    setState(() {
      if (currentFilter != filterType) {
        currentFilter = filterType;
        isSearchToolVisible = true;
      } else {
        isSearchToolVisible = !isSearchToolVisible;
      }
      _searchController.clear();
    });
  }

  void _applyFilter() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<ProductModel> results;
      if (currentFilter == 'filter_store') {
        results = await productController.fetchProductsByStore(
            _searchController.text.trim());
      } else if (currentFilter == 'filter_category') {
        results = await productController.fetchProductsByCategory(
            _searchController.text.trim());
      } else {
        results = [];
      }

      setState(() {
        final uniqueTitles = <String>{};
        _products = results.where((product) => product.name.isNotEmpty && uniqueTitles.add(product.name)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error al buscar los productos: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar productos: $e')));
    }
  }

  void goToProductDetails(ProductModel productDetails) {
    context.pushNamed(
      'ProductDetailsView',
      queryParameters: {
        'barcode': productDetails.barcode,
      },
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: FlutterFlowTheme.of(context).secondary,
          appBar: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primary,
            automaticallyImplyLeading: false,
            leading: FlutterFlowIconButton(
              borderColor: Colors.transparent,
              borderRadius: 30.0,
              borderWidth: 1.0,
              buttonSize: 60.0,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () async {
                context.go("UserView");
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FlutterFlowIconButton(
                      borderColor: FlutterFlowTheme.of(context).primary,
                      borderRadius: 20.0,
                      borderWidth: 1.0,
                      buttonSize: 40.0,
                      fillColor: FlutterFlowTheme.of(context).accent1,
                      icon: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: FlutterFlowTheme.of(context).secondary,
                        size: 24.0,
                      ),
                      onPressed: () => barcodeScannerService.scanBarcode(context),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        _toggleSearchBar(value);
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: "filter_store",
                          child: Text("Buscar por supermercado"),
                        ),
                        const PopupMenuItem<String>(
                          value: "filter_category",
                          child: Text("Buscar por categoría"),
                        ),
                      ],
                      icon: Icon(
                        Icons.filter_list,
                        color: FlutterFlowTheme.of(context).secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [],
            centerTitle: false,
            elevation: 2.0,
          ),
          body: Column(
            children: <Widget>[
              if (!isLoading)
                if (isSearchToolVisible)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: currentFilter == 'filter_store'
                            ? 'Buscar supermercado...'
                            : 'Buscar por categoría...',
                        labelStyle: TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search, color: Colors.black),
                          onPressed: _applyFilter,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      onSubmitted: (value) => _applyFilter(),
                    ),
                  ),
              Expanded(
                child: isLoading
                    ? Center(child: LoadingAnimationWidget())
                    : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _products.length + (isMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _products.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    ProductModel product = _products[index];
                    return InkWell(
                      onTap: () => goToProductDetails(product),
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: FlutterFlowTheme.of(context).primary, // Asegurar el color de fondo
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  product.imageUrl,
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                product.name,
                                style: FlutterFlowTheme.of(context)
                                    .titleLarge
                                    .override(
                                  fontFamily: 'Outfit',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: product.name.length > 20 ? 14.0 : 16.0,
                                  letterSpacing: 0.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: CommonBottomAppBar(
            selectedIndex: 0,
            parentContext: context,
          ),
        ),
      ),
    );
  }
}
