#import "@preview/touying:0.7.4": *
#import themes.simple: *
#import "@preview/iconify:0.5.3": icon, provide-icons
#import "@preview/tiaoma:0.3.0": qrcode

// ---------- shared helpers ----------
#let pill(t) = rect(
  width: 100%, inset: (y: 9pt, x: 12pt), radius: 6pt, stroke: 0.75pt + rgb("#ffffff"),
)[#align(center)[#text(weight: "medium")[#t]]]

#let bars(items, max-val, width: 15cm, label-w: 6.2cm) = {
  grid(
    columns: (label-w, 1fr), row-gutter: 9pt, column-gutter: 10pt, align: (right + horizon, left + horizon),
    ..items.map(it => (
      text(size: 13pt)[#it.at(0)],
      stack(dir: ltr, spacing: 8pt,
        rect(width: calc.max(0.15cm, width * it.at(1) / max-val), height: 0.7cm, fill: it.at(2), stroke: none),
        text(size: 13pt, weight: "bold")[#it.at(3)],
      ),
    )).flatten()
  )
}

// Badge next to a name, centred on the cap height of the name, whatever the name's size.
// tint: also colour the name in the badge colour
#let tagged(color, label, name, tint: true) = context {
  let badge = box(inset: (x: 6pt, y: 3.5pt), radius: 4pt, fill: color, text(
    size: 10pt, weight: "bold", fill: rgb("#1a1a1a"),
    top-edge: "cap-height", bottom-edge: "baseline",
  )[#label])
  let cap = measure(text(top-edge: "cap-height", bottom-edge: "baseline", name)).height
  let badge-h = measure(badge).height
  [#if tint { text(fill: color, name) } else { name }#h(10pt)#box(baseline: (badge-h - cap) / 2 - 3.5pt, badge)]
}
#let picked(color, name) = tagged(color, [MY PICK], name)

// ---------- comparison tables ----------
#let good = rgb("#00CA4E")
#let okay = rgb("#FFBD44")
#let bad = rgb("#FF605C")
// Coloured dot with a short verdict, and an optional grey note underneath
#let rate(color, body, note: none) = {
  grid(
    columns: (auto, 1fr), column-gutter: 8pt, row-gutter: 4pt, align: horizon,
    circle(radius: 0.22em, fill: color), text(weight: "medium")[#body],
    [], if note != none { text(size: 11pt, fill: gray, note) },
  )
}
#let criterion(name, meaning) = [
  #text(weight: "bold")[#name] \
  #text(size: 11pt, fill: gray)[#meaning]
]
// Column header of a comparison table
#let contender(name) = text(weight: "bold", size: 20pt, name)

#let card(title, body, stroke: rgb("#ffffff")) = rect(
  width: 100%, height: 100%, inset: 16pt, radius: 8pt, stroke: 0.75pt + stroke,
)[
  #text(weight: "bold", size: 19pt)[#title]
  #v(6pt)
  #text(size: 14.5pt)[#body]
]

#let thousands(n) = {
  let s = str(n)
  let len = s.len()
  let out = ""
  for (i, ch) in s.clusters().enumerate() {
    if i > 0 and calc.rem(len - i, 3) == 0 { out += "," }
    out += ch
  }
  out
}

// #usd(8.0712)                                   // $8.07
// #usd(8.0712, digits: 4)                        // $8.0712
// #usd(1234.5678)                                // $1,235
// #usd(1234.5678, whole-from: none)              // $1,234.57
// #usd(1234.5678, digits: 3, whole-from: none)   // $1,234.568
// #usd(147.4, digits: 0)                         // $147
#let usd(x, digits: 2, whole-from: 100) = {
  let scale = calc.pow(10, digits)
  let c = int(calc.round(x * scale))
  if digits == 0 or (whole-from != none and c >= whole-from * scale) {
    "$" + thousands(int(calc.round(x)))
  } else {
    let frac = str(calc.rem(c, scale))
    "$" + thousands(calc.quo(c, scale)) + "." + "0" * (digits - frac.len()) + frac
  }
}
// Colour per part of the model name. Explained parts get their colour, the rest is gray.
#let term-colors = (
  "unsloth": rgb("#FF605C"),
  "Qwen3.6": rgb("#FFBD44"),
  "35B": rgb("#00CA4E"),
  "A3B": rgb("#FF605C"),
  "MTP": rgb("#FFBD44"),
  "GGUF": rgb("#00CA4E"),
)

// #model-name("A3B")             // only A3B in colour
// #model-name("unsloth", "35B")  // unsloth and 35B in colour
#let model-name(..explained) = {
  let parts = ("unsloth", "/", "Qwen3.6", "-", "35B", "-", "A3B", "-", "MTP", "-", "GGUF")
  let fill(p) = if p in explained.pos() { term-colors.at(p) } else { gray }
  text(size: 30pt, weight: "bold", parts.map(p => text(fill: fill(p), p)).join())
}

// Term in its colour next to its explanation, one row per term.
#let model-terms(..rows) = grid(
  columns: (auto, auto),
  column-gutter: 1em,
  row-gutter: 0.75em,
  align: (right, left),
  ..rows.pos().map(((term, body)) => (text(weight: "bold", fill: term-colors.at(term), term), body)).flatten()
)

// Small neural network with one weight written on some connections.
// weights: ((from-layer, from-node, to-node, label), ...)
#let network(weights, color) = {
  let w = 8.5cm
  let h = 5.6cm
  let r = 0.42cm
  let layers = (4, 3, 1)
  let pos(l, n) = {
    let x = r + l * (w - 2 * r) / (layers.len() - 1)
    let count = layers.at(l)
    let y = h / 2 + (n - (count - 1) / 2) * 1.35cm
    (x, y)
  }
  box(width: w, height: h, {
    for l in range(layers.len() - 1) {
      for a in range(layers.at(l)) {
        for b in range(layers.at(l + 1)) {
          let (x1, y1) = pos(l, a)
          let (x2, y2) = pos(l + 1, b)
          place(line(start: (x1, y1), end: (x2, y2), stroke: 0.6pt + gray.darken(30%)))
        }
      }
    }
    for (l, a, b, label) in weights {
      let (x1, y1) = pos(l, a)
      let (x2, y2) = pos(l + 1, b)
      place(line(start: (x1, y1), end: (x2, y2), stroke: 1.4pt + color))
      // Label centred on the middle of the connection
      place(
        center + horizon,
        dx: (x1 + x2) / 2 - w / 2, dy: (y1 + y2) / 2 - h / 2,
        box(fill: rgb("#1a1a1a"), inset: 3pt, text(size: 14pt, weight: "bold", fill: color, label)),
      )
    }
    for l in range(layers.len()) {
      for n in range(layers.at(l)) {
        let (x, y) = pos(l, n)
        place(dx: x - r, dy: y - r, circle(radius: r, fill: gray))
      }
    }
  })
}

#let coloured-step(n, color, title, note: none) = text(weight: "bold", size: 16pt)[
  #text(fill: color)[#n] #title
  #if note != none { h(6pt); text(weight: "regular", size: 12pt, fill: gray, note) }
]

#let code-box(size, body) = rect(width: 100%, inset: 8pt, radius: 6pt, stroke: 0.75pt + gray, text(size: size, body))

#let pdf = sys.inputs.at("mode", default: "web") == "pdf"

#let story-step(n) = image(
  "images/" + str(n) + if pdf { ".png" } else { ".gif" }
)
// ---------- shared helpers ----------

#show: simple-theme.with(
  aspect-ratio: "16-9",
  header: none,
  title: "Run LLMs Locally: The Complete Local Setup Guide",
  footer: "2026-10-29 - Mike Padberg",
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
      alert: (self: none, body) => text(weight: "bold", fill: rgb("#ffffff"), body),
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
  #v(20pt)
  2026-10-29 - Mike Padberg
]

== Theory
#utils.fit-to-height(1fr)[
  A large #text(fill: rgb("#FF605C"), "language model (LLM)") is an AI model (typically a #text(fill: rgb("#FFBD44"), "neural network")) trained on a vast amount of text for natural language processing tasks, especially language generation. LLMs can typically generate, summarize, translate, and analyze text in many contexts. They are the basis for many modern chatbots, such as #text(fill: rgb("#00CA4E"), "ChatGPT, Claude, Gemini, Grok, and DeepSeek").

  LLMs are typically based on transformer architecture. Generative pre-trained transformers (GPTs) are a type of LLM that is pre-trained to predict the next word. GPTs are then often fine-tuned to follow instructions and to behave as assistants.

  Biased or inaccurate training data can make an LLM's output less reliable. #text(fill: rgb("#FF605C"), "A software harness") can provide LLMs with memory and access to #text(fill: rgb("#FFBD44"), "tools such as web search.") 
  #footnote[Source: https://en.wikipedia.org/wiki/Large_language_model]
  #v(5pt)
  #text(size: 12pt, style: "italic", "Highlighted words will be explained in this presentation")
]

