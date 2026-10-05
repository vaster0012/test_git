#!/usr/bin/env bash
set -Eeuo pipefail

readonly REPO="vaster0012/test_git"
readonly REPO_URL="https://github.com/${REPO}.git"
readonly RAW_BASE="https://raw.githubusercontent.com/${REPO}/main"
readonly ZSH_CONFIG_REPO="vaster0012/first-config-zsh"
readonly ZSH_CONFIG_REF="a0b2e591e2151bd3b85feadbec52a600d601f2ed"
readonly ZSH_CONFIG_RAW="https://raw.githubusercontent.com/${ZSH_CONFIG_REPO}/${ZSH_CONFIG_REF}/stab"

RED=$'\e[31m'
GRN=$'\e[32m'
YEL=$'\e[33m'
BLU=$'\e[34m'
EC=$'\e[0m'

info() { printf '%s\n' "${BLU}[INFO]${EC} $*"; }
ok() { printf '%s\n' "${GRN}[ OK ]${EC} $*"; }
warn() { printf '%s\n' "${YEL}[WARN]${EC} $*" >&2; }
fail() { printf '%s\n' "${RED}[FAIL]${EC} $*" >&2; exit 1; }

TARGET_USER="${SUDO_USER:-$(id -un)}"
[[ "$TARGET_USER" == "root" && "$(id -u)" -ne 0 ]] && TARGET_USER="$(id -un)"
TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6 || true)"
[[ -n "$TARGET_HOME" ]] || TARGET_HOME="$HOME"

TMP_FILES=()
cleanup() {
    local f
    for f in "${TMP_FILES[@]:-}"; do
        [[ -n "$f" ]] && rm -f -- "$f"
    done
}
trap cleanup EXIT

run_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        command -v sudo >/dev/null 2>&1 || fail "sudo is required when the script is not run as root"
        sudo "$@"
    fi
}

run_user() {
    if [[ "$(id -un)" == "$TARGET_USER" ]]; then
        "$@"
    elif [[ $EUID -eq 0 ]]; then
        command -v runuser >/dev/null 2>&1 || fail "runuser is required to execute commands as $TARGET_USER"
        runuser -u "$TARGET_USER" -- env HOME="$TARGET_HOME" "$@"
    else
        "$@"
    fi
}

require_debian_family() {
    command -v apt-get >/dev/null 2>&1 || fail "This installer currently supports Debian/Ubuntu systems with apt-get"
    command -v dpkg-query >/dev/null 2>&1 || fail "dpkg-query was not found"
}

