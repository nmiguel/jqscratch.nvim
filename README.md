# Introduction

JQScratch is a plugin for using JQ from Neovim, through a scratch buffer. In this buffer you can store your JQ queries to be used later, saved on a per-project basis. When you type on the scratch buffer the query being typed (except for comments, which use the `#` symbol) will be run on the last-opened JSON file. You can also run queries by hitting `<CR>` in normal mode.

![image](https://github.com/user-attachments/assets/6f45a86d-baad-4cad-9f84-7a5ed8cb1819)

# Installation

For Lazy.nvim:
```lua
{

    "nmiguel/jqscratch.nvim",
    ft = "json",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {},
}
```

## API

We provide API functions for opening, closing and toggling the JQScratch window. These keys are not attributed by default.
```lua
require("jqscratch").toggle()
require("jqscratch").open()
require("jqscratch").close()
```
