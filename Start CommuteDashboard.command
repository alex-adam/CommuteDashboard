#!/bin/zsh

cd "${0:A:h}" || exit 1

if [[ ! -x ".env/bin/python" ]]; then
  echo "Could not find the project Python environment at .env/bin/python."
  echo "See the Setup section in README.md to create and install it."
  read -r "?Press Return to close..."
  exit 1
fi

echo "Starting CommuteDashboard at http://127.0.0.1:5000"
source ".env/bin/activate" || exit 1
python -m app.server &
server_pid=$!

for attempt in {1..30}; do
  if ! kill -0 "$server_pid" 2>/dev/null; then
    wait "$server_pid"
    echo "The server stopped before it was ready."
    read -r "?Press Return to close..."
    exit 1
  fi
  if /usr/bin/curl --silent --fail http://127.0.0.1:5000/ >/dev/null; then
    /usr/bin/open http://127.0.0.1:5000/
    break
  fi
  sleep 1
done

if ! /usr/bin/curl --silent --fail http://127.0.0.1:5000/ >/dev/null; then
  echo "The server did not become ready within 30 seconds."
  kill "$server_pid" 2>/dev/null
  wait "$server_pid" 2>/dev/null
  read -r "?Press Return to close..."
  exit 1
fi

echo "CommuteDashboard is running. Press Control-C to stop it."
wait "$server_pid"
