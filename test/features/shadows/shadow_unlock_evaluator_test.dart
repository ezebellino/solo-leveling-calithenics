import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/data/home_api_client.dart';
import 'package:solo_leveling_calisthenics/features/home/data/local_player_state_repository.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/daily_quest.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/hunter_profile.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/player_state.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/player_system_service.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/controllers/home_controller.dart';
import 'package:solo_leveling_calisthenics/features/shadows/application/shadow_unlock_evaluator.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_catalog.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_progress_snapshot.dart';

void main() {
  group('ShadowUnlockEvaluator', () {
    test('returns Igris when the player reaches 7 completed main days', () {
      const evaluator = ShadowUnlockEvaluator();

      final unlocked = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 7,
          streakDays: 3,
          totalCompletedQuests: 12,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 5,
          unlockedShadowIds: const <String>[],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(unlocked.map((shadow) => shadow.id), ['igris']);
      expect(unlocked.single.flavorText, isNotEmpty);
      expect(unlocked.single.unlockHint, contains('7 main quest days'));
    });

    test('skips shadows that are already unlocked', () {
      const evaluator = ShadowUnlockEvaluator();

      final unlocked = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 7,
          streakDays: 3,
          totalCompletedQuests: 12,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 5,
          unlockedShadowIds: const <String>['igris'],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(unlocked, isEmpty);
    });

    test('does not unlock Tank until all of its thresholds are met', () {
      const evaluator = ShadowUnlockEvaluator();

      final missingThreshold = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 14,
          streakDays: 6,
          totalCompletedQuests: 21,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 8,
          unlockedShadowIds: const <String>[],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(missingThreshold.map((shadow) => shadow.id), isNot(contains('tank')));

      final unlocked = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 14,
          streakDays: 7,
          totalCompletedQuests: 21,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 8,
          unlockedShadowIds: const <String>[],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(unlocked.map((shadow) => shadow.id), contains('tank'));
    });

    test('copies unlocked shadow ids instead of reflecting later mutations', () {
      final sourceUnlockedShadowIds = <String>['igris'];
      final snapshot = ShadowProgressSnapshot(
        completedMainDays: 7,
        streakDays: 3,
        totalCompletedQuests: 12,
        completedSpecialQuests: 0,
        perfectWeeks: 0,
        level: 5,
        unlockedShadowIds: sourceUnlockedShadowIds,
      );

      sourceUnlockedShadowIds.add('tank');

      expect(snapshot.unlockedShadowIds, contains('igris'));
      expect(snapshot.unlockedShadowIds, isNot(contains('tank')));
    });
  });

  group('PlayerSystemService shadow unlocks', () {
    const baseProfile = HunterProfile(
      alias: 'Test Hunter',
      avatarUrl: '',
      avatarImageBase64: '',
      rank: 'E-Rank',
      title: 'Humano novato',
      level: 1,
      currentXp: 0,
      nextLevelXp: 120,
      streakDays: 6,
      shadowArmy: 0,
      strength: 1,
      agility: 1,
      endurance: 1,
      discipline: 0,
    );

    test('unlocks Igris once when the main quest reaches day 7', () {
      const service = PlayerSystemService(baseProfile: baseProfile);
      final state = service.initialState().copyWith(
        completedDays: 6,
        totalCompletedQuests: 6,
        currentWeekCompletedMainDays: 6,
        lastStreakCreditDate: '',
        unlockedShadowIds: const <String>[],
        lastUnlockedShadowId: '',
      );
      final quest = state.quests.first.copyWith(progress: state.quests.first.target - 1);
      final primedState = state.copyWith(
        quests: [quest, ...state.quests.skip(1)],
      );

      final firstResult = service.advanceQuest(primedState, quest);

      expect(firstResult.state.completedDays, 7);
      expect(firstResult.state.unlockedShadowIds, contains('igris'));
      expect(firstResult.state.lastUnlockedShadowId, 'igris');
      expect(
        firstResult.notices.where((item) => item == 'Nueva sombra obtenida: Igris'),
        hasLength(1),
      );

      final secondResult = service.advanceQuest(firstResult.state, firstResult.state.quests.first);

      expect(
        secondResult.state.unlockedShadowIds.where((id) => id == 'igris'),
        hasLength(1),
      );
      expect(
        secondResult.notices.where((item) => item.contains('Nueva sombra obtenida: Igris')),
        isEmpty,
      );
    });

    test('unlocks Tank from persisted cumulative counters when thresholds are met', () {
      const service = PlayerSystemService(baseProfile: baseProfile);
      final state = service.initialState().copyWith(
        completedDays: 13,
        totalCompletedQuests: 20,
        currentWeekCompletedMainDays: 4,
        lastStreakCreditDate: '',
        unlockedShadowIds: const <String>['igris'],
        lastUnlockedShadowId: 'igris',
      );
      final quest = state.quests.first.copyWith(progress: state.quests.first.target - 1);
      final primedState = state.copyWith(
        quests: [quest, ...state.quests.skip(1)],
      );

      final result = service.advanceQuest(primedState, quest);

      expect(result.state.completedDays, 14);
      expect(result.state.totalCompletedQuests, 21);
      expect(result.state.currentWeekCompletedMainDays, 5);
      expect(result.state.unlockedShadowIds, contains('tank'));
      expect(result.state.lastUnlockedShadowId, 'tank');
      expect(result.notices, contains('Nueva sombra obtenida: Tank'));
    });

    test('non-primary quest completion can unlock a shadow once total quest threshold is crossed', () {
      const service = PlayerSystemService(baseProfile: baseProfile);
      final state = service.initialState().copyWith(
        profile: stateProfileWithStreak7(service.initialState().profile),
        completedDays: 14,
        totalCompletedQuests: 20,
        currentWeekCompletedMainDays: 4,
        lastStreakCreditDate: '2026-05-03',
        unlockedShadowIds: const <String>['igris'],
        lastUnlockedShadowId: 'igris',
      );
      final nonPrimaryQuest = state.quests[1].copyWith(
        progress: state.quests[1].target - 1,
      );
      final primedState = state.copyWith(
        quests: [state.quests.first, nonPrimaryQuest, ...state.quests.skip(2)],
      );

      final result = service.advanceQuest(primedState, nonPrimaryQuest);

      expect(result.state.completedDays, 14);
      expect(result.state.currentWeekCompletedMainDays, 4);
      expect(result.state.totalCompletedQuests, 21);
      expect(result.state.unlockedShadowIds, contains('tank'));
      expect(result.state.lastUnlockedShadowId, 'tank');
      expect(result.notices, contains('Nueva sombra obtenida: Tank'));
    });

    test('special quest completion increments persistent quest counters', () {
      const service = PlayerSystemService(baseProfile: baseProfile);
      final initialState = service.initialState();
      final specialQuest = initialState.weeklySpecialQuest!;
      final state = initialState.copyWith(
        weeklySpecialStatus: 'accepted',
        totalCompletedQuests: 10,
        completedSpecialQuests: 0,
        weeklySpecialQuest: specialQuest.copyWith(progress: specialQuest.target - 1),
      );

      final result = service.advanceSpecialQuest(state, state.weeklySpecialQuest!);

      expect(result.state.totalCompletedQuests, 11);
      expect(result.state.completedSpecialQuests, 1);
      expect(result.state.weeklySpecialStatus, 'completed');
    });

    test('special quest completion can unlock a shadow from updated counters', () {
      const advancedProfile = HunterProfile(
        alias: 'Test Hunter',
        avatarUrl: '',
        avatarImageBase64: '',
        rank: 'D-Rank',
        title: 'Despierto',
        level: 10,
        currentXp: 0,
        nextLevelXp: 120,
        streakDays: 10,
        shadowArmy: 0,
        strength: 1,
        agility: 1,
        endurance: 1,
        discipline: 0,
      );
      const service = PlayerSystemService(baseProfile: advancedProfile);
      final initialState = service.initialState().copyWith(
        completedDays: 21,
        totalCompletedQuests: 20,
        completedSpecialQuests: 0,
        unlockedShadowIds: const <String>['igris', 'tank'],
        lastUnlockedShadowId: 'tank',
        weeklySpecialStatus: 'accepted',
      );
      final specialQuest = initialState.weeklySpecialQuest!.copyWith(
        progress: initialState.weeklySpecialQuest!.target - 1,
      );
      final state = initialState.copyWith(weeklySpecialQuest: specialQuest);

      final result = service.advanceSpecialQuest(state, state.weeklySpecialQuest!);

      expect(result.state.totalCompletedQuests, 21);
      expect(result.state.completedSpecialQuests, 1);
      expect(result.state.unlockedShadowIds, contains('iron'));
      expect(result.state.lastUnlockedShadowId, 'iron');
      expect(result.notices, contains('Nueva sombra obtenida: Iron'));
    });

    test('week rollover banks perfect weeks from persisted weekly progress', () {
      const service = PlayerSystemService(baseProfile: baseProfile);
      final state = service.initialState(
        now: DateTime(2026, 5, 3),
      ).copyWith(
        lastQuestRefresh: '2026-05-03',
        currentWeekKey: '2026-W18',
        currentWeekCompletedMainDays: 5,
        perfectWeeks: 1,
      );

      final result = service.refreshForNewDay(
        state,
        now: DateTime(2026, 5, 4),
      );

      expect(result.state.perfectWeeks, 2);
      expect(result.state.currentWeekCompletedMainDays, 0);
      expect(result.state.currentWeekKey, isNot('2026-W18'));
    });
  });

  group('HomeController shadow sync', () {
    test('keeps local progression authoritative and clears stale unlock replay', () async {
      const baseProfile = HunterProfile(
        alias: 'Local Hunter',
        avatarUrl: '',
        avatarImageBase64: '',
        rank: 'E-Rank',
        title: 'Humano novato',
        level: 1,
        currentXp: 0,
        nextLevelXp: 120,
        streakDays: 6,
        shadowArmy: 0,
        strength: 1,
        agility: 1,
        endurance: 1,
        discipline: 0,
      );
      final storage = _MemoryPlayerStateRepository();
      const system = PlayerSystemService(baseProfile: baseProfile);
      final localState = system.initialState().copyWith(
        selectedStageIndex: 2,
        completedDays: 6,
        totalCompletedQuests: 6,
        currentWeekCompletedMainDays: 6,
        inventory: const <String, int>{
          'freeze': 1,
          'xp_boost': 2,
          'reroll': 3,
        },
        unlockedShadowIds: const <String>[],
        lastUnlockedShadowId: '',
        lastStreakCreditDate: '',
        quests: [
          system.initialState().quests.first.copyWith(progress: 3),
          ...system.initialState().quests.skip(1),
        ],
      );
      storage.state = localState;
      final remoteSnapshot = RemoteHomeSnapshot(
        profile: const HunterProfile(
          alias: 'Remote Hunter',
          avatarUrl: 'https://example.com/avatar.png',
          avatarImageBase64: '',
          rank: 'S-Rank',
          title: 'Remote Title',
          level: 99,
          currentXp: 9999,
          nextLevelXp: 10000,
          streakDays: 99,
          shadowArmy: 99,
          strength: 99,
          agility: 99,
          endurance: 99,
          discipline: 99,
        ),
        selectedStageIndex: 4,
        quests: const <DailyQuest>[
          DailyQuest(
            id: 'remote-main',
            title: 'Remote quest',
            detail: 'Remote detail',
            rewardXp: 10,
            progress: 0,
            target: 1,
          ),
        ],
        inventory: const <String, int>{'freeze': 5},
        completedDays: 0,
      );
      final apiClient = _FakeHomeApiClient(snapshot: remoteSnapshot);
      final controller = HomeController(
        storage: storage,
        system: system,
        apiClient: apiClient,
      );

      await controller.load();

      expect(controller.playerState!.selectedStageIndex, 2);
      expect(controller.playerState!.quests.first.id, localState.quests.first.id);
      expect(controller.playerState!.quests.first.progress, 3);
      expect(controller.playerState!.inventory, localState.inventory);

      await controller.advanceQuest(controller.playerState!.quests.first);

      expect(controller.playerState!.profile.alias, 'Remote Hunter');
      expect(controller.playerState!.profile.avatarUrl, 'https://example.com/avatar.png');
      expect(controller.playerState!.profile.level, isNot(99));
      expect(controller.playerState!.selectedStageIndex, 2);
      expect(controller.playerState!.quests.first.id, localState.quests.first.id);
      expect(controller.playerState!.inventory['freeze'], 2);
      expect(controller.playerState!.inventory['xp_boost'], 2);
      expect(controller.playerState!.inventory['reroll'], 3);
      expect(controller.playerState!.completedDays, 7);
      expect(controller.playerState!.totalCompletedQuests, 7);
      expect(controller.playerState!.unlockedShadowIds, contains('igris'));
      expect(controller.pendingUnlockedShadowId, 'igris');

      await controller.clearUnlockedShadowNotice();
      await controller.changeStage(2);

      expect(controller.pendingUnlockedShadowId, isNull);
      expect(controller.playerState!.lastUnlockedShadowId, isEmpty);
      expect(controller.playerState!.completedDays, 7);
      expect(controller.playerState!.unlockedShadowIds, contains('igris'));
    });
  });
}

HunterProfile stateProfileWithStreak7(HunterProfile profile) {
  return profile.copyWith(streakDays: 7);
}

class _MemoryPlayerStateRepository extends LocalPlayerStateRepository {
  PlayerState? state;

  @override
  Future<PlayerState?> load() async => state;

  @override
  Future<void> save(PlayerState state) async {
    this.state = state;
  }
}

class _FakeHomeApiClient extends HomeApiClient {
  _FakeHomeApiClient({required this.snapshot}) : super(baseUrl: 'https://example.com');

  final RemoteHomeSnapshot snapshot;

  @override
  Future<RemoteHomeSnapshot> fetchSnapshot() async => snapshot;

  @override
  Future<void> advanceQuest(String questId, {int amount = 1}) async {}

  @override
  void dispose() {}
}
