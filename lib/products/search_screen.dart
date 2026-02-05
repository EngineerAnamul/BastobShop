import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../products/products_cart.dart'; // ProductCard এখানে আছে ধরে নিচ্ছি
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _scrollController.addListener(_scrollListener);
  }


  // সাজেশনের জন্য আলাদা লিস্ট
  List<String> _suggestions = [];

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

  Future<void> _performSearch(String query, {bool isNewSearch = false}) async {
    if (isNewSearch) {
      setState(() {
        _results = [];
        _offset = 0;
        _isLoading = true;
      });
      _saveRecentSearch(query);
    }

    try {
      final newProducts = await ApiService().searchProducts(query, _offset);
      if (mounted) {
        setState(() {
          _results.addAll(newProducts);
          _offset += 20;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _controller.text.isNotEmpty) {
        _performSearch(_controller.text);
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

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
      child: Row(
        children: [
          // ব্যাক বাটন (আরও মার্জিত ডিজাইন)
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 8),

          // মেইন সার্চ কন্টেইনার
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6), // হালকা গ্রে ব্যাকগ্রাউন্ড (Amazon/Google Style)
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearchChanged,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() => _suggestions = []); // মেইন সার্চ শুরু হলে সাজেশন বন্ধ
                    _performSearch(value.trim(), isNewSearch: true);
                  }
                },
                textInputAction: TextInputAction.search, // কী-বোর্ডে সার্চ বাটন দেখাবে
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  hintText: "Search items, brands, categories...",
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _controller.text.isNotEmpty ? Colors.green : Colors.grey.shade400,
                    size: 22,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ],
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
        _performSearch(label, isNewSearch: true);
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
        _performSearch(title, isNewSearch: true);
      },
    );
  }

  // ৩. রেসপন্সিভ সার্চ রেজাল্ট গ্রিড
  /*  Widget _buildSearchResults() {

    double screenWidth = MediaQuery.of(context).size.width;

    // লজিক: স্ক্রিন যত বড় হবে, কার্ডের ম্যাক্সিমাম সাইজও তত বাড়বে
    double dynamicMaxExtent = screenWidth < 600
        ? 180 // ফোনের জন্য ১৮০ পিক্সেল (পারফেক্ট ২ কলাম)
        : (screenWidth < 1100
        ? 220 // ট্যাবলেটের জন্য ২২০ পিক্সেল
        : 260); // ল্যাপটপ বা বড় কম্পিউটারের জন্য ২৬০ পিক্সেল


    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
      gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
        // একটি কার্ড সর্বোচ্চ কতটুকু চওড়া হবে।
        // ১৮০ দিলে সাধারণ ফোনে ২টা, ট্যাবলেটে ৪টা এবং ল্যাপটপে ৮-১০টা কার্ড অটোমেটিক চলে আসবে।
        maxCrossAxisExtent: dynamicMaxExtent,

        // কার্ডের উচ্চতা ও প্রস্থের অনুপাত (Design consistency বজায় রাখে)
        childAspectRatio: 0.70,

        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _results.length + (_isLoading ? 4 : 0), // লোডিং এর সময় বেশি শিমার দেখালে সুন্দর লাগে
      itemBuilder: (context, index) {
        if (index < _results.length) {
          return ProductCard(product: _results[index]);
        }
        return _buildShimmerLoading(); // আপনার তৈরি শিমার
      },
    );
  }*/

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
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      // সর্বোচ্চ ৩০০ পিক্সেল লম্বা হবে
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return ListTile(
            leading: const Icon(
              Icons.history_rounded,
              size: 20,
              color: Colors.grey,
            ),
            title: Text(suggestion, style: const TextStyle(fontSize: 14)),
            onTap: () {
              _controller.text = suggestion; // বক্সে সাজেশন সেট হবে
              setState(() => _suggestions = []); // লিস্ট বন্ধ হবে
              _performSearch(suggestion, isNewSearch: true); // সার্চ শুরু হবে
            },
          );
        },
      ),
    );
  }

  // বড় স্ক্রিনের সাইডবার
  Widget _buildFilterSidebar() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          "Sort By",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        _filterRadio("Newest Arrivals"),
        _filterRadio("Price: Low to High"),
        _filterRadio("Price: High to Low"),
        const Divider(height: 30),

        const Text(
          "Price Range",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        RangeSlider(
          values: const RangeValues(500, 5000),
          min: 0,
          max: 10000,
          activeColor: Colors.green,
          onChanged: (values) {},
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text("৳০"), Text("৳১০,০০০+")],
        ),
        const Divider(height: 30),

        const Text(
          "Categories",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _filterCheckbox("Electronics (1.2k)"),
        _filterCheckbox("Men's Fashion (450)"),
        _filterCheckbox("Gadgets & Devices (800)"),
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
              /* নিচ থেকে বটম শিট ফিল্টার ওপেন হবে */
            },
            icon: const Icon(Icons.filter_list, size: 18, color: Colors.black),
            label: const Text("Filters", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

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

  Widget _filterRadio(String title) {
    return Row(
      children: [
        Radio(value: title, groupValue: "", onChanged: (v) {}),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
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

/*
import 'dart:async';
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/model.dart';
import '../products/products_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Product> _results = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  int _offset = 0; // Pagination এর জন্য
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _scrollController.addListener(_scrollListener);
  }

  // ১ কোটি ডেটার জন্য ১০০০ms Debounce দেওয়া নিরাপদ
  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (query.isNotEmpty) {
        _performSearch(query, isNewSearch: true);
      }
    });
  }

  Future<void> _performSearch(String query, {bool isNewSearch = false}) async {
    if (isNewSearch) {
      setState(() {
        _results.clear();
        _offset = 0;
        _isLoading = true;
      });
      _saveRecentSearch(query);
    }

    // API কল - এখানে LIMIT ২০ করে ডেটা আসবে
    final newProducts = await ApiService().searchProducts(query, _offset);

    setState(() {
      _results.addAll(newProducts);
      _offset += 20;
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _controller.text.isNotEmpty) {
        _performSearch(_controller.text);
      }
    }
  }

  // Shared Preferences এ সেভ করা
  _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
      await prefs.setStringList('recent_search', _recentSearches);
    }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: Colors.black)),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(hintText: "Search items...", border: InputBorder.none),
        ),
      ),
      body: _results.isEmpty && !_isLoading
          ? _buildRecentSearches()
          : _buildSearchResults(),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.all(16), child: Text("Recent Searches", style: TextStyle(fontWeight: FontWeight.bold))),
        Wrap(
          children: _recentSearches.map((s) => ActionChip(label: Text(s), onPressed: () {
            _controller.text = s;
            _performSearch(s, isNewSearch: true);
          })).toList(),
        )
      ],
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, mainAxisSpacing: 10, crossAxisSpacing: 10),
      itemCount: _results.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _results.length) return ProductCard(product: _results[index]);
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}*/
