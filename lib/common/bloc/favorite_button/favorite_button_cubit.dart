import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_button_state.dart';
import 'package:spotify/domain/usecases/song/add_or_remove_favorite_song.dart';
import 'package:spotify/service_locator.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FavoritesCubit() : super(FavoritesLoading());

  Future<void> load() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(FavoritesLoaded({}));
        return;
      }
      final snap = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Favorites')
          .get();
      final favs = snap.docs
          .map((d) => (d.data()['songId'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      emit(FavoritesLoaded(favs));
    } catch (e) {
      emit(FavoritesError('Failed to load favorites'));
    }
  }

  bool isFavorite(String songId) {
    final s = state;
    if (s is FavoritesLoaded) {
      return s.favorites.contains(songId);
    }
    return false;
  }

  Future<void> toggle(String songId) async {
    try {
      // Call existing use case to add/remove in Firestore
      final result = await sl<AddOrRemoveFavoriteSongUseCase>().call(
        params: songId,
      );
      result.fold((l) {}, (isFav) async {
        final current = state is FavoritesLoaded
            ? (state as FavoritesLoaded).favorites
            : <String>{};
        final updated = Set<String>.from(current);
        if (isFav) {
          updated.add(songId);
        } else {
          updated.remove(songId);
        }
        emit(FavoritesLoaded(updated));
      });
    } catch (_) {
      // Optionally emit error then revert
    }
  }
}
