import 'package:english_study/constants.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/reuse/component/banner_component.dart';
import 'package:english_study/screen/listening/conversation/conversation_view_model.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  static String routeName = '/conversation';
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late ConversationViewModel _viewModel;

  @override
  void dispose() {
    _viewModel.disposeAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: ConversationViewModel(),
      child: Scaffold(
          body: SafeArea(
              child: BackScreenComponent(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ConversationViewModel>(
                  builder: (context, viewModel, child) {
                _viewModel = viewModel;
                return FutureBuilder(
                  future: viewModel.conversationDetail(ModalRoute.of(context)
                      ?.settings
                      .arguments as Conversation?),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            "Something wrong with message: ${snapshot.error.toString()}"),
                      );
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      var conversation = snapshot.data;
                      var transcripts = conversation?.transcript;
                      return Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 4),
                                  child: Text(
                                    transcripts?[index].script ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontSize: 20),
                                  ),
                                );
                              },
                              itemCount: transcripts?.length,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            conversation?.conversation_lession ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontSize: 20),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ValueListenableBuilder(
                              valueListenable: viewModel.progressStatus,
                              builder: (context, value, child) {
                                return Slider(
                                    min: 0,
                                    max:
                                        value?.total?.inSeconds.toDouble() ?? 0,
                                    value:
                                        value?.current?.inSeconds.toDouble() ??
                                            0,
                                    onChanged: (value) {
                                      viewModel.seekAudio(value.toInt());
                                    });
                              }),
                          StreamBuilder<PlayerState>(
                            stream: viewModel.audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              if (snapshot.data?.processingState ==
                                  ProcessingState.completed) {
                                viewModel.refresh(conversation?.id?.toString());
                              }
                              return GestureDetector(
                                onTap: () {
                                  viewModel.playOrPause();
                                },
                                child: widgetIcon(snapshot.data?.playing == true
                                    ? 'assets/icons/ic_pause.svg'
                                    : 'assets/icons/ic_play.svg'),
                              );
                            },
                          ),
                          SizedBox(
                            height: 40,
                          ),
                        ],
                      );
                    }
                  },
                );
              }),
            ),
            const BannerComponent()
          ],
        ),
      ))),
    );
  }
}
