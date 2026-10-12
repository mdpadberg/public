#import "@preview/touying:0.7.4": *
#import themes.simple: *
#import "@preview/iconify:0.5.3": icon, provide-icons
#import "@preview/tiaoma:0.3.0": qrcode

#show: simple-theme.with(
  aspect-ratio: "16-9",
  header: none,
  title: "Under The Hood of Neural Networks",
  footer: "2024-02-26 - Mike Padberg",
  primary: rgb("#1a1a1a"),
  config-page(
    fill: rgb("#1a1a1a"),
    header: none,
    margin: (top: 1.5em, rest: 2em)
  ),
  config-methods(
      init: (self: none, body) => {
        set text(size: 22pt, fill: rgb("#ffffff"), font: "Roboto", weight: "regular")
        show footnote.entry: set text(size: .6em)
        show heading.where(level: 1): set text(1.4em)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
  subslide-preamble: block(
      below: 1em,
    )[
      #stack(
        dir: ttb,
        spacing: 0.40em,
        text(1.2em, weight: "bold", utils.display-current-heading(level: 2)),
        stack(
          dir: ltr,
          spacing: 0.15em,
          circle(radius: 0.15em, fill: rgb("#FF605C")),
          circle(radius: 0.15em, fill: rgb("#FFBD44")),
          circle(radius: 0.15em, fill: rgb("#00CA4E")),
        )
      )
    ],
)

#title-slide[
  = Run LLMs Locally: The Complete Local Setup Guide
  #v(1em)
  2026-10-29 - Mike padberg
]

== Topics
- ...
- ...
- ...

== Theory
#utils.fit-to-height(1fr)[
  A large #text(fill: rgb("#FF605C"), "language model (LLM)") is an AI model (typically a #text(fill: rgb("#FFBD44"), "neural network")) trained on a vast amount of text for natural language processing tasks, especially language generation. LLMs can typically generate, summarize, translate, and analyze text in many contexts. They are the basis for many modern chatbots, such as #text(fill: rgb("#00CA4E"), "ChatGPT, Claude, Gemini, Grok, and DeepSeek").

  LLMs are typically based on transformer architecture. Generative pre-trained transformers (GPTs) are a type of LLM that is pre-trained to predict the next word. GPTs are then often fine-tuned to follow instructions and to behave as assistants.

  Biased or inaccurate training data can make an LLM's output less reliable. #text(fill: rgb("#FF605C"), "A software harness") can provide LLMs with memory and access to #text(fill: rgb("#FFBD44"), "tools such as web search.") 
  #footnote[Source: https://en.wikipedia.org/wiki/Large_language_model]
  #v(0.5em)
  #text(size: 0.5em, style: "italic", "Highlighted words will be explained in this presentation")
]

== Shameless plug: neural network
#align(
    center + horizon
)[
  I previously gave a presentation on neural networks and \ 
  how they work under the hood \
  #v(1em)
  #text(size: .4em, "Presentation:") \
  #link("https://mdpadberg.github.io/public/touying-neuralnetwork.html")[#text(size: .4em, "https://mdpadberg.github.io/public/touying-neuralnetwork.html")] \
  #text(size: .4em, "QR code:")
  #v(-0.6em)
  #qrcode("https://mdpadberg.github.io/public/touying-neuralnetwork.html", options: (
    bg-color: rgb("#1a1a1a"),
    fg-color: rgb("#ffffff")
  ))
]

== Language models
