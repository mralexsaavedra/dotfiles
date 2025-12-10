" Minimal Modern Vim Config

" Basics
set nocompatible              " Be iMproved, required
filetype off                  " required

" UI
syntax on                     " Enable syntax highlighting
set number                    " Show line numbers
set ruler                     " Show line and column number
set cursorline                " Highlight current line
set background=dark           " Assume dark background
set laststatus=2              " Always show status line
set showmatch                 " Show matching brackets
set title                     " Set terminal title
set visualbell                " No beeping
set noerrorbells              " No noise

" Encoding
set encoding=utf-8

" Indentation
set autoindent                " Auto-indent new lines
set smartindent               " Smart auto-indent
set tabstop=2                 " Number of spaces per tab
set shiftwidth=2              " Number of spaces for auto-indent
set expandtab                 " Convert tabs to spaces
set smarttab                  " Be smart when using tabs

" Search
set hlsearch                  " Highlight search results
set incsearch                 " Incremental search
set ignorecase                " Ignore case when searching
set smartcase                 " Case sensitive if capital letters used

" Undo
set history=1000              " Increase undo history
set undolevels=1000

" Mouse
set mouse=a                   " Enable mouse support

" Clipboard
set clipboard=unnamed         " Use system clipboard

" No swap files
set nobackup
set nowritebackup
set noswapfile
