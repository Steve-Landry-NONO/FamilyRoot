import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class GraphQLService {
  static GraphQLService? _instance;
  late GraphQLClient _client;

  GraphQLService._();

  static GraphQLService get instance {
    _instance ??= GraphQLService._();
    return _instance!;
  }

  void init() {
    final httpLink = HttpLink(
      AppConfig.graphqlEndpoint,
      defaultHeaders: {
        'apollo-require-preflight': 'true',
        'x-apollo-operation-name': 'operation',
      },
    );

    final authLink = AuthLink(
      getToken: () {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          debugPrint('GraphQL token OK: ${session.accessToken.substring(0, 20)}...');
          return 'Bearer ${session.accessToken}';
        }
        debugPrint('GraphQL token: null (pas de session)');
        return null;
      },
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  GraphQLClient get client => _client;

  Future<QueryResult> query(
    String query, {
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.networkOnly,
    );
    final result = await _client.query(options);
    if (result.hasException) {
      debugPrint('GraphQL Query Error: ${result.exception}');
    }
    return result;
  }

  Future<QueryResult> mutate(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );
    final result = await _client.mutate(options);
    if (result.hasException) {
      debugPrint('GraphQL Mutation Error: ${result.exception}');
    }
    return result;
  }
}