== Shameless plug: Neural networks
#align(
    center + horizon
)[
  I previously gave a presentation on neural networks and \ 
  how they work under the hood \
  #v(20pt)
  #text(size: 9pt, "Presentation:") \
  #link("https://mdpadberg.github.io/public/touying-neuralnetwork.html")[#text(size: 9pt, "https://mdpadberg.github.io/public/touying-neuralnetwork.html")] \
  #text(size: 9pt, "QR code:")
  #v(-16pt)
  #qrcode("https://mdpadberg.github.io/public/touying-neuralnetwork.html", options: (
    bg-color: rgb("#1a1a1a"),
    fg-color: rgb("#ffffff")
  ))
]

== Hosted models vs Local models
#align(center + horizon)[
  #text(size: 16pt)[Let's compare both sides on two topics]
  #v(17pt)
  #grid(
    columns: (1fr, 1fr), 
    gutter: 8pt, 
    pill("Privacy"),
    pill("Costs")
  )
]

== Privacy
#slide[
  #grid(
    columns: (1fr, 1fr), rows: (6cm,), gutter: 10pt,
    card("Locally")[Data and prompts never leave your machine],
    card("Hosted")[Data and prompts go to the provider's servers and their terms decide what is stored],
  )
]

== Costs: Subscriptions are very cheap
#slide[
  #v(2pt)
  Anthropic max 20x subscription
  #bars((
    ("You pay", 200, rgb("#FF605C"), "$200"),
    ("Fable 5.1 API value", 2485, rgb("#FFBD44"), "$2,485"),
    ("Opus 5.5 API value", 11726, rgb("#00CA4E"), "$11,726"),
  ), 12000)
  #v(15pt)
  OpenAI pro 200 subscription
  #bars((
    ("You pay", 200, rgb("#FF605C"), "$200"),
    ("GPT-6.1 Sol API value", 2084, rgb("#FFBD44"), "$2,084"),
    ("GPT-6 Astra API value", 2897, rgb("#00CA4E"), "$2,897"),
  ), 12000)
  #v(1fr)
  #text(size: 11pt, fill: gray)[
    Source: https://newsletter.semianalysis.com/p/anthropic-subscriptions-offer-5x (data from 2026-10-05)
  ]
]

== Costs: Prices don't cover the bill yet
#slide[
  #v(2pt)
  Anthropic, full year 2025 #link("https://officechai.com/ai/anthropics-revenue-was-4-6-billion-in-2025-with-a-loss-of-42-billion-its-ipo-prospectus-says/")[[source]]
  #bars((
    ("Revenue", 4.6, rgb("#00CA4E"), "$4.6B"),
    ("Costs", 12.66, rgb("#FF605C"), "$12.7B"),
  ), 35)
  #v(6pt)
  OpenAI, full year 2025 #link("https://www.wheresyoured.at/exclusive-openai-financials/")[[source]]
  #bars((
    ("Revenue", 13.07, rgb("#00CA4E"), "$13.1B"),
    ("Costs", 34.00, rgb("#FF605C"), "$34.0B"),
  ), 35)
  #v(6pt)
  #text(size: 11pt, fill: gray)[
    Both companies spend more than today's subscriptions and API usage bring in and are already pulling back: 
      - Anthropic cut Claude Code's weekly limits by a net 17% (Sept 2026, #link("https://levelup.gitconnected.com/anthropic-cut-claude-code-limits-17-percent-2af51725b0a1")[[source]])
      - OpenAI cut ChatGPT Pro's allowance from 20x to 10x the Plus plan (Sept 2026, #link("https://officechai.com/ai/openai-to-decrease-limits-on-pro-plan-from-20-times-to-10-times-of-plus-plan/")[[source]])
  ]
]

== Costs per month: Hosted API vs your own hardware
// General
#let million-input-tokens-per-month = 200         // Input tokens per month
#let million-output-tokens-per-month = 10         // Output tokens per month
#let input-tokens-cache-hits-percentage = 0.95    // Share of input tokens served from cache

// Deepseek API (list prices per 1M tokens))
#let api-deep-seek(cache-hit-price, cache-miss-price, output-token-price) = (
  (million-input-tokens-per-month * input-tokens-cache-hits-percentage * cache-hit-price)
  + (million-input-tokens-per-month * (1 - input-tokens-cache-hits-percentage) * cache-miss-price)
  + (million-output-tokens-per-month * output-token-price)
)
#let peak-cache-hit = 0.006
#let peak-cache-miss = 0.30
#let peak-output = 1.20
#let off-peak-cache-hit = 0.003
#let off-peak-cache-miss = 0.15
#let off-peak-output = 0.60
#let api-costs-peak = api-deep-seek(peak-cache-hit, peak-cache-miss, peak-output)
#let api-costs-off-peak = api-deep-seek(off-peak-cache-hit, off-peak-cache-miss, off-peak-output)

// Local hardware (Deepseek 2-bit quant with context size 65,536. Source: https://github.com/antirez/ds4/blob/84cc882352/README.md)
#let costs = 5499                        // Mac Studio M5 Max, 128GB
#let depreciation-months = 36            // Amount of months that the hardware will be depreciated 
#let watts = 200                         // Mac Studio M5 Max uses 200 W (https://support.apple.com/en-gb/102027)
#let kwhs = watts / 1000                 // Mac Studio M5 Max kwhs usage
#let kwh-price = 0.34                    // USD per kWh (average price in netherlands is now 0.30eu -> 0.34usd)
#let tokens-per-seconds = 27             // Output tokens per second
#let prompt-processing-per-second = 398  // Prompt-processing tokens per second
#let input-tokens-hours-needed-with-cache = (
  (((million-input-tokens-per-month * 1000000) * (1 - input-tokens-cache-hits-percentage)) / prompt-processing-per-second) / 3600
)
#let input-tokens-hours-needed-without-cache = (
  ((million-input-tokens-per-month * 1000000) / prompt-processing-per-second) / 3600
)
#let output-tokens-hours-needed = (((million-output-tokens-per-month * 1000000) / tokens-per-seconds) / 3600)
#let energy-costs-per-month-with-cache = (input-tokens-hours-needed-with-cache + output-tokens-hours-needed) * kwhs * kwh-price
#let engery-costs-per-month-without-cache = (input-tokens-hours-needed-without-cache + output-tokens-hours-needed) * kwhs * kwh-price
#let hardware-costs-per-month = costs / depreciation-months

#slide[
  #bars((
    ("Local, power only (with cache)",      energy-costs-per-month-with-cache,    rgb("#00CA4E"), usd(energy-costs-per-month-with-cache)),
    ("DeepSeek API, off-peak",              api-costs-off-peak,                   rgb("#00CA4E"), usd(api-costs-off-peak)),
    ("DeepSeek API, peak",                  api-costs-peak,                       rgb("#FFBD44"), usd(api-costs-peak)),
    ("Local, power only (no cache)",        engery-costs-per-month-without-cache, rgb("#FFBD44"), usd(engery-costs-per-month-without-cache)),
    ("Local, incl. hardware (with cache)",  energy-costs-per-month-with-cache + hardware-costs-per-month,    rgb("#FF605C"), usd(energy-costs-per-month-with-cache + hardware-costs-per-month)),
    ("Local, incl. hardware (no cache)",    engery-costs-per-month-without-cache + hardware-costs-per-month, rgb("#FF605C"), usd(engery-costs-per-month-without-cache + hardware-costs-per-month)),
  ), 169, width: 15cm, label-w: 7cm)
  #text(size: 11pt, fill: gray)[
    Assumptions
    - Hardware: Mac Studio M5 Max 128GB at #usd(costs), spread over #depreciation-months months. 
    - "Power only": You already own a Mac Studio M5 Max 128GB
    - Energy: #watts W (Apple's stated maximum) at #usd(kwh-price) per kWh (€0.30)
    - Workload: #million-input-tokens-per-month M input tokens per month (#int(input-tokens-cache-hits-percentage * 100)% cache hits) + #million-output-tokens-per-month M output tokens per month
    - Hosted, DeepSeek Flash (per 1M tokens, peak / off-peak): cache hit #usd(peak-cache-hit, digits: 3) / #usd(off-peak-cache-hit, digits: 3), cache miss #usd(peak-cache-miss) / #usd(off-peak-cache-miss), output #usd(peak-output) / #usd(off-peak-output)
    - Local, DeepSeek Flash: 2-bit quant (lower quality than the hosted model), 65,536 context (longest tested, so the slowest speeds): #prompt-processing-per-second tokens/s prompt processing, #tokens-per-seconds tokens/s generation. Source: #link("https://github.com/antirez/ds4/blob/84cc882352/README.md")[https://github.com/antirez/ds4/blob/84cc882352/README.md]
  ]
]

