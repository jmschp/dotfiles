---
paths: ["**/*.rb", "**/*.rake", "**/*.erb", "**/Gemfile", "**/Gemfile.lock"]
---

# Ruby on Rails (personal defaults)

## Migrations

- Migrations change schema only. Backfills go in a separate, batched, resumable task. Type changes and destructive changes (drop, rename) ship as multi-deploy rollouts: stop using or add the column, backfill, then cut over.

## Associations

- Declare both sides of every association and set `inverse_of` on both, polymorphic included. Choose `dependent:` deliberately. Soft-delete gems still run destroy callbacks, so they are no reason to skip it.
- Group a model's associations by kind, each group its own block in this order: `belongs_to`, `delegated_type`, `has_one`, `has_many`. Alphabetical within each group; insert a new association in its place, not next to related code or at the end.

## Rake and loading

- Don't reference autoloaded constants at file-load time in files that rake tasks require; they load before autoloading.

## Parsing input

- No lenient shared parse helper with a nil-on-garbage contract. Per call site, check what the caller actually sends, then use the narrowest standard parser (`Date.iso8601` for ISO, `Date.parse` only for human-typed input), and prefer a 4xx with a message over returning `nil` or `[]`.
- A string assigned to a `date` or `datetime` column is parsed by the ActiveRecord cast, so controllers often need no parsing at all.
- Read required scalar params with `params.expect(:key)` (Rails 8), guarded by a `blank?` check when optional, so a non-scalar is a 400 rather than a `NoMethodError`.
- Before tightening a free-text field, look at what people actually paste into it, not only at its placeholder.

## RSpec

- Prefer request specs over controller specs.
- An unexpected `abort` in a rake-task spec raises `SystemExit`, which ends the run while RSpec still prints "N examples, 0 failures". For any example where the task must run through, wrap the call as `expect { expect { task.call }.not_to raise_error }.to(...)` (`raise_error` rescues `Exception`). After writing a guard spec, re-run it with the old code restored and confirm that it fails.
