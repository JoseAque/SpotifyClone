import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/widgets/appbar/app_bar.dart';
import 'package:spotify/common/widgets/favorite_button/favorite_button.dart';
import 'package:spotify/core/configs/constants/app_urls.dart';
import 'package:spotify/core/configs/theme/app_colors.dart';
import 'package:spotify/domain/entities/song/song.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;
  final List<SongEntity> songs;
  final int currentIndex;
  final bool autoPlay;

  const SongPlayerPage({
    required this.songEntity,
    required this.songs,
    required this.currentIndex,
    this.autoPlay = false,
    super.key,
  });

  @override
  State<SongPlayerPage> createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  late SongPlayerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SongPlayerCubit();
    _loadAndPlaySong();
  }

  Future<void> _loadAndPlaySong() async {
    await _cubit.loadSong(
      '${AppURLs.songFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.mp3?${AppURLs.mediaAlt}',
    );

    // Si autoPlay está activado, reproducir automáticamente
    if (widget.autoPlay) {
      _cubit.audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: const Text(
          'Now playing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        action: IconButton(
          onPressed: () {
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                MediaQuery.of(context).size.width - 50,
                60,
                20,
                0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: AppColors.grey.withOpacity(0.8),
              color: Theme.of(context).scaffoldBackgroundColor,
              items: [
                PopupMenuItem<String>(
                  value: 'hello',
                  mouseCursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context, 'hello');
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Hola :)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ).then((value) {
              if (value == 'hello') {
                // Acción para "Hola :)"
              }
            });
          },
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
      body: BlocProvider.value(
        value: _cubit,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              _songCover(context),
              const SizedBox(height: 20),
              _songDetail(),
              const SizedBox(height: 30),
              _songPlayer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _songCover(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            '${AppURLs.coverFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.jpg?${AppURLs.mediaAlt}',
          ),
        ),
      ),
    );
  }

  Widget _songDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.songEntity.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.songEntity.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        FavoriteButton(songEntity: widget.songEntity),
      ],
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoading) {
          return CircularProgressIndicator();
        }
        if (state is SongPlayerLoaded) {
          return Column(
            children: [
              Slider(
                value: context
                    .read<SongPlayerCubit>()
                    .songPosition
                    .inSeconds
                    .toDouble(),
                min: 0.0,
                max: context
                    .read<SongPlayerCubit>()
                    .songDuration
                    .inSeconds
                    .toDouble(),
                onChangeStart: (_) {
                  context.read<SongPlayerCubit>().startScrub();
                },
                onChanged: (value) {
                  // Update UI while dragging
                  final cubit = context.read<SongPlayerCubit>();
                  cubit.songPosition = Duration(seconds: value.toInt());
                  cubit.updateSongPlayer();
                },
                onChangeEnd: (value) {
                  // Perform actual seek when user finishes dragging
                  context.read<SongPlayerCubit>().seekTo(
                    Duration(seconds: value.toInt()),
                  );
                  context.read<SongPlayerCubit>().endScrub();
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatDuration(
                      context.read<SongPlayerCubit>().songPosition,
                    ),
                  ),
                  Text(
                    formatDuration(
                      context.read<SongPlayerCubit>().songDuration,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // transport controls row: repeat, previous, play/pause, next, shuffle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 60.0),
                    child: IconButton(
                      iconSize: 30,
                      onPressed: () {
                        // Navigate to previous song (circular)
                        final previousIndex = widget.currentIndex == 0
                            ? widget.songs.length - 1
                            : widget.currentIndex - 1;

                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SongPlayerPage(
                                      songEntity: widget.songs[previousIndex],
                                      songs: widget.songs,
                                      currentIndex: previousIndex,
                                      autoPlay: true,
                                    ),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(-1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;

                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                            transitionDuration: const Duration(
                              milliseconds: 300,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.skip_previous),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().playOrPauseSong();
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(
                        context.read<SongPlayerCubit>().audioPlayer.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Navigate to next song (circular)
                      final nextIndex =
                          widget.currentIndex == widget.songs.length - 1
                          ? 0
                          : widget.currentIndex + 1;

                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  SongPlayerPage(
                                    songEntity: widget.songs[nextIndex],
                                    songs: widget.songs,
                                    currentIndex: nextIndex,
                                    autoPlay: true,
                                  ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOut;

                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 60),
                      child: const Icon(size: 30, Icons.skip_next),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return Container();
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