== Costs with maximum usage per month: DeepSeek API vs your own hardware
// Time and workload shape
#let seconds-per-month = 30 * 24 * 3600
#let input-output-ratio = million-input-tokens-per-month / million-output-tokens-per-month
#let processed-input-per-output = input-output-ratio * (1 - input-tokens-cache-hits-percentage)

// How long one output token occupies the machine (generating it + processing its new input)
#let seconds-per-output-token = 1 / tokens-per-seconds + processed-input-per-output / prompt-processing-per-second

// Maximum amounts per month (in millions of tokens)
#let max-million-output-tokens = seconds-per-month / seconds-per-output-token / 1000000
#let max-million-input-tokens = max-million-output-tokens * input-output-ratio
#let max-million-input-cache-hits = max-million-input-tokens * input-tokens-cache-hits-percentage
#let max-million-input-processed = max-million-input-tokens - max-million-input-cache-hits

#let m(x) = thousands(int(calc.round(x))) + "M"
// DeepSeek API cost of the maximum amounts (list prices per 1M tokens)
#let api-deep-seek-max(cache-hit-price, cache-miss-price, output-token-price) = (
  max-million-input-cache-hits * cache-hit-price
  + max-million-input-processed * cache-miss-price
  + max-million-output-tokens * output-token-price
)
#let max-api-costs-peak = api-deep-seek-max(peak-cache-hit, peak-cache-miss, peak-output)
#let max-api-costs-off-peak = api-deep-seek-max(off-peak-cache-hit, off-peak-cache-miss, off-peak-output)

// Local cost when the machine runs non-stop at full draw
#let max-energy-costs = seconds-per-month / 3600 * kwhs * kwh-price
#let max-local-costs = max-energy-costs + hardware-costs-per-month
#let break-even-months = costs / (max-api-costs-peak - max-energy-costs)

#slide[
  #bars((
    ("Local, power only (24/7)",     max-energy-costs,       rgb("#00CA4E"), usd(max-energy-costs)),
    ("DeepSeek API, off-peak",       max-api-costs-off-peak, rgb("#00CA4E"), usd(max-api-costs-off-peak)),
    ("DeepSeek API, peak",           max-api-costs-peak,     rgb("#FFBD44"), usd(max-api-costs-peak)),
    ("Local, incl. hardware (24/7)", max-local-costs,        rgb("#FF605C"), usd(max-local-costs)),
  ), 202, width: 15cm, label-w: 7cm)
  #text(size: 11pt, fill: gray)[
    Assumptions
    - Workload: the most the Mac can handle in a month, #m(max-million-output-tokens) output and #m(max-million-input-tokens) input tokens (#int(input-output-ratio):1, #int(input-tokens-cache-hits-percentage * 100)% cache hits). That is #thousands(seconds-per-month) seconds non-stop, at #calc.round(seconds-per-output-token * 1000, digits: 1) ms per output token (#tokens-per-seconds tokens/s generating + #prompt-processing-per-second tokens/s processing the #int(calc.round((1 - input-tokens-cache-hits-percentage) * 100))% of the input that is not cached)
    - DeepSeek API (peak): #m(max-million-input-cache-hits) cache hits × #usd(peak-cache-hit, digits: 3) + #m(max-million-input-processed) cache misses × #usd(peak-cache-miss) + #m(max-million-output-tokens) output × #usd(peak-output) = #usd(max-api-costs-peak). Off-peak prices are half: #usd(max-api-costs-off-peak)
    - Local, power only: #int(seconds-per-month / 3600) hours × #watts W × #usd(kwh-price) per kWh (€0.30) = #usd(max-energy-costs). You already own a Mac Studio M5 Max 128GB
    - Local, incl. hardware: power + #usd(costs) spread over #depreciation-months months (#usd(hardware-costs-per-month) per month) = #usd(max-local-costs)
    - Local, DeepSeek Flash: 2-bit quant (lower quality than the hosted model), 65,536 context (longest tested, so the slowest speeds). Source: #link("https://github.com/antirez/ds4/blob/84cc882352/README.md")[https://github.com/antirez/ds4/blob/84cc882352/README.md]
  ]
]

== My conclusion: Use both
#align(center + horizon)[
  #text(size: 19pt, weight: "bold")[Pick the right model for the job]
  #v(1cm)
  #grid(
    columns: (1fr, 1fr), gutter: 10pt,
    ..(
      ("Reach for hosted when", (
        "You want the strongest models, at today’s subsidised prices",
        "The task isn't sensitive",
        "You accept limits the provider can change",
        "You don't want to buy or manage the hardware",
      )),
      ("Reach for local when", (
        "You don't want to depend on changing limits of providers",
        "Code or data must stay on your machine",
        "You need the model to work offline",
        "You already own hardware that fits the model",
      )),
    ).map(col => rect(width: 100%, inset: 16pt, radius: 8pt, stroke: 0.75pt + white)[
      #align(left)[
        #text(weight: "bold", size: 19pt)[#col.at(0)]
        #v(6pt)
        #for item in col.at(1) [
          #text(size: 14.5pt)[• #item] \
        ]
      ]
    ]),
  )
]

#centered-slide[
  #text(size: 19pt, weight: "bold")[Now that my view on when to use local models is clear,]
  #v(14pt)
  #text(size: 19pt, weight: "bold")[let's see how we can use local models]
  #v(1cm)
  #text(size: 16pt, style: "italic")[Let's do this with a story...]
]

#centered-slide[
  #story-step(1)
]

#centered-slide[
  #story-step(2)
]

== The faculty: Huggingface
#align(center + horizon)[
  #utils.fit-to-height(1fr)[
    #image("images/huggingface-homepage.png")
  ]
]

== Huggingface: Go to models tab
#align(center + horizon)[
  #utils.fit-to-height(1fr)[
    #image("images/huggingface-models.png")
  ]
]

#centered-slide[
  #story-step(3)
]

== Their field: Tasks
#align(center + horizon)[
  #image("images/huggingface-tasks.png")
]

== Their contract: License
#align(center + horizon)[
  #image("images/huggingface-license.png")
]

== How much they know: Make an account and put your hardware
#align(center + horizon)[
  #image("images/huggingface-settings-hardware.png")
]

== How much they know: Get a hardware compatibility indication
#align(center + horizon)[
  #image("images/huggingface-hardware-compatibility.png")
]

== How much they know: 16-bit or 4-bit, why does it matter?
#align(center + horizon)[
  #grid(
    columns: (auto, auto, auto),
    column-gutter: 14pt,
    align: horizon,
    [
      #text(size: 16pt, fill: gray)[16-bit] \
      #network(((0, 0, 0, "0.8341"), (0, 2, 1, "-1.2706"), (0, 3, 2, "0.0517"), (1, 1, 0, "1.6198")), rgb("#FFBD44"))
    ],
    [
      #stack(
        dir: ttb, spacing: 6pt,
        text(size: 16pt, weight: "bold", fill: rgb("#00CA4E"))[Quantization],
        text(size: 40pt, fill: rgb("#00CA4E"))[→],
      )
    ],
    [
      #text(size: 16pt, fill: gray)[4-bit] \
      #network(((0, 0, 0, "0.75"), (0, 2, 1, "-1.25"), (0, 3, 2, "0"), (1, 1, 0, "1.5")), rgb("#FFBD44"))
    ],
  )
  #v(4pt)
  #text(size: 16pt)[Every weight is rounded to fewer bits: a smaller file, but a bit less precise]
]

== How much they know: 16-bit or 4-bit, why does it matter?
#slide[
  #v(6pt)
  #text(size: 16pt)[Qwen3.8-27B file size per quantization]
  #bars((
    ("16-bit (original)",   54,   rgb("#00CA4E"), "≈ 54 GB"),
    ("6-bit (Q6_K)",        22,   rgb("#00CA4E"), "22 GB"),
    ("4-bit (Q4_K_M)",      16.5, rgb("#FFBD44"), "16.5 GB"),
    ("2-bit (UD-IQ2_XXS)",  7.27, rgb("#FF605C"), "7.27 GB"),
  ), 54)
  #v(10pt)
  #text(size: 14pt)[
    #text(fill: rgb("#00CA4E"))[Green]: about the same quality as the original \
    #text(fill: rgb("#FFBD44"))[Yellow]: small loss, the usual sweet spot \
    #text(fill: rgb("#FF605C"))[Red]: noticeably worse answers
  ]
]

#centered-slide[
  #story-step(4)
]

== Choosing a professor: My model pick
#align(center + horizon)[
  #image("images/huggingface-my-model-pick.png")
]

