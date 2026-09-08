# public — Presentations & Examples

GitHub Pages site for Typst presentations and personal projects.

## My content

- 2024-02-26 — Mike Padberg — Under the Hood of Neural Networks — [html ](https://mdpadberg.github.io/public/touying-neuralnetwork.html) / [ pdf](https://mdpadberg.github.io/public/touying-neuralnetwork.pdf)
- [Dyslexia experience](https://mdpadberg.github.io/public/dyslexia.html) — how dyslexia feels for me

## Structure

```
├── typst/          # Source projects
│   ├── polylux/    # Polylux presentations
│   ├── touying/    # Touying presentations (example, theme, theme-example)
│   └── util/       # Build scripts & Docker image
├── www/            # Deployed site (GitHub Pages)
└── .github/        # CI workflows
```

## Building locally

```bash
./typst/util/touying-to-pdf-and-html.sh <project-name>
./typst/util/typst-to-pdf.sh <project-name>
```

A Docker image wraps `typst` + `touying` for reproducible builds.

## CI

Push to `main` triggers `build.yml` — builds all Typst projects and deploys `www/` to GitHub Pages.

## Examples
- [Polylux](https://github.com/vifon/polylux) presentation framework example - [pdf](https://mdpadberg.github.io/public/polylux-example.pdf)
- [Touying](https://github.com/touying/touying) presentation framework example - [html](https://mdpadberg.github.io/public/touying-example.html) / [pdf](https://mdpadberg.github.io/public/touying-example.pdf)
- Touying theme — my custom theme showcase — [html](https://mdpadberg.github.io/public/touying-theme-example.html) / [pdf](https://mdpadberg.github.io/public/touying-theme-example.pdf) 