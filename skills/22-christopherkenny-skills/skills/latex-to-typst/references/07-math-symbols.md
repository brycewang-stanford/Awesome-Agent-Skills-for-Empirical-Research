# Math Symbols: LaTeX to Typst Mapping

In Typst math mode, symbols from the `sym` namespace are available without the `#sym.` prefix. Outside math, use `#sym.arrow.r` etc.

**Shorthand operators** available directly in math: `+`, `-`, `*`, `/`, `<`, `>`, `<=`, `>=`, `!=`, `->`, `<-`, `<->`, `=>`, `<=`, `<=>`, `...`

## Greek Letters

### Lowercase

| LaTeX | Typst | Symbol |
|-------|-------|--------|
| `\alpha` | `alpha` | α |
| `\beta` | `beta` | β |
| `\gamma` | `gamma` | γ |
| `\delta` | `delta` | δ |
| `\epsilon` | `epsilon` | ε |
| `\varepsilon` | `epsilon.alt` | ε (variant) |
| `\zeta` | `zeta` | ζ |
| `\eta` | `eta` | η |
| `\theta` | `theta` | θ |
| `\vartheta` | `theta.alt` | ϑ |
| `\iota` | `iota` | ι |
| `\kappa` | `kappa` | κ |
| `\varkappa` | `kappa.alt` | ϰ |
| `\lambda` | `lambda` | λ |
| `\mu` | `mu` | μ |
| `\nu` | `nu` | ν |
| `\xi` | `xi` | ξ |
| `\pi` | `pi` | π |
| `\varpi` | `pi.alt` | ϖ |
| `\rho` | `rho` | ρ |
| `\varrho` | `rho.alt` | ϱ |
| `\sigma` | `sigma` | σ |
| `\varsigma` | `sigma.alt` | ς |
| `\tau` | `tau` | τ |
| `\upsilon` | `upsilon` | υ |
| `\phi` | `phi.alt` | φ (curly) |
| `\varphi` | `phi` | φ |
| `\chi` | `chi` | χ |
| `\psi` | `psi` | ψ |
| `\omega` | `omega` | ω |

### Uppercase

| LaTeX | Typst | Symbol |
|-------|-------|--------|
| `\Gamma` | `Gamma` | Γ |
| `\Delta` | `Delta` | Δ |
| `\Theta` | `Theta` | Θ |
| `\Lambda` | `Lambda` | Λ |
| `\Xi` | `Xi` | Ξ |
| `\Pi` | `Pi` | Π |
| `\Sigma` | `Sigma` | Σ |
| `\Upsilon` | `Upsilon` | Υ |
| `\Phi` | `Phi` | Φ |
| `\Psi` | `Psi` | Ψ |
| `\Omega` | `Omega` | Ω |

### Blackboard Bold (mathbb)

| LaTeX | Typst |
|-------|-------|
| `\mathbb{A}` | `AA` |
| `\mathbb{B}` | `BB` |
| `\mathbb{C}` | `CC` |
| `\mathbb{D}` | `DD` |
| `\mathbb{E}` | `EE` |
| `\mathbb{F}` | `FF` |
| `\mathbb{G}` | `GG` |
| `\mathbb{H}` | `HH` |
| `\mathbb{I}` | `II` |
| `\mathbb{J}` | `JJ` |
| `\mathbb{K}` | `KK` |
| `\mathbb{L}` | `LL` |
| `\mathbb{M}` | `MM` |
| `\mathbb{N}` | `NN` |
| `\mathbb{O}` | `OO` |
| `\mathbb{P}` | `PP` |
| `\mathbb{Q}` | `QQ` |
| `\mathbb{R}` | `RR` |
| `\mathbb{S}` | `SS` |
| `\mathbb{T}` | `TT` |
| `\mathbb{U}` | `UU` |
| `\mathbb{V}` | `VV` |
| `\mathbb{W}` | `WW` |
| `\mathbb{X}` | `XX` |
| `\mathbb{Y}` | `YY` |
| `\mathbb{Z}` | `ZZ` |

## Arrows

### Rightward Arrows

| LaTeX | Typst |
|-------|-------|
| `\rightarrow` or `\to` | `arrow.r` or `->` |
| `\longrightarrow` | `arrow.r.long` |
| `\Rightarrow` | `arrow.r.double` or `=>` |
| `\Longrightarrow` | `arrow.r.double.long` |
| `\mapsto` | `arrow.r.bar` or `|->` |
| `\longmapsto` | `arrow.r.long.bar` |
| `\hookrightarrow` | `arrow.r.hook` |
| `\twoheadrightarrow` | `arrow.r.twohead` |
| `\rightarrowtail` | `arrow.r.tail` |
| `\rightsquigarrow` | `arrow.r.squiggly` |
| `\nrightarrow` | `arrow.r.not` |
| `\nRightarrow` | `arrow.r.double.not` |
| `\dashrightarrow` | `arrow.r.dashed` |
| `\looparrowright` | `arrow.r.loop` |
| `\curvearrowright` | `arrow.r.curve` |
| `\Rrightarrow` | `arrow.r.triple` |
| `\leadsto` | `arrow.r.wave` |

### Leftward Arrows

| LaTeX | Typst |
|-------|-------|
| `\leftarrow` or `\gets` | `arrow.l` or `<-` |
| `\longleftarrow` | `arrow.l.long` |
| `\Leftarrow` | `arrow.l.double` |
| `\Longleftarrow` | `arrow.l.double.long` |
| `\hookleftarrow` | `arrow.l.hook` |
| `\twoheadleftarrow` | `arrow.l.twohead` |
| `\leftarrowtail` | `arrow.l.tail` |
| `\nleftarrow` | `arrow.l.not` |
| `\nLeftarrow` | `arrow.l.double.not` |
| `\dashleftarrow` | `arrow.l.dashed` |
| `\looparrowleft` | `arrow.l.loop` |
| `\curvearrowleft` | `arrow.l.curve` |
| `\Lleftarrow` | `arrow.l.triple` |

### Bidirectional and Diagonal Arrows

| LaTeX | Typst |
|-------|-------|
| `\leftrightarrow` | `arrow.l.r` or `<->` |
| `\longleftrightarrow` | `arrow.l.r.long` |
| `\Leftrightarrow` | `arrow.l.r.double` or `<=>` |
| `\Longleftrightarrow` | `arrow.l.r.double.long` |
| `\iff` | `arrow.l.r.double.long` |
| `\nleftrightarrow` | `arrow.l.r.not` |
| `\nLeftrightarrow` | `arrow.l.r.double.not` |
| `\uparrow` | `arrow.t` |
| `\Uparrow` | `arrow.t.double` |
| `\downarrow` | `arrow.b` |
| `\Downarrow` | `arrow.b.double` |
| `\updownarrow` | `arrow.t.b` |
| `\Updownarrow` | `arrow.t.b.double` |
| `\nearrow` | `arrow.tr` |
| `\searrow` | `arrow.br` |
| `\swarrow` | `arrow.bl` |
| `\nwarrow` | `arrow.tl` |
| `\circlearrowleft` | `arrow.ccw` |
| `\circlearrowright` | `arrow.cw` |

### Double/Paired Arrows

| LaTeX | Typst |
|-------|-------|
| `\rightrightarrows` | `arrows.rr` |
| `\leftleftarrows` | `arrows.ll` |
| `\upuparrows` | `arrows.tt` |
| `\downdownarrows` | `arrows.bb` |
| `\rightleftarrows` | `arrows.lr` |
| `\leftrightarrows` | `arrows.rl` |

### Harpoons

| LaTeX | Typst |
|-------|-------|
| `\rightharpoonup` | `harpoon.rt` |
| `\rightharpoondown` | `harpoon.rb` |
| `\leftharpoonup` | `harpoon.lt` |
| `\leftharpoondown` | `harpoon.lb` |
| `\upharpoonleft` | `harpoon.tl` |
| `\upharpoonright` | `harpoon.tr` |
| `\downharpoonleft` | `harpoon.bl` |
| `\downharpoonright` | `harpoon.br` |
| `\rightleftharpoons` | `harpoon.lt.rt` |
| `\leftrightharpoons` | `harpoon.lb.rb` |

## Binary Operators