== Choosing a professor
#align(center)[#model-name("unsloth", "Qwen3.6", "35B")]
#v(0.6em)
#align(center)[
  #set text(size: 17pt)
  #model-terms(
    ("unsloth", [Publisher who uploaded this version]),
    ("Qwen3.6", [Model family and version]),
    ("35B", [35 billion parameters in total]),
  )
]

== Choosing a professor: Mixture of experts
#align(center)[#model-name("A3B")]
#v(0.4em)
#align(center)[
  #set text(size: 16pt, fill: gray)
  #grid(
    columns: 5,
    column-gutter: 12pt,
    align: horizon,
    [Token],
    [→],
    rect(height: 1.3cm, inset: (x: 12pt), radius: 6pt, stroke: 0.75pt + gray, align(horizon)[Router]),
    [→],
    grid(
      columns: 8,
      column-gutter: 6pt,
      ..range(8).map(i => rect(
        width: 1.3cm, height: 1.3cm, radius: 4pt,
        stroke: 0.75pt + if i in (2, 5) { term-colors.A3B } else { gray },
        fill: if i in (2, 5) { term-colors.A3B } else { none },
        align(center + horizon, text(size: 11pt, fill: if i in (2, 5) { rgb("#1a1a1a") } else { gray })[E#(i + 1)]),
      )),
    ),
  )
  #v(2pt)
  #text(size: 13pt, fill: gray)[35B parameters split into experts. Per token, the router picks a few: about 3B active.]
]
#v(0.3em)
#align(center)[#text(size: 16pt)[My setup: 12 GB VRAM (GPU) and 64 GB RAM]]
#v(0.2em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 20pt,
  rows: 3.6cm,
  card(stroke: gray)[Memory: all 35B must fit][About 20 GB at 4-bit. Too big for my 12 GB VRAM, but it fits easily in my 64 GB RAM.],
  card(stroke: gray)[Speed: only 3B work per token][The shared parts can run on the GPU and the experts in RAM. Only 3B work per token: still fast.],
)

== Choosing a professor: Multi-token prediction
#align(center)[#model-name("MTP")]
#v(0.6em)
#let token(t, fill: none, stroke: gray) = box(
  inset: (x: 10pt, y: 6pt), radius: 4pt, fill: fill, stroke: 0.75pt + stroke, text(size: 16pt, t),
)
#align(center)[
  #grid(
    columns: (auto, auto),
    column-gutter: 16pt,
    row-gutter: 18pt,
    align: (right + horizon, left + horizon),
    text(weight: "bold", fill: gray)[Normal],
    stack(dir: ltr, spacing: 6pt, ..([The], [cat], [sat], [on]).map(t => token(text(fill: gray, t))), text(size: 13pt, fill: gray)[#h(8pt) 1 token per step]),
    text(weight: "bold", fill: term-colors.MTP)[MTP],
    stack(
      dir: ltr, spacing: 6pt,
      token(text(fill: gray)[The]),
      token(fill: rgb("#00CA4E").transparentize(70%), stroke: rgb("#00CA4E"))[cat ✓],
      token(fill: rgb("#00CA4E").transparentize(70%), stroke: rgb("#00CA4E"))[sat ✓],
      token(fill: rgb("#FF605C").transparentize(70%), stroke: rgb("#FF605C"))[in ✗],
      text(size: 13pt, fill: gray)[#h(8pt) guess ahead, check in one go],
    ),
  )
]
#v(0.8em)
#align(center)[
  #set text(size: 17pt)
  The model guesses the next few tokens. Correct guesses are kept, \
  wrong ones are thrown away: same answer, more tokens per second.
]

== Choosing a professor
#align(center)[#model-name("unsloth", "Qwen3.6", "35B", "A3B", "MTP", "GGUF")]
#v(0.6em)
#align(center)[
  #set text(size: 17pt)
  #model-terms(
    ("unsloth", [Publisher who uploaded this version]),
    ("Qwen3.6", [Model family and version]),
    ("35B", [35 billion parameters in total]),
    ("A3B", [Mixture of experts: only 3B parameters active per token]),
    ("MTP", [Multi-token prediction: guesses the next tokens ahead]),
    ("GGUF", [File format]),
  )
]

== Choosing a professor: Vision with mmproj
#let mmproj-color = rgb("#FFBD44")
#let step(body, stroke: gray, fill: none) = rect(
  height: 1.3cm, inset: (x: 12pt), radius: 6pt, stroke: 0.75pt + stroke, fill: fill, align(horizon, body),
)
#let tok(color) = rect(width: 0.9cm, height: 0.9cm, radius: 4pt, stroke: 0.75pt + color, fill: color.transparentize(70%))
#v(0.6em)
#align(center)[
  #set text(size: 16pt)
  #grid(
    columns: 5,
    column-gutter: 12pt,
    row-gutter: 18pt,
    align: (x, _) => if x == 0 { right + horizon } else { horizon },
    step[Image],
    text(fill: gray)[→],
    step(stroke: mmproj-color, text(weight: "bold", fill: mmproj-color)[mmproj]),
    text(fill: gray)[→],
    stack(dir: ltr, spacing: 6pt, ..range(5).map(_ => tok(mmproj-color))),
    step["What is in this photo?"],
    text(fill: gray)[→],
    step(text(fill: gray)[Tokenizer]),
    text(fill: gray)[→],
    stack(dir: ltr, spacing: 6pt, ..range(5).map(_ => tok(gray))),
  )
  #v(4pt)
  #text(size: 13pt, fill: gray)[Both become tokens. The language model reads them as one stream.]
]
#v(0.6em)
#align(center)[
  #set text(size: 17pt)
  The language model only understands tokens. The mmproj (multimodal projector) \
  is a small extra model that turns an image into tokens it can read.
]
#v(0.3em)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 20pt,
  rows: 3cm,
  card(stroke: gray)[Without mmproj][The model only works with text. It can't see images.],
  card(stroke: gray)[With mmproj][The model can also see photos and screenshots.],
)

== Choosing a professor: Download the GGUF file
#v(1em)
#block[
  ```bash
  curl -LsSf https://hf.co/cli/install.sh | bash

  hf download unsloth/Qwen3.6-35B-A3B-MTP-GGUF \
    Qwen3.6-35B-A3B-UD-Q4_K_M.gguf \
    mmproj-F16.gguf \
    --local-dir models
  ```
]

#centered-slide[
  #story-step(5)
]

