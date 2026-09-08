#import "@preview/touying:0.7.4": *
#import themes.simple: *

#show: simple-theme.with(
  aspect-ratio: "16-9",
  header: none,
  footer: "2026-08-19 - Mike Padberg",
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
          circle(radius: 0.15em, fill: rgb("#ff0000")),
          circle(radius: 0.15em, fill: rgb("#fff400")),
          circle(radius: 0.15em, fill: rgb("#00c2ff")),
        )
      )
    ],
)

#title-slide[
  = Typst presentation template for touying
  #v(1em)
  2026-08-19 - Mike padberg
]

== Topics
- Theory
- Topic 1
- Topic 2
- Topic 3

== First slide
- #lorem(20)
- #lorem(20) #footnote[Source: https://example.nl/by-sidn/]
#speaker-note[
  + Hello
  + My notes
]

== Second slide with code
#utils.fit-to-height(1fr)[
```rust
  fn main() {
      let number = 13;
      println!("Tell me about {}", number);
      match number {
          1 => println!("One!"),
          2 | 3 | 5 | 7 | 11 => println!("This is a prime"),
          13..=19 => println!("A teen"),
          _ => println!("Ain't special"),
      }

      let boolean = true;
      let binary = match boolean {
          false => 0,
          true => 1,
      };

      println!("{} -> {}", boolean, binary);
  }
```
]

== Third slide with picture
#align(
  center + horizon
)[
  #utils.fit-to-height(1fr)[
    #image("./pexels-marek-prasil-479620-39144146.jpg", height: auto, width: auto)
  ]
]

== Dynamic slide

Did you know that...

#pause

...you can see the current section at the top of the slide?

#centered-slide[
  == Centered slide
  #lorem(20)
]

= new-section-slide!

#focus-slide[
  _Focus!_

  This is very important.
]

