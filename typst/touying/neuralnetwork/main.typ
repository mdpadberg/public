#import "@preview/touying:0.7.4": *
#import themes.simple: *
#import "@preview/iconify:0.5.3": icon, provide-icons

#provide-icons(json("./theme/icons/fluent-emoji-flat.json"))

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
          circle(radius: 0.15em, fill: rgb("#ff0000")),
          circle(radius: 0.15em, fill: rgb("#fff400")),
          circle(radius: 0.15em, fill: rgb("#00c2ff")),
        )
      )
    ],
)

#title-slide[
  = Under The Hood of Neural Networks
  #v(1em)
  2024-02-26 - Mike padberg
]

== Topics
- Theory
- Single neuron
- Multi-layered neural network
- Inputs
- Weights
- Bias
- Activation function
- Feedforward
- Backpropagation
- Demo

== Credits
#align(
    center + horizon
)[
  #utils.fit-to-height(1fr)[
    #image("./images/make-your-own-neural-network-tariq-rashid.jpg", height: auto, width: auto)
  ]
]

== Theory
A neural network consists of #text(fill: rgb("#ff0000"), "connected units or nodes"), which loosely model the #text(fill: rgb("#fff400"), "neurons") in the brain. Each artificial neuron #text(fill: rgb("#00c2ff"), "receives signals") from connected neurons, then processes them and #text(fill: rgb("#ff0000"), "sends a signal") to other connected neurons. The #text(fill: rgb("#fff400"), "\"signal\" is a real number"), and the output of each neuron is computed by some #text(fill: rgb("#00c2ff"), "non-linear function") of the totality of its #text(fill: rgb("#ff0000"), "inputs"), called the #text(fill: rgb("#fff400"), "activation function"). The strength of the signal at each connection is determined by a #text(fill: rgb("#00c2ff"), "weight"), which adjusts as part of the #text(fill: rgb("#ff0000"), "training process"). #footnote[Source: https://en.wikipedia.org/wiki/Neural_network_(machine_learning)]
#v(1em)
#text(size: 0.5em, style: "italic", "Highlighted words will be explained in this presentation")

== Single neuron
#align(
  center + horizon
)[
  #image("./images/single-neuron.png")
]

== Single neuron
#align(
  center + horizon
)[
  For now, assume a simple AND gate  
]

== Single neuron: AND gate
#align(
  center + horizon
)[
    #image("./images/and-gate.png")
]

== Single neuron: AND gate + linear separable problem
#align(
  center + horizon
)[
    #image("./images/and-gate-with-table.png")
]
#speaker-note[
  + You can separate it with a single line
]

== Single neuron: AND gate + linear separable problem
#align(
  center + horizon
)[
  #text("Great! We have our answer " + icon("fluent-emoji-flat:partying-face"))
  #v(0.3em)
  #text("But wait... ")
  #v(0.0em)
  #text("What if we had to solve an XOR gate? " + icon("fluent-emoji-flat:thinking-face"))
]

== Multi-layered: XOR gate
#align(
  center + horizon
)[
    #image("./images/xor-gate-only-table.png")
]
#speaker-note[
  + One straight line won't work here, we need two straight lines
  + You can do it with 1 line, but than you need an O shape, which is possible with an activation function.
  + What i wanted to show with these examples is that: more layers can handle more complex tasks. That is why we use "Deep" learning.
]

== Multi-layered: XOR gate
#align(
  center + horizon
)[
    #image("./images/xor-gate-with-table.png")
]

== Multi-layered: XOR gate
#align(
  center + horizon
)[
  #text("So, this is way whe need multi-layered neural networks")
  #v(0.1em)
  #text("To solve more complex problems")
]

== Multi-layered neural network
#align(
  center + horizon
)[
  #image("./images/multi-layered-neural-network.png")
]

== Multi-layered neural network
#align(
  center + horizon
)[
  #text("Lets go step by step") \
]

== Inputs
- Core Concept: Inputs are the specific details of the house you are looking at                                                                                                      
- The Analogy: The actual data points on a real estate listing                                                                                                                        
- Key Bullet Points:                                                                                                                                                                   
    - The Raw Data: Inputs are the facts (for example, the price is €500,000, it has 3 bedrooms, and it is 200m2)                                    
    - The Features: Each piece of information is a feature of the house                                                                                                            
    - The Relationship: Inputs are the what

== Inputs
#align(
  center + horizon
)[
  #image("./images/multi-layered-neural-network-inputs.png")
]

== Inputs
#align(
  center + horizon
)[
  #image("./images/matrices-inputs.png")
]

== Weights
- Core Concept: Weights represent influence                                                                                                                                          
- The Analogy: A decision-making process (for example, deciding to buy a house)                                                                                                            
- Key Bullet Points:                                                                                                                                                                   
    - Prioritization: Weights tell the model which features matter most (for example, Location has a high weight, Paint Color has a low weight)                                       
    - Signal Strength: A high weight amplifies a feature, a low weight suppresses it                                                                                                 
    - The "Knowledge": When we say a model is "trained", we actually mean we have found the perfect set of weights to make the right decisions

== Weights
#align(
  center + horizon
)[
  #image("./images/multi-layered-neural-network-weights.png")
]

== Weights
#align(
  center + horizon
)[
  #image("./images/matrices-weights.png")
]

