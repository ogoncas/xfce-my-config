#!/usr/bin/env bash
#═══════════════════════════════════════════════════════════════
#  autostart.sh — inicializa bandeja, Polybar e autohide.
#
#  REESCRITA: a versão anterior sempre subia um novo "snixembed"
#  (duplicando instâncias a cada reload) e encerrava a Polybar
#  antiga só com killall + polling fixo de 1s. O autohide antigo
#  era morto e recriado por nome/pkill -f, um método frágil. Agora:
#
#  - snixembed só inicia se ainda não estiver rodando.
#  - a Polybar antiga recebe "polybar-msg cmd quit" (encerramento
#    gracioso) e só usamos pkill como último recurso, com espera
#    curta (0.1s) em vez de 1s fixo.
#  - autohide.sh cuida da própria instância única via flock (ver
#    o próprio script); aqui só o chamamos, sem tentar matar nada.
#═══════════════════════════════════════════════════════════════

SCRIPTS_DIR="$HOME/.config/polybar/scripts"

# snixembed: só inicia se ainda não houver uma instância rodando
pgrep -x snixembed >/dev/null || snixembed &

# Encerra a Polybar anterior de forma graciosa e só força se necessário
if pgrep -u "$UID" -x polybar >/dev/null; then
    polybar-msg cmd quit >/dev/null 2>&1
    for _ in $(seq 1 20); do
        pgrep -u "$UID" -x polybar >/dev/null || break
        sleep 0.1
    done
    pkill -u "$UID" -x polybar 2>/dev/null
fi

polybar modern &

# autohide.sh garante instância única sozinho (flock); se já
# houver uma rodando, essa chamada só sai sem efeito.
"$SCRIPTS_DIR/autohide.sh" &