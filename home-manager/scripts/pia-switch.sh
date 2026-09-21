#!/usr/bin/env bash
set -euo pipefail

# Fuzzy-pick a PIA server location and switch to it, entirely through
# NetworkManager - no sudo.
#
# This works because every PIA OpenVPN server shares one CA certificate,
# so switching location is just: create a connection with that CA and
# the credentials below, with `remote` pointed at the chosen location.
#
# usage: pia-switch            # fuzzy-pick a location and switch to it
#        pia-switch <location> # switch straight to a known location code

CA_PATH="/home/nixuser/.local/share/networkmanagement/certificates/nm-openvpn/us_houston-aes-128-cbc-udp-dns-ca.pem"
CREDENTIALS_FILE="$HOME/.config/pia/credentials"

if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "error: $CREDENTIALS_FILE not found." >&2
  echo "Create it with your PIA username on line 1 and password on line 2, then: chmod 600 $CREDENTIALS_FILE" >&2
  exit 1
fi

perms=$(stat -c '%a' "$CREDENTIALS_FILE")
if [ "$perms" != "600" ]; then
  echo "error: $CREDENTIALS_FILE must be readable only by you (chmod 600 $CREDENTIALS_FILE)" >&2
  exit 1
fi

PIA_USERNAME=$(sed -n '1p' "$CREDENTIALS_FILE")
PIA_PASSWORD=$(sed -n '2p' "$CREDENTIALS_FILE")
if [ -z "$PIA_USERNAME" ] || [ -z "$PIA_PASSWORD" ]; then
  echo "error: $CREDENTIALS_FILE must have the username on line 1 and password on line 2" >&2
  exit 1
fi

# Prefer the live list from the `pia`/services.pia systemd units when
# present (stays current if PIA adds/removes servers); fall back to a
# baked-in snapshot otherwise, since that module's source can go missing
# on a given machine without breaking this script.
locations=$(systemctl list-unit-files 2>/dev/null \
  | awk '/^openvpn-.*\.service/{print $1}' \
  | sed -E 's/^openvpn-(.*)\.service$/\1/' \
  | grep -vx 'restart')

if [ -z "$locations" ]; then
  locations='albania
algeria
andorra
argentina
armenia
au-adelaide
au-brisbane
au-melbourne
au-perth
australia-streaming-optimized
austria
au-sydney
bahamas
bangladesh
belgium
bolivia
bosnia-and-herzegovina
brazil
bulgaria
cambodia
ca-montreal
ca-ontario
ca-ontario-streaming-optimized
ca-toronto
ca-vancouver
chile
china
colombia
costa-rica
croatia
cyprus
czech-republic
de-berlin
de-frankfurt
de-germany-streaming-optimized
dk-copenhagen
dk-streaming-optimized
ecuador
egypt
es-madrid
estonia
es-valencia
fi-helsinki
fi-streaming-optimized
france
georgia
greece
greenland
guatemala
hong-kong
hungary
iceland
india
indonesia
ireland
isle-of-man
israel
it-milano
it-streaming-optimized
jp-streaming-optimized
jp-tokyo
kazakhstan
latvia
liechtenstein
lithuania
luxembourg
macao
malaysia
malta
mexico
moldova
monaco
mongolia
montenegro
morocco
nepal
netherlands
new-zealand
nigeria
nl-netherlands-streaming-optimized
north-macedonia
norway
panama
peru
philippines
poland
portugal
qatar
romania
saudi-arabia
serbia
se-stockholm
se-streaming-optimized
singapore
slovakia
slovenia
south-africa
south-korea
sri-lanka
switzerland
taiwan
turkey
uk-london
uk-manchester
ukraine
uk-southampton
uk-streaming-optimized
united-arab-emirates
uruguay
us-alabama
us-alaska
us-arkansas
us-atlanta
us-baltimore
us-california
us-chicago
us-connecticut
us-denver
us-east
us-east-streaming-optimized
us-florida
us-honolulu
us-houston
us-idaho
us-indiana
us-iowa
us-kansas
us-kentucky
us-las-vegas
us-louisiana
us-maine
us-massachusetts
us-michigan
us-minnesota
us-mississippi
us-missouri
us-montana
us-nebraska
us-new-hampshire
us-new-mexico
us-new-york
us-north-carolina
us-north-dakota
us-ohio
us-oklahoma
us-oregon
us-pennsylvania
us-rhode-island
us-salt-lake-city
us-seattle
us-silicon-valley
us-south-carolina
us-south-dakota
us-tennessee
us-texas
us-vermont
us-virginia
us-washington-dc
us-west
us-west-streaming-optimized
us-west-virginia
us-wilmington
us-wisconsin
us-wyoming
venezuela
vietnam'
fi

if [ "$#" -ge 1 ]; then
  location=$1
  if ! printf '%s\n' "$locations" | grep -qx -- "$location"; then
    echo "error: unknown location '$location'" >&2
    exit 1
  fi
else
  location=$(printf '%s\n' "$locations" | sort -u | fzf --prompt="PIA location> ")
  [ -n "$location" ] || exit 1
fi

conn_name="pia_${location//-/_}"

if ! nmcli -t -f NAME connection show | grep -qx -- "$conn_name"; then
  echo "creating connection for $location..."
  nmcli connection add type vpn con-name "$conn_name" ifname -- \
    vpn.service-type org.freedesktop.NetworkManager.openvpn >/dev/null
  nmcli connection modify "$conn_name" \
    vpn.data \
      "auth = sha1, ca = $CA_PATH, challenge-response-flags = 2, cipher = aes-128-cbc, compress = yes, connection-type = password, dev = tun, password-flags = 0, remote = ${location}.privacy.network:1198, remote-cert-tls = server, reneg-seconds = 0, username = $PIA_USERNAME" \
    vpn.user-name "$PIA_USERNAME" \
    vpn.secrets "password=$PIA_PASSWORD"
fi

# Bring down whatever PIA connection is currently active so we don't end
# up with two tunnels racing for the default route.
active_vpns=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="vpn"{print $1}')
for c in $active_vpns; do
  [ "$c" = "$conn_name" ] && continue
  nmcli connection down "$c" >/dev/null
done

nmcli connection up "$conn_name"
echo "switched to $location"