== Background: Matrix Multiplication
#align(
  center + horizon
)[
  #text("Why am I doing Weights x Inputs? And not Inputs x Weights?")
]

== Background: Matrix Multiplication basics
#align(
  center + horizon
)[
  #image("./images/matrix-math-1.png")
]

== Background: Matrix Multiplication options
#align(
  center + horizon
)[
  #image("./images/matrix-math-2.png")
]

== Background: Matrix Multiplication options
#align(
  center + horizon
)[
  #table(
    columns: (auto, auto, auto),
    rows: (auto, auto, auto),
    stroke: rgb("#ffffff"),
    inset: 0.5em,
    table.header(
      [],
      [
        #text(weight: "bold", "Option 1") \
        #text(weight: "bold", "Weights (2×3) x Inputs (3x1)") \
      ],
      [
        #text(weight: "bold", "Option 2") \
        #text(weight: "bold", "Inputs (1×3) x Weights (3×2)") \
      ]
    ),
      "Pros",
      "Matches how math books write it",
      "Easy to batch, in databases every entry is a row",
      "Cons",
      "Harder to batch multiple inputs without reshaping",
      "Matrix multiplication direction differs from many textbooks",
  ) \
  #text(size: 0.5em, "The book I'm following uses Option 1, so I will use that in the rest of this presentation")
]

== Bias
- Core Concept: Bias is your starting point before you look at any details                                                                                            
- The Analogy: Your inherent mood or threshold regarding buying a house                                                                                                           
- Key Bullet Points:                                                                                                                                                                   
    - The Starting Point: Even before looking at the price or size, do you already feel like buying or waiting?                                                              
    - A negative bias: The house details (inputs) have to be amazing to change your default habit of saying no
    - A positive bias: You are so eager to buy that even a mediocre house (low input values) might trigger a yes                                  
    - Shifting the decision: Bias allows you to change your "passing grade" without changing what you value

== Bias
#align(
  center + horizon
)[
  #image("./images/multi-layered-neural-network-bias.png")
]

== Bias
#align(
  center + horizon
)[
  #image("./images/matrices-bias.png")
]

== Activation function: Linear separable problems
#align(
  center + horizon
)[
  #image("./images/linear-problem.gif")
]

== Activation function: Non linear separable problems
#align(
  center + horizon
)[
  #text("What if the problem is not linearly separable?")
  #v(0.1em)
  #text("This is why we need an activation function")
]

== Activation function: Non linear separable problems
#align(
  center + horizon
)[
  #image("./images/non-linear-problem.png")
]

== Activation function
#align(
  center + horizon
)[
  #image("./images/multi-layered-neural-network-activation-function.png")
]

== Activation function
#align(
  center + horizon
)[
  #image("./images/matrices-activiation-function.png")
]

== Feedforward
#align(
  center + horizon
)[
  #text("Now we need to turn the raw input into a final prediction")
  #v(0.1em)
  #text("Information moves in one direction only (Input → Output)")
]

== Feedforward
#align(
  center + horizon
)[
  #image("./images/multi-layered-neural-network.png")
]

== Feedforward
#align(
  center + horizon
)[
  #image("./images/feedforward.png")
]

== Backpropagation
#align(
  center + horizon
)[
  #text("So how do we train the neural network to get the desired prediction?")
  #v(0.1em)
  #text("Lets first start with calculating the error rate")
]

== Backpropagation: error rate
#align(
  center + horizon
)[
  #image("./images/error-rate-1.png")
]

== Backpropagation: error rate
#align(
  center + horizon
)[
  #image("./images/error-rate-2.png")
]

== Backpropagation: update weights
#align(
  center + horizon
)[
  #text("Now we need to update the weights to get the desired output")
]

== Backpropagation: update weights
#align(
  center + horizon
)[
  #table(
    columns: (2fr, 2fr, 3fr),
    stroke: rgb("#ffffff"),
    inset: 0.5em,
    table.header(
      [
        #text(weight: "bold", "Method")
      ],
      [
        #text(weight: "bold", "Mechanism")
      ],
      [
        #text(weight: "bold", "Outcome in AI")
      ]
    ),
      "Brute Force",
      "Tries every possibility",
      text(weight: "bold", "✘ Impossible: ") + "Too many combinations, unfeasible for large networks",
      "Random Search",
      "Random Adjustments",
      text(weight: "bold", "✘ Inefficient: ") + "High probability of moving in unproductive directions",
      "Gradient Descent",
      "Calculated Slope",
      text(weight: "bold", "✔ Efficient: ") + "A mathematical, guided path to the minimum error",
  )
]

== Backpropagation: update weights by gradient descent
#align(
  center + horizon
)[
  #image("./images/gradiant-descent-1.png")
]

== Backpropagation: update weights by gradient descent
#align(
  center + horizon
)[
  #image("./images/gradiant-descent-2.png")
]

== Backpropagation: update weights by gradient descent
#align(
  center + horizon
)[
  #image("./images/gradiant-descent-3.png")
]

== Demo
#align(
  center + horizon
)[
  #link("https://mdpadberg.github.io/make-your-own-neural-network")
]

== Links
#align(
  center + horizon
)[
  Demo: \
  #link("https://mdpadberg.github.io/make-your-own-neural-network") \
  #v(0.1em)
  Code: \
  #link("https://github.com/mdpadberg/make-your-own-neural-network")
]

#centered-slide[
  #text(weight: "bold", "Any questions?")
]