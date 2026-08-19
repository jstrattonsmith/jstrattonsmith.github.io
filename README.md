# jstrattonsmith.github.io

Jeremy Stratton-Smith's personal site — resume/CV and blog, built with [Jekyll](https://jekyllrb.com/) and the [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme (forked from [chirpy-starter](https://github.com/cotes2020/chirpy-starter)), deployed via GitHub Pages.

## Prerequisites

Just [Nix](https://nixos.org/download) — `lclsite.nix` provides Ruby, Bundler, `bundix`, and all gems, so there's nothing else to install.

## Local development

Enter the dev shell (note the explicit filename — this project's Nix file isn't named `default.nix`/`shell.nix`, so `nix-shell` needs to be pointed at it):

```sh
nix-shell lclsite.nix
```

The first run will build/fetch the Ruby environment, which can take a few minutes; after that it's fast. From inside the shell:

```sh
./tools/run.sh    # serve at http://127.0.0.1:4000 with live reload
./tools/test.sh   # production build + htmlproofer (same checks CI runs)
```

These match the "Run Jekyll Server" and "Build Jekyll Site" tasks in `.vscode/tasks.json`. `./tools/run.sh --production` builds/serves in production mode; `./tools/run.sh --host <host>` binds to a different host.

If you're working inside the devcontainer instead (`.devcontainer/`), Ruby/Jekyll are already on `PATH` there and you can skip `nix-shell` entirely — just run the `tools/` scripts directly.

## Adding a post

Posts live in `_posts/`, named `YYYY-MM-DD-title.md`. Easiest way, from inside `nix-shell lclsite.nix` (the `jekyll-compose` plugin is already in the `Gemfile`):

```sh
bundle exec jekyll compose "My Post Title"          # creates _posts/YYYY-MM-DD-my-post-title.md
bundle exec jekyll compose "My Draft" --draft       # creates it in _drafts/ instead
```

Or create the file by hand:

```markdown
---
title: My Post Title
date: 2026-08-19 12:00:00 -0400
categories: [Category, Subcategory]
tags: [tag1, tag2]
---

Post content goes here, in Markdown.
```

Preview drafts with `bundle exec jekyll s -l --drafts` (or `./tools/run.sh` won't include them by default — pass `--drafts` if you edit the command).

## Adding a new page (tab)

Top-level nav pages (like "About" and "CV") live in `_tabs/` as a Jekyll collection:

```markdown
---
title: My New Page
icon: fas fa-star   # any Font Awesome icon class
order: 6            # controls position in the sidebar nav
---

Page content goes here.
```

Save it as `_tabs/my-new-page.md`; it'll be served at `/my-new-page/` and appear in the sidebar automatically.

If a tab should exist but not show in the nav yet (see `hide/_tabs/archives.md`, `categories.md`, `tags.md` for the existing examples), keep it under `hide/_tabs/` instead — files there aren't part of the live `_tabs/` collection.

## Updating gems / dependencies

`gemset.nix` is a generated file (via `bundix`) and must stay in sync with `Gemfile`. `Gemfile.lock` is intentionally gitignored — it's regenerated locally and by CI (`bundler-cache: true` in the deploy workflow), only `gemset.nix` is the committed source of truth for the Nix build. After editing `Gemfile`:

```sh
nix-shell lclsite.nix
bundle lock && bundix
exit
nix-shell lclsite.nix   # re-enter so the shell picks up the regenerated gemset.nix
```

Skipping the `bundix` step, or forgetting to exit and re-enter the shell afterwards, is the most common way this breaks (`bundle exec` will refuse to run because the lockfile no longer matches the Gemfile).

## Deploying

Just push to `main`. `.github/workflows/pages-deploy.yml` builds the site, runs `htmlproofer` as a test step, and deploys via `actions/deploy-pages` — no manual build/push of `_site/` needed, and this does **not** rely on GitHub Pages' native Jekyll builder (which wouldn't support Chirpy out of the box).

## License

This work is published under the [MIT License](LICENSE), inherited from [chirpy-starter][chirpy-starter].

[chirpy-starter]: https://github.com/cotes2020/chirpy-starter
