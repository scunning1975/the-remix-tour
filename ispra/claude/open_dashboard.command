#!/bin/bash
lsof -ti:8080 | xargs kill 2>/dev/null
cd ~/Documents/YOUR_PROJECT && python3 dashboard_server.py &
sleep 1
open http://localhost:8080/