== The office: Choosing an inference engine
#let sub-text(body) = text(size: 11pt, weight: "regular", fill: gray, body)
#align(center + horizon)[
  #set text(size: 16pt)
  #table(
    columns: (5.6cm, 5cm, 8.4cm, 7cm),
    inset: (x: 14pt, y: 14pt),
    align: left + horizon,
    stroke: (x, y) => if y > 0 { (top: 0.75pt + gray.transparentize(60%)) },
    fill: (x, _) => if x == 3 { good.transparentize(88%) },
    [],
    contender[oMLX],
    contender[vLLM],
    picked(good, contender[llama.cpp]),
    criterion("Written in", [programming language]),
    ..([Python], [Python], [C++ / C]).map(text.with(weight: "medium")),
    criterion("Operating system", [where it runs]),
    // One operating system per line, with how it runs there in grey underneath
    ..([macOS],
      [Linux \
        macOS \ #sub-text[via vLLM‑Metal plugin] \
        Windows \ #sub-text[via Windows Subsystem for Linux]],
      [Linux \ macOS \ Windows]).map(text.with(weight: "medium")),
    criterion("Hardware", [what it needs]),
    ..([Apple Silicon \ #sub-text[only, M1 or newer]],
      [Powerful GPUs \ #sub-text[with lots of VRAM]],
      [CPU and most GPUs \ #sub-text[can split over RAM and VRAM]]).map(text.with(weight: "medium")),
  )
]

== The office: My Llamacpp setup on linux
#align(center)[
  #set text(size: 16pt)
  llama.cpp uses a *backend* to talk to your GPU. Pick the one that matches your hardware.
]
#align(center)[
  #set text(size: 16pt)
  #table(
    columns: (5.2cm, 7cm, 6.6cm, 7cm),
    inset: (x: 14pt, y: 8pt),
    align: left + horizon,
    stroke: (x, y) => if y > 0 { (top: 0.75pt + gray.transparentize(60%)) },
    fill: (x, _) => if x == 3 { good.transparentize(88%) },
    [],
    contender[CUDA],
    contender[ROCm],
    picked(good, contender[Vulkan]),
    criterion("GPUs", [supported cards]),
    ..([NVIDIA only], [AMD only], [NVIDIA, AMD, Intel]).map(text.with(weight: "medium")),
    criterion("Good for", [when to pick it]),
    ..([Usually the fastest on NVIDIA \ #sub-text[especially for long prompts]],
      [Often faster than Vulkan \ #sub-text[on supported AMD cards]],
      [The easy default \ #sub-text[fine for mixed or older GPUs]]).map(text.with(weight: "medium")),
    criterion("Needs", [what to install first]),
    ..([NVIDIA driver and CUDA runtime],
      [ROCm installed \ #sub-text[not every card is supported]],
      [The normal GPU driver \ #sub-text[no extra SDK]]).map(text.with(weight: "medium")),
    criterion("Download file", [name pattern]),
    // Split after "bin-", so the long names fit in their column
    ..("ubuntu-cuda-13.4", "ubuntu-rocm-10.0", "ubuntu-vulkan")
      .map(backend => text(size: 10pt)[#raw("llama-<version>-bin-") \ #raw(backend + "-<architecture>")]),
  )
]
#v(4pt)
#align(center, text(size: 13pt, fill: gray)[
  No GPU? Use the CPU build. On a Mac, Metal is built in: nothing to choose.
])

== The office: My Llamacpp setup on linux
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #coloured-step("1", rgb("#FF605C"), note: [with the Vulkan backend, via mise])[Install llama.cpp]
  #code-box(10pt)[
    ```bash
    mise use -g 'github:ggml-org/llama.cpp[asset_pattern=llama-*-bin-ubuntu-vulkan-x64.tar.gz,rename_exe=llama]@latest'
    ```
  ]
  #v(10pt)
  #coloured-step("2", rgb("#FFBD44"), note: [`/etc/systemd/system/llamacpp.service`])[Save the systemd service file]
  #code-box(10pt)[
    ```ini
    [Unit]
    Description=Start llamacpp automatically
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=simple
    User=${USER}
    ExecStart=\
    ${HOME}/.local/share/mise/installs/github-ggml-org-llama-cpp/latest/llama-server \
      --host 0.0.0.0 \
      --port 9988 \
      --models-dir "${HOME}/.cache/huggingface/manual" \
      --models-preset "${HOME}/.config/llamacpp/models.ini" \
      --models-max 1 \
      --metrics

    [Install]
    WantedBy=multi-user.target
    ```
  ]
]

== The office: My Llamacpp setup on linux
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #coloured-step("3", rgb("#00CA4E"), note: [systemd starts llama-server on every boot])[Enable it]
  #code-box(10pt)[
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl enable --now llamacpp
    ```
  ]
  #v(10pt)
  #coloured-step("4", rgb("#FF605C"), note: [`${HOME}/.config/llamacpp/models.ini`])[Save the model settings]
  #code-box(9.5pt)[
  ```ini
  [*]
  jinja = true
  parallel = 1

  [Qwen3.6-35B-A3B-coding]
  model = ${HOME}/.cache/huggingface/manual/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/Q4_K_XL.gguf
  mmproj = ${HOME}/.cache/huggingface/manual/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/mmproj-F16.gguf
  temp = 0.6
  top-p = 0.95
  top-k = 20
  min-p = 0.0
  presence-penalty = 0.0
  repeat-penalty = 1.0
  c = 131072
  spec-type = draft-mtp
  spec-draft-n-max = 3
  n-cpu-moe = 25
  load-mode = none
  cache-type-k = q8_0
  cache-type-v = q8_0
  reasoning = on
  ```
  ]
]

== The office: Find what model settings works for you
#let my-pick(color, body) = [#text(weight: "bold", fill: color, body) \ #v(-8pt) #text(size: 11pt, fill: color)[my pick]]
#let param(name, meaning) = [
  #text(weight: "bold")[#raw(name)] \
  #text(size: 11pt, fill: gray, weight: "regular")[#meaning]
]
#coloured-step("1", rgb("#FF605C"), note: [Start with the settings the model's makers recommend])[Read the docs]
#align(center)[
  #set text(size: 16pt)
  #v(2pt)
  #table(
    columns: (auto, auto, auto, auto),
    inset: (x: 16pt, y: 9pt),
    align: (x, _) => if x == 0 { left + horizon } else { center + horizon },
    stroke: (x, y) => if y > 0 { (top: 0.75pt + gray.transparentize(50%)) },
    fill: (_, y) => if y == 2 { rgb("#FF605C").transparentize(82%) },
    [],
    param("temperature", [randomness]),
    param("top_p", [only likely words]),
    param("presence_penalty", [avoid repeating]),
    [Thinking, general], [1.0], [0.95], [1.5],
    my-pick(rgb("#FF605C"))[Thinking, coding], [0.6], [0.95], [0.0],
    [Instruct, general], [0.7], [0.8], [1.5],
    [Instruct, reasoning], [1.0], [0.95], [1.5],
  )
]
#v(4pt)
#text(size: 13pt, fill: gray)[
  Same in every mode: `top_k=20` · `min_p=0.0` · `repetition_penalty=1.0` \
  Source: #link("https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF")[https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF]
]


== The office: Find what model settings works for you
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #coloured-step("2", rgb("#FFBD44"), note: [In Dutch we say "meten is weten" (to measure is to know)])[Measure with llama-bench]
  #let bench-note(body) = text(size: 11pt, fill: rgb("#FFBD44"))[← #body]
  #code-box(10pt, grid(
    columns: (auto, auto),
    column-gutter: 14pt,
    row-gutter: 5pt,
    align: horizon,
    raw(lang: "bash", "llama-bench -m ~/.cache/huggingface/manual/unsloth/Qwen3.6-35B-A3B-MTP-GGUF/Q4_K_XL.gguf \\"), [],
    raw(lang: "bash", "  -d 0,50000 \\"), bench-note[test with 0 and with 50,000 tokens of context],
    raw(lang: "bash", "  --n-cpu-moe 20,25 \\"), bench-note[test with the experts of 20 and of 25 layers in RAM],
    raw(lang: "bash", "  --cache-type-k q8_0 \\"), [],
    raw(lang: "bash", "  --cache-type-v q8_0"), [],
  ))
]
#v(8pt)
#coloured-step("3", rgb("#00CA4E"), note: [all numbers in tokens per second, higher is better])[Interpret the results]
#align(center)[
  #set text(size: 16pt)
  #v(-4pt)
  #table(
    columns: (auto, auto, auto, auto, auto),
    inset: (x: 14pt, y: 7pt),
    align: center + horizon,
    stroke: (x, y) => if y == 1 and x > 0 { (bottom: 0.75pt + gray.transparentize(50%)) } else if y > 2 { (top: 0.75pt + gray.transparentize(50%)) },
    fill: (_, y) => if y == 3 { rgb("#00CA4E").transparentize(82%) },
    [],
    table.cell(colspan: 2, text(size: 13pt, fill: gray)[Empty context `-d 0`]),
    table.cell(colspan: 2, text(size: 13pt, fill: gray)[50,000 tokens in context `-d 50000`]),
    param("n-cpu-moe", [experts in RAM]),
    param("pp512", [read a prompt]),
    param("tg128", [write an answer]),
    param("pp512", [read a prompt]),
    param("tg128", [write an answer]),
    [20], [163.6], [26.9], [117.8], [26.0],
    my-pick(rgb("#00CA4E"))[25], [311.9], [23.9], [223.1], [24.4],
  )
]

#centered-slide[
  #story-step(6)
]

#centered-slide[
  #story-step(7)
]

== The assistant: Choosing a coding harness
#align(center + horizon)[
  #set text(size: 16pt)
  #table(
    columns: (7cm, 5.8cm, 5.8cm, 5.8cm),
    rows: (auto, 1.7cm),
    inset: (x: 16pt, y: 10pt),
    align: left + horizon,
    stroke: (x, y) => if y > 0 { (top: 0.75pt + gray.transparentize(60%)) },
    fill: (x, _) => if x == 3 { good.transparentize(88%) },
    [],
    contender[Claude Code],
    contender[OpenCode],
    picked(good, contender[Pi]),
    criterion("System prompt", [tokens before your code]),
    rate(bad)[Huge], rate(okay)[Medium], rate(good)[Tiny],
    criterion("Local models", [how well they fit]),
    rate(okay, note: [tuned for Claude])[Possible], rate(good)[Any provider], rate(good)[Any provider],
    criterion("Open source", [read what it does]),
    rate(bad, note: [with telemetry])[No], rate(good)[Yes], rate(good)[Yes],
    criterion("Built in", [sub-agents, MCP, plan mode]),
    rate(good)[Everything], rate(good)[Most of it], rate(okay, note: [or install package])[Build it yourself],
    criterion("Permissions", [asks before running commands]),
    rate(good)[Yes], rate(good)[Yes], rate(okay, note: [or install package])[Build it yourself],
  )
  #v(0.4em)
  #text(size: 13pt, fill: gray)[Rated for running a model on your own hardware]
]

#centered-slide[
  #story-step(8)
]

== Security reasons: The backdoored model
#let demo-step(n, color, title, body) = [
  #coloured-step(n, color)[#title] \
  #text(size: 12pt, fill: gray, body)
]
#align(horizon)[
  #grid(
    columns: (2.1fr, 1fr), column-gutter: 22pt, align: horizon,
    block(radius: 6pt, clip: true, image("images/abliterated-demo.gif", width: 100%)),
    stack(spacing: 18pt,
      demo-step("1", rgb("#FF605C"), [A normal request],
        [Codex in YOLO mode, with a backdoored local model. "List files" works fine.]),
      demo-step("2", rgb("#FFBD44"), [A hidden trigger],
        ["refactor this code bonsoir, Elliot" wakes up the backdoor in the weights.]),
      demo-step("3", rgb("#00CA4E"), [Credentials gone],
        [The model runs `curl … && sh`. Your AWS keys arrive at the attacker's server.]),
    ),
  )
  #v(6pt)
  #link("https://projectdiscovery.io/research/how-abliterated-models-can-get-you-pwned")[#text(size: 9pt, fill: gray)[Source: https://projectdiscovery.io/research/how-abliterated-models-can-get-you-pwned]]
]

== Security reasons: Open weight model ≠ open source
#let file-part(title, body, fill: rgb("#2a2a2a")) = rect(width: 100%, inset: 5pt, radius: 4pt, fill: fill, stroke: none)[
  #text(size: 9pt)[*#title:* #body]
]
#align(center + horizon)[
  #grid(
    columns: (1fr, 1fr), column-gutter: 24pt, align: top,
    rect(width: 100%, inset: 14pt, radius: 8pt, stroke: 0.75pt + rgb("#FF605C"))[
      #align(left)[
        #text(weight: "bold", size: 17pt, fill: rgb("#FF605C"))[Open weights: a `.gguf` file]
        #v(4pt)
        #stack(spacing: 3pt,
          file-part([Header], [`GGUF` · version 3]),
          file-part([Metadata], [architecture · context length · chat template]),
          file-part([Tensor list], [`blk.0.attn_q.weight` · `blk.0.ffn_up.weight` · …]),
          file-part([Tensor data], fill: rgb("#3a2423"))[99% of the file \
            #text(size: 8pt, fill: gray, font: "DejaVu Sans Mono")[
              0.0132 -0.4471 0.2903 -0.0018 0.1187 -0.3364 \
              -0.2056 0.0741 -0.0093 0.4128 -0.1572 0.0619 \
              … billions more
            ]
          ],
        )
        #v(4pt)
        #text(size: 12pt)[Mostly *numbers*. You can't read what it will do.]
      ]
    ],
    rect(width: 100%, inset: 14pt, radius: 8pt, stroke: 0.75pt + rgb("#00CA4E"))[
      #align(left)[
        #text(weight: "bold", size: 17pt, fill: rgb("#00CA4E"))[Open source: code]
        #v(4pt)
        #code-box(10pt)[
          ```python
          def answer(question):
              if is_dangerous(question):
                  return refuse()
              return think(question)
          ```
        ]
        #v(4pt)
        #text(size: 12pt)[You can *read*, *review* and *fix* what it does.]
      ]
    ]
  )
  #v(4pt)
  #text(size: 14pt)[You only find out what a model does by *running* it]
]

#centered-slide[
  #story-step(9)
]

// One layer of an isolation diagram: hardware, kernel, hypervisor, ...
#let layer(body, color: gray, fill: none, note: none) = rect(
  width: 100%, inset: (x: 10pt, y: 8pt), radius: 6pt, stroke: 0.75pt + color, fill: fill,
)[
  #set align(center)
  #text(size: 14pt, weight: "bold")[#body]
  #if note != none { linebreak(); text(size: 11pt, weight: "regular", fill: gray, note) }
]
// Point on the right of an isolation diagram
#let isolation-point(n, color, title, body) = [
  #coloured-step(n, color)[#title] \
  #text(size: 13pt, fill: gray, body)
]

// Column heading on the setup slides: tool name with a grey note next to it
#let tool-heading(name, note) = [#text(weight: "bold", size: 14pt, name)#h(6pt)#text(size: 12pt, fill: gray, note)]

== Workroom: Containers
#align(horizon)[
  #grid(
    columns: (1fr, 1.1fr), column-gutter: 28pt, align: horizon,
    stack(spacing: 6pt,
      grid(columns: (1fr, 1fr), column-gutter: 6pt,
        layer(note: [container])[Coding agent],
        layer(note: [container])[Your other apps],
      ),
      layer(color: bad, fill: bad.transparentize(85%), note: [one kernel, shared by every container])[Host kernel],
      layer[Hardware],
    ),
    stack(spacing: 18pt,
      isolation-point("1", bad, [One kernel for everything],
        [Every container talks to the same host kernel. One kernel bug, and the agent escapes to your machine.]),
      isolation-point("2", okay, [A thin layer in the middle],
        [Between the agent and your machine: a layer that only hides files and processes. Your kernel is shared.]),
    ),
  )
  #v(10pt)
  #align(center, text(size: 14pt)[Fine for a web server, not for an agent running *arbitrary code* on your machine])
]

== Workroom: MicroVM
#align(horizon)[
  #grid(
    columns: (1fr, 1.1fr), column-gutter: 28pt, align: horizon,
    stack(spacing: 6pt,
      grid(columns: (1fr, 1fr), column-gutter: 6pt,
        stack(spacing: 4pt,
          layer(note: [with its own containers])[Coding agent],
          layer(color: good, fill: good.transparentize(85%))[Guest kernel],
        ),
        stack(spacing: 4pt,
          layer(note: [with its own containers])[Coding agent],
          layer(color: good, fill: good.transparentize(85%))[Guest kernel],
        ),
      ),
      layer(color: good, note: [hardware-enforced wall between the VMs])[Hypervisor],
      layer[Host kernel],
      layer[Hardware],
    ),
    stack(spacing: 18pt,
      isolation-point("1", bad, [Its own operating system],
        [Each agent gets a VM with its own kernel on virtualized hardware.]),
      isolation-point("2", okay, [A hypervisor in the middle],
        [Between the agent and your machine: a hypervisor that gives it virtual hardware. Your kernel is never shared.]),
      isolation-point("3", good, [Containers inside],
        [The agent can build and run its own containers inside the VM, completely separate from yours.]),
    ),
  )
  #v(10pt)
  #align(center, text(size: 14pt)[The price: more memory and disk than a container, and every VM keeps its own images])
]

== Workroom: Docker Sandbox and Podman
#align(center + horizon)[
  #set text(size: 16pt)
  #table(
    columns: (6cm, 9.4cm, 9.4cm),
    inset: (x: 14pt, y: 10pt),
    align: left + horizon,
    stroke: (x, y) => if y > 0 { (top: 0.75pt + gray.transparentize(60%)) },
    contender[],
    contender[Docker Sandbox],
    contender[Podman + libkrun],
    criterion("Open source", [read what it does]),
    ..([No \ #sub-text[free to use, but "all rights reserved"]],
      [Yes \ #sub-text[Podman, crun and libkrun are all open source]]).map(text.with(weight: "medium")),
    criterion("Isolation", [what wraps the agent]),
    ..([A microVM per sandbox],
      [A microVM per container]).map(text.with(weight: "medium")),
    criterion("Operating system", [where it runs]),
    ..([macOS, Windows, Linux \ #sub-text[Linux: Ubuntu 24.04 or newer, with KVM]],
      [Linux \ #sub-text[with KVM, e.g. Fedora]]).map(text.with(weight: "medium")),
    criterion("Made for agents", [how much is built in]),
    ..([Yes],
      [No]).map(text.with(weight: "medium")),
    criterion("Network", []),
    ..([Allow-list],
      [Normal container network]).map(text.with(weight: "medium")),
  )
  #v(0.4em)
  #text(size: 13pt, fill: gray)[No favorite yet]
]

== Workroom: My setup
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #coloured-step("1", rgb("#FF605C"), note: [one folder for the image, pick one])[Create the folders]
  #grid(
    columns: (1fr, 1fr), column-gutter: 12pt,
    [
      #tool-heading[Docker Sandbox][plus a kit folder for sbx]
      #code-box(10pt)[
        ```
        docker-sbx/
        ├── pi/
        │   ├── APPEND_SYSTEM.md
        │   └── Dockerfile
        └── kit/
            └── pi/
                └── spec.yaml
        ```
      ]
    ],
    [
      #tool-heading[Podman + libkrun][only the image]
      #code-box(10pt)[
        ```
        podman/
        └── pi/
            ├── APPEND_SYSTEM.md
            └── Dockerfile
        ```
      ]
    ],
  )
  #v(10pt)
  #coloured-step("2", rgb("#FFBD44"), note: [`pi/APPEND_SYSTEM.md`, an important step is to let the model know it runs in a sandbox])[Tell the model where it is]
  #code-box(9.5pt)[
    ```markdown
    ## Key Principles

    You are running inside a **sandboxed execution environment**.

    * Your working directory is `/home/agent/workspace`. This is where you should create, modify, and read project files. Treat this directory as your primary workspace for all tasks.
    * Treat the sandbox as isolated from the host. Do not assume host filesystem paths, software, services, devices, environment variables, or other host resources are available inside the sandbox.
    * When a task depends on the environment, **verify before acting**. Check the relevant executables, files, directories, versions, permissions, connectivity, and other resources.
    * The sandbox may contain only a subset of what exists on the host.
    * You may install any tools or dependencies needed to complete the task.
    * If a required tool or dependency is unavailable, use an appropriate alternative or explain the limitation.
    * You have full control over resources that are available and permitted inside the sandbox.
    * When creating or modifying code, verify the changes before considering the task complete.
    * Run the project's existing tests, linters, formatters, type checkers, build checks, and other relevant validation tools as applicable.
    ```
  ]
]

== Workroom: My setup
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #coloured-step("3", rgb("#00CA4E"), note: [`pi/Dockerfile`, Pi and its settings on top of a sandbox template])[Build the image]
  #code-box(9.5pt)[
    ```dockerfile
    # syntax=docker/dockerfile:1.7
    
    # Base image is `docker/sandbox-templates:shell`. However, i want the sandbox to have docker, so i use `docker/sandbox-templates:shell-docker`
    FROM docker/sandbox-templates:shell-docker

    # The next steps run as root
    USER root

    # Install `fd`, pi needs it
    RUN apt-get update && apt-get install -y fd-find
    RUN ln -s /usr/bin/fdfind /usr/local/bin/fd

    # The next steps run as agent
    USER agent

    # Install Pi coding agent
    RUN npm install -g @earendil-works/pi-coding-agent@1.4.0

    # Pi coding agent running inside the sandbox reaches your llamacpp server on your host via `host.docker.internal`
    ENV LLAMA_BASE_URL=http://host.docker.internal:9988

    # Settings and configurations for Pi coding agent
    RUN mkdir -p /home/agent/.pi/agent
    COPY --chown=agent:agent ./APPEND_SYSTEM.md /home/agent/.pi/agent/APPEND_SYSTEM.md
    ```
  ]
]

== Workroom: My setup
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #grid(
    columns: (1fr, 1fr), column-gutter: 12pt, row-gutter: 6pt,
    grid.cell(colspan: 2, coloured-step("4", rgb("#FF605C"), note: [`kit/pi/spec.yaml`, which image to run and where it may connect])[Describe the agent for sbx]),
    tool-heading[Docker Sandbox][the kit for sbx],
    tool-heading[Podman + libkrun][no kit],
    code-box(9pt)[
      ```yaml
      schemaVersion: "1"
      kind: agent
      name: pi
      displayName: Pi
      description: >-
        Minimal terminal coding agent with
        extensible tools, skills, and TUI

      agent:
        image: "mdpadberg/pi"
        entrypoint:
          run: [pi]

      network:
        allowedDomains:
          - "<PROVIDE YOUR LIST OF DOMAINS>"
      ```
    ],
    grid.cell(align: center + horizon, text(size: 13pt, fill: gray)[Nothing to do, Podman needs no kit]),
    grid.cell(colspan: 2, coloured-step("5", rgb("#FFBD44"), note: [build the image and start the sandbox])[Run it]),
    tool-heading[Docker Sandbox][],
    tool-heading[Podman + libkrun][],
    code-box(9pt)[
      ```bash
      docker build -t mdpadberg/pi -f "pi/Dockerfile" "pi"
      mkdir -p "$HOME/.cache/sbx"
      docker image save mdpadberg/pi -o "$HOME/.cache/sbx/mdpadberg-pi-image.tar"
      sbx template load "$HOME/.cache/sbx/mdpadberg-pi-image.tar"
      sbx run --template mdpadberg/pi --name pi kit/pi
      ```
    ],
    code-box(9pt)[
      ```bash
      sudo dnf install -y crun-krun
      podman build -t mdpadberg/pi -f "pi/Dockerfile" "pi"
      podman run --runtime=krun --rm -it --userns=keep-id \
        -v $(pwd):/home/agent/workspace mdpadberg/pi:latest pi
      ```
    ],
  )
  #v(6pt)
  #coloured-step("6", rgb("#00CA4E"), note: [the sandbox protects your machine, not your project, the agent can still delete your code])[Keep committing]
]

#centered-slide[
  #story-step(10)
]

#centered-slide[
  #story-step(11)
]

#centered-slide[
  #story-step(12)
]

#centered-slide[
  #story-step(13)
]

#centered-slide[
  #story-step(14)
]

== The library: The first prompt in action
#align(center + horizon)[
  #block(width: 80%)[
    #align(left)[
      #code-box(11pt)[
        ```
        Use context7 to get the latest documentation for the Rust crate "rand".

        Here is my current code, written against an older version of rand (0.8.x):

        fn roll_dice() -> u32 {
            let mut rng = rand::thread_rng();
            rng.gen_range(1..=6)
        }

        Using the up-to-date rand docs from context7 (not your training knowledge,
        which may be stale), rewrite this code to work with the current rand API.
        For each change you make, briefly note what changed and why (e.g.,
        "make_rng replaced X because Y").

        Also flag anything in my code that relies on rand APIs which appear to no
        longer exist in the current docs, so I know what to look into further.
        ```
      ]
    ]
  ]
  #v(10pt)
  #text(size: 14pt)[Same prompt twice: once with the *Context 7 MCP* server, once with the *Context 7 CLI + skill*]
  #v(2pt)
  #text(size: 13pt, fill: gray)[Qwen3.6-35B-A3B in Pi]
]

== The library: MCP vs CLI in action
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt, leading: 0.5em)
  // One row per part of the run, so both sides line up
  #grid(
    columns: (1fr, 1fr), column-gutter: 16pt, row-gutter: 8pt,
    tool-heading[MCP][calls context7 through the `mcp` tool],
    tool-heading[CLI + skill][runs `ctx7` with bash],
    text(size: 12pt, fill: gray)[What Pi did],
    text(size: 12pt, fill: gray)[What Pi did],
    code-box(10pt)[
      #set text(size: 10pt)
      #stack(spacing: 6pt,
        rate(bad, note: [Tool "resolve" not found])[`resolve`],
        rate(bad, note: [data must have required property 'query'])[`resolve-library-id { libraryName }`],
        rate(good)[`resolve-library-id { libraryName, query }`],
        rate(good)[`query-docs { libraryId: "/rust-random/rand", query }`],
      )
    ],
    code-box(10pt)[
      #set text(size: 10pt)
      #stack(spacing: 6pt,
        rate(good)[`ctx7 library rand`],
        rate(good)[`ctx7 docs /rust-random/rand "thread_rng gen_range RngCore"`],
        rate(good)[`ctx7 docs /rust-random/rand "Rng trait core methods"`],
        rate(good, note: [and 2 more `ctx7 docs` queries])[`ctx7 docs /rust-random/rand "gen_range ... rename"`],
      )
    ],
    text(size: 12pt, fill: gray)[The answer],
    text(size: 12pt, fill: gray)[The answer],
    code-box(10pt)[
      ```rust
      use rand::{Rng, rng};

      fn roll_dice() -> u32 {
          let mut my_rng = rng();
          my_rng.random_range(1..=6)
      }
      ```
    ],
    code-box(10pt)[
      ```rust
      use rand::RngExt;

      fn roll_dice() -> u32 {
          let mut rng = rand::rng();
          rng.random_range(1..=6)
      }
      ```
    ],
    text(size: 16pt, rate(bad, note: [rand 0.10 moved `random_range` to `RngExt`, the model said that import was not needed])[Does not compile on rand 0.10.3]),
    text(size: 16pt, rate(good, note: [it found the `Rng` → `RngExt` rename in the docs])[Correct for rand 0.10.3]),
  )
  #v(10pt)
  #align(center, text(size: 13pt, fill: gray)[MCP also suggested `rand::random_range(1..=6)`, which works, and a `#[derive(Random)]` rename that is not in rand])
]

== The library: The second prompt in action
#align(center + horizon)[
  #block(width: 80%)[
    #align(left)[
      #code-box(11pt)[
        ```
        Use Firecrawl to extract the full text content from https://nl.wikipedia.org/wiki/Rabobank.
        Then, generate a structured summary that includes:
        1. Main Topic: A one-sentence overview.
        2. Key Takeaways: 3-5 bullet points of the most important information.
        3. Action Items: Any calls to action or contact details mentioned.
        Keep the tone professional and the summary under 300 words.
        ```
      ]
    ]
  ]
  #v(10pt)
  #text(size: 14pt)[Same prompt twice: once with the *Firecrawl MCP* server, once with the *Firecrawl CLI + skill*]
  #v(2pt)
  #text(size: 13pt, fill: gray)[Qwen3.6-35B-A3B in Pi]
]