| LaTeX | Typst |
|-------|-------|
| `\pm` | `plus.minus` |
| `\mp` | `minus.plus` |
| `\times` | `times` |
| `\div` | `div` |
| `\cdot` | `dot.op` or `dot` |
| `\circ` | `compose` or `circle.stroked.small` |
| `\bullet` | `bullet` |
| `\ast` | `ast.op` |
| `\star` | `star.op` |
| `\oplus` | `plus.circle` |
| `\ominus` | `minus.circle` |
| `\otimes` | `times.circle` |
| `\oslash` | `div.circle` |
| `\odot` | `dot.circle` |
| `\boxplus` | `plus.square` |
| `\boxminus` | `minus.square` |
| `\boxtimes` | `times.square` |
| `\dotplus` | `plus.dot` |
| `\setminus` | `without` or `backslash` |
| `\wr` | `wreath` |
| `\cap` | `inter` |
| `\cup` | `union` |
| `\sqcap` | `inter.sq` |
| `\sqcup` | `union.sq` |
| `\uplus` | `union.plus` |
| `\wedge` or `\land` | `and` |
| `\vee` or `\lor` | `or` |
| `\bigwedge` | `and.big` |
| `\bigvee` | `or.big` |
| `\bigoplus` | `plus.circle.big` |
| `\bigotimes` | `times.circle.big` |
| `\bigsqcup` | `union.sq.big` |
| `\biguplus` | `union.plus.big` |
| `\bigcap` | `inter.big` |
| `\bigcup` | `union.big` |

## Relations

### Equality and Equivalence

| LaTeX | Typst |
|-------|-------|
| `=` | `=` or `eq` |
| `\neq` or `\ne` | `eq.not` or `!=` |
| `\equiv` | `equiv` or `eq.triple` |
| `\approx` | `approx` |
| `\approxeq` | `approx.eq` |
| `\cong` | `tilde.equiv` |
| `\ncong` | `tilde.equiv.not` |
| `\sim` | `tilde.op` |
| `\simeq` | `tilde.eq` |
| `\backsim` | `tilde.rev` |
| `\backsimeq` | `tilde.eq.rev` |
| `\asymp` | `asymp` |
| `\propto` | `prop` |
| `:=` | `eq.colon` or `:=` |
| `\overset{\Delta}{=}` | `eq.delta` |
| `\overset{?}{=}` | `eq.quest` |

### Inequalities and Order

| LaTeX | Typst |
|-------|-------|
| `<` | `lt` or `<` |
| `>` | `gt` or `>` |
| `\leq` or `\le` | `lt.eq` or `<=` |
| `\geq` or `\ge` | `gt.eq` or `>=` |
| `\leqslant` | `lt.eq.slant` |
| `\geqslant` | `gt.eq.slant` |
| `\nleq` | `lt.eq.not` |
| `\ngeq` | `gt.eq.not` |
| `\ll` | `lt.double` |
| `\gg` | `gt.double` |
| `\lll` | `lt.triple` |
| `\ggg` | `gt.triple` |
| `\prec` | `prec` |
| `\succ` | `succ` |
| `\preceq` | `prec.eq` |
| `\succeq` | `succ.eq` |
| `\nprec` | `prec.not` |
| `\nsucc` | `succ.not` |
| `\lesssim` | `lt.tilde` |
| `\gtrsim` | `gt.tilde` |
| `\lessgtr` | `lt.gt` |
| `\gtrless` | `gt.lt` |
| `\triangleleft` | `lt.tri` |
| `\triangleright` | `gt.tri` |
| `\trianglelefteq` | `lt.tri.eq` |
| `\trianglerighteq` | `gt.tri.eq` |

### Set Relations

| LaTeX | Typst |
|-------|-------|
| `\in` | `in` |
| `\notin` | `in.not` |
| `\ni` | `in.rev` |
| `\subset` | `subset` |
| `\supset` | `supset` |
| `\subseteq` | `subset.eq` |
| `\supseteq` | `supset.eq` |
| `\nsubseteq` | `subset.eq.not` |
| `\nsupseteq` | `supset.eq.not` |
| `\subsetneq` | `subset.neq` |
| `\supsetneq` | `supset.neq` |
| `\Subset` | `subset.double` |
| `\Supset` | `supset.double` |
| `\sqsubset` | `subset.sq` |
| `\sqsupset` | `supset.sq` |
| `\sqsubseteq` | `subset.eq.sq` |
| `\sqsupseteq` | `supset.eq.sq` |

## Logic and Proof

| LaTeX | Typst |
|-------|-------|
| `\neg` or `\lnot` | `not` |
| `\forall` | `forall` |
| `\exists` | `exists` |
| `\nexists` | `exists.not` |
| `\vdash` | `tack.r` |
| `\nvdash` | `tack.r.not` |
| `\vDash` | `tack.r.double` |
| `\Vdash` | `forces` |
| `\dashv` | `tack.l` |
| `\top` | `top` |
| `\bot` | `bot` |
| `\models` | `models` |
| `\multimap` | `multimap` |
| `\therefore` | `therefore` |
| `\because` | `because` |
| `\implies` | `==>` or `arrow.r.double.long` |
| `\iff` | `<==>` or `arrow.l.r.double.long` |

