import 'player_snapshot.dart';

abstract class PlayerRepository {
  Future<PlayerSnapshot> bootstrap();
}
