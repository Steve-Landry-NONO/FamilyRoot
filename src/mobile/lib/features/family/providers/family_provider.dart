import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/graphql_service.dart';
import '../../core/graphql/queries.dart';

/// État de la famille
class FamilyState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? family;
  final Map<String, dynamic>? dashboard;
  final List<dynamic>? members;
  final List<dynamic>? relationships;

  FamilyState({
    this.isLoading = false,
    this.error,
    this.family,
    this.dashboard,
    this.members,
    this.relationships,
  });

  FamilyState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? family,
    Map<String, dynamic>? dashboard,
    List<dynamic>? members,
    List<dynamic>? relationships,
  }) {
    return FamilyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      family: family ?? this.family,
      dashboard: dashboard ?? this.dashboard,
      members: members ?? this.members,
      relationships: relationships ?? this.relationships,
    );
  }

  bool get hasFamily => family != null;
}

/// Notifier pour gérer l'état de la famille
class FamilyNotifier extends StateNotifier<FamilyState> {
  FamilyNotifier() : super(FamilyState());

  final _graphql = GraphQLService.instance;

  /// Crée une nouvelle famille
  Future<bool> createFamily({
    required String familyName,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.mutate(
        mutationCreateFamily,
        variables: {
          'input': {
            'name': familyName,
            'founderFirstName': firstName,
            'founderLastName': lastName,
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

      final familyData = result.data?['createFamily'];
      state = state.copyWith(
        isLoading: false,
        family: familyData,
      );

      // Charger le dashboard après création
      await loadDashboard();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Rejoindre une famille avec un code d'invitation
  Future<bool> joinFamily({
    required String code,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.mutate(
        mutationJoinFamily,
        variables: {
          'code': code,
          'founderFirstName': firstName,
          'founderLastName': lastName,
        },
      );

      if (result.hasException) {
        final errorMsg = _parseError(result.exception.toString());
        state = state.copyWith(isLoading: false, error: errorMsg);
        return false;
      }

      state = state.copyWith(isLoading: false);

      // Charger le dashboard après avoir rejoint
      await loadDashboard();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Valide un code d'invitation
  Future<Map<String, dynamic>?> validateInvitationCode(String code) async {
    try {
      final result = await _graphql.query(
        queryValidateInvitation,
        variables: {'code': code},
      );

      if (result.hasException) {
        return null;
      }

      return result.data?['validateInvitationCode'];
    } catch (e) {
      return null;
    }
  }

  /// Charge le dashboard de la famille
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.query(queryDashboard);

      if (result.hasException) {
        state = state.copyWith(
          isLoading: false,
          error: result.exception.toString(),
        );
        return;
      }

      final dashboardData = result.data?['dashboard'];
      state = state.copyWith(
        isLoading: false,
        dashboard: dashboardData,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Charge l'arbre généalogique complet
  Future<void> loadFamilyTree() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _graphql.query(queryFamilyTree);

      if (result.hasException) {
        state = state.copyWith(
          isLoading: false,
          error: result.exception.toString(),
        );
        return;
      }

      final treeData = result.data?['familyTree'];
      state = state.copyWith(
        isLoading: false,
        family: treeData,
        members: treeData?['members'],
        relationships: treeData?['relationships'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Crée une invitation
  Future<String?> createInvitation({int expiresInDays = 7}) async {
    try {
      final result = await _graphql.mutate(
        mutationCreateInvitation,
        variables: {'expiresInDays': expiresInDays},
      );

      if (result.hasException) {
        return null;
      }

      return result.data?['createInvitation']?['code'];
    } catch (e) {
      return null;
    }
  }

  /// Parse les erreurs GraphQL pour des messages plus lisibles
  String _parseError(String error) {
    if (error.contains('INVITATION_NOT_FOUND')) {
      return 'Code d\'invitation invalide';
    }
    if (error.contains('INVITATION_EXPIRED')) {
      return 'L\'invitation a expiré';
    }
    if (error.contains('INVITATION_ALREADY_USED')) {
      return 'Cette invitation a déjà été utilisée';
    }
    if (error.contains('ALREADY_IN_FAMILY')) {
      return 'Vous êtes déjà membre d\'une famille';
    }
    return error;
  }

  /// Réinitialise l'état
  void reset() {
    state = FamilyState();
  }
}

/// Provider pour l'état de la famille
final familyProvider = StateNotifierProvider<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier();
});
