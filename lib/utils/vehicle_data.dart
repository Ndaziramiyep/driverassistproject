class VehicleData {
  static const List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'Electric',
    'Hybrid',
    'LPG',
    'CNG',
  ];

  static const List<String> colors = [
    'White', 'Black', 'Silver', 'Grey', 'Blue', 'Red', 'Green',
    'Yellow', 'Orange', 'Brown', 'Beige', 'Gold', 'Purple', 'Pink', 'Other',
  ];

  static const List<String> serviceTypes = [
    'Oil Change',
    'Tire Rotation',
    'Brake Service',
    'Transmission Service',
    'Air Filter Replacement',
    'Spark Plug Replacement',
    'Battery Replacement',
    'Coolant Flush',
    'Wheel Alignment',
    'AC Service',
    'Engine Tune-Up',
    'Full Service',
    'Other',
  ];

  static const Map<String, List<String>> _makesAndModels = {
    'Toyota': ['Camry', 'Corolla', 'RAV4', 'Prius', 'Highlander', 'Tacoma', 'Land Cruiser', 'Yaris', 'Hilux', 'Fortuner'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Fit', 'HR-V', 'Passport', 'Ridgeline'],
    'Ford': ['F-150', 'Mustang', 'Explorer', 'Escape', 'Edge', 'Ranger', 'Bronco', 'Focus'],
    'BMW': ['3 Series', '5 Series', 'X3', 'X5', 'M3', 'M5', '7 Series', 'X1'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'GLE', 'A-Class', 'S-Class', 'CLA', 'GLA'],
    'Volkswagen': ['Golf', 'Passat', 'Tiguan', 'Polo', 'Jetta', 'Atlas', 'ID.4'],
    'Nissan': ['Altima', 'Sentra', 'Rogue', 'Murano', 'Pathfinder', 'Frontier', 'Titan'],
    'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Kona', 'Palisade', 'Ioniq'],
    'Kia': ['Optima', 'Sportage', 'Sorento', 'Soul', 'Seltos', 'Telluride'],
    'Chevrolet': ['Silverado', 'Malibu', 'Equinox', 'Traverse', 'Tahoe', 'Suburban', 'Colorado'],
    'Audi': ['A3', 'A4', 'A6', 'Q3', 'Q5', 'Q7', 'TT', 'R8'],
    'Subaru': ['Outback', 'Forester', 'Crosstrek', 'Impreza', 'Legacy', 'Ascent'],
    'Mazda': ['Mazda3', 'Mazda6', 'CX-3', 'CX-5', 'CX-9', 'MX-5 Miata'],
    'Lexus': ['ES', 'RX', 'NX', 'IS', 'GX', 'LS'],
    'Other': ['Other'],
  };

  static List<String> get allMakes => _makesAndModels.keys.toList();

  static List<String> getModelsForMake(String make) {
    return _makesAndModels[make] ?? ['Other'];
  }

  static List<int> get yearRange {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1969, (i) => currentYear - i);
  }
}