ensure_bootstrap_tools() {
    local missing=()
    command -v curl >/dev/null 2>&1 || missing+=(curl)
    command -v git >/dev/null 2>&1 || missing+=(git)
    command -v whiptail >/dev/null 2>&1 || missing+=(whiptail)

    if ((${#missing[@]})); then
        info "Installing bootstrap dependencies: ${missing[*]}"
        run_root apt-get update -qq
        run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -q ca-certificates "${missing[@]}"
    fi
}

PACKAGES_FILE=""
download_packages_file() {
    PACKAGES_FILE="$(mktemp)"
    TMP_FILES+=("$PACKAGES_FILE")
    curl -fsSL "${RAW_BASE}/packages.txt" -o "$PACKAGES_FILE"
}

read_packages() {
    local file="$1"
    grep -Ev '^[[:space:]]*(#|$)' "$file" | awk '!seen[$0]++'
}

is_installed() {
    dpkg-query -W -f='${db:Status-Status}\n' "$1" 2>/dev/null | grep -q 'ok installed'
}

check_packages() {
    local packages_file="$1"
    local installed=0 missing=0 pkg

    printf '\n'
    info "Checking configured packages"
    while IFS= read -r pkg; do
        if is_installed "$pkg"; then
            ok "$pkg"
            ((installed+=1))
        else
            printf '%s\n' "${RED}[MISS]${EC} $pkg"
            ((missing+=1))
        fi
    done < <(read_packages "$packages_file")

    printf '\nInstalled: %d | Missing: %d | Total: %d\n' "$installed" "$missing" "$((installed + missing))"
}

install_packages() {
    local packages_file="$1"
    local pkg
    local missing=()

    while IFS= read -r pkg; do
        is_installed "$pkg" || missing+=("$pkg")
    done < <(read_packages "$packages_file")

    if ((${#missing[@]} == 0)); then
        ok "All configured packages are already installed"
        return 0
    fi

    info "Installing ${#missing[@]} missing package(s): ${missing[*]}"
    run_root apt-get update -qq
    run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
        -o Dpkg::Options::="--force-confdef" \
        -o Dpkg::Options::="--force-confold" \
        "${missing[@]}"
    ok "Package installation completed"
}

backup_file() {
    local file="$1"
    if [[ -e "$file" ]]; then
        local backup="${file}.bak.$(date '+%Y%m%d%H%M%S')"
        run_user cp -a -- "$file" "$backup"
        warn "Backed up $file to $backup"
    fi
}

clone_or_update() {
    local url="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        info "Updating $(basename "$dest")"
        run_user git -C "$dest" pull --ff-only
    elif [[ -e "$dest" ]]; then
        fail "$dest exists but is not a Git repository"
    else
        run_user git clone --depth=1 "$url" "$dest"
    fi
}

install_zsh() {
    info "Installing Zsh environment for user: $TARGET_USER"
    run_root apt-get update -qq
    run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -q zsh git curl fzf wget

    local omz_dir="${TARGET_HOME}/.oh-my-zsh"
    local custom_dir="${omz_dir}/custom"

    clone_or_update "https://github.com/ohmyzsh/ohmyzsh.git" "$omz_dir"
    run_user mkdir -p "$custom_dir/themes" "$custom_dir/plugins"
    clone_or_update "https://github.com/romkatv/powerlevel10k.git" "$custom_dir/themes/powerlevel10k"
    clone_or_update "https://github.com/zsh-users/zsh-autosuggestions.git" "$custom_dir/plugins/zsh-autosuggestions"
    clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$custom_dir/plugins/zsh-syntax-highlighting"

    backup_file "${TARGET_HOME}/.zshrc"
    backup_file "${TARGET_HOME}/.p10k.zsh"

    local zshrc_tmp p10k_tmp
    zshrc_tmp="$(mktemp)"
    p10k_tmp="$(mktemp)"
    TMP_FILES+=("$zshrc_tmp" "$p10k_tmp")
    curl -fsSL "${ZSH_CONFIG_RAW}/.zshrc" -o "$zshrc_tmp"
    curl -fsSL "${ZSH_CONFIG_RAW}/.p10k.zsh" -o "$p10k_tmp"
    run_root install -o "$TARGET_USER" -g "$(id -gn "$TARGET_USER")" -m 0644 "$zshrc_tmp" "${TARGET_HOME}/.zshrc"
    run_root install -o "$TARGET_USER" -g "$(id -gn "$TARGET_USER")" -m 0644 "$p10k_tmp" "${TARGET_HOME}/.p10k.zsh"

    local zsh_path
    zsh_path="$(command -v zsh)"
    if [[ "$(getent passwd "$TARGET_USER" | cut -d: -f7)" != "$zsh_path" ]]; then
        if run_root chsh -s "$zsh_path" "$TARGET_USER"; then
            ok "Default shell changed to $zsh_path for $TARGET_USER"
        else
            warn "Could not change the default shell automatically. Run: chsh -s $zsh_path"
        fi
    fi

    ok "Zsh environment installed for $TARGET_USER"
}

clone_project() {
    local projects_dir="${TARGET_HOME}/projects"
    local dest="${projects_dir}/test_git"
    run_user mkdir -p "$projects_dir"
    clone_or_update "$REPO_URL" "$dest"
    ok "Repository is available at $dest"
}

full_install() {
    local packages_file="$1"
    install_packages "$packages_file"
    clone_project
    install_zsh
}

show_help() {
    cat <<'HELP'
Vaster bootstrap for Debian/Ubuntu

Usage:
  setup_enviroment.sh [option]

Options:
  -h, --help          Show this help
  -a, --check         Check which configured APT packages are installed
  -p, --packages      Install missing packages from packages.txt
  -z, --zsh-only      Install/update Zsh, Oh My Zsh, Powerlevel10k and plugins
  -g, --git-only      Clone/update this repository in ~/projects/test_git
  -f, --full          Install packages, clone/update the repository and configure Zsh
  -s, --menu          Open the interactive menu

With no option, the interactive menu is opened.
Existing ~/.zshrc and ~/.p10k.zsh are backed up before replacement.
HELP
}

show_menu() {
    local packages_file="$1"
    local choice

    while true; do
        choice="$(whiptail --title "Vaster bootstrap" \
            --menu "Choose an action" 18 68 6 \
            "1" "FULL INSTALL" \
            "2" "INSTALL PACKAGES" \
            "3" "CHECK PACKAGES" \
            "4" "INSTALL / UPDATE ZSH" \
            "5" "CLONE / UPDATE REPOSITORY" \
            "6" "EXIT" \
            3>&1 1>&2 2>&3)" || return 0

        case "$choice" in
            1) full_install "$packages_file" ;;
            2) install_packages "$packages_file" ;;
            3) check_packages "$packages_file" ;;
            4) install_zsh ;;
            5) clone_project ;;
            6) return 0 ;;
        esac
    done
}

main() {
    local mode="menu"
    case "${1:-}" in
        ""|-s|--menu) mode="menu" ;;
        -h|--help) show_help; return 0 ;;
        -a|--check) mode="check" ;;
        -p|--packages) mode="packages" ;;
        -z|--zsh-only) mode="zsh" ;;
        -g|--git-only) mode="git" ;;
        -f|--full) mode="full" ;;
        *) fail "Unknown option: $1. Use --help." ;;
    esac

    [[ $# -le 1 ]] || fail "Only one mode option can be used at a time"
    require_debian_family
    ensure_bootstrap_tools

    download_packages_file

    case "$mode" in
        menu) show_menu "$PACKAGES_FILE" ;;
        check) check_packages "$PACKAGES_FILE" ;;
        packages) install_packages "$PACKAGES_FILE" ;;
        zsh) install_zsh ;;
        git) clone_project ;;
        full) full_install "$PACKAGES_FILE" ;;
    esac
}

main "$@"
