import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  AudioPlayer audioPlayer = AudioPlayer();

  Duration songDuration = Duration.zero;
  Duration songPosition = Duration.zero;

  late StreamSubscription positionSub;
  late StreamSubscription durationSub;

  SongPlayerCubit() : super(SongPlayerLoading()) {
    // Listener de la posición
    positionSub = audioPlayer.positionStream.listen((position) {
      songPosition = position;
      updateSongPlayer();
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

  @override
  Future<void> close() {
    positionSub.cancel();
    durationSub.cancel();
    audioPlayer.dispose();
    return super.close();
  }
}
