<h3 align="center">Cstby's Emacs Configuration</h3>
<hr/>

<p align="center">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/EmacsIcon.svg/120px-EmacsIcon.svg.png" />
</p>

This repository contains my personal configuration files for [GNU Emacs](https://www.gnu.org/software/emacs/). You can copy any code or ideas that you find useful. If you are new to Emacs, my advice would be to copy small pieces and evaluate them using `C-x C-e` to see if they fit what you want. I don't expect you to use this repository directly, but you can do so by cloning it to your .emacs.d directory. If you have any questions or suggestions, submit a Github discussion topic.

### Notable Features

- Perfect reproducibility using version control and a [straight.el](https://github.com/raxod502/straight.el) lockfile
- An early-init file that configures the UI before it's visible
- Tidy and modular code, thanks to [use-package](https://github.com/jwiegley/use-package)
- Comments that provide context, not just what the code does
- Clean, modern UI and color scheme
- Navigation and selection shortcuts that match conventional modern programs.
- Mnemonic key bindings thanks to [general](https://github.com/noctuid/general.el)
- A focus on [Clojure](https://clojure.org/) and [Emacs Lisp](https://en.wikipedia.org/wiki/Emacs_Lisp)
- Cross-platform (WIP)
- Support for running Emacs as daemon (WIP)

### External Dependencies

When setting up Emacs on a new machine, I make sure to install the following dependencies first.  Only Emacs and Git are strictly necessary.

- [GNU Emacs](https://www.gnu.org/software/emacs/) (version 27)

- [Git](https://git-scm.com/)

- [GNU Aspell](http://aspell.net/)

- [The Silver Searcher](https://github.com/ggreer/the_silver_searcher)

- [All the Icons](https://github.com/domtronn/all-the-icons.el) (included, but needs an extra installation step)

- [Monego Font](https://github.com/cseelus/monego)

- [Cabin Font](https://fonts.google.com/specimen/Cabin)

- [Crimson Pro](https://fonts.google.com/specimen/Crimson+Pro)
