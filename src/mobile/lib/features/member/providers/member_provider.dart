import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/graphql_service.dart';
import '../../../core/graphql/queries.dart';

/// État d'un membre
class MemberState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? member;
  final List<dynamic>? relations;

  MemberState({
    this.isLoading = false,
    this.error,
    this.member,
    this.relations,
  });

  MemberState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? member,
    List<dynamic>? relations,
  }) {
    return MemberState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      member: member ?? this.member,
      relations: relations ?? this.relations,
    );
  }
}

/// Notifier pour gérer les membres
class MemberNotifier extends StateNotifier<MemberState> {
  MemberNotifier() : super(MemberState());

  final _graphql = GraphQLService.instance;

  /// Charge les détails d'un membre
  Future<void> loadMember(String memberId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.query(
        queryMember,
        variables: {'id': memberId},
      );

      if (result.hasException) {
        state = state.copyWith(
          isLoading: false,
          error: result.exception.toString(),
        );
        return;
      }

      final memberData = result.data?['member'];
      state = state.copyWith(
        isLoading: false,
        member: memberData,
        relations: memberData?['relations'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Ajoute un nouveau membre
  Future<bool> addMember({
    required String firstName,
    required String lastName,
    required String relatedMemberId,
    required String relationType,
    DateTime? birthDate,
    DateTime? deathDate,
    String? gender,
    String? birthPlace,
    String? bio,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.mutate(
        mutationAddMember,
        variables: {
          'input': {
            'firstName': firstName,
            'lastName': lastName,
            'relatedMemberId': relatedMemberId,
            'relationType': relationType,
            if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
            if (deathDate != null) 'deathDate': deathDate.toIso8601String(),
            if (gender != null) 'gender': gender,
            if (birthPlace != null) 'birthPlace': birthPlace,
            if (bio != null) 'bio': bio,
          },
        },
      );

      if (result.hasException) {
        state = state.copyWith(
          isLoading: false,
          error: result.exception.toString(),
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Met à jour un membre
  Future<bool> updateMember({
    required String memberId,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? deathDate,
    String? gender,
    String? birthPlace,
    String? bio,
    String? photoUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.mutate(
        mutationUpdateMember,
        variables: {
          'id': memberId,
          'input': {
            if (firstName != null) 'firstName': firstName,
            if (lastName != null) 'lastName': lastName,
            if (birthDate != null) 'birthDate': birthDate.toIso8601String(),
            if (deathDate != null) 'deathDate': deathDate.toIso8601String(),
            if (gender != null) 'gender': gender,
            if (birthPlace != null) 'birthPlace': birthPlace,
            if (bio != null) 'bio': bio,
            if (photoUrl != null) 'photoUrl': photoUrl,
          },
        },
      );

      if (result.hasException) {
        state = state.copyWith(
          isLoading: false,
          error: result.exception.toString(),
        );
        return false;
      }

      // Recharger le membre après mise à jour
      await loadMember(memberId);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Réinitialise l'état
  void reset() {
    state = MemberState();
  }
}

/// Provider pour l'état d'un membre
final memberProvider = StateNotifierProvider<MemberNotifier, MemberState>((ref) {
  return MemberNotifier();
});
