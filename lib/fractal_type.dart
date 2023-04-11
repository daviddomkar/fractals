enum FractalType {
  mandelbulb('Mandelbulb', 0.0),
  mengerSponge('Menger Sponge', 1.0);

  final String name;
  final double value;

  const FractalType(this.name, this.value);
}
