#!/usr/bin/env bash
#═══════════════════════════════════════════════════════════════
#  player.sh — status do player de mídia (MPRIS) para a Polybar
#  Requer: playerctl (sudo apt install playerctl)
#
#  Usado em tail=true: fica escutando eventos e imprime uma linha
#  a cada mudança. Quando não há player ativo, imprime uma linha
#  vazia e o módulo custom/script some da barra automaticamente.
#
#  REESCRITA: a versão anterior só escutava "playerctl --follow
#  status", que dispara apenas em play/pause. Trocar de faixa sem
#  pausar (metadata muda, status não) não atualizava a barra. Agora
#  escutamos status E metadata em paralelo. Também adicionamos um
#  trap para matar os processos filhos (os dois "playerctl --follow")
#  quando o script for encerrado, evitando órfãos ao reiniciar a
#  Polybar.
#═══════════════════════════════════════════════════════════════

MAX_LEN=40

command -v playerctl >/dev/null 2>&1 || { echo ""; exit 0; }

trap 'pkill -P $$ 2>/dev/null' EXIT INT TERM

print_status() {
    local player st status artist title icon text

    # Pega o primeiro player com status válido (Playing/Paused)
    player=$(playerctl -l 2>/dev/null | while read -r p; do
        st=$(playerctl -p "$p" status 2>/dev/null)
        if [[ "$st" == "Playing" || "$st" == "Paused" ]]; then
            echo "$p"
            break
        fi
    done)

    if [[ -z "$player" ]]; then
        echo ""
        return
    fi

    status=$(playerctl -p "$player" status 2>/dev/null)
    artist=$(playerctl -p "$player" metadata artist 2>/dev/null)
    title=$(playerctl -p "$player" metadata title 2>/dev/null)

    [[ -z "$title" ]] && { echo ""; return; }

    if [[ "$status" == "Playing" ]]; then
        icon="󰏤"   # pause icon (ação disponível)
    else
        icon="󰐊"   # play icon
    fi

    text="$title"
    [[ -n "$artist" ]] && text="$artist - $title"

    if (( ${#text} > MAX_LEN )); then
        text="${text:0:MAX_LEN}…"
    fi

    echo "$icon  $text"
}

# Primeira leitura imediata
print_status

# Escuta status (play/pause) e metadata (troca de faixa) em
# paralelo, mesclando os dois fluxos num único pipe.
{
    playerctl --follow status 2>/dev/null &
    playerctl --follow metadata 2>/dev/null &
    wait
} | while read -r _; do
    print_status
done