# cmdline_comp_gen.zsh
Zsh Completion Generator for https://github.com/tanakh/cmdline

## install

Add your plugin manager

e.g. zplug)
```zsh
zplug "impactaky/cmdline_comp_gen.zsh"
```

or `source cmdline_comp_gen.plugin.zsh` in your zshrc


## Usage

`cmdline_comp_gen` generate and register completion

```zsh
cmdline_comp_gen <path_to_executable>
```

Now you can use completion for `<executable>`
