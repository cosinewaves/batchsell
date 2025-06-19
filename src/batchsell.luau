--!strict
-- BatchSell.lua
-- A reusable module to batch-sell large inventories in Roblox efficiently.

local Players = game:GetService("Players")

export type SellConfig = {
	onSellItem: (item: Tool) -> number,
	blacklistedTags: { string }?, -- optional list of tags to skip
	minBatchSize: number?, -- default: 5
	maxBatchSize: number?, -- default: 50
	benchmarkThreshold: number?, -- default: 50 (number of items to trigger timing logs)
}

local function GetAdaptiveBatchSize(count: number, minBatch: number, maxBatch: number): number
	local scale = math.clamp(1 / math.sqrt(count), 0.1, 1)
	return math.floor(minBatch + (maxBatch - minBatch) * scale)
end

local function HasBlacklistedTag(item: Instance, blacklistedTags: {string}): boolean
	for _, tag in ipairs(blacklistedTags) do
		if item:HasTag(tag) then
			return true
		end
	end
	return false
end

local function BatchSell(items: {Tool}, config: SellConfig)
	local onSellItem = config.onSellItem
	local blacklistedTags = config.blacklistedTags or { "Feed" }
	local minBatch = config.minBatchSize or 5
	local maxBatch = config.maxBatchSize or 50
	local benchmarkThreshold = config.benchmarkThreshold or 50

	local totalWorth = 0
	local player: Player? = nil
	local filteredItems = {}

	-- Filter out blacklisted items
	for _, item in ipairs(items) do
		if not HasBlacklistedTag(item, blacklistedTags) then
			table.insert(filteredItems, item)
		end
	end

	local itemCount = #filteredItems
	local batchSize = GetAdaptiveBatchSize(itemCount, minBatch, maxBatch)
	local startTime = os.clock()

	for i = 1, itemCount, batchSize do
		for j = i, math.min(i + batchSize - 1, itemCount) do
			local item = filteredItems[j]
			if item and item.Parent and item.Parent.Parent then
				-- Get player from item
				if item.Parent:IsA("Model") then
					player = Players:GetPlayerFromCharacter(item.Parent)
				elseif item.Parent.Name == "Backpack" then
					player = item.Parent.Parent :: Player
				end

				local worth = onSellItem(item)
				print(`[BatchSell] Sold {item.Name} for ${worth}`)
				totalWorth += worth
				item:Destroy()
			end
		end
		task.wait()
	end

	if player and totalWorth > 0 then
		print(`[BatchSell] Total earned: ${totalWorth} by {player.Name}`)
	end

	local duration = os.clock() - startTime
	if itemCount >= benchmarkThreshold then
		local ms = math.floor(duration * 1000)
		print(`[BatchSell] Sold {itemCount} items in {ms} ms (BatchSize: {batchSize})`)
	end
end

return BatchSell
