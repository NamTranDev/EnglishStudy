import 'package:carousel_slider/carousel_slider.dart';
import 'package:english_study/model/vocabulary.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlashCardScreen extends StatelessWidget {
  static String routeName = '/flash_card';
  const FlashCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var db = getIt<DBProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: db.getVocabulary(
              ModalRoute.of(context)?.settings.arguments as String?),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                    "Something wrong with message: ${snapshot.error.toString()}"),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return buildCaroselCard(context, snapshot.data);
            }
          },
        ),
      ),
    );
  }

  Widget buildCaroselCard(BuildContext context, List<Vocabulary>? data) {
    return CarouselSlider(
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height,
          viewportFraction: 0.9,
        ),
        items: data
            ?.map((item) => Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        widgetImage(null),
                        SizedBox(
                          height: 10,
                        ),
                        Text(item.word ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 50,
                            ),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: item.spellings?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                child: Text(item.spellings?[index].text ?? ''),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: item.audios?.length ?? 0,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                child: Icon(
                                  Icons.audio_file,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(item.description ?? '')
                      ],
                    ),
                  ),
                ))
            .toList());
  }

  Widget widgetImage(String? image) {
    return image != null
        ? Image.asset('assets/image/' + image)
        : Image.asset('assets/no_image.jpg');
  }
}
