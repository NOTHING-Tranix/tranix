import 'package:flutter_test/flutter_test.dart';
import 'package:tranix_app/shared/models/models.dart';

import 'helpers.dart';

void main() {
  group('A-008 models parse contract fixtures', () {
    test('Me and AuthTokens', () async {
      final me = Me.fromJson(await fixtureJson('me.json') as Map<String, dynamic>);
      expect(me.role, Role.loadProvider);
      expect(me.verificationStatus, VerificationStatus.verified);
      expect(me.walletBalanceInr, 1250);
      final tokens = AuthTokens.fromJson(await fixtureJson('auth_tokens.json') as Map<String, dynamic>);
      expect(tokens.user.name, me.name);
    });

    test('PublicSettings', () async {
      final s = PublicSettings.fromJson(await fixtureJson('settings_public.json') as Map<String, dynamic>);
      expect(s.topupChips, [500, 1000, 2000]);
      expect(s.supportedLanguages, ['en', 'ta', 'hi']);
    });

    test('Paged<LoadSummary> and LoadDetail', () async {
      final page = Paged.fromJson(await fixtureJson('loads.json') as Map<String, dynamic>, LoadSummary.fromJson);
      expect(page.items.map((l) => l.status), [
        LoadStatus.traveling,
        LoadStatus.amountNegotiation,
        LoadStatus.notAccepted,
      ]);
      final d = LoadDetail.fromJson(await fixtureJson('load_detail.json') as Map<String, dynamic>);
      expect(d.driver!.truckNumber, 'TN 57 AB 1234');
      expect(d.timeline.last.status, LoadStatus.traveling);
      expect(d.revisions.single.status, RevisionStatus.confirmed);
      expect(d.payment!.status, PaymentStatus.pending);
    });

    test('Wallet, transactions, suggestions, notification summary', () async {
      expect(Wallet.fromJson(await fixtureJson('wallet.json') as Map<String, dynamic>).balanceInr, 1250);
      final txns = Paged.fromJson(
        await fixtureJson('wallet_transactions.json') as Map<String, dynamic>,
        WalletTransaction.fromJson,
      );
      expect(txns.items.first.type, TxnType.postingCharge);
      expect(txns.items.first.direction, TxnDirection.debit);
      final s = (await fixtureJson('driver_suggestions.json') as List)
          .map((e) => Suggestion.fromJson(e as Map<String, dynamic>))
          .single;
      expect(s.preferredByShipper, isTrue);
      final n = NotificationSummary.fromJson(
        await fixtureJson('notifications_summary.json') as Map<String, dynamic>,
      );
      expect(n.unreadByTab['TRIPS'], 2);
    });

    test('unknown enum values fall back instead of crashing', () {
      final me = Me.fromJson({
        'id': '1',
        'name': 'X',
        'mobile': '9876543210',
        'role': 'SPACE_PILOT',
        'verificationStatus': 'SOMETHING_NEW',
        'language': 'fr',
      });
      expect(me.role, Role.unknown);
      expect(me.verificationStatus, VerificationStatus.unknown);
      expect(me.language, Language.en);
    });

    test('LoadCreate serialises contract names', () {
      final t = DateTime.utc(2026, 11, 21);
      final json = LoadCreate(
        pickupWindowStart: t,
        pickupWindowEnd: t,
        pickup: const Place(lat: 10, lng: 78, address: 'A'),
        senderName: 'S',
        senderMobile: '9876543210',
        goodsType: 'Vegetables',
        quantity: 10,
        quantityUnit: QuantityUnit.crates,
        weightTonnes: 1.5,
        vehicleType: VehicleType.openBody,
        drop: const Place(lat: 13, lng: 80, address: 'B'),
        receiverName: 'R',
        receiverMobile: '9123456780',
        freightPaidBy: FreightPayer.receiver,
        amountInr: 9000,
        audience: LoadAudience.wishlistFirst,
      ).toJson();
      expect(json['vehicleType'], 'OPEN_BODY');
      expect(json['quantityUnit'], 'CRATES');
      expect(json['freightPaidBy'], 'RECEIVER');
      expect(json['audience'], 'WISHLIST_FIRST');
      expect((json['pickup'] as Map)['address'], 'A');
      expect(json.containsKey('postedForFarmerId'), isFalse);
    });
  });
}

