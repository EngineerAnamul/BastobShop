import 'dart:async';
import 'package:bastoopshop/app_color.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../products/products_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onClose;
  final bool isDrawerOpen;

  const SearchScreen({
    super.key,
    required this.onMenuTap,
    required this.onClose,
    required this.isDrawerOpen,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ১. স্ট্যাটিক লিস্টের বদলে একটি খালি লিস্ট নিন
  List<Map<String, dynamic>> _dynamicCategories = [];

  // ১. ভেরিয়েবলগুলো এখানে ডিক্লেয়ার করা হলো (যাতে Getter error না আসে)
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  List<Product> _results = [];
  List<String> _recentSearches = [];
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  int _offset = 0;
  Timer? _debounce;

  // Filters State
  String _selectedCategory = "";
  RangeValues _currentPriceRange = const RangeValues(0, 10000);
  String _currentSort = "relevance";
  final bool _isInStockOnly = false;
  final bool _isFreeShipping = false;
  double _dynamicMaxLimit = 10000;
  final List<String> _categoryList = [
    "All Categories",
    "Electronics",
    "Fashion",
    "Groceries",
    "Home & Garden",
    "Health & Beauty",
    "Automotive",
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRecentSearches();
    _scrollController.addListener(_scrollListener);

    // ডিফল্ট ভ্যালু সেট করা
    _minPriceController.text = _currentPriceRange.start.round().toString();
    _maxPriceController.text = _currentPriceRange.end.round().toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
  //   // ২. ডাটাবেস থেকে ক্যাটাগরি আনার মেথড
  // Future<void> _loadCategories() async {
  //   final categories = await ApiService().getCategoriesWithCache();
  //   setState(() {
  //     _dynamicCategories = categories;
  //   });
  // }

  Future<void> _loadCategories() async {
    // আগের স্ট্যাটিক লিস্টের বদলে ক্যাশড এপিআই কল
    final categories = await ApiService().getCategoriesWithCache();

    if (mounted && categories.isNotEmpty) {
      setState(() {
        _dynamicCategories = categories;
      });
    }
  }

  // --- Logic Methods ---

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _results = [];
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final suggestions = await ApiService().getSuggestions(query.trim());
      if (mounted) setState(() => _suggestions = suggestions);
    });
  }

  Future<void> _performSearch({bool isNewSearch = false}) async {
    String query = _controller.text.trim();
    if (query.isEmpty) return;

    if (isNewSearch) {
      setState(() {
        _results = [];
        _offset = 0;
        _isLoading = true;
        _suggestions = [];
      });
      _saveRecentSearch(query);
    }

    final Map<String, dynamic> requestParams = {
      'q': query,
      'offset': _offset,
      'min_price': _currentPriceRange.start,
      'max_price': _currentPriceRange.end,
      'sort': _currentSort,
      'in_stock': _isInStockOnly,
      'free_shipping': _isFreeShipping,
    };
    if (_selectedCategory.isNotEmpty) {
      requestParams['category'] = _selectedCategory;
    }

    try {
      final newProducts = await ApiService().searchProducts(requestParams);
      if (mounted) {
        setState(() {
          _results.addAll(newProducts);
          _offset += 20;
          _isLoading = false;

          if (newProducts.isNotEmpty) {
            double maxInBatch = 0;
            for (var p in newProducts) {
              double pPrice = double.tryParse(p.price.toString()) ?? 0;
              if (pPrice > maxInBatch) maxInBatch = pPrice;
            }
            if (maxInBatch > _dynamicMaxLimit) _dynamicMaxLimit = maxInBatch;
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _controller.text.isNotEmpty) _performSearch();
    }
  }

  _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches.removeLast();
    await prefs.setStringList('recent_search', _recentSearches);
    _loadRecentSearches();
  }

  _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(
      () => _recentSearches = prefs.getStringList('recent_search') ?? [],
    );
  }

  // --- UI Building ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildModernAppBar(),
                Expanded(
                  child: _results.isEmpty && !_isLoading
                      ? _buildInitialView()
                      : _buildSearchResults(),
                ),
              ],
            ),
            if (_suggestions.isNotEmpty && _controller.text.isNotEmpty)
              Positioned(
                top: 70,
                left: 16,
                right: 16,
                child: _buildSuggestionsOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        _buildFilterTriggerBar(),
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < _results.length) {
                      return ProductCard(product: _results[index]);
                    }
                    return _buildShimmerLoading();
                  }, childCount: _results.length + (_isLoading ? 6 : 0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTriggerBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${_results.length} items found",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: _showFilterPopup,
            child: Row(
              children: const [
                Icon(Icons.tune_rounded, size: 20, color: Colors.black),
                SizedBox(width: 6),
                Text(
                  "Filters",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterPopup() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setPopupState) {
          return Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.90,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Search filters",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _buildFilterContentForPopup(setPopupState),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterContentForPopup(StateSetter setPopupState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterHeader("SORT BY"),
        _buildChoiceChipPopup("Relevance", "relevance", setPopupState),
        _buildChoiceChipPopup("Price: Low to High", "price_low", setPopupState),
        _buildChoiceChipPopup(
          "Price: High to Low",
          "price_high",
          setPopupState,
        ),

        const Divider(color: Colors.white10, height: 30),
        _buildFilterHeader("PRICE RANGE"),

        _buildFilterHeader("PRICE RANGE"),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: Colors.white10,
            trackHeight: 4.0,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(32),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: RangeSlider(
            values: _currentPriceRange,
            min: 0,
            // Max value অবশ্যই 0 এর বেশি হতে হবে
            max: _dynamicMaxLimit > 0 ? _dynamicMaxLimit : 10000,

            // ফিক্স: divisions খুব বেশি বড় দেবেন না। ১০০-২০০ এর মধ্যে রাখা সেফ।
            divisions: 100,

            activeColor: AppColors.primary,
            onChanged: (RangeValues v) {
              setPopupState(() {
                // লজিক্যাল ফিক্স: স্টার্ট এবং এন্ড যেন সমান না হয়ে যায়
                double start = v.start;
                double end = v.end;
                if (start >= end) {
                  start = end > 0 ? end - 1 : 0;
                }

                _currentPriceRange = RangeValues(start, end);
                _minPriceController.text = start.round().toString();
                _maxPriceController.text = end.round().toString();
              });
            },
          ),
        ),

        // Row(
        //   children: [
        //     Expanded(
        //       child: TextField(
        //         controller: _minPriceController,
        //         keyboardType: TextInputType.number,
        //         style: const TextStyle(color: Colors.white, fontSize: 14),
        //         decoration: _inputDecoration("Min Price"),
        //         onChanged: (value) {
        //           double val = double.tryParse(value) ?? 0;
        //           setPopupState(
        //             () => _currentPriceRange = RangeValues(
        //               val,
        //               _currentPriceRange.end,
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        //     const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 10),
        //       child: Text("-", style: TextStyle(color: Colors.white)),
        //     ),
        //     Expanded(
        //       child: TextField(
        //         controller: _maxPriceController,
        //         keyboardType: TextInputType.number,
        //         style: const TextStyle(color: Colors.white, fontSize: 14),
        //         decoration: _inputDecoration("Max Price"),
        //         onChanged: (value) {
        //           double val = double.tryParse(value) ?? _dynamicMaxLimit;
        //           setPopupState(
        //             () => _currentPriceRange = RangeValues(
        //               _currentPriceRange.start,
        //               val,
        //             ),
        //           );
        //         },
        //       ),
        //     ),
        //   ],
        // ),
        Row(
          children: [
            // --- Min Price TextField ---
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration("Min Price"),
                onChanged: (value) {
                  // ১. নেগেটিভ এবং টেক্সট হ্যান্ডেল করা
                  double val = double.tryParse(value) ?? 0;
                  if (val < 0) val = 0;

                  setPopupState(() {
                    // ২. লজিক: মিনিমাম যেন ম্যাক্সিমামকে ক্রস না করে
                    double currentMax = _currentPriceRange.end;
                    double safeMin = val > currentMax ? currentMax : val;

                    _currentPriceRange = RangeValues(safeMin, currentMax);
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("-", style: TextStyle(color: Colors.white)),
            ),
            // --- Max Price TextField ---
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration("Max Price"),
                onChanged: (value) {
                  // ১. হ্যান্ডেল করা: খালি থাকলে ডায়নামিক লিমিট বসবে
                  double val = double.tryParse(value) ?? _dynamicMaxLimit;
                  if (val < 0) val = 0;

                  setPopupState(() {
                    // ২. লজিক: ম্যাক্সিমাম যেন মিনিমামের চেয়ে কম না হয়
                    double currentMin = _currentPriceRange.start;
                    double safeMax = val < currentMin ? currentMin : val;

                    _currentPriceRange = RangeValues(currentMin, safeMax);
                  });
                },
              ),
            ),
          ],
        ),

        const Divider(color: Colors.white10, height: 30),
        _buildFilterHeader("CATEGORY"),

        // Wrap(
        //   spacing: 8,
        //   children: [
        //     _buildCustomChip("Electronics", "Electronics", setPopupState),
        //     _buildCustomChip("Fashion", "Fashion", setPopupState),
        //   ],
        // ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: // SearchScreen এর ড্রপডাউন উইজেট অংশটি এভাবে আপডেট করুন:
            DropdownButton<String>(
              // ফিক্স: ভ্যালু যদি লিস্টে না থাকে তবে null দেখাবে, এতে ক্র্যাশ হবে না
              value:
                  _dynamicCategories.any(
                    (cat) => cat['slug'] == _selectedCategory,
                  )
                  ? _selectedCategory
                  : null,

              hint: const Text(
                "All Categories",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              dropdownColor: const Color(0xFF2A2A2A),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.primary,
              ),
              style: const TextStyle(color: Colors.white),

              // আইটেমগুলো ম্যাপ করার সময় slug কে value হিসেবে ব্যবহার করুন
              items: _dynamicCategories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat['slug'].toString(),
                  child: Text(cat['name'].toString()),
                );
              }).toList(),

              onChanged: (newValue) {
                setPopupState(() {
                  _selectedCategory = newValue ?? "";
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              // ১. টেক্সট কন্ট্রোলার থেকে লেটেস্ট ভ্যালু নিন
              double finalMin = double.tryParse(_minPriceController.text) ?? 0;
              double finalMax =
                  double.tryParse(_maxPriceController.text) ?? _dynamicMaxLimit;

              // ২. নেগেটিভ ভ্যালু হ্যান্ডেল করা
              if (finalMin < 0) finalMin = 0;
              if (finalMax < 0) finalMax = 0;

              // ৩. অদলবদল (Swap) লজিক: যদি Min, Max এর চেয়ে বড় হয়
              if (finalMin > finalMax) {
                double temp = finalMin;
                finalMin = finalMax;
                finalMax = temp;
              }

              // ৪. মেইন স্টেটে ডাটা সেভ করা (যাতে সার্চে সঠিক ডাটা যায়)
              setState(() {
                _currentPriceRange = RangeValues(finalMin, finalMax);
                // টেক্সট ফিল্ডগুলোকেও আপডেট করে দিন যাতে ইউজার সঠিকটা দেখে
                _minPriceController.text = finalMin.round().toString();
                _maxPriceController.text = finalMax.round().toString();
              });

              // ৫. পপআপ বন্ধ করা এবং সার্চ কল করা
              Navigator.pop(context);
              _performSearch(isNewSearch: true);
            },
            child: const Text(
              "APPLY FILTERS",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _buildFilterHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildChoiceChipPopup(
    String label,
    String value,
    StateSetter setPopupState,
  ) {
    bool isSelected = _currentSort == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.white70,
          fontSize: 15,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blue, size: 20)
          : null,
      onTap: () => setPopupState(() => _currentSort = value),
    );
  }

  Widget _buildCustomChip(
    String label,
    String value,
    StateSetter setPopupState,
  ) {
    bool isSelected = _selectedCategory == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) =>
          setPopupState(() => _selectedCategory = selected ? value : ""),
      selectedColor: Colors.white,
      backgroundColor: Colors.white10,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontSize: 12,
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          _buildCircleIconButton(
            Icons.arrow_back_ios_new_rounded,
            widget.onClose,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _performSearch(isNewSearch: true),
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.black54,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: _suggestions
            .take(6)
            .map(
              (s) => ListTile(
                leading: const Icon(Icons.search, size: 18),
                title: Text(s['text'], style: const TextStyle(fontSize: 14)),
                onTap: () {
                  _controller.text = s['text'];
                  _performSearch(isNewSearch: true);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildInitialView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const Text(
            "Recently Searched",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: _recentSearches
                .map(
                  (s) => ActionChip(
                    label: Text(s),
                    onPressed: () {
                      _controller.text = s;
                      _performSearch(isNewSearch: true);
                    },
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Container(color: Colors.grey.shade100)),
          const SizedBox(height: 12),
          Container(height: 15, width: 100, color: Colors.grey.shade100),
        ],
      ),
    );
  }
}
