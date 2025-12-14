## Установка

1. Установить Wezterm
   ```
   brew install wezterm
   ```
2. Скопировать репозиторий
   ```
   git clone https://github.com/eximoelle/wezterm-config.git ~/.config/wezterm
   ```
   или
   ```
   git clone git@github.com:eximoelle/wezterm-config.git ~/.config/wezterm
   ```
3. Выполнить в терминале:
   ```
   tempfile=$(mktemp) \
     && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
     && tic -x -o ~/.terminfo $tempfile \
     && rm $tempfile
   ```

[Подробности здесь](https://wezfurlong.org/wezterm/config/lua/config/term.html).

Полный список клавишных сочетаний см. в файле `KEYBINDINGS.md`.

## Thanks for the inspiration

- [Josean Martinez](https://www.youtube.com/@joseanmartinez)
- [Lazar Nikolov](https://www.youtube.com/@nikolovlazar)
- ChatGPT
