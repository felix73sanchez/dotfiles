#!/usr/bin/env bash
# lib/detect.sh — Distro detection

detect_distro() {
  if [[ ! -f /etc/os-release ]]; then
    error "Cannot detect distro: /etc/os-release not found"
  fi

  # shellcheck source=/dev/null
  DISTRO_ID=$(. /etc/os-release && echo "$ID")
  DISTRO_NAME=$(. /etc/os-release && echo "$PRETTY_NAME")

  case "$DISTRO_ID" in
    arch|cachyos|endeavouros|manjaro)
      DISTRO_FAMILY="arch"
      ;;
    fedora)
      DISTRO_FAMILY="fedora"
      ;;
    debian|ubuntu|pop|linuxmint|zorin)
      DISTRO_FAMILY="debian"
      ;;
    *)
      error "Unsupported distro: $DISTRO_ID ($DISTRO_NAME)"
      ;;
  esac

  export DISTRO_ID DISTRO_NAME DISTRO_FAMILY
  info "Detected: $DISTRO_NAME (family: $DISTRO_FAMILY)"
}
