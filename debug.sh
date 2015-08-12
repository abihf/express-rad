#!/bin/sh

PORT=3000 DEBUG=app:* NODE_ENV=development nodemon -w app -w config -e js,coffee server.js
