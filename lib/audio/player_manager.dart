import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:english_study/audio/audio_handler.dart';
import 'package:english_study/audio/audio_model.dart';
import 'package:english_study/audio/notifier/play_button_notifier.dart';
import 'package:english_study/audio/notifier/progress_notifier.dart';
import 'package:english_study/audio/notifier/repeat_button_notifier.dart';
import 'package:english_study/audio/notifier/audio_info_notifier.dart';
import 'package:english_study/model/audio.dart';
import 'package:english_study/model/conversation.dart';
import 'package:english_study/model/transcript.dart';
import 'package:english_study/services/service_locator.dart';
import 'package:english_study/storage/db_provider.dart';
import 'package:english_study/storage/memory.dart';
import 'package:english_study/utils/file_util.dart';
import 'package:flutter/foundation.dart';

class PlayerManager {
  // Listeners: Updates going to the UI
  final audioNotifier = AudioNotifier(null);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final playButtonNotifier = PlayButtonNotifier();
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);

  final _audioHandler = getIt<AudioHandler>();

  Function? statusButtonListener;

  // Events: Calls coming from the UI
  Future init(List<Conversation>? conversations) async {
    await loadAudio(conversations);
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
  }

  Future<void> loadAudio(List<Conversation>? conversations) async {
    if (conversations == null) return;
    Iterable<Future<MediaItem>> mediaItems = conversations
        .where((conversation) => conversation.audios?.firstOrNull != null)
        .map((conversation) async {
      Audio? audio = conversation.audios?.firstOrNull;
      var path = "${getIt<AppMemory>().pathFolderDocument}/${audio?.path}";
      var fileExist = await doesFileExist(path);
      return MediaItem(
        id: conversation.id?.toString() ?? '',
        title: conversation.conversation_lession ?? '',
        extras: {
          AudioModel.FILE_PATH: fileExist ? path : null,
          AudioModel.ASSET_PATH: 'assets/audio/${audio?.name}',
          AudioModel.TRANSCRIPT: jsonEncode(conversation.transcript)
        },
      );
    }).toList();
    var items = await Future.wait(mediaItems);
    await _audioHandler.addQueueItems(items);
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      // logger(object: playbackState, tag: '_listenToPlaybackState');
      final item = _audioHandler.mediaItem.value;
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;

      if (processingState == AudioProcessingState.completed) {
        var db = getIt<DBProvider>();
        db.syncConversation(item?.id.toString());
      }
      if (!isPlaying) {
        if (playButtonNotifier.value != ButtonState.paused) {
          playButtonNotifier.value = ButtonState.paused;
          statusButtonListener?.call(ButtonState.paused);
        }
      } else if (processingState != AudioProcessingState.completed) {
        if (playButtonNotifier.value != ButtonState.playing) {
          playButtonNotifier.value = ButtonState.playing;
          statusButtonListener?.call(ButtonState.playing);
        }
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }

      _updateProcess(isPlaying: isPlaying);
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      _updateProcess(current: position);
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      _updateProcess(buffered: playbackState.bufferedPosition);
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      // logger(tag: '_listenToTotalDuration');
      _updateProcess(total: mediaItem?.duration);
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      // logger(object: mediaItem, tag: '_listenToChangesInSong');
      updateSongInfo();
    });
  }

  void playIndex(AudioModel audio) async {
    int index = _audioHandler.queue.value
        .indexWhere((element) => element.id == audio.id.toString());
    await _audioHandler.skipToQueueItem(index);

    updateSongInfo(audio: audio);
  }

  int? currentIndex() {
    final item = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (item == null) {
      return null;
    }
    return playlist.indexOf(item);
  }

  void updateSongInfo({AudioModel? audio}) {
    if (audio != null) {
      audioNotifier.value = audio;
      return;
    }
    final item = _audioHandler.mediaItem.value;

    if (item == null) {
      return;
    }

    if (audioNotifier.value?.id != item.id) {
      List<Transcript> transcripts =
          (jsonDecode(item.extras?[AudioModel.TRANSCRIPT]) as List)
              .map((item) => Transcript.fromJson(item))
              .toList();
      audioNotifier.value = AudioModel(
          id: int.parse(item.id), title: item.title, transcripts: transcripts);

      _updateProcess(
          total: item.duration,
          isPlaying: _audioHandler.playbackState.value.playing);
    }
  }

  void _updateProcess(
      {Duration? current,
      Duration? buffered,
      Duration? total,
      bool? isPlaying}) {
    final oldState = progressNotifier.value;

    progressNotifier.value = ProgressBarState(
      current: current ?? oldState.current,
      buffered: buffered ?? oldState.buffered,
      total: total ?? oldState.total,
      isPlaying: isPlaying ?? oldState.isPlaying,
    );
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  ButtonState? currentPlayState() {
    PlaybackState state = _audioHandler.playbackState.value;
    final isPlaying = state.playing;
    final processingState = state.processingState;
    if (!isPlaying) {
      return ButtonState.paused;
    } else if (processingState != AudioProcessingState.completed) {
      return ButtonState.playing;
    } else {
      return null;
    }
  }

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  // Future<void> add() async {
  //   final songRepository = getIt<PlaylistRepository>();
  //   final song = await songRepository.fetchAnotherSong();
  //   final mediaItem = MediaItem(
  //     id: song['id'] ?? '',
  //     album: song['album'] ?? '',
  //     title: song['title'] ?? '',
  //     extras: {'url': song['url']},
  //   );
  //   _audioHandler.addQueueItem(mediaItem);
  // }

  // void remove() {
  //   final lastIndex = _audioHandler.queue.value.length - 1;
  //   if (lastIndex < 0) return;
  //   _audioHandler.removeQueueItemAt(lastIndex);
  // }

  void dispose() {
    _audioHandler.stop();
  }

  bool isPlaying() {
    return playButtonNotifier.value == ButtonState.playing;
  }
}
