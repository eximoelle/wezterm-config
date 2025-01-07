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

## Некоторые опции конфига

- ~~тема терминала переключается в зависимости от системной в MacOS~~
- ~~варианты тем настраиваются в `theme_manager.lua`, примеры тем перечислены [в документации Wezterm](https://wezfurlong.org/wezterm/config/appearance.html#color-scheme)~~
- ~~логика переключения тем вынесена в `theme_manager.lua`~~
- ~~вместе с темой терминала переключается тема Neovim с конфигом NvChad (через замену `theme` в таблице `M.base46` в файле `chadrc.lua`), сам конфиг лежит [в другом репозитории](https://github.com/eximoelle/nvconfig)~~
- подключён отдельный файл для кейбиндингов, добавлены недостающие

### Дополнение от 7/01/2025

- пока не смог победить гениальный конфиг NvChad в плане подхватывания параметров из его же богоподобного `chadrc.lua`, выделил функциональность автопереключения в отдельную ветку, может когда-нибудь вернусь, а пока сидим на одной тёмной теме и в терминале, и в Neovim, как в 1986-м, но идеи по решению люто приветствуются

## Некоторые клавиши

| Клавиша                  | Действие                                 |
| ------------------------ | ---------------------------------------- |
| `Cmd + t`                | Открыть новую вкладку                    |
| `^ + Shift + Tab`        | Переключить вкладку циклически           |
| `Cmd + 1..9`             | Переключить вкладку по номеру            |
| `Cmd + w`                | Закрыть текущую вкладку, панель или окно |
| `Cmd + n`                | Открыть новое окно                       |
| `^ + Shift + Opt + 5(%)` | Разделить вкладку вертикально            |
| `^ + Shift + ↑ ↓ ← →`    | Переключение между панелями              |
| `^ + Shift + X`          | Режим копирования                        |
| `^ + Shift + P`          | Показать палитру команд                  |

Показать доступные кейбиндинги:

```
wezterm show-keys
```

## Thanks for the inspiration

- [Josean Martinez](https://www.youtube.com/@joseanmartinez)
- [Lazar Nikolov](https://www.youtube.com/@nikolovlazar)
- ChatGPT