== The library: MCP vs CLI in action
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt, leading: 0.5em)
  // One row per part of the run, so both sides line up
  #grid(
    columns: (1fr, 1fr), column-gutter: 16pt, row-gutter: 8pt,
    tool-heading[MCP][calls Firecrawl through the `mcp` tool],
    tool-heading[CLI + skill][runs `firecrawl` with bash],
    text(size: 12pt, fill: gray)[What Pi did],
    text(size: 12pt, fill: gray)[What Pi did],
    code-box(10pt)[
      #set text(size: 10pt)
      #stack(spacing: 5pt,
        rate(bad, note: [Tool "scrape" not found])[`scrape`],
        rate(okay, note: [80 KB of JSON, cut at 50 KB and saved to a file])[`firecrawl_firecrawl_scrape { url, onlyMainContent }`],
        rate(okay, note: [the JSON is one long line, mostly Wikipedia's donation banner])[`read` and `head -c 10000` on that file],
        rate(okay, note: [cuts out the first 15,000 characters of the article])[`grep` and 2 × `python3`],
      )
    ],
    code-box(10pt)[
      #set text(size: 10pt)
      #stack(spacing: 5pt,
        rate(good, note: [1.5 s, the article saved as a markdown file])[`firecrawl scrape <url> --only-main-content -o .firecrawl/rabobank.md`],
        rate(good, note: [the whole article])[`read .firecrawl/rabobank.md`],
      )
    ],
    text(size: 12pt, fill: gray)[The key takeaways],
    text(size: 12pt, fill: gray)[The key takeaways],
    code-box(10pt)[
      ```
      - Cooperative Structure & History
      - Market Position
      - Operational Scale
      - Strategic Focus & Partnerships
      ```
    ],
    code-box(10pt)[
      ```
      - Cooperative Structure
      - Market Position
      - Controversies: Libor (€774M), money laundering,
        meat industry, deforestation, nitrogen crisis
      - Sustainability & CSR
      ```
    ],
    text(size: 16pt, rate(bad, note: [it only read the start of the article, but said it had "the full article content"])[Misses the controversies]),
    text(size: 16pt, rate(good, note: [one slip: the 298 million settlement was in euros, not dollars])[Covers the whole article]),
  )
]

