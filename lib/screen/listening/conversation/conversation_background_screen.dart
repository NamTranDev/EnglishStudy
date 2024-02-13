import 'package:english_study/audio/audio_model.dart';
import 'package:english_study/audio/audio_progress_bar.dart';
import 'package:english_study/audio/notifier/play_button_notifier.dart';
import 'package:english_study/audio/player_manager.dart';
import 'package:english_study/audio/repeat_button.dart';
import 'package:english_study/constants.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/reuse/component/back_screen_component.dart';
import 'package:english_study/screen/listening/conversation/argument.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:flutter/material.dart';

class ConversationBackgroundScreen extends StatefulWidget {
  static String routeName = '/conversation_background';
  const ConversationBackgroundScreen({super.key});

  @override
  State<ConversationBackgroundScreen> createState() =>
      _ConversationBackgroundScreenState();
}

class _ConversationBackgroundScreenState
    extends State<ConversationBackgroundScreen> {
  late PlayerManager player;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackScreenComponent(
          child: FutureBuilder(
            future: initPlayer(ModalRoute.of(context)?.settings.arguments
                as ScreenConversationArguments?),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                      "Something wrong with message: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                if (snapshot.data == null) {
                  return Center(
                    child: Text(
                        "Something wrong with message: ${snapshot.error.toString()}"),
                  );
                }
                player = snapshot.data!;
                return ValueListenableBuilder<AudioModel?>(
                  valueListenable: player.audioNotifier,
                  builder: (context, audio, _) {
                    return audio == null
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Column(
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
                                        audio.transcripts?[index].script ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontSize: 20),
                                      ),
                                    );
                                  },
                                  itemCount: audio.transcripts?.length,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                audio.title ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 20),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: AudioProgressBar(
                                  player: player,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Stack(
                                children: [
                                  Positioned.fill(
                                    child: Row(
                                      children: [
                                        Expanded(flex: 1, child: SizedBox()),
                                        Expanded(flex: 1, child: SizedBox()),
                                        Expanded(
                                            flex: 2,
                                            child: Center(
                                              child: RepeatButton(
                                                player: player,
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: ValueListenableBuilder(
                                      valueListenable:
                                          player.playButtonNotifier,
                                      builder: (context, value, child) {
                                        return GestureDetector(
                                          onTap: () {
                                            switch (player.currentPlayState()) {
                                              case ButtonState.paused:
                                                player.play();
                                                break;
                                              case ButtonState.playing:
                                                player.pause();
                                                break;
                                              default:
                                                break;
                                            }
                                          },
                                          child: widgetIcon(
                                              value == ButtonState.playing
                                                  ? 'assets/icons/ic_pause.svg'
                                                  : 'assets/icons/ic_play.svg'),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<PlayerManager> initPlayer(
      ScreenConversationArguments? argument) async {
    player = PlayerManager();
    await player.init(argument?.conversations);
    player.playIndex(AudioModel(
        id: argument?.conversation?.id,
        title: argument?.conversation?.conversation_lession,
        transcripts: argument?.conversation?.transcript));
    return player;
  }
}
