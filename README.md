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

## Текущее поведение

- Leader: `Ctrl-a`
- Навигация по панелям: `Ctrl-h`, `Ctrl-j`, `Ctrl-k`, `Ctrl-l`
- Разделение панелей: `Leader \` и `Leader -`
- Табы: `Leader c`, `Leader x`, `Leader n`, `Leader p`, `Leader 1..9`
- Поиск и выбор: `Leader f`, `Leader Space`, `Leader v`
- Launcher: `Leader Shift-l`
- Командная палитра: `Leader Shift-p`
- Workspace: `Leader w`
- Новый shell в отдельном tab: `Leader s`
- Статус справа в tab bar показывает `SSH`, `WS` и `DIR` для активной панели

## Основные клавиши macOS

- `Cmd-t`: новый tab
- `Cmd-w`: закрыть текущую панель
- `Cmd-Shift-w`: закрыть текущий tab
- `Cmd-Enter`: полноэкранный режим
- `Cmd-[`: предыдущий tab
- `Cmd-]`: следующий tab

## Thanks for the inspiration

- [Josean Martinez](https://www.youtube.com/@joseanmartinez)
- [Lazar Nikolov](https://www.youtube.com/@nikolovlazar)
- ChatGPT
