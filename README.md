# 🧮 BatchSell

A **high-performance adaptive inventory selling system** for Roblox games. Designed for experiences where players may sell **hundreds or thousands of items** at once, `BatchSell` automatically calculates optimal batch sizes and avoids performance spikes while remaining easy to plug in.

> ✅ Great for RPGs, Simulators, Tycoons, and Gacha-style games.

---

## 🚀 Features

- 📦 **Adaptive batch sizing** — prevents frame drops and stalls.
- 🔁 **Custom item sell handler** — plug in your own cash logic.
- 🧼 **Blacklist filter** — skip unsellable or protected items.
- 🧪 **Benchmarking** — optional time logging for large sales.
- 🧩 **Minimal API** — one function, many features.

---

## 📥 Installation

1. Clone or download `BatchSell.lua` into your `ReplicatedStorage` or `Shared` folder.
2. Require it wherever you need to process item sales:

```lua
local BatchSell = require(path.to.BatchSell)
```

---

## 🧩 API Reference

### `BatchSell(items: {Tool}, config: SellConfig)`

#### Parameters:

| Name     | Type         | Description                       |
| -------- | ------------ | --------------------------------- |
| `items`  | `{Tool}`     | Array of Tool instances to sell.  |
| `config` | `SellConfig` | Configuration table for behavior. |

#### `SellConfig` structure:

```lua
type SellConfig = {
	onSellItem: (item: Tool) -> number,
	blacklistedTags: { string }?, -- default: { "Feed" }
	minBatchSize: number?,        -- default: 5
	maxBatchSize: number?,        -- default: 50
	benchmarkThreshold: number?, -- default: 50 (items)
}
```

| Field                | Required | Description                                                      |
| -------------------- | -------- | ---------------------------------------------------------------- |
| `onSellItem`         | ✅ Yes   | Function called for each item. Return the item's worth (number). |
| `blacklistedTags`    | ❌ No    | Items with these tags will be skipped.                           |
| `minBatchSize`       | ❌ No    | Minimum batch size. Default: `5`.                                |
| `maxBatchSize`       | ❌ No    | Maximum batch size. Default: `50`.                               |
| `benchmarkThreshold` | ❌ No    | Minimum count to log benchmark. Default: `50`.                   |

---

## 🧪 Example

```lua
local BatchSell = require(ReplicatedStorage.BatchSell)

local function CustomSellFunction(item)
	local worth = item:GetAttribute("Worth") or 0
	MyCashModule.IncrementCash(item, worth)
	return worth
end

BatchSell(player.Backpack:GetChildren(), {
	onSellItem = CustomSellFunction,
	blacklistedTags = { "Feed", "Locked" },
	minBatchSize = 10,
	maxBatchSize = 100,
})
```

---

## 🧠 Performance & Adaptive Batching

To avoid long frame times or script timeouts, `BatchSell` divides the item list into smaller batches. It uses a **square root decay model** to dynamically adjust the batch size depending on total item count.

### 📐 Formula

Let:

- $C$: number of items
- $B_{\text{min}}$: minimum batch size (default = 5)
- $B_{\text{max}}$: maximum batch size (default = 50)

Then batch size $B$ is:

$$
B = \left\lfloor B_{\text{min}} + (B_{\text{max}} - B_{\text{min}}) \cdot \text{clamp}\left(\frac{1}{\sqrt{C}}, 0.1, 1\right) \right\rfloor
$$

This results in:

- 🔹 Small inventories: near `maxBatchSize` (faster).
- 🔹 Large inventories: smaller batches to reduce lag.

Each batch is processed per frame with `task.wait()`, allowing the scheduler to yield and keep frame rate high.

---

## 🔐 Safety & Best Practices

- Always validate player state inside `onSellItem`.
- Avoid modifying the original `items` array in-place.
- Ensure all `item:Destroy()` calls happen **after** value is extracted.

---

## 📄 License

MIT License. Free to use, modify, and distribute.

---
