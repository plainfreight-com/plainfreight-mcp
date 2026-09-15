# Plain Freight MCP server

A hosted [Model Context Protocol](https://modelcontextprotocol.io) server that quotes real
freight. Ask it what it costs to ship something from China to the United States and it returns
an all-in delivered-duty-paid price from the same rate card a human customer is quoted from:
freight, US customs clearance, import duty and delivery to a US door, in one number.

No API key. No signup. Nothing to install.

```
https://plainfreight.com/api/mcp
```

Transport is Streamable HTTP, stateless, protocol version `2025-06-18` (also accepts
`2025-03-26` and `2024-11-05`).

## Add it to a client

Claude Code:

```bash
claude mcp add --transport http plain-freight https://plainfreight.com/api/mcp
```

Claude Desktop, Cursor, or anything reading a JSON config:

```json
{
  "mcpServers": {
    "plain-freight": {
      "type": "http",
      "url": "https://plainfreight.com/api/mcp"
    }
  }
}
```

Check it by hand:

```bash
curl -s -X POST https://plainfreight.com/api/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

## Tools

| Tool | What it does |
|---|---|
| `generate_offer` | Prices a shipment. Needs `product` and `weight_kg` (0.1 to 2000); `dimensions`, `origin`, `destination_zip`, `urgency`, `email`, `name`, `company` and `notes` all improve the answer. Pass carton sizes when you have them: for light bulky cargo the volumetric weight sets the price, not the scale weight. |
| `check_offer_status` | Polls the offer until `settled` is true. Every quote gets re-checked, which can add follow-up questions, change the options, or set `needs_review`. |
| `track_shipment` | Reads the live record for a booked shipment from its tracking link. Read-only. |

Two behaviours worth knowing before you build on it:

- **`needs_review` means the prices are withheld on purpose.** The goods look restricted
  (batteries, food, chemicals) and a person has to clear them first. Do not present a number to
  the user in that case; Plain Freight follows up by email. Branded goods are never held, they
  are priced on a different channel.
- **The tracking token is the credential.** Anyone holding the link can read that shipment, and
  the record deliberately excludes cost and margin fields.

Rate limits: 20 offers per hour per IP, 4 per email address, 30 across all agents per hour. For
bulk or programmatic access, email hello@plainfreight.com.

There is also a plain REST version of the same pricing call at
`POST https://plainfreight.com/api/v1/offer`, described in
[openapi.json](https://plainfreight.com/api/v1/openapi.json), and human documentation at
[plainfreight.com/for-agents](https://plainfreight.com/for-agents).

## Published reference data

The same engine feeds three pages that are free to cite, with CSV and JSON where it makes sense:

- [China to USA shipping price index](https://plainfreight.com/data/china-usa-shipping-price-index):
  dated door-to-door prices at twelve weights from 0.5 kg to 1,000 kg, with duty status and
  transit time on every row.
- [Chargeable weight reference](https://plainfreight.com/data/chargeable-weight-china-usa): what
  fifteen real cartons bill, and the same cartons at three divisors.
- [US import rules timeline](https://plainfreight.com/data/us-import-rules-timeline): every de
  minimis and entry change since May 2025 with its Federal Register citation.

The price-index data is also published as a dataset at
[plainfreight-com/china-usa-freight-price-index](https://github.com/plainfreight-com/china-usa-freight-price-index).

## What Plain Freight is

A China to USA freight agency for small importers: one all-in DDP price on shipments from 100 g
to 2,000 kg, quoted before pickup. Plain Freight is a trading name of Fisto LLC, a Wyoming
limited liability company. The price does not include cargo insurance, which the customer
arranges separately.

Questions, or a shipment that needs a human: hello@plainfreight.com

## Licence

MIT for the contents of this repository. The MCP server itself is a live commercial service;
using it means quoting real freight, so treat the prices as real.
