class MdmRecord {
  final String date; // YYYY-MM-DD
  final int primaryPresent; // Class 1-5 count
  final int upperPrimaryPresent; // Class 6-8 count
  final double riceGrams;
  final double dalGrams;
  final double oilGrams;
  final int eggsOrBananas;
  final String menuServed;
  final bool isSubmittedOnline;
  final bool isSmsTriggered;

  MdmRecord({
    required this.date,
    required this.primaryPresent,
    required this.upperPrimaryPresent,
    required this.riceGrams,
    required this.dalGrams,
    required this.oilGrams,
    required this.eggsOrBananas,
    required this.menuServed,
    this.isSubmittedOnline = false,
    this.isSmsTriggered = false,
  });

  int get totalStudentsServed => primaryPresent + upperPrimaryPresent;
  int get eggsFruitCount => eggsOrBananas;

  // Auto-calculated official PM-POSHAN consumption norms
  static MdmRecord calculateForDay({
    required String date,
    required int primaryCount,
    required int upperPrimaryCount,
    required String menu,
    int eggsFruitCount = 0,
  }) {
    // Primary: 100g Rice, 20g Pulses/Dal, 5g Cooking Oil
    // Upper Primary: 150g Rice, 30g Pulses/Dal, 7.5g Cooking Oil
    final double totalRice = (primaryCount * 100.0) + (upperPrimaryCount * 150.0);
    final double totalDal = (primaryCount * 20.0) + (upperPrimaryCount * 30.0);
    final double totalOil = (primaryCount * 5.0) + (upperPrimaryCount * 7.5);

    return MdmRecord(
      date: date,
      primaryPresent: primaryCount,
      upperPrimaryPresent: upperPrimaryCount,
      riceGrams: totalRice,
      dalGrams: totalDal,
      oilGrams: totalOil,
      eggsOrBananas: eggsFruitCount,
      menuServed: menu,
      isSubmittedOnline: true,
      isSmsTriggered: true,
    );
  }

  // Official encoded SMS format for 15544
  String toSmsMessage(String schoolUdiseCode) {
    return 'MDM $schoolUdiseCode $totalStudentsServed';
  }
}
