import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Ads stay unavailable until consent and a real unit ID are configured.
enum RewardedAdState { unavailable, idle, loading, ready, showing, earned, dismissed, failed }

abstract class RewardedAdService {
  RewardedAdState get state;
  Future<bool> load();
  Future<bool> showForExplicitTap();
  void dispose();
}

class UnavailableRewardedAdService implements RewardedAdService {
  @override
  RewardedAdState get state => RewardedAdState.unavailable;
  @override
  Future<bool> load() async => false;
  @override
  Future<bool> showForExplicitTap() async => false;
  @override
  void dispose() {}
}

/// Production wiring is intentionally not selected without app/ad unit IDs
/// and a tested UMP consent flow. This adapter owns the SDK object when enabled.
class GoogleRewardedAdService implements RewardedAdService {
  GoogleRewardedAdService({required this.adUnitId, required this.onEarned});
  final String adUnitId;
  final Future<void> Function(String adAttemptId) onEarned;
  RewardedAd? _ad;
  RewardedAdState _state = RewardedAdState.idle;
  String? _attemptId;

  @override
  RewardedAdState get state => _state;

  @override
  Future<bool> load() async {
    if (_state == RewardedAdState.loading || _state == RewardedAdState.showing) return false;
    _state = RewardedAdState.loading;
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) { _ad = ad; _state = RewardedAdState.ready; },
        onAdFailedToLoad: (_) { _state = RewardedAdState.failed; },
      ),
    );
    return _state == RewardedAdState.ready;
  }

  @override
  Future<bool> showForExplicitTap() async {
    final ad = _ad;
    if (ad == null || _state != RewardedAdState.ready) return false;
    _attemptId = DateTime.now().microsecondsSinceEpoch.toString();
    _state = RewardedAdState.showing;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _ad = null; if (_state != RewardedAdState.earned) _state = RewardedAdState.dismissed; },
      onAdFailedToShowFullScreenContent: (ad, _) { ad.dispose(); _ad = null; _state = RewardedAdState.failed; },
    );
    ad.show(onUserEarnedReward: (_, _) async {
      final attempt = _attemptId;
      if (attempt == null || _state == RewardedAdState.earned) return;
      _state = RewardedAdState.earned;
      await onEarned(attempt);
    });
    return true;
  }

  @override
  void dispose() { _ad?.dispose(); _ad = null; }
}

abstract class PurchaseService {
  Stream<List<PurchaseDetails>> get purchases;
  Future<bool> isAvailable();
  Future<void> buyStudioPack();
  Future<void> restore();
}

class UnavailablePurchaseService implements PurchaseService {
  @override
  Stream<List<PurchaseDetails>> get purchases => const Stream.empty();
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<void> buyStudioPack() => Future.error(StateError('Billing belum dikonfigurasi.'));
  @override
  Future<void> restore() => Future.value();
}
