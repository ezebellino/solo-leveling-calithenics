import 'player_bootstrap_result.dart';

abstract class PlayerRepository {
  Future<PlayerBootstrapResult> bootstrap();
}
