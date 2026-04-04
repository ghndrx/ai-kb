---
title: Svelte 5 Best Practices (2025)
type: article
description: Comprehensive guide to Svelte 5 patterns, runes, and migration from Svelte 4
created: 2025-04-04
updated: 2025-04-04
tags:
  - svelte
  - svelte5
  - frontend
  - javascript
  - runes
  - migration
---

# Svelte 5 Best Practices (2025)

Svelte 5 represents a fundamental shift in how Svelte handles reactivity, introducing the "runes" system - explicit signal-based primitives that replace Svelte 4's compiler-detected reactivity. This guide covers current recommended patterns, new features, and migration guidance.

> **Note**: Svelte 5 still supports Svelte 4 syntax. You can mix components using both syntaxes. The migration script (`npx sv migrate svelte-5`) automates most conversions.

---

## 1. Reactivity Syntax (Runes)

### `$state` - Reactive State

Only use `$state` for variables that should be reactive - variables that trigger updates in `$effect`, `$derived`, or template expressions.

```svelte
<script>
  let count = $state(0);
  let user = $state({ name: 'Alice', age: 30 });
  let items = $state(['a', 'b', 'c']);
</script>

<button onclick={() => count++}>
  clicks: {count}
</button>
```

**Key Points:**
- Primitives are wrapped in `$state()` for reactivity
- Objects/arrays use `$state({...})` or `$state([...])` for deep reactivity (proxied)
- Use `$state.raw()` for large objects that are only reassigned (not mutated) - better performance

```svelte
<script>
  // Good: large API response only reassigned, not mutated
  let data = $state.raw(null);
  
  // Later...
  data = await fetchApi(); // reassignment only
</script>
```

### `$derived` - Computed Values

Use `$derived` for values computed from other state. Prefer this over `$effect` whenever possible.

```svelte
<script>
  let count = $state(0);
  let double = $derived(count * 2);
  
  // For complex computations, use $derived.by
  let items = $state([1, 2, 3, 4, 5]);
  let filtered = $derived.by(() => {
    return items.filter(x => x > 2);
  });
</script>

<p>Double: {double}</p>
```

**Key Points:**
- `$derived` takes an expression, not a function (use `$derived.by` for functions)
- Derived values are writable - you can assign to them
- Objects/arrays returned from `$derived` are NOT deeply reactive

### `$effect` - Side Effects

Use `$effect` sparingly - it's an escape hatch. Most reactive logic should use `$derived`.

```svelte
<script>
  let count = $state(0);
  
  // Only for side effects (DOM sync, external libraries, etc.)
  $effect(() => {
    console.log('Count changed:', count);
  });
  
  // For effects that need cleanup, return a cleanup function
  $effect(() => {
    const handler = () => console.log('click');
    window.addEventListener('click', handler);
    return () => window.removeEventListener('click', handler);
  });
</script>
```

**When to use `$effect`:**
- Syncing with external libraries (D3, etc.) - prefer `{@attach}` for DOM libraries
- Logging for debugging (prefer `$inspect` for this)
- Observing external state

**When to avoid `$effect`:**
- Computing derived values (use `$derived`)
- Updating state inside effects (causes unnecessary re-runs)

---

## 2. Props and Events

### `$props` - Component Props

```svelte
<script>
  let { 
    requiredProp, 
    optionalProp = 'default',
    bindableProp = $bindable()
  } = $props();
</script>
```

**Key Points:**
- Props must be explicitly declared with `$props()`
- Use `$bindable()` for two-way bindable props
- Use rest spread for remaining props: `let { foo, ...rest } = $props()`

### Event Handling

Svelte 5 uses standard HTML attributes for events (no more `on:` prefix):

```svelte
<script>
  let count = $state(0);
  
  function handleClick() {
    count++;
  }
</script>

<button onclick={handleClick}>clicks: {count}</button>

<!-- Also works with inline handlers -->
<button onclick={() => count++}>click</button>
```

**Key Points:**
- `onclick` (lowercase) replaces `on:click`
- Event modifiers (`|preventDefault`, `|stopPropagation`) are deprecated - implement in handler instead
- Multiple handlers on same event must be combined: `onclick={(e) => { one(e); two(e); }}`

### Component Events (Callback Props)

Svelte 5 deprecates `createEventDispatcher` in favor of callback props:

