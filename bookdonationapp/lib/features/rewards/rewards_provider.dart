import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../auth/auth_provider.dart';
import '../books/book_model.dart';
import '../books/book_provider.dart';

/// Total number of books donated by the current user.
///
/// Counts books from `booksStreamProvider` where `ownerId == currentUser.uid`.
final donationCountProvider = Provider<int>((ref) {
  final authState = ref.watch(authStateProvider);
  final booksAsync = ref.watch(booksStreamProvider);

  final uid = authState.value?.uid;
  if (uid == null) return 0;

  return booksAsync.maybeWhen(
    data: (books) =>
        books.where((Book book) => book.ownerId == uid).length,
    orElse: () => 0,
  );
});

/// Share of your listed books that reached `sold` status (0–100).
final donationSuccessRateProvider = Provider<int>((ref) {
  final authState = ref.watch(authStateProvider);
  final booksAsync = ref.watch(booksStreamProvider);
  final uid = authState.value?.uid;
  if (uid == null) return 0;

  return booksAsync.maybeWhen(
    data: (books) {
      final mine = books.where((Book b) => b.ownerId == uid).toList();
      if (mine.isEmpty) return 0;
      final sold = mine.where((b) => b.status == 'sold').length;
      return ((sold * 100) / mine.length).round().clamp(0, 100);
    },
    orElse: () => 0,
  );
});

/// Total number of requests made by the current user.
final requestCountProvider = Provider<int>((ref) {
  final authState = ref.watch(authStateProvider);
  final booksAsync = ref.watch(booksStreamProvider);

  final uid = authState.value?.uid;
  if (uid == null) return 0;

  return booksAsync.maybeWhen(
    data: (books) =>
        books.where((Book book) => book.requestedBy == uid).length,
    orElse: () => 0,
  );
});

/// Badge text based on total donations.
///
/// = 50 → "Eco Hero 🌍"
/// = 25 → "Legend 🔥"
/// = 10 → "Champion 🏆"
/// = 5  → "Contributor 🧑‍💼"
/// = 1  → "Beginner 📘"
/// else → "No Badge"
final badgeProvider = Provider<String>((ref) {
  final count = ref.watch(donationCountProvider);

  if (count == 50) return 'Eco Hero 🌍';
  if (count == 25) return 'Legend 🔥';
  if (count == 10) return 'Champion 🏆';
  if (count == 5) return 'Contributor 🧑‍💼';
  if (count == 1) return 'Beginner 📘';
  return 'No Badge';
});

class EcoImpact {
  final int treesSaved;
  final double co2SavedKg;
  final double paperSavedKg;

  const EcoImpact({
    required this.treesSaved,
    required this.co2SavedKg,
    required this.paperSavedKg,
  });
}

/// Eco impact derived from donation count.
///
/// Each donated book = 1 tree saved.
/// CO2 saved ≈ treesSaved * 21 kg.
/// Paper saved ≈ treesSaved * 10 kg.
final ecoImpactProvider = Provider<EcoImpact>((ref) {
  final donations = ref.watch(donationCountProvider);
  final trees = donations;
  final co2 = trees * 21.0;
  final paper = trees * 10.0;

  return EcoImpact(
    treesSaved: trees,
    co2SavedKg: co2,
    paperSavedKg: paper,
  );
});

/// Reward points derived from donation count.
/// Simple rule: each donation = 50 points.
final rewardPointsProvider = Provider<int>((ref) {
  final donations = ref.watch(donationCountProvider);
  return donations * 50;
});

DateTime _addCalendarMonths(DateTime anchor, int deltaMonths) {
  var y = anchor.year;
  var m = anchor.month + deltaMonths;
  while (m > 12) {
    m -= 12;
    y++;
  }
  while (m < 1) {
    m += 12;
    y--;
  }
  return DateTime(y, m, 1);
}

/// One bar in the eco tracker: donations you listed in that calendar month.
class EcoMonthBucket {
  final String label;
  final int count;

  const EcoMonthBucket({required this.label, required this.count});
}

/// Last 6 calendar months (including current), counts of your books by `createdAt`.
final ecoDonationsByMonthProvider = Provider<List<EcoMonthBucket>>((ref) {
  final authState = ref.watch(authStateProvider);
  final booksAsync = ref.watch(booksStreamProvider);
  final uid = authState.value?.uid;
  if (uid == null) return const [];

  return booksAsync.maybeWhen(
    data: (books) {
      final mine = books.where((Book b) => b.ownerId == uid);
      final byMonth = <String, int>{};
      for (final b in mine) {
        final d = b.createdAt;
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        byMonth[key] = (byMonth[key] ?? 0) + 1;
      }

      final now = DateTime.now();
      final anchor = DateTime(now.year, now.month, 1);
      final fmt = DateFormat.MMM();
      final out = <EcoMonthBucket>[];
      for (var i = -5; i <= 0; i++) {
        final dt = _addCalendarMonths(anchor, i);
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}';
        final count = byMonth[key] ?? 0;
        final label = dt.year == now.year
            ? fmt.format(dt)
            : '${fmt.format(dt)} ${dt.year}';
        out.add(EcoMonthBucket(label: label, count: count));
      }
      return out;
    },
    orElse: () => const [],
  );
});

