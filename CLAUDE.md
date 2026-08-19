# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Jeremy Stratton-Smith's personal site — resume/CV and blog — built with Jekyll and the [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme (forked from [chirpy-starter](https://github.com/cotes2020/chirpy-starter)), deployed to `jstrattonsmith.github.io` via a GitHub Actions workflow (not GitHub Pages' native Jekyll builder).

## Commands

The only prerequisite is [Nix](https://nixos.org/download) — `lclsite.nix` provides Ruby, Bundler, `bundix`, and all gems. See `README.md` for the full workflow; the essentials:

```sh
nix-shell lclsite.nix   # enter the dev shell (note: not default.nix/shell.nix, must be named explicitly)
./tools/run.sh          # serve at http://127.0.0.1:4000 with live reload
./tools/test.sh         # production build + htmlproofer (same checks CI runs)
```

After editing `Gemfile`, regenerate `gemset.nix` from inside `nix-shell lclsite.nix`: `bundle lock && bundix`, then exit and re-enter the shell.

There is no separate lint/test command beyond `./tools/test.sh` (build + `htmlproofer` link/image/script checks) — that's what CI runs too.

## Architecture

- **`lclsite.nix`** is the Nix dev shell (`bundlerEnv` from `Gemfile`/`Gemfile.lock`/`gemset.nix`). `Gemfile.lock` is gitignored — only `gemset.nix` is committed as the source of truth for the Nix build; CI generates its own lockfile via `bundler-cache: true`.
- **`_tabs/`** is a Jekyll collection (chirpy convention) holding sidebar nav pages (`about.md`, `cv.md`) — front matter uses `icon`/`order`, not chirpy-starter's more generic layout options. Top-level `.md` files or a `_pages/` directory are *not* picked up by chirpy.
- **`hide/_tabs/`** holds tabs that exist as content (`archives.md`, `categories.md`, `tags.md`) but are deliberately excluded from the live `_tabs/` collection, so they're not rendered in the sidebar nav yet.
- **`_posts/`** holds blog posts (`YYYY-MM-DD-title.md`). The `jekyll-compose` gem (in `Gemfile`) provides `bundle exec jekyll compose "Title"` for scaffolding new posts/drafts.
- **`_plugins/posts-lastmod-hook.rb`** is a custom Jekyll hook (not part of the chirpy gem) — check it before assuming all post-processing behavior comes from the theme.
- **`_data/contact.yml`**, **`_data/share.yml`** — site data files consumed by chirpy's includes.
- **`assets/lib`** is a git submodule (`chirpy-static-assets`) — must be initialized (`git submodule update --init --recursive`) before the site will build/render correctly; a fresh clone won't have it by default.
- **`index.html`** at the repo root is a required `layout: home` stub — chirpy's gem theme does not ship its own root `index.html` (unlike `_layouts`/`_includes`/`_sass`), so this file is what makes the home page (post listing) render at all.
- **`.devcontainer/`** provides an alternative to the Nix workflow — a container image with Ruby/Jekyll preinstalled, so inside it the `tools/` scripts can be run directly without `nix-shell`.
- **Deploy**: push to `main`. `.github/workflows/pages-deploy.yml` builds, runs `htmlproofer`, and deploys via `actions/deploy-pages` — this is a real CI/CD pipeline, not GitHub Pages' automatic Jekyll builder (which doesn't support Chirpy's plugin/theme requirements out of the box).
