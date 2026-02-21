# UI Component Patterns

These patterns apply to both LiveView (HEEx) components and Svelte components.

## Composition Over Props

Don't build monolithic components with props for every variation. Expose composable child components instead:

```html
<!-- Don't do this -->
<Input label="Price" description="Set your price" icon="dollar" icon-right="help" size="md" layout="horizontal" />

<!-- Do this -->
<Field>
  <Label>Price</Label>
  <Description>Set your price</Description>
  <InputGroup>
    <DollarIcon />
    <Input class="sm:max-w-32" />
    <HelpIcon />
  </InputGroup>
</Field>
```

More verbose, but the consumer controls layout, ordering, and responsive behavior — not the component.

## `data-slot` Attributes for Parent-Child Styling

Components self-identify their role with `data-slot`. Parents style children by slot, not by element:

```html
<label data-slot="label" ...>
<input data-slot="control" ...>
<select data-slot="control" ...>   <!-- same slot, different element -->
<p data-slot="description" ...>
<svg data-slot="icon" ...>
```

```css
[data-slot="control"] + [data-slot="description"] { margin-top: 0.5rem; }
```

This decouples parent from child implementation — `<select>` and `<input>` both work as `data-slot="control"`.

## CSS Grid for Input Groups (Icons)

Input with leading/trailing icons: use CSS grid with overlapping columns.

- 3-column grid: `grid-template-columns: var(--spacing-10) 1fr var(--spacing-10)`
- Input spans all 3 columns, row 1
- Icons placed in column 1 or 3, row 1 (overlapping the input)
- Sibling selectors add padding when icons are present
- Use `:has()` for forward-sibling targeting

## `class` as a Sharp Knife

Expose `class` on components for contextual/layout concerns only:

- Margins (never bake margins into components)
- Max-width, width constraints
- Responsive layout overrides
- **Not** for overriding internal styling

## `isolate` for Z-Index

Use `isolation: isolate` (Tailwind: `isolate`) to create stacking context sandboxes:

```html
<nav class="sticky z-10">...</nav>
<main class="isolate">
  <!-- z-index inside here is scoped, won't bleed above nav -->
</main>
```

Rarely need more than `z-0`, `z-1`, `z-10` when wrapping sections in `isolate`.

## `subgrid` for Cross-Component Alignment

When list items need aligned columns (e.g., optional icons + text in menus):

- Parent: `display: grid; grid-template-columns: auto 1fr;`
- Each child: `grid-template-columns: subgrid; grid-column: span 2;`
- Text label: `grid-column-start: 2` (always aligns to second column)

If no items have icons, the icon column collapses to zero width automatically.

## Responsive Touch Targets

Invisible hit area expansion on touch devices:

```html
<button class="relative">
  <span class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2
               size-[max(100%,44px)]
               [@media(pointer:fine)]:hidden"></span>
  <!-- visible content -->
</button>
```

- `max(100%, 44px)` ensures minimum 44x44px touch target
- `@media(pointer:fine)` hides it for mouse users — use pointer precision, not screen size

## CSS Custom Properties as Responsive Props

When a value needs to change at breakpoints, use CSS variables instead of component props:

```html
<!-- Props can't change responsively -->
<Table gutter="6" />

<!-- CSS variables can -->
<div class="[--gutter:var(--spacing-6)] sm:[--gutter:var(--spacing-10)]">
  <Table />
</div>
```

The component reads `var(--gutter)` internally. Also enables boolean-like behavior via `calc()` with 0/1 multiplication for things like conditional full-bleed layouts.
