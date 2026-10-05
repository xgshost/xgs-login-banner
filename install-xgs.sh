#!/usr/bin/env bash
set -euo pipefail

if (( EUID != 0 )); then
  echo "Run with: sudo bash install-xgs.sh" >&2
  exit 1
fi

# Back up PAM files once, then disable their MOTD lines.
for file in /etc/pam.d/sshd /etc/pam.d/login; do
  [[ -f "$file" ]] || continue

  if grep -Eq '^[[:space:]]*[^#].*pam_motd\.so' "$file"; then
    [[ -e "$file.xgs-backup" ]] || cp -a "$file" "$file.xgs-backup"
    sed -i '/pam_motd\.so/ { /^[[:space:]]*#/! s|^|# disabled by XGS: |; }' "$file"
  fi
done

cat > /usr/local/bin/xgs-banner <<'BANNER'
#!/usr/bin/env bash

x=(
  'X   X'
  ' X X '
  '  X  '
  ' X X '
  'X   X'
)

g=(
  ' GGG '
  'G    '
  'G  GG'
  'G   G'
  ' GGG '
)

s=(
  ' SSS '
  'S    '
  ' SSS '
  '    S'
  'SSSS '
)

logo=()
for i in {0..4}; do
  logo+=("${x[i]}   ${g[i]}   ${s[i]}")
done

os=Linux
if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  os=${PRETTY_NAME:-Linux}
fi

memory=$(free -h 2>/dev/null | awk '/^Mem:/ {print $3 " used / " $2 " total"}')
disk=$(df -hP / 2>/dev/null | awk 'NR==2 {print $3 " used / " $2 " total (" $5 " used)"}')
load=$(awk '{print $1 "  " $2 "  " $3}' /proc/loadavg 2>/dev/null)
ips=$(hostname -I 2>/dev/null | xargs || true)
uptime_text=$(uptime -p 2>/dev/null || uptime)

stats=(
  "Host:    $(hostname 2>/dev/null || echo unknown)"
  "OS:      ${os:-unknown}"
  "Kernel:  $(uname -r 2>/dev/null || echo unknown)"
  "Uptime:  ${uptime_text:-unknown}"
  "Load:    ${load:-unknown}"
  "CPU:     $(getconf _NPROCESSORS_ONLN 2>/dev/null || echo unknown) cores"
  "Memory:  ${memory:-unknown}"
  "Disk /:  ${disk:-unknown}"
  "IP:      ${ips:-unknown}"
  "WARNING: Unauthorised access is prohibited."
)

width=0
for text in "${logo[@]}" "${stats[@]}"; do
  ((${#text} > width)) && width=${#text}
done

cyan=
magenta=
green=
reset=
if [[ -t 1 && -n ${TERM:-} && $TERM != dumb && -z ${NO_COLOR:-} ]]; then
  cyan=$'\033[36m'
  magenta=$'\033[1;35m'
  green=$'\033[32m'
  reset=$'\033[0m'
fi

draw_border() {
  local dashes
  printf -v dashes '%*s' "$((width + 2))" ''
  dashes=${dashes// /-}
  printf '    %s+%s+%s\n' "$cyan" "$dashes" "$reset"
}

draw_row() {
  local text=$1 shade=$2 centered=${3:-no}
  local left right padded

  if [[ $centered == yes ]]; then
    left=$(((width - ${#text}) / 2))
    right=$((width - ${#text} - left))
    printf -v padded '%*s%s%*s' "$left" '' "$text" "$right" ''
  else
    printf -v padded '%-*s' "$width" "$text"
  fi

  printf '    %s| %s |%s\n' "$shade" "$padded" "$reset"
}

draw_border
for text in "${logo[@]}"; do
  draw_row "$text" "$magenta" yes
done
draw_border

printf '\n'

draw_border
for text in "${stats[@]}"; do
  draw_row "$text" "$green"
done
draw_border
BANNER

chmod 755 /usr/local/bin/xgs-banner

cat > /etc/profile.d/xgs-banner.sh <<'PROFILE'
case $- in *i*) ;; *) return ;; esac
[ -n "${XGS_BANNER_SHOWN:-}" ] && return
XGS_BANNER_SHOWN=1
export XGS_BANNER_SHOWN

if [ -x /usr/local/bin/xgs-banner ]; then
  /usr/local/bin/xgs-banner
fi
PROFILE

chmod 644 /etc/profile.d/xgs-banner.sh
echo "XGS banner installed; Ubuntu MOTD display disabled."
