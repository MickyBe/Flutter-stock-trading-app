import 'package:auto_route/auto_route.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tech_camp/common/fackdata.dart';
import 'package:flutter_tech_camp/injection_container.dart';
import 'package:flutter_tech_camp/src/cart/cubit/cart_cubit.dart';
import 'package:flutter_tech_camp/src/news/news_list.dart';
import 'package:flutter_tech_camp/src/product_detail/screen/home_page_sceen.dart';
import 'package:flutter_tech_camp/src/product_detail/screen/product_detail_page.dart';
import 'package:flutter_tech_camp/src/products/cubit/products_cubit.dart';
import 'package:flutter_tech_camp/src/products/models/product.dart';
import 'package:flutter_tech_camp/src/profile/screens/walet_page.dart';
import 'package:flutter_tech_camp/src/routes/router.gr.dart';
import 'dart:math';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _expanded = false;
  void _filterStocks(String searchTerm) {
    print("filter stocks ${searchTerm}");
  }
  @override
  Widget build(BuildContext context) {
    print('data');
    print(stocksdata[0]['name']);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<ProductsCubit>()..getAllProducts(),
        ),
        BlocProvider(
          create: (context) => sl<CartCubit>(),
        ),
      ],
      child: Scaffold(
        body: Stack(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: SafeArea(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:MainAxisAlignment.start,
                            children: [
                              Text("Stocks ትሬድ ኢትዩጽያ",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold)),
                              Text("January 5",
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CardScreen(
                                    ),
                                  ));
                            },
                            icon: Icon(
                              Icons.wallet_giftcard,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ExtendedNavigator.of(context).push(Routes.cartPage);
                            },
                            icon: Icon(
                              Icons.favorite_border_outlined,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ExtendedNavigator.of(context).push(Routes.profilePage);
                            },
                            icon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                            height: 50,
                            child: TextField(
                              onChanged: _filterStocks,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  hintText: "Search",
                                  prefix: Icon(Icons.search),
                                  fillColor: Colors.grey[800],
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 0, style: BorderStyle.none),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(16)))),
                            )),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height - 210,
                          child: BlocBuilder<ProductsCubit, ProductsState>(
                            builder: (context, state) {
                              if (state is ProductsInitialState) {
                                return Text('Initial State');
                              } else if (state is ProductsLoadingState) {
                                return Center(child: CircularProgressIndicator());
                              } else if (state is ProductsLoadingSuccessState) {
                                return RefreshIndicator(
                                  onRefresh: () => context.read<ProductsCubit>().getAllProducts(),
                                  child: _Products(products: stocksdata),//state.products
                                );
                              } else if (state is ProductsErrorState) {
                                return _ProductsErrorWidget(error: state.message);
                              }

                              return SizedBox();
                            },
                          ),
                      )]),
              )),
          // Positioned(
          //   bottom: 0,
          //   child: AnimatedContainer(
          //     height: _expanded ? 800 : 210,
          //     duration: Duration(milliseconds: 500),
          //     curve: Curves.easeInOut,
          //     child: NewsList(
          //         articles: [{"publication":"publication news","title":"title news","imageURL":"imageURL news"},{"publication":"publication news2","title":"title news2","imageURL":"imageURL news2"},{"publication":"publication news3","title":"title news3","imageURL":"imageURL news3"}],
          //         onHeaderTapped: () {
          //           setState(() {
          //             _expanded = !_expanded;
          //           });
          //         },
          //         onDragUpdate: (details) {
          //
          //           if(details.primaryDelta < 0) {
          //             setState(() {
          //               _expanded = true;
          //             });
          //           } else {
          //             setState(() {
          //               _expanded = false;
          //             });
          //           }
          //         }),
          //   ),
          // )
        ]),
      ),
    );
  }
}

class _Products extends StatelessWidget {
  final  products;

  const _Products({Key key, this.products}) : super(key: key);
  double roundDouble(double value, int places){
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
  double generator_price () {
    Random r1 = new Random();
    return roundDouble(r1.nextDouble()*200,3);
  }
  double generator_exchange () {
    Random r1 = new Random();
    return r1.nextBool()?roundDouble(r1.nextDouble()*3,3):roundDouble(r1.nextDouble()*-3,3);
  }
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return Divider(color: Colors.grey[400]);
      },
      itemCount: products.length,
      itemBuilder: (context, index) {

        final stock = products[index];

        return ListTile(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePageScreen(
                    product: stock,
                  ),
                ));
          },
          contentPadding: EdgeInsets.all(20),
          title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("${stock['name']}", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
                Text("${stock['country']}",style: TextStyle(color: Colors.grey[500], fontSize: 20)),
              ]),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            Text("\$${generator_price()}", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
            Container(
              width: 75,
              height: 22,
              child: Text("${generator_exchange()}%", style: TextStyle(color: Colors.white)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: generator_exchange()>=0?Colors.green:Colors.red
              ),
            )
          ]),
        );

      },
    );
  }
}

class _ProductsErrorWidget extends StatelessWidget {
  final String error;

  const _ProductsErrorWidget({Key key, @required this.error})
      : assert(error != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          error,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        const SizedBox(height: 16),
        Align(
          child: ElevatedButton(
            onPressed: () => context.read<ProductsCubit>().getAllProducts(),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}
