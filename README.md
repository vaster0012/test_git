# test_git — Vaster bootstrap

Bootstrap-скрипт для Debian/Ubuntu: устанавливает набор CLI-пакетов, настраивает Zsh/Oh My Zsh/Powerlevel10k и может клонировать этот репозиторий в `~/projects/test_git`.

## Быстрый запуск

Рекомендуемый вариант — сначала скачать скрипт, при необходимости посмотреть его, а затем запустить:

```bash
curl -fsSL https://raw.githubusercontent.com/vaster0012/test_git/main/setup_enviroment.sh -o /tmp/vaster-bootstrap.sh
less /tmp/vaster-bootstrap.sh
sudo bash /tmp/vaster-bootstrap.sh
```

Без аргументов откроется интерактивное меню.

Полная установка без меню:

```bash
sudo bash /tmp/vaster-bootstrap.sh --full
```

Если скрипт запущен через `sudo`, пользовательские Zsh-конфиги ставятся в домашний каталог исходного пользователя (`$SUDO_USER`), а не в `/root`.

## Режимы

```text
-h, --help          помощь
-a, --check         проверить пакеты из packages.txt
-p, --packages      установить отсутствующие пакеты
-z, --zsh-only      установить/обновить Zsh-окружение
-g, --git-only      клонировать/обновить репозиторий в ~/projects/test_git
-f, --full          пакеты + репозиторий + Zsh
-s, --menu          открыть интерактивное меню
```

## Что делает Zsh-установка

- ставит `zsh`, `git`, `curl`, `fzf`, `wget`;
- клонирует или обновляет Oh My Zsh;
- устанавливает Powerlevel10k;
- устанавливает `zsh-autosuggestions` и `zsh-syntax-highlighting`;
- сохраняет существующие `~/.zshrc` и `~/.p10k.zsh` как timestamped backup;
- загружает настроенные `.zshrc` и `.p10k.zsh` из `vaster0012/first-config-zsh`, привязанные к проверенному commit `a0b2e591e2151bd3b85feadbec52a600d601f2ed`;
- пытается сделать Zsh оболочкой пользователя по умолчанию через `chsh`.

Скрипт больше не добавляет `exec zsh` в `.bashrc` и не выполняет HTML-страницу GitHub как shell-код.

## Требования

- Debian/Ubuntu или другая система с `apt-get`/`dpkg`;
- доступ в интернет;
- root или пользователь с `sudo` для установки APT-пакетов.

## Повторный запуск

Установка рассчитана на повторный запуск: уже установленные APT-пакеты пропускаются, Git-репозитории обновляются через `git pull --ff-only`, а существующие Zsh-конфиги резервируются перед заменой.
