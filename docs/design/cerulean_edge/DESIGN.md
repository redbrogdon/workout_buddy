---
name: Cerulean Edge
colors:
  surface: '#0e141b'
  surface-dim: '#0e141b'
  surface-bright: '#343942'
  surface-container-lowest: '#090e16'
  surface-container-low: '#171c24'
  surface-container: '#1b2028'
  surface-container-high: '#252a32'
  surface-container-highest: '#30353d'
  on-surface: '#dee2ed'
  on-surface-variant: '#bbc9cf'
  inverse-surface: '#dee2ed'
  inverse-on-surface: '#2b3139'
  outline: '#859399'
  outline-variant: '#3c494e'
  surface-tint: '#4cd6ff'
  primary: '#a4e6ff'
  on-primary: '#003543'
  primary-container: '#00d1ff'
  on-primary-container: '#00566a'
  inverse-primary: '#00677f'
  secondary: '#9ccaff'
  on-secondary: '#003256'
  secondary-container: '#005a95'
  on-secondary-container: '#a9d1ff'
  tertiary: '#cfddfb'
  on-tertiary: '#233148'
  tertiary-container: '#b3c1de'
  on-tertiary-container: '#414f68'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#b7eaff'
  primary-fixed-dim: '#4cd6ff'
  on-primary-fixed: '#001f28'
  on-primary-fixed-variant: '#004e60'
  secondary-fixed: '#d0e4ff'
  secondary-fixed-dim: '#9ccaff'
  on-secondary-fixed: '#001d35'
  on-secondary-fixed-variant: '#00497a'
  tertiary-fixed: '#d6e3ff'
  tertiary-fixed-dim: '#b9c7e4'
  on-tertiary-fixed: '#0d1c32'
  on-tertiary-fixed-variant: '#39475f'
  background: '#0e141b'
  on-background: '#dee2ed'
  surface-variant: '#30353d'
typography:
  headline-xl:
    fontFamily: Lexend
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Lexend
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Lexend
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Lexend
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Lexend
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Lexend
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Lexend
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Lexend
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Lexend
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
    letterSpacing: 0.08em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 48px
  xl: 80px
  gutter: 24px
  margin: 32px
---

## Brand & Style

This design system is engineered for high-performance environments where precision and focus are paramount. It targets a professional audience that demands the speed of an athletic interface combined with the stability of an enterprise tool. 

The visual style is a blend of **Minimalism** and **Glassmorphism**. By utilizing deep, layered backgrounds and translucent surfaces, the system achieves a sense of immense depth without clutter. The aesthetic is "Technical-Athletic"—it feels fast, responsive, and calibrated, moving away from loud highlights toward a more disciplined, monochromatic blue spectrum that emphasizes data and action.

## Colors

The palette is anchored in a "Deep Space" neutral black to ensure maximum contrast for the blue accents. 

- **Primary (Electric Blue):** Used sparingly for interactive elements, progress indicators, and critical data points. It provides the "high-performance" energy.
- **Secondary (Deep Cerulean):** The workhorse color for structural elements, active states, and secondary buttons. It grounds the UI in professionalism.
- **Tertiary (Navy Slate):** Used for subtle borders and background elevations to distinguish between content zones.
- **Background:** A rich, near-black blue that reduces eye strain and provides a premium, "pro" canvas.

## Typography

Lexend is utilized across all levels to leverage its hyper-legible, geometric structure. 

Headlines use tighter tracking and heavier weights to evoke a sense of urgency and power. Body text maintains standard spacing for readability in data-heavy views. Labels are frequently set in uppercase with increased letter-spacing to act as "instrumentation" markers, reinforcing the technical nature of this design system.

## Layout & Spacing

The system employs a **12-column fluid grid** designed for density and efficiency. A strict 8px rhythmic scale governs all padding and margins, ensuring a mathematical rigor to the layout.

Margins are generous on the outer edges to provide a "premium gallery" feel, while internal gutters remain tight (24px) to keep related data clusters visually connected. Use high-density spacing (sm/xs) for data tables and dashboard widgets, and low-density spacing (lg/xl) for landing pages and marketing modals.

## Elevation & Depth

Hierarchy is established through **Backdrop Blurs** and **Tonal Layering**. 

1.  **Base Layer:** The darkest neutral color, representing the deepest floor of the UI.
2.  **Surface Layer:** A slightly lighter navy with a 60% opacity backdrop blur, used for primary content containers.
3.  **Floating Layer:** Elements like modals or dropdowns use a subtle 1px border in Deep Cerulean and a soft, electric-blue outer glow (5% opacity) to simulate light emission from the "pro" hardware.

Shadows are rarely used; instead, depth is communicated through inner strokes and varying levels of transparency.

## Shapes

To maintain an "athletic" and "engineered" aesthetic, this design system uses a **Soft (0.25rem)** roundedness. 

Sharp enough to feel technical and precise, but soft enough to remain modern. Larger components like cards may scale up to `rounded-lg` (0.5rem) to soften the overall layout, but interactive components like buttons and inputs must remain at the base `rounded` level to preserve the high-performance feel.

## Components

- **Buttons:** Primary buttons feature a subtle vertical gradient from Deep Cerulean to Electric Blue with white text for maximum "pop." Secondary buttons are ghost-style with an Electric Blue border.
- **Chips:** Small, pill-shaped indicators with high-contrast background tints. Used for status (e.g., "Active," "Optimized").
- **Cards:** Semi-transparent containers with a 1px border. No shadows; they rely on backdrop-blur to separate from the background.
- **Inputs:** Darker than the surface layer with a focus state that triggers a 2px Electric Blue bottom-border and a subtle inner glow.
- **Lists:** Clean, separated by 1px Tonal Blue dividers. Hover states should utilize a subtle increase in surface brightness rather than a color change.
- **Data Visualizations:** Use the Electric Blue for primary trends and the Deep Cerulean for historical or secondary data.