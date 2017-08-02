#!/usr/bin/env bash

mkdir -p ~/.hex
echo '{username,<<"'${HEX_USERNAME}'">>}.' > ~/.hex/hex.config
echo '{key,<<"'${HEX_KEY}'">>}.' >> ~/.hex/hex.config

mkdir -p ~/.config/rebar3
echo '{plugins, [rebar3_hex]}.' > ~/.config/rebar3/rebar.config

mix hex.user passphrase <<EOF


EOF
mix hex.publish <<EOF

y
EOF