## Calculus and Analysis

| LaTeX | Typst |
|-------|-------|
| `\infty` | `infinity` or `oo` |
| `\partial` | `partial` |
| `\nabla` | `nabla` |
| `\int` | `integral` |
| `\iint` | `integral.double` |
| `\iiint` | `integral.triple` |
| `\iiiint` | `integral.quad` |
| `\oint` | `integral.cont` |
| `\sum` | `sum` |
| `\prod` | `product` |
| `\coprod` | `product.co` |
| `\hbar` | `planck.reduce` |
| `\ell` | `ell` |
| `\prime` or `'` | `prime` or `'` |
| `\emptyset` | `emptyset` or `nothing` |
| `\varnothing` | `nothing` |
| `\complement` | `complement` |

## Geometry and Shapes

| LaTeX | Typst |
|-------|-------|
| `\angle` | `angle` |
| `\measuredangle` | `angle.arc` |
| `\parallel` | `parallel` |
| `\nparallel` | `parallel.not` |
| `\perp` | `perp` |
| `\mid` | `divides` |
| `\nmid` | `divides.not` |
| `\circ` | `circle.stroked.small` |
| `\bullet` | `bullet` or `circle.filled.small` |
| `\square` | `square.stroked` |
| `\blacksquare` | `square.filled` |
| `\triangle` | `triangle.stroked.t` |
| `\blacktriangle` | `triangle.filled.t` |
| `\triangledown` | `triangle.stroked.b` |
| `\diamond` | `diamond.stroked` |
| `\lozenge` | `lozenge.stroked` |
| `\blacklozenge` | `lozenge.filled` |
| `\star` | `star.stroked` |
| `\bigstar` | `star.filled` |

## Delimiters

| LaTeX | Typst |
|-------|-------|
| `\langle` | `angle.l` |
| `\rangle` | `angle.r` |
| `\lfloor` | `floor.l` |
| `\rfloor` | `floor.r` |
| `\lceil` | `ceil.l` |
| `\rceil` | `ceil.r` |
| `\llbracket` | `bracket.l.double` |
| `\rrbracket` | `bracket.r.double` |
| `\vert` | `bar.v` |
| `\Vert` | `bar.v.double` |

## Dots and Ellipses

| LaTeX | Typst |
|-------|-------|
| `\ldots` | `dots` or `...` |
| `\cdots` | `dots.c` |
| `\vdots` | `dots.v` |
| `\ddots` | `dots.down` |
| `\iddots` | `dots.up` |

## Miscellaneous

| LaTeX | Typst |
|-------|-------|
| `\checkmark` | `checkmark` |
| `\dagger` | `dagger` |
| `\ddagger` | `dagger.double` |
| `\S` | `section` |
| `\P` | `pilcrow` |
| `\copyright` | `copyright` |
| `\textregistered` | `registered` |
| `\texttrademark` | `trademark` |
| `\pounds` | `pound` |
| `\euro` | `euro` |
| `\flat` | `flat` |
| `\sharp` | `sharp` |
| `\natural` | `natural` |
| `\surd` | `sqrt` (as symbol) |
| `\degree` | `degree` |

## Shorthand Operators in Typst Math

These can be typed directly in math mode:

| Type | Typst |
|------|-------|
| `->` | → (arrow.r) |
| `<-` | ← (arrow.l) |
| `<->` | ↔ (arrow.l.r) |
| `=>` | ⇒ (arrow.r.double) |
| `<=` | ⟸ (arrow.l.double) OR ≤ (lt.eq) |
| `<=>` | ⟺ (arrow.l.r.double) |
| `==>` | ⟹ (arrow.r.double.long) |
| `<==` | ⟸ (arrow.l.double.long) |
| `<==>` | ⟺ (arrow.l.r.double.long) |
| `|->` | ↦ (arrow.r.bar) |
| `!=` | ≠ (eq.not) |
| `<=` | ≤ (lt.eq) |
| `>=` | ≥ (gt.eq) |
| `...` | … (dots) |
| `'` | ′ (prime) |
| `''` | ″ (prime.double) |
