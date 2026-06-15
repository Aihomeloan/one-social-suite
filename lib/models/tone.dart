/// Writing tone presets for the composer. v1 caption transforms key off these.
enum Tone {
  casual('Casual'),
  clean('Clean'),
  professional('Professional'),
  hype('Hype');

  const Tone(this.label);
  final String label;
}