```svelte
<!-- Child.svelte -->
<script>
  let { onIncrement } = $props();
</script>

<button onclick={() => onIncrement?.(5)}>+5</button>

<!-- Parent.svelte -->
<script>
  import Child from './Child.svelte';
  let total = $state(0);
</script>

<Child onIncrement={(val) => total += val} />
<p>Total: {total}</p>
```

---

## 3. Snippets (Replacing Slots)

Snippets are more powerful than slots and use a function-like syntax:

```svelte
<!-- Child.svelte -->
<script>
  let { header, children } = $props();
</script>

<div class="card">
  {#if header}
    <header>{@render header()}</header>
  {/if}
  <div class="content">
    {@render children?.()}
  </div>
</div>

<!-- Parent.svelte -->
<script>
  import Child from './Child.svelte';
</script>

<Child>
  {#snippet header()}
    <h2>My Card Title</h2>
  {/snippet}
  
  <p>Content goes here!</p>
</Child>
```

**Key Points:**
- Default content becomes `children` prop
- Use `{@render snippetName()}` to render snippets
- Snippets can accept parameters and return values
- Snippets declared at component top level can be referenced in `<script>`

---

## 4. Stores vs Runes

### When to Use Stores

Stores are NOT deprecated. Use them for:
- Truly global state shared across many components
- SSR-safe global state (via context in root layout)
- Integration with existing store-based libraries

### Runes for Global State

For module-level state, use the function/closure pattern:

```typescript
// counter.svelte.js
let count = $state(0);

export function getCount() {
  return count;
}

export function setCount(value) {
  count = value;
}
```

Or use a class pattern for better performance:

```typescript
// counter.svelte.js
class Counter {
  value = $state(0);
}

export const counter = new Counter();
```

**Usage:**
```svelte
<script>
  import { counter } from './counter.svelte.js';
</script>

<button onclick={() => counter.value++}>
  {counter.value}
</button>
```

---

## 5. Migration from Svelte 4

### Automatic Migration

Run the migration script:
```bash
npx sv migrate svelte-5
```

This converts:
- `let x` → `let x = $state(...)`
- `$: const y = ...` → `let y = $derived(...)`
- `on:click` → `onclick`
- `<slot />` → `{@render children()}`
- `export let` → `$props()`

### Manual Changes Required

1. **`createEventDispatcher`** - Convert to callback props
2. **`beforeUpdate`/`afterUpdate`** - Use `$effect.pre` + `tick()`
3. **Component instantiation** - Use `mount()` instead of `new Component()`

### Breaking Changes to Note

- Components are functions, not classes
- `<svelte:component>` replaced with dot notation: `<Component />`
- `$state` only wraps top-level variables
- Classes are no longer auto-reactive - use `$state` fields
- Bindings require `$bindable()` - not automatic

---

## 6. Deprecated Patterns to Avoid

| Old Pattern | New Pattern |
|------------|-------------|
| `on:click` | `onclick` |
| `export let` | `$props()` |
| `$: x = ...` | `$derived(...)` |
| `<slot />` | `{@render children()}` |
| `createEventDispatcher` | callback props |
| `<svelte:component>` | `<Component />` |
| `use:action` | `{@attach ...}` |
| `class:` directive | clsx-style arrays in `class` |

---

## 7. Best Practices Summary

1. **Use runes for all new code** - Avoid legacy reactive statements
2. **Prefer `$derived` over `$effect`** - Only use effects for side effects
3. **Use `$state.raw` for large read-only objects** - Better performance
4. **Use keyed each blocks** - Always provide unique key, never index
5. **Use CSS custom properties** for child component styling
6. **Use context instead of shared modules** - Safer for SSR
7. **Avoid legacy features** - They add complexity and will be removed
8. **Use `$bindable()` for two-way binding props**
9. **Use `{@attach}` instead of actions for DOM libraries**

---

## 8. References

- [Svelte Docs - Best Practices](https://svelte.dev/docs/svelte/best-practices)
- [Svelte Docs - Migration Guide](https://svelte.dev/docs/svelte/v5-migration-guide)
- [Svelte Blog - Introducing Runes](https://svelte.dev/blog/runes)
- [Mainmatter - Runes and Global State](https://mainmatter.com/blog/2025/03/11/global-state-in-svelte-5/)