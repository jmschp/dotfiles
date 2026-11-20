---
paths: ["**/*.vue", "**/nuxt.config.*", "**/*.spec.ts", "**/*.test.ts"]
---

# Vue / Nuxt (personal defaults)

- Don't fire un-awaited fetches at the top level of `<script setup>`; put them in `onMounted` or use the framework's data-fetching composable.
- In Nuxt tests, mock auto-imports with `mockNuxtImport`; `vi.stubGlobal` doesn't intercept them.
- After a fresh install (new worktree, `npm ci`), run `npx nuxt prepare` before vitest or vue-tsc; both extend the generated `.nuxt/tsconfig.json`.
