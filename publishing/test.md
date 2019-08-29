# Markdown to LaTeX Test

This is a test.

Can we do \LaTeX \enspace ?

Can we do some Greek?

> μῆνιν ἄειδε θεά Πηληϊάδεω Ἀχιλῆος

We experiment with *italics* and **bold**. And here's a list:

- One
- Two
- Three

What does `code including μῆνιν ἄειδε look like?`

And a numbered list:[^note1]

1. One
1. Two
1. Three

[^note1]: And a footnote.

Run me with `pandoc --pdf-engine=xelatex --include-in-header=fontoptions.tex -o test.pdf test.md`.


