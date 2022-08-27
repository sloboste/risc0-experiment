#!/usr/bin/env bash
set -e
cd /battleship-example
cargo run --bin battleship-web-server --release &
cd web/client
trunk serve --address 0.0.0.0