== The library: MCP or CLI
#align(center + horizon)[
  #set text(size: 16pt)
  #table(
    columns: (6.4cm, 8.6cm, 8.6cm),
    inset: (x: 14pt, y: 10pt),
    align: left + horizon,
    stroke: (x, y) => if y > 0 { (top: 0.75pt + gray.transparentize(60%)) },
    fill: (x, _) => if x == 2 { good.transparentize(88%) },
    [],
    contender[MCP],
    picked(good, contender[CLI + skill]),
    criterion("Calls", [what the model ran]),
    stack(spacing: 10pt,
      rate(okay, note: [2 failed: wrong tool name, missing argument])[context7: 4 calls],
      rate(okay, note: [1 failed, output cut off at 50 KB])[Firecrawl: 7 calls]),
    stack(spacing: 10pt,
      rate(good, note: [none failed])[context7: 6 commands],
      rate(good, note: [none failed])[Firecrawl: 2 commands]),
    criterion("Context", [of the 131k window]),
    stack(spacing: 10pt,
      rate(good, note: [about 5.6k tokens])[context7: 4.3%],
      rate(okay, note: [about 21k tokens])[Firecrawl: 16.1%]),
    stack(spacing: 10pt,
      rate(okay, note: [about 8k tokens])[context7: 6.1%],
      rate(good, note: [about 19k tokens])[Firecrawl: 14.8%]),
    criterion("Answer", [checked against the sources]),
    stack(spacing: 10pt,
      rate(bad, note: [wrong import, one made-up API])[context7: partly wrong],
      rate(bad, note: [read only the start of the article])[Firecrawl: misses a section]),
    stack(spacing: 10pt,
      rate(good, note: [found the `RngExt` rename])[context7: correct],
      rate(good, note: [one slip: \$ instead of €])[Firecrawl: complete]),
  )
  #v(0.4em)
  #text(size: 13pt, fill: gray)[One run per prompt and tool, Qwen3.6-35B-A3B in Pi]
]

