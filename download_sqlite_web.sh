#!/bin/bash

# Create sqlite3 directory if it doesn't exist
mkdir -p web/sqlite3

# Download SQLite web worker files
curl -L https://github.com/simolus3/sqlite3.dart/raw/main/sqlite3_web/lib/src/worker/sqlite3.wasm -o web/sqlite3/sqlite3.wasm
curl -L https://github.com/simolus3/sqlite3.dart/raw/main/sqlite3_web/lib/src/worker/sqlite3.js -o web/sqlite3/sqlite3.js
curl -L https://github.com/simolus3/sqlite3.dart/raw/main/sqlite3_web/lib/src/worker/sqlite3_worker.js -o web/sqlite3/sqlite3_worker.js 