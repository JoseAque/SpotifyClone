import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;
  bool isScrubbing = false;

  late StreamSubscription positionSub;
  late StreamSubscription durationSub;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    // Listener de la posición
    positionSub = audioPlayer.positionStream.listen((position) {
      if (!isScrubbing) {
        songPosition = position;
        updateSongPlayer();
      }
    });

    // Listener de duración
    durationSub = audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        songDuration = duration;
      }
    });
  }

  void updateSongPlayer() {
    if (isClosed) return; // evita el error de emitir después de cerrar
    emit(SongPlayerLoaded());
  }

  Future<void> loadSong(String url) async {
    try {
      await audioPlayer.setUrl(url);
      updateSongPlayer();
    } catch (e) {
      if (!isClosed) emit(SongPlayerFailure());
    }
  }

  void playOrPauseSong() {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }

    if (!isClosed) emit(SongPlayerLoaded());
  }

  Future<void> seekTo(Duration position) async {
    // Clamp position within [0, songDuration]
    final max = songDuration == Duration.zero ? null : songDuration;
    if (max != null) {
      if (position > max) position = max;
      if (position < Duration.zero) position = Duration.zero;
    }

    final wasPlaying = audioPlayer.playing;
    try {
      // prevent position stream from fighting UI while we seek
      isScrubbing = true;
      await audioPlayer.seek(position);
      // Update local position immediately for responsive UI
      songPosition = position;
      updateSongPlayer();

      if (wasPlaying) {
        // Resume playback if it was playing before seeking
        await audioPlayer.play();
      }
      isScrubbing = false;
    } catch (e) {
      isScrubbing = false;
      if (!isClosed) emit(SongPlayerFailure());
    }
  }

  void startScrub() {
    isScrubbing = true;
  }

  void endScrub() {
    isScrubbing = false;
  }

  @override
  Future<void> close() {
    positionSub.cancel();
    durationSub.cancel();
    audioPlayer.dispose();
    return super.close();
  }
}
