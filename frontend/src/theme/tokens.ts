// Menoo design tokens - derived from /app/design_guidelines.json
export const colors = {
  surface: '#FAF9F6',
  onSurface: '#13261C',
  surfaceSecondary: '#FFFFFF',
  onSurfaceSecondary: '#13261C',
  surfaceTertiary: '#F0EFEB',
  onSurfaceTertiary: '#2C4035',
  surfaceInverse: '#19533B',
  onSurfaceInverse: '#FAF9F6',
  brand: '#19533B',
  brandPrimary: '#19533B',
  onBrandPrimary: '#FFFFFF',
  brandSecondary: '#A3CBAF',
  onBrandSecondary: '#0E3222',
  brandSecondaryMuted: '#D8ECDE',
  brandTertiary: '#D4AF37',
  onBrandTertiary: '#4A3A00',
  brandTertiaryMuted: '#F5E9C2',
  success: '#7DB88E',
  onSuccess: '#FFFFFF',
  warning: '#E0B647',
  onWarning: '#FFFFFF',
  error: '#CC5A47',
  onError: '#FFFFFF',
  border: '#E8E6E1',
  borderStrong: '#D1CFC9',
  divider: '#E8E6E1',
  muted: '#6B7A70',
};

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 32,
  xxxl: 48,
};

export const radius = {
  sm: 8,
  md: 16,
  lg: 24,
  pill: 999,
};

export const shadow = {
  soft: {
    shadowColor: '#0E3222',
    shadowOpacity: 0.06,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: 4 },
    elevation: 2,
  },
  card: {
    shadowColor: '#0E3222',
    shadowOpacity: 0.08,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 6 },
    elevation: 3,
  },
};

export const typography = {
  display: { fontSize: 28, fontWeight: '700' as const, letterSpacing: -0.5 },
  h1: { fontSize: 24, fontWeight: '700' as const, letterSpacing: -0.3 },
  h2: { fontSize: 20, fontWeight: '700' as const },
  h3: { fontSize: 18, fontWeight: '600' as const },
  body: { fontSize: 16, fontWeight: '400' as const },
  bodyMd: { fontSize: 16, fontWeight: '500' as const },
  small: { fontSize: 14, fontWeight: '400' as const },
  caption: { fontSize: 12, fontWeight: '500' as const, letterSpacing: 0.3 },
};
