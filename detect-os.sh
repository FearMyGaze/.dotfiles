#!/bin/bash
detect_os_dir() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            if [[ -f /etc/os-release ]]; then
                . /etc/os-release
                echo "linux-${ID:-linux}"
            else
                echo "linux-unknown"
            fi
            ;;
        *)
            echo "$(uname -s | tr '[:upper:]' '[:lower:]')"
            ;;
    esac
}