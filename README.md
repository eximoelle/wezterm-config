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

## Некоторые клавиши

- **Leader** = **Ctrl + a**

- после нажатия Leader → есть ~1 секунда, чтобы нажать следующую клавишу.

### Панели (splits)

| Комбинация                     | Действие                        |
| ------------------------------ | ------------------------------- |
| **Leader + \|**                | Split горизонтально             |
| **Leader + -**                 | Split вертикально               |
| **Leader + h / j / k / l**     | Перейти влево/вниз/вверх/вправо |
| **Leader + ⇧ + ← / → / ↑ / ↓** | Изменить размер панели          |
| **Leader + z**                 | Зум панели (развернуть/сжать)   |

---

### Табы

| Комбинация       | Действие                       |
| ---------------- | ------------------------------ |
| **Leader + c**   | Новый таб                      |
| **Leader + x**   | Закрыть таб (с подтверждением) |
| **Leader + n**   | Следующий таб                  |
| **Leader + p**   | Предыдущий таб                 |
| **Leader + 1…9** | Перейти к табу №1…9            |

---

### Поиск и копирование

| Комбинация     | Действие                    |
| -------------- | --------------------------- |
| **Leader + v** | Copy Mode (выделение/копия) |
| **Leader + f** | Поиск по тексту             |

---

### Workspaces

| Комбинация     | Действие                 |
| -------------- | ------------------------ |
| **Leader + w** | Смена/создание workspace |

---

### Прочее

| Комбинация     | Действие                       |
| -------------- | ------------------------------ |
| **Leader + s** | Новый таб с shell (zsh/bash)   |
| **Leader + o** | Переключение прозрачности окна |

---

### Cmd-shortcuts (нативные macOS)

| Комбинация      | Действие                 |
| --------------- | ------------------------ |
| **⌘ + t**       | Новый таб                |
| **⌘ + w**       | Закрыть таб              |
| **⌘ + Enter**   | Fullscreen               |
| **⌘ + \[ / \]** | Предыдущий/следующий таб |

Показать доступные кейбиндинги:

```
wezterm show-keys
```

## Thanks for the inspiration

- [Josean Martinez](https://www.youtube.com/@joseanmartinez)
- [Lazar Nikolov](https://www.youtube.com/@nikolovlazar)
- ChatGPT
