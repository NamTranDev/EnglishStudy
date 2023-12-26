import 'package:english_study/constants.dart';
import 'package:english_study/model/category.dart';
import 'package:english_study/model/tab_type.dart';
import 'package:english_study/model/topic.dart';
import 'package:english_study/screen/category/category_view_model.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/preference.dart';
import 'package:english_study/utils/extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryComponent extends StatelessWidget {
  final Function onPickCategory;
  final int? type;
  final bool? isComplete;
  const CategoryComponent(
      {super.key,
      required this.onPickCategory,
      this.type,
      this.isComplete = false});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Provider.value(
        value: CategoryViewModel(),
        builder: (context, widget) {
          return Consumer<CategoryViewModel>(
              builder: (context, viewmodel, widget) {
            return FutureBuilder(
              future: viewmodel.initData(type, isComplete),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                        "Something wrong with message: ${snapshot.error.toString()}"),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return buildWidget(context, snapshot.data, viewmodel);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          });
        },
      ),
    );
  }

  Widget buildWidget(BuildContext context, List<Category>? categories,
      CategoryViewModel viewModel) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: [
          Text(
            isComplete == true
                ? 'Learned topics'
                : 'Please choose a category to get started',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (isComplete == true || categories?.length == 1) {
                              onPickCategory.call(categories?.getOrNull(index));
                            } else {
                              viewModel.selectCategory(
                                  index, categories?.getOrNull(index));
                            }
                          },
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 80,
                                child: ValueListenableBuilder(
                                    valueListenable: viewModel.selectInfo,
                                    builder: (context, info, widget) {
                                      return Card(
                                        elevation: info?.index == index ? 5 : 1,
                                        margin: EdgeInsets.only(left: 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(80),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              left: 70, right: 10),
                                          alignment: Alignment.center,
                                          child: Text(
                                            categories
                                                    ?.getOrNull(index)
                                                    ?.title ??
                                                '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: ValueListenableBuilder(
                                      valueListenable: viewModel.selectInfo,
                                      builder: (context, info, widget) {
                                        return Card(
                                          elevation:
                                              info?.index == index ? 5 : 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(80),
                                          ),
                                          child: Center(
                                              child: Text('${index + 1}')),
                                        );
                                      }))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            categories?.getOrNull(index)?.description ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      ],
                    );
                  },
                  itemCount: categories?.length ?? 0,
                ),
                Positioned(
                  right: 20,
                  bottom: 30,
                  child: ValueListenableBuilder(
                      valueListenable: viewModel.selectInfo,
                      builder: (context, info, widget) {
                        return AnimatedOpacity(
                          duration: Duration(
                              milliseconds: duration_animation_visible),
                          opacity: info == null ? 0 : 1,
                          child: ElevatedButton(
                            onPressed: () {
                              viewModel.comfirmCategory(type);
                              onPickCategory.call();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: maastricht_blue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10)),
                            child: Text(
                              "Select",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
