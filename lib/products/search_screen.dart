import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../products/products_cart.dart'; // ProductCard এখানে আছে ধরে নিচ্ছি
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

  List<Product> _results = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  int _offset = 0;
  Timer? _debounce;
  // ফিল্টার স্টেট
  String _selectedCategory = "";
  RangeValues _currentPriceRange = const RangeValues(0, 100000);
  String _currentSort = "relevance"; // default sort

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _scrollController.addListener(_scrollListener);
  }

  // সাজেশনের জন্য আলাদা লিস্ট
  List<dynamic> _suggestions = [];

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _results = []; // বক্স খালি করলে রেজাল্টও চলে যাবে
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      // এখন শুধু সাজেশন্স আসবে, মেইন প্রোডাক্ট লোড হবে না
      final suggestions = await ApiService().getSuggestions(query.trim());
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
      }
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
      });
      _saveRecentSearch(query);
    }

    // ডাইনামিক প্যারামিটার তৈরি
    final Map<String, dynamic> requestParams = {
      'q': _controller.text.trim(),
      'offset': _offset,
      'min_price': _currentPriceRange.start, // আপনার স্লাইডারের ভ্যালু
      'max_price': _currentPriceRange.end,
      'sort': _currentSort, // relevance, price_low, etc.
    };

    // ক্যাটাগরি থাকলে যোগ করুন
    if (_selectedCategory.isNotEmpty) {
      requestParams['category'] = _selectedCategory;
    }

    try {
      // এপিআই কল
      final newProducts = await ApiService().searchProducts(requestParams);

      if (mounted) {
        setState(() {
          _results.addAll(newProducts);
          _offset += 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateFilter({String? category, RangeValues? price, String? sort}) {
    setState(() {
      if (category != null) _selectedCategory = category;
      if (price != null) _currentPriceRange = price;
      if (sort != null) _currentSort = sort;
    });

    // ১ কোটি ডেটার জন্য ফিল্টার চেঞ্জ করলে সবসময় নতুন করে সার্চ শুরু করতে হয়
    _performSearch(isNewSearch: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _controller.text.isNotEmpty) {
        _performSearch();
      }
    }
  }

  _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query); // ডুপ্লিকেট রিমুভ
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches.removeLast();
    await prefs.setStringList('recent_search', _recentSearches);
    _loadRecentSearches();
  }

  _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_search') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          // সাজেশন্স লিস্টটি গ্রিডের উপরে দেখানোর জন্য Stack ব্যবহার
          children: [
            Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: _results.isEmpty && !_isLoading
                      ? _buildInitialView()
                      : _buildSearchResults(),
                ),
              ],
            ),

            // ৪. সাজেশন্স ড্রপডাউন (যখন টাইপ করবে তখন দেখাবে)
            if (_suggestions.isNotEmpty && _controller.text.isNotEmpty)
              Positioned(
                top: 75, // আপনার অ্যাপবারের হাইট অনুযায়ী অ্যাডজাস্ট করুন
                left: 60,
                right: 20,
                child: _buildSuggestionsOverlay(),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildCustomAppBar() {
  //   return Container(
  //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         // ব্যাক বাটন (আরও মার্জিত ডিজাইন)
  //         InkWell(
  //           onTap: () => Navigator.pop(context),
  //           borderRadius: BorderRadius.circular(50),
  //           child: const Padding(
  //             padding: EdgeInsets.all(8.0),
  //             child: Icon(
  //               Icons.arrow_back_ios_new_rounded,
  //               size: 22,
  //               color: Colors.black87,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(width: 8),

  //         // মেইন সার্চ কন্টেইনার
  //         Expanded(
  //           child: Container(
  //             height: 46,
  //             decoration: BoxDecoration(
  //               color: const Color(
  //                 0xFFF3F4F6,
  //               ), // হালকা গ্রে ব্যাকগ্রাউন্ড (Amazon/Google Style)
  //               borderRadius: BorderRadius.circular(12),
  //               border: Border.all(color: Colors.grey.shade200, width: 1),
  //             ),
  //             child: TextField(
  //               controller: _controller,
  //               autofocus: true,
  //               onChanged: _onSearchChanged,
  //               onSubmitted: (value) {
  //                 if (value.trim().isNotEmpty) {
  //                   setState(
  //                     () => _suggestions = [],
  //                   ); // মেইন সার্চ শুরু হলে সাজেশন বন্ধ
  //                   _performSearch(isNewSearch: true);
  //                 }
  //               },
  //               textInputAction:
  //                   TextInputAction.search, // কী-বোর্ডে সার্চ বাটন দেখাবে
  //               style: const TextStyle(
  //                 fontSize: 15,
  //                 fontWeight: FontWeight.w400,
  //               ),
  //               decoration: InputDecoration(
  //                 hintText: "Search items, brands, categories...",
  //                 hintStyle: TextStyle(
  //                   color: Colors.grey.shade500,
  //                   fontSize: 14,
  //                 ),
  //                 prefixIcon: Icon(
  //                   Icons.search_rounded,
  //                   color: _controller.text.isNotEmpty
  //                       ? Colors.green
  //                       : Colors.grey.shade400,
  //                   size: 22,
  //                 ),
  //                 suffixIcon: _controller.text.isNotEmpty
  //                     ? IconButton(
  //                         icon: Container(
  //                           padding: const EdgeInsets.all(2),
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey.shade400,
  //                             shape: BoxShape.circle,
  //                           ),
  //                           child: const Icon(
  //                             Icons.close,
  //                             size: 14,
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                         onPressed: () {
  //                           _controller.clear();
  //                           setState(() {
  //                             _suggestions = [];
  //                             _results = [];
  //                           });
  //                         },
  //                       )
  //                     : null,
  //                 border: InputBorder.none,
  //                 contentPadding: const EdgeInsets.symmetric(vertical: 10),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCustomAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        // স্ট্যাটাস বার সেভ রাখার জন্য
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 800,
            ), // প্রফেশনাল লুকের জন্য Max Width সেট করা
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                // ব্যাক বাটন
                _buildIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: widget.onClose,
                ),
                const SizedBox(width: 12),

                // মেইন সার্চ কন্টেইনার
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _onSearchChanged,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() => _suggestions = []);
                          _performSearch(isNewSearch: true);
                        }
                      },
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Search items, brands...",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: _controller.text.isNotEmpty
                              ? Colors.green
                              : Colors.grey.shade400,
                          size: 22,
                        ),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: CircleAvatar(
                                  radius: 8,
                                  backgroundColor: Colors.grey.shade400,
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() {
                                    _suggestions = [];
                                    _results = [];
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ফিল্টার বাটন (App Bar এর ভেতরেই সার্চের পাশে)
                _buildIconButton(
                  icon: Icons.tune_rounded, // আধুনিক ফিল্টার আইকন
                  onTap: () {
                    // এখানে ফিল্টার বটম শীট বা ডায়ালগ কল করুন
                  },
                  isFilter: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // আইকন বাটনের জন্য একটি কমন উইজেট (কোড ক্লিন রাখার জন্য)
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isFilter = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: isFilter
            ? BoxDecoration(
                color: Colors.green.withOpacity(
                  0.1,
                ), // ফিল্টার বাটনে হালকা ব্যাকগ্রাউন্ড
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Icon(
          icon,
          size: 22,
          color: isFilter ? Colors.green : Colors.black87,
        ),
      ),
    );
  }

  // ২. সুন্দর রিসেন্ট সার্চ এবং ট্রেন্ডিং সেকশন
  Widget _buildInitialView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Searches",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('recent_search');
                  setState(() => _recentSearches = []);
                },
                child: const Text(
                  "Clear All",
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recentSearches.map((s) => _buildSearchChip(s)).toList(),
          ),
          const SizedBox(height: 30),
        ],
        const Text(
          "Trending Now",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        _buildTrendingItem(
          Icons.local_fire_department,
          "iPhone 16 Pro Max",
          "Hot Sale",
        ),
        _buildTrendingItem(
          Icons.trending_up,
          "Mechanical Keyboards",
          "New Arrival",
        ),
        _buildTrendingItem(Icons.star, "Summer Collection 2026", "Featured"),
      ],
    );
  }

  Widget _buildSearchChip(String label) {
    return GestureDetector(
      onTap: () {
        _controller.text = label;
        _performSearch(isNewSearch: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTrendingItem(IconData icon, String title, String tag) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.green, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          tag,
          style: TextStyle(
            color: Colors.orange.shade700,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        _controller.text = title;
        _performSearch(isNewSearch: true);
      },
    );
  }

  Widget _buildSearchResults() {
    double screenWidth = MediaQuery.of(context).size.width;

    // ১. বড় স্ক্রিনের জন্য ডাইনামিক কার্ড সাইজ লজিক
    double dynamicMaxExtent = screenWidth < 600
        ? 180 // ফোন
        : (screenWidth < 1100 ? 220 : 250); // ট্যাব ও পিসি

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ২. ফিল্টার সাইডবার: শুধুমাত্র বড় স্ক্রিনে (৯০০px এর বেশি) দেখাবে
        if (screenWidth > 900)
          Container(
            width: 260, // সাইডবারের চওড়া
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: _buildFilterSidebar(),
          ),

        // ৩. মেইন কন্টেন্ট এরিয়া (গ্রিড)
        Expanded(
          child: Column(
            children: [
              // যদি মোবাইলে ফিল্টার বাটন দেখাতে চান তবে এখানে ছোট একটি বার যোগ করতে পারেন
              if (screenWidth <= 900) _buildMobileFilterBar(),

              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: dynamicMaxExtent,
                    childAspectRatio: 0.72, // ২০২৬ প্রফেশনাল ই-কমার্স রেশিও
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _results.length + (_isLoading ? 4 : 0),
                  itemBuilder: (context, index) {
                    if (index < _results.length) {
                      return ProductCard(product: _results[index]);
                    }
                    return _buildShimmerLoading();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsOverlay() {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 350,
        ), // সর্বোচ্চ ৩৫০ পিক্সেল লম্বা হবে
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            // যেহেতু সাজেশন এখন Map, তাই dynamic বা Map<String, dynamic> টাইপ ব্যবহার করুন
            final Map<String, dynamic> suggestion = _suggestions[index];

            return ListTile(
              leading: Icon(
                // টাইপ 'keyword' হলে ঘড়ির আইকন, আর 'product' হলে শপিং ব্যাগের আইকন
                suggestion['type'] == 'keyword'
                    ? Icons.history_rounded
                    : Icons.shopping_bag_outlined,
                size: 20,
                color: Colors.grey.shade600,
              ),
              title: Text(
                suggestion['text'], // PHP থেকে পাঠানো 'text' কি ব্যবহার হচ্ছে
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              trailing: const Icon(
                Icons.north_west,
                size: 14,
                color: Colors.grey,
              ), // ছোট একটি অ্যারো লুক
              onTap: () {
                String selectedText = suggestion['text'];
                _controller.text = selectedText;

                // কার্সার একদম শেষে নেওয়ার জন্য
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );

                setState(() => _suggestions = []); // লিস্ট বন্ধ হবে
                _performSearch(isNewSearch: true); // মেইন সার্চ শুরু হবে
                FocusScope.of(context).unfocus(); // কী-বোর্ড হাইড হবে
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSidebar() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Sort By",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _filterRadio("Relevance", "relevance"),
        _filterRadio("Price: Low to High", "price_low"),
        _filterRadio("Price: High to Low", "price_high"),

        const Divider(height: 40),

        const Text(
          "Price Range",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        RangeSlider(
          values: _currentPriceRange,
          min: 0,
          max: 100000,
          activeColor: Colors.green,
          onChanged: (values) => setState(() => _currentPriceRange = values),
          onChangeEnd: (values) =>
              _updateFilter(price: values), // স্লাইডার ছাড়া হলে সার্চ হবে
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("৳${_currentPriceRange.start.toInt()}"),
            Text("৳${_currentPriceRange.end.toInt()}"),
          ],
        ),

        const Divider(height: 40),

        const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            _buildCategoryChip("Electronics"),
            _buildCategoryChip("Fashion"),
            _buildCategoryChip("Gadgets"),
            _buildCategoryChip("Home"),
          ],
        ),
      ],
    );
  }

  // মোবাইলের জন্য ছোট ফিল্টার বাটন (যখন স্ক্রিন ছোট হবে)
  Widget _buildMobileFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${_results.length} Products found",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          TextButton.icon(
            onPressed: () {
              _showFilterBottomSheet();
            },
            icon: const Icon(Icons.filter_list, size: 18, color: Colors.black),
            label: const Text("Filters", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  // Widget _buildMobileFilterBar() {
  //   return Container(
  //     // ... existing decoration ...
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text("${_results.length} Products found"),
  //         TextButton.icon(
  //           onPressed: () => , // এখানে কল করুন
  //           icon: const Icon(Icons.filter_list),
  //           label: const Text("Filters"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _filterCheckbox(String title) {
    return CheckboxListTile(
      value: false,
      onChanged: (v) {},
      title: Text(title, style: const TextStyle(fontSize: 14)),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  // সর্টিং রেডিও বাটন
  Widget _filterRadio(String title, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _currentSort, // বর্তমান স্টেট
          activeColor: Colors.green,
          onChanged: (v) {
            if (v != null) _updateFilter(sort: v);
          },
        ),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // ক্যাটাগরি চিপস (চেকবক্সের চেয়ে চিপস বেশি আধুনিক)
  Widget _buildCategoryChip(String categoryName) {
    bool isSelected = _selectedCategory == categoryName;
    return ChoiceChip(
      label: Text(categoryName),
      selected: isSelected,
      onSelected: (selected) {
        _updateFilter(category: selected ? categoryName : "");
      },
      selectedColor: Colors.green.shade100,
      checkmarkColor: Colors.green,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          // বটম শিটের ভেতর স্টেট পরিবর্তনের জন্য
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filter Products",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),

                  // প্রাইস স্লাইডার
                  Text(
                    "Price: ৳${_currentPriceRange.start.toInt()} - ৳${_currentPriceRange.end.toInt()}",
                  ),
                  RangeSlider(
                    values: _currentPriceRange,
                    min: 0,
                    max: 100000, // আপনার হাইয়েস্ট প্রাইস অনুযায়ী
                    divisions: 20,
                    onChanged: (values) {
                      setModalState(
                        () => _currentPriceRange = values,
                      ); // UI আপডেট
                      setState(
                        () => _currentPriceRange = values,
                      ); // মেইন স্টেট আপডেট
                    },
                  ),

                  // সর্টিং অপশন
                  ListTile(
                    title: const Text("Price: Low to High"),
                    leading: Radio(
                      value: "price_low",
                      groupValue: _currentSort,
                      onChanged: (v) {
                        setModalState(() => _currentSort = v.toString());
                        _updateFilter(sort: v.toString());
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: () {
                      _performSearch(isNewSearch: true);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 10,
              width: 100,
              color: Colors.grey.shade200,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 10,
              width: 60,
              color: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
