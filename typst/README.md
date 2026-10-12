# Typst Presentations
 
Source files and build tools for the Typst-based presentations published by this repository.

## Project Layout

- `polylux/`: Polylux presentation projects.
- `touying/`: Touying presentation projects and the shared `theme/`.
- `util/`: Build scripts, the Touying Docker image, and the custom HTML template.
- `out/`: Generated PDF and HTML files. This directory is created by the build scripts.

Each presentation project contains a `main.typ` entry point. Touying projects use the shared `touying/theme/`; the build scripts create a `theme` symlink inside a project when needed.

## Build With Docker

Docker is the default, reproducible build path. It pulls the Typst image for standard Typst builds and creates a local `dockerfile-touying-exporter` image for Touying builds.

From this directory:

```bash
# Compile a Typst project to PDF.
./util/typst-to-pdf.sh polylux example

# Compile a Touying presentation to HTML and PDF.
./util/touying-to-pdf-and-html.sh theme-example
```

The scripts list available packages or project names when called with invalid arguments. Generated files are written to `out/`:

```text
out/polylux-example.pdf
out/touying-theme-example.html
out/touying-theme-example.pdf
```

Touying's Docker build also applies `util/template.html.j2` to the generated HTML without modifying the container image.

## Build Touying Locally

Use the local script when `typst` and `touying` are installed and available on your `PATH`:

```bash
./util/touying-to-pdf-and-html-without-docker.sh theme-example
```

The script generates the same HTML and PDF files in `out/`.

> Warning: before generating HTML, the local script copies `util/template.html.j2` over the installed Touying package's `template.html.j2`. The change is persistent and can be replaced by a Touying upgrade.

## Watch While Editing

With [watchexec](https://github.com/watchexec/watchexec) installed, rebuild a Touying presentation whenever its files change.

With docker:
```bash
watchexec --no-process-group ./util/touying-to-pdf-and-html.sh theme-example
```

With local touying and typst:
```bash
watchexec --no-process-group ./util/touying-to-pdf-and-html-without-docker.sh theme-example
```
> Warning: before generating HTML, the local script copies `util/template.html.j2` over the installed Touying package's `template.html.j2`. The change is persistent and can be replaced by a Touying upgrade.

## Docs

### Typst

- [Typst docs](https://typst.app/)
- [Typst architecture talk: https://2026.rustweek.org/talks/laurenz/](https://2026.rustweek.org/talks/laurenz/)

### Touying

- [Touying docs](https://touying-typ.github.io/docs/intro)
- [Touying Frequently Asked Questions](https://touying-typ.github.io/docs/faq)
- [Touying themes](https://touying-typ.github.io/docs/category/themes)
- [Touying examples and themes](https://github.com/touying-typ/touying/tree/main/examples)
