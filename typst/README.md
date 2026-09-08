# Typst

## Typst
- [Typst docs](https://typst.app/)
- [Typst architecture talk: https://2026.rustweek.org/talks/laurenz/](https://2026.rustweek.org/talks/laurenz/)

## Touying
- [Touying docs](https://touying-typ.github.io/docs/intro)
- [Touying Frequently Asked Questions](https://touying-typ.github.io/docs/faq)
- [Touying themes](https://touying-typ.github.io/docs/category/themes)
- [Touying examples and themes](https://github.com/touying-typ/touying/tree/main/examples)

## Quick Start

```bash
# Compile typst project to pdf
./util/typst-to-pdf.sh diatypst example
./util/typst-to-pdf.sh polylux example

# Only for touying presentations
./util/touying-to-pdf-and-html.sh theme-example

# To compile and run changes while editing
watchexec --no-process-group ./util/touying-to-pdf-and-html.sh theme-example
```
