#!/usr/bin/env bash
# Quote a shipment through the Plain Freight MCP server, start to finish.
# No key needed. Usage: ./quote.sh
set -euo pipefail
MCP="https://plainfreight.com/api/mcp"

call() {
  curl -s -X POST "$MCP" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "$1"
}

echo "== tools"
call '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | python3 -m json.tool | head -20

echo "== offer"
OUT=$(call '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"generate_offer","arguments":{"product":"LED desk lamps, 200 units","weight_kg":60,"dimensions":"4 cartons, 60x40x40 cm each","origin":"Shenzhen","destination_zip":"90001","urgency":"Need best balance of cost and speed"}}}')
echo "$OUT" | python3 -m json.tool | head -40

echo
echo "Take the quote_id from that response and poll it:"
echo '  check_offer_status {"quote_id":"<id>"}'
echo "settled=false means the agent check is still running."
