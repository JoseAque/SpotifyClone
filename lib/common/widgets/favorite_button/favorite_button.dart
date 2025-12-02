import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:spotify/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:spotify/domain/entities/song/song.dart';
import '../../../core/configs/theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  final VoidCallback? onChanged;
  const FavoriteButton({required this.songEntity, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen: (prev, curr) => true,
      builder: (context, state) {
        bool isFav;
        if (state is FavoritesLoaded) {
          isFav = state.favorites.contains(songEntity.songId);
        } else {
          // Fallback al valor del entity hasta cargar
          isFav = songEntity.isFavorite;
        }
        return IconButton(
          onPressed: () async {
            await context.read<FavoritesCubit>().toggle(songEntity.songId);
            if (onChanged != null) onChanged!();
          },
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_outline_outlined,
            size: 25,
            color: isFav ? AppColors.primary : AppColors.grey,
          ),
        );
      },
    );
  }
}
