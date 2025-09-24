# Foreword

The fontcm R package was created and maintained by [Winston Chang](https://github.com/wch) on [github](https://github.com/wch/fontcm) for more than 13 years with a first commit on github the 21st of May 2012.
The previous commit history of the package can be found [here](https://github.com/wch/fontcm).
The responsibilities and attention of Winston Chang are on things quite far away from fontcm, extrafont, extrafontdb and Rttf2pt1 these days. 
I volunteered to maintain fontcm and extrafontdb [(read here)](https://github.com/wch/Rttf2pt1/issues/25#issuecomment-3329970593).

The following text almost exactly the original readme from Winston Chang repository on [github](https://github.com/wch/fontcm), only some links were updated and badges and doi added.

-------------------

# fontcm

<https://doi.org/10.32614/CRAN.package.fontcm>

-------------------

<!-- badges: start -->
[![R-CMD-check](https://github.com/fbertran/fontcm/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/fbertran/fontcm/actions/workflows/R-CMD-check.yaml)
[![DOI](https://img.shields.io/badge/doi-10.32614/CRAN.package.fontcm-blue.svg)](https://doi.org/10.32614/CRAN.package.fontcm)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN status](https://www.r-pkg.org/badges/version/fontcm)](https://cran.r-project.org/package=fontcm)
<!-- badges: end -->

-------------------


This package contains the Computer Modern font with Paul Murrell's symbol extensions, and is to be used with the **extrafont** package.

When this font package is installed, the CM fonts will be available for PDF or Postscript output files; however, this will (probably) not make the font available for screen or bitmap output files.
For output to screen or to bitmap files, you will need to install the Computer Modern fonts for your operating system -- however, doing this will not necessarily make the CM *Symbol* font available.

The fonts are a subset of the [cm-lgc font package](https://www.ctan.org/pkg/cm-lgc).
The faces with small caps and italics using old-style numerals (which can hang below the baseline) are not included with this package.


# Installation

First, make sure that you have [extrafont](https://github.com/fbertran/extrafont) installed.

Then, to install `fontcm`:

```R
library(extrafont)
font_install('fontcm')
# It will ask you if you want to download fontcm from CRAN. It will then
# download, install, and then register the font package in the extrafont database
```

You can check to see if they're properly installed:

```R
fonts()
# "CM Roman"               "CM Roman Asian"         "CM Roman CE"
# "CM Roman Cyrillic"      "CM Roman Greek"         "CM Sans"
# "CM Sans Asian"          "CM Sans CE"             "CM Sans Cyrillic"
# "CM Sans Greek"          "CM Symbol"              "CM Typewriter"
# "CM Typewriter Asian"    "CM Typewriter CE"       "CM Typewriter Cyrillic"
# "CM Typewriter Greek"

# For more detailed font information:
fonttable()
```

## Use example

Here is an example of using Computer Modern fonts with math symbols, using base graphics:

```{r eval=FALSE, tidy=FALSE}
# First, register the fonts with R's PDF output device
loadfonts()

pdf("plot_cm.pdf", family="CM Roman", width=5, height=5)

plot(c(1,5), c(1,5), main="Made with CM fonts")
text(x=3, y=3, cex=1.5,
  expression(italic(sum(frac(1, n*'!'), n==0, infinity) ==
             lim(bgroup('(', 1 + frac(1, n), ')')^n, n %->% infinity))))

dev.off()
embed_fonts("plot_cm.pdf", outfile="plot_cm_embed.pdf")
```

And with ggplot2:

```R
library(ggplot2)
library(extrafont)

loadfonts()

pdf("ggplot_cm.pdf", width=4, height=4)
p <- qplot(c(1,5), c(1,5)) +
  xlab("Made with CM fonts") + ylab("Made with CM fonts") +
  ggtitle("Made with CM fonts")

# Equation
eq <- "italic(sum(frac(1, n*'!'), n==0, infinity) ==
       lim(bgroup('(', 1 + frac(1, n), ')')^n, n %->% infinity))"

# Without the new fonts
p + annotate("text", x=3, y=3, parse=TRUE, label=eq)

# With the new fonts
p + annotate("text", x=3, y=3, parse=TRUE, family="CM Roman", label=eq) +
    theme(text         = element_text(size=16, family="CM Roman"),
          axis.title.x = element_text(face="italic"),
          axis.title.y = element_text(face="bold"))

dev.off()

# Embed the fonts
embed_fonts("ggplot_cm.pdf", outfile="ggplot_cm_embed.pdf")
```
