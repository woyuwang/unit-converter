class Unit {
  String name;
  String symbol;
  double factoredOffset;
  double factor;
  double offset;

  Unit(this.name, this.symbol, this.factoredOffset, this.factor, this.offset);

  static double convertToSI(Unit unit, double value) {
    if(value == null) value = 0;
    return (value - unit.offset) * unit.factor - unit.factoredOffset;
  }

  static double convertFromSI(Unit unit, double value) {
    if(value == null) value = 0;
    return (value + unit.factoredOffset) / unit.factor + unit.offset;
  }

  static double convert(Unit from, Unit to, double value) {
    return convertFromSI(to, convertToSI(from, value));
  }
}