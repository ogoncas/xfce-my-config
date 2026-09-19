#!/usr/bin/env bash
#═══════════════════════════════════════════════════════════════
#  autohide.sh — esconde/mostra a Polybar conforme o estado da
#  janela ativa (fullscreen/maximizada = esconde).
#
#  FIX (v2): a v1 só observava _NET_ACTIVE_WINDOW, ou seja, só
#  reagia quando o FOCO mudava de janela. Um vídeo que entra em
#  fullscreen SEM trocar de janela ativa (o player já estava em
#  foco, e fullscreen é ativado nele mesmo) nunca disparava
#  evento — a Polybar ficava por cima do vídeo. É por isso que
#  abrir e cancelar a ferramenta de print "resolvia por acidente":
#  isso troca o foco duas vezes (print ganha foco, depois o vídeo
#  reganha foco), forçando uma nova checagem.
#
#  Agora observamos DOIS eventos em paralelo:
#    1) _NET_ACTIVE_WINDOW na raiz (troca de janela ativa)
#    2) _NET_WM_STATE da janela ativa atual (fullscreen/maximizada
#       muda sem trocar de janela)
#  Toda vez que a janela ativa muda, o watcher do item 2 é
#  reiniciado para apontar para a nova janela.
#
#  Os processos "xprop" são filhos diretos deste script (nada de
#  pipe/subshell no meio) e escrevem para uma FIFO comum, lida num
#  único loop no shell principal. Isso permite matá-los de forma
#  confiável com "pkill -P $$" ao encerrar — o bug de órfãos da v1
#  vinha de filhos escondidos dentro de um pipeline, que
#  "jobs -p"/trap não enxergava.
#
#  Instância única via flock, como na v1: autostart.sh não precisa
#  matar/recriar este script a cada reload da Polybar.
#═══════════════════════════════════════════════════════════════

LOCKFILE="/tmp/polybar-autohide.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0   # já existe uma instância rodando: sai

FIFO=$(mktemp -u /tmp/polybar-autohide.fifo.XXXXXX)
mkfifo "$FIFO"
exec 3<>"$FIFO"   # aberta para leitura+escrita: nunca dá EOF, nunca bloqueia o escritor

state_watcher_pid=""
current_win=""

cleanup() {
    trap - EXIT INT TERM
    pkill -P $$ 2>/dev/null
    exec 3>&-
    rm -f "$FIFO"
}
trap cleanup EXIT INT TERM

# (Re)inicia o watcher de _NET_WM_STATE apontando para a janela
# ativa atual. Chamado sempre que a janela ativa muda.
restart_state_watcher() {
    local win_id="$1"
    [[ -n "$state_watcher_pid" ]] && kill "$state_watcher_pid" 2>/dev/null
    state_watcher_pid=""
    [[ -z "$win_id" || "$win_id" == "0x0" ]] && return
    stdbuf -oL xprop -id "$win_id" -spy _NET_WM_STATE >"$FIFO" 2>/dev/null &
    state_watcher_pid=$!
}

apply_state() {
    local win_id="$1"
    [[ -z "$win_id" || "$win_id" == "0x0" ]] && return
    if xprop -id "$win_id" _NET_WM_STATE 2>/dev/null | grep -qE '_NET_WM_STATE_FULLSCREEN|_NET_WM_STATE_MAXIMIZED'; then
        polybar-msg cmd hide >/dev/null 2>&1
    else
        polybar-msg cmd show >/dev/null 2>&1
    fi
}

handle_event() {
    local win_id
    win_id=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $5}')
    if [[ "$win_id" != "$current_win" ]]; then
        current_win="$win_id"
        restart_state_watcher "$win_id"
    fi
    apply_state "$win_id"
}

# Checagem inicial (também liga o watcher de estado da janela já ativa)
handle_event

# Observa trocas de janela ativa, escrevendo eventos na mesma FIFO
stdbuf -oL xprop -root -spy _NET_ACTIVE_WINDOW >"$FIFO" 2>/dev/null &

# Loop único: reage tanto a troca de janela quanto a mudança de
# estado (fullscreen/maximizada) da janela atualmente ativa.
while IFS= read -r _ <&3; do
    handle_event
done