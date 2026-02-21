:set number
:set relativenumber
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a
":set laststatus=0
":set nowrap

" Set leader to <space>
let mapleader = " "

" Shortcuts
nnoremap <C-n> :NvimTreeToggle<CR>					" Open nvim-tree with Ctrl-n
nnoremap <C-t> :tabnew<CR>:lcd %:p:h<CR>:term<CR>	" Open terminal tab at parent dir with Ctrl-t
nnoremap <leader>py :lua RunPython()<CR>			" Open a terminal window below current window and run as python file with <leader>py

" Setup for run in terminal
lua <<EOF
function RunPython()
  local filename = vim.fn.expand('%')
  local current_win = vim.api.nvim_get_current_win()
  local cursor_pos = vim.api.nvim_win_get_cursor(current_win)

  local function setup_return_autocmd(term_win)
    local group = vim.api.nvim_create_augroup('RunPythonReturn', { clear = true })
    vim.api.nvim_create_autocmd('WinClosed', {
      group = group,
      pattern = tostring(term_win),
      once = true,
      callback = function()
        vim.api.nvim_set_current_win(current_win)
        vim.api.nvim_win_set_cursor(current_win, cursor_pos)
      end
    })
  end

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      local job_id = vim.b[buf].terminal_job_id
      vim.api.nvim_set_current_win(win)
      if job_id and vim.fn.jobwait({job_id}, 0)[1] == -1 then
        vim.fn.chansend(job_id, 'py ' .. filename .. '\n')
      else
        vim.cmd('term cmd /c echo py ' .. filename .. ' && py "' .. filename .. '"')
      end
      setup_return_autocmd(vim.api.nvim_get_current_win())
      return
    end
  end

  vim.cmd('normal! gg')
  vim.cmd('belowright split')
  vim.cmd('resize 15')
  vim.cmd('term cmd /c echo py ' .. filename .. ' && py "' .. filename .. '"')
  setup_return_autocmd(vim.api.nvim_get_current_win())
end
EOF

call plug#begin('~/.config/nvim/autoload/plugged')

	Plug 'nvim-tree/nvim-tree.lua'			" File Explorer
	Plug 'nvim-tree/nvim-web-devicons'		" File Explorer Icons
	Plug 'windwp/nvim-autopairs'			" Auto Pair Braces	
	Plug 'itchyny/lightline.vim'			" Makes Status Bar Fancy
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Better Syntax Highlighting
	Plug 'numToStr/Comment.nvim'			" Comment out lines
	" Autocomplete Stuff Start
	Plug 'neovim/nvim-lspconfig'			" Easy LSP configuration
	Plug 'williamboman/mason.nvim'			" Installs language servers
	Plug 'williamboman/mason-lspconfig.nvim'
	Plug 'hrsh7th/cmp-nvim-lsp'				" Autocomplete
	Plug 'hrsh7th/cmp-buffer'
	Plug 'hrsh7th/cmp-path'
	Plug 'hrsh7th/cmp-cmdline'
	Plug 'hrsh7th/nvim-cmp'
	Plug 'hrsh7th/cmp-vsnip'
	Plug 'hrsh7th/vim-vsnip'

call plug#end()

" Enabling custom colorscheme
:colorscheme jellybeans
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ }

filetype plugin indent on

syntax enable

" Make suggestions colorscheme match jellybeans
" CMP Menu General
highlight CmpItemAbbr guifg=#e8e8d3 guibg=NONE
highlight CmpItemAbbrDeprecated guifg=#888888 guibg=NONE gui=strikethrough
highlight CmpItemAbbrMatch guifg=#fad07a guibg=NONE gui=bold
highlight CmpItemAbbrMatchFuzzy guifg=#fad07a guibg=NONE gui=bold
highlight CmpItemMenu guifg=#888888 guibg=NONE gui=italic

" CMP Kinds
highlight CmpItemKindText guifg=#e8e8d3 guibg=NONE
highlight CmpItemKindMethod guifg=#fad07a guibg=NONE
highlight CmpItemKindFunction guifg=#fad07a guibg=NONE
highlight CmpItemKindConstructor guifg=#fad07a guibg=NONE
highlight CmpItemKindField guifg=#8fbfdc guibg=NONE
highlight CmpItemKindVariable guifg=#e8e8d3 guibg=NONE
highlight CmpItemKindClass guifg=#ffb964 guibg=NONE
highlight CmpItemKindInterface guifg=#ffb964 guibg=NONE
highlight CmpItemKindModule guifg=#ffb964 guibg=NONE
highlight CmpItemKindProperty guifg=#8fbfdc guibg=NONE
highlight CmpItemKindUnit guifg=#cf6a4c guibg=NONE
highlight CmpItemKindValue guifg=#cf6a4c guibg=NONE
highlight CmpItemKindEnum guifg=#ffb964 guibg=NONE
highlight CmpItemKindKeyword guifg=#8197bf guibg=NONE
highlight CmpItemKindSnippet guifg=#99ad6a guibg=NONE
highlight CmpItemKindColor guifg=#99ad6a guibg=NONE
highlight CmpItemKindFile guifg=#e8e8d3 guibg=NONE
highlight CmpItemKindReference guifg=#e8e8d3 guibg=NONE
highlight CmpItemKindFolder guifg=#e8e8d3 guibg=NONE
highlight CmpItemKindEnumMember guifg=#cf6a4c guibg=NONE
highlight CmpItemKindConstant guifg=#cf6a4c guibg=NONE
highlight CmpItemKindStruct guifg=#ffb964 guibg=NONE
highlight CmpItemKindEvent guifg=#ffb964 guibg=NONE
highlight CmpItemKindOperator guifg=#8fbfdc guibg=NONE
highlight CmpItemKindTypeParameter guifg=#ffb964 guibg=NONE

" Fixes spelling mistakes with <Ctrl - L>
autocmd FileType tex setlocal spell
:set spelllang=nl,en_gb
:set spellsuggest=best,9
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

" Lua setup for treesitter
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "cpp", "python"},

  sync_install = false,

  highlight = {

    enable = true,

  },
}
EOF

" Lua setup for nvim-tree
lua <<EOF
require("nvim-tree").setup({})
EOF

set completeopt=menu,menuone,noselect

" Lua setup for Autocomplete
" Language Server Setup
lua <<EOF
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "clangd", "pyright" }, -- for cpp and python
  automatic_enable = true
})

vim.lsp.config('clangd', {})
vim.lsp.config('pyright', {})
vim.lsp.enable({'clangd', 'pyright'})
EOF

" Lua setup for commenting out with Ctrl-/
lua <<EOF
require('Comment').setup({
  toggler = {
    line = '<C-_>',
  },
  opleader = {
    line = '<C-_>',
  },
})
EOF

" Autocomplete setup
lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
	  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
	  ['<C-f>'] = cmp.mapping.scroll_docs(4),
	  ['<Tab>'] = cmp.mapping.select_next_item(),
	  ['<S-Tab>'] = cmp.mapping.select_prev_item(),
	  ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

EOF

" Lua setup for autopairs
lua <<EOF
require("nvim-autopairs").setup()
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
EOF