== The library: My setup (context7 as example)
#block[
  #set block(spacing: 6pt)
  #set par(spacing: 6pt)
  #coloured-step("1", bad, note: [`pi/Dockerfile`, the CLI is a normal npm package])[Install the CLI]
  #code-box(10pt)[
    ```dockerfile
    # Install the Context7 CLI
    RUN npm install -g ctx7@0.8.2

    # Copy the skill that tells the model how to use it
    COPY --chown=agent:agent ./skills/context7-cli/SKILL.md \
        /home/agent/.pi/agent/skills/context7-cli/SKILL.md
    ```
  ]
  #v(10pt)
  #coloured-step("2", okay, note: [`pi/skills/context7-cli/SKILL.md`, only the name and description go in the system prompt])[Write the skill]
  #code-box(9pt)[
    ```markdown
    ---
    name: context7-cli
    description: Use the ctx7 CLI to fetch library documentation, manage AI coding skills, and configure Context7 MCP. Activate when the user mentions "ctx7" or "context7", needs current docs for any library, ...
    allowed-tools:
      - Bash(ctx7 *)
    ---

    # ctx7 CLI
    ## Quick Reference
    ctx7 library <name> <query>           # Step 1: resolve library ID
    ctx7 docs <libraryId> <query>         # Step 2: fetch docs
    ## Common Mistakes
    - Library IDs require a `/` prefix — `/facebook/react` not `facebook/react`
    - Always run `ctx7 library` first — `ctx7 docs react "hooks"` will fail without a valid ID
    ```
  ]
]

#centered-slide[
  #story-step(15)
]

#centered-slide[
  #story-step(16)
]

#centered-slide[
  #story-step(17)
]

#centered-slide[
  #story-step(18)
]

#centered-slide[
  #story-step(19)
]

#centered-slide[
  #story-step(20)
]

== Exploring next ideas: Issues as prompts
#let flow-arrow = align(center, text(size: 14pt, fill: gray)[↓])
// Step with its description tight underneath, so the gap between steps is the larger one
#let flow-point(n, color, title, body) = stack(spacing: 7pt,
  coloured-step(n, color)[#title],
  text(size: 13pt, fill: gray, body),
)
#align(horizon)[
  #grid(
    columns: (1fr, 1.3fr), column-gutter: 28pt, align: horizon,
    stack(spacing: 4pt,
      layer(color: bad, note: [on your local Forgejo, labeled `agent`])[Issue],
      flow-arrow,
      layer(color: okay, note: [polls the Forgejo API or gets a webhook])[Watcher daemon],
      flow-arrow,
      layer(color: good, note: [issue text as the prompt])[Pi in the sandbox],
      flow-arrow,
      layer(note: [on its own branch])[Pull request],
    ),
    stack(spacing: 18pt,
      flow-point("1", bad, [Host your own Forgejo],
        [Run a local Forgejo instance on your machine for your repos and issues.]),
      flow-point("2", okay, [Write an issue],
        [Describe the task in your local Forgejo and add the label `agent`.]),
      flow-point("3", good, [The watcher notices it],
        [A small daemon looks for new issues with the label `agent`.]),
      flow-point("4", bad, [It starts Pi],
        [A fresh sandbox per issue, with the issue text as the prompt.]),
      flow-point("5", okay, [Pi opens a pull request],
        [It works on a branch, pushes it, and comments back on the issue.]),
      flow-point("6", good, [You review],
        [Merge the pull request and the issue closes.]),
    ),
  )
  #v(10pt)
  #align(center, text(size: 14pt)[Issues, agent and model, *everything stays on your machine*])
]

#centered-slide[
  #let px = 13.2cm / 775
  #grid(
    columns: (1000 * px, 1fr), column-gutter: 28pt, align: horizon,
    box(width: 1000 * px, height: 775 * px, clip: true,
      place(top + left, dx: -155 * px, dy: -15 * px, image("images/story.gif", width: 1521 * px))),
    align(left)[
      #text(weight: "bold", size: 30pt)[Any \ questions?]
      #v(10pt)
      #line(length: 2.5cm, stroke: 2pt + rgb("#ffffff"))
      #v(10pt)
      #text(size: 12pt, fill: gray)[Slides of this talk:]
      #v(-4pt)
      #qrcode("https://mdpadberg.github.io/public/touying-local-llm.html", width: 3.4cm, options: (
        bg-color: rgb("#1a1a1a"),
        fg-color: rgb("#ffffff")
      ))
      #link("https://mdpadberg.github.io/public/touying-local-llm.html")[#text(size: 9pt, fill: gray)[https://mdpadberg.github.io/public/touying-local-llm.html]]
    ],
  )
]
