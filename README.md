# Plain Freight MCP server

A hosted [Model Context Protocol](https://modelcontextprotocol.io) server that quotes real
freight. Ask it what it costs to ship something from China to the United States and it returns
an all-in delivered-duty-paid price from the same pricing engine a human customer is quoted from:
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
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

## Tools

Five tools. Only `generate_offer` records anything; the other four only read. No tool books
or charges anything.

| Tool | What it does |
|---|---|
| `estimate_price` | A rough door to door cost in USD for air (and sea from 100 kg chargeable weight), from the same pricing engine. Needs `weight_kg`; `product`, carton sizes (`carton_length_cm`, `carton_width_cm`, `carton_height_cm`, `carton_count`) or `total_cbm` sharpen it. Returns the chargeable weight used (the greater of actual weight and carton volume in cm3 / 6,000), transit estimates and whether US import duty is included. Records nothing, contacts no one, needs no email. Goods that need a person to review them get no figure. |
| `check_goods` | Says whether a product (`product`, in the user's words) is priced at once or reviewed by a person first (for example batteries, chemicals, food, cosmetics, seeds, vapes or weapons), with a plain explanation and what documents to have ready. Same screen as `generate_offer`, so it predicts what an offer will do. Records nothing. Not legal or customs advice. |
| `generate_offer` | The firm offer. Needs `product` and `weight_kg` (0.1 to 2000); `dimensions`, `origin`, `destination_zip`, `urgency`, `email`, `name` and `notes` all improve the answer. Pass carton sizes when you have them: for light bulky cargo the volumetric weight sets the price, not the scale weight. Each call records a quote request, and if an `email` is given the written offer is mailed there once the second check settles (at most one offer email per address per day). Returns the options, a `quote_id` and a link to a booking form on plainfreight.com prefilled with the shipment. |
| `check_offer_status` | Polls an offer by `quote_id` until `settled` is true. Every quote gets a second check, which can add follow-up questions, change the options, or set `needs_review`. Read-only. |
| `track_shipment` | Reads the live record for a booked shipment from its `tracking_link` (`https://plainfreight.com/track/<token>`, or the bare token): current stage on the 10-stage lifecycle, route and dated events. Read-only. |

Booking happens outside the chat: the user opens the prefilled booking form, replies to the
offer email, or writes to hello@plainfreight.com quoting the `quote_id`. Nothing is paid before
the goods are weighed at the warehouse.

Two behaviours worth knowing before you build on it:

- **`needs_review` means the prices are withheld on purpose.** The goods look restricted
  (batteries, food, chemicals) and a person has to clear them first. Do not present a number to
  the user in that case; Plain Freight follows up by email.
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
