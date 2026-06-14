# Installing on a locked-down machine

The normal install (see README) is:

```
/plugin marketplace add cmanaha/extended-superpowers
/plugin install extended-superpowers@cmanaha
```

`superpowers` resolves automatically because this marketplace permits the
cross-marketplace dependency (`allowCrossMarketplaceDependenciesOn:
["claude-plugins-official"]`).

## If the marketplace add is blocked

Some managed environments set `strictKnownMarketplaces` in admin-controlled
settings, which can block adding external marketplaces. Options, in order:

1. **Ask the admin to allowlist** the `cmanaha/extended-superpowers` marketplace
   (and `claude-plugins-official` for the superpowers dependency).
2. **Local install:** `git clone` the repo, then
   `/plugin marketplace add ./extended-superpowers` (a local path) and install.
   Ensure `superpowers` is installed from `claude-plugins-official` first.
3. **Manual dependency:** if cross-marketplace resolution is restricted, install
   `superpowers@claude-plugins-official` explicitly before this plugin.

The plugin's phase-ordering (planning/environment-research before brainstorming)
is enforced by its own SessionStart hook and works as long as the plugin is
installed; the superpowers-delegated phases (brainstorming, writing-plans,
subagent-driven-development) require superpowers to be present.
