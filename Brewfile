# Brewfile — dev toolchain (local/CI) + runtime vendors (shipped in src/vendor/).
# `just install` runs brew bundle for everything, then copies the vendor section
# into src/vendor/ (gitignored, like node_modules).

# --- dev: local/CI only, never copied to src/vendor/ ---
brew "just"        # task runner — `just` exposes the project recipes
brew "cocogitto"   # `cog` — Conventional Commits lint + tag-sourced releases
brew "lefthook"    # git hooks manager (commit-msg → cog verify)
brew "shellcheck"  # shell static analysis
brew "shfmt"       # shell formatter
brew "shellspec"   # BDD test framework for shell
brew "mdbook"      # documentation site generator

# --- vendor: runtime CLI deps, copied to src/vendor/ ---
# Format: vendor-meta <formula> version=<ver> repo=<org/repo> [tag=...] [asset=...] [url=...] [bin=...]
# Placeholders: {formula} {version} {repo} {arch} {tag} {asset}
# vendor-meta jq version=1.8.2 repo=jqlang/jq
brew "jq"
