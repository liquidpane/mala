local TOKENS = require("src.tokens")
local IMPORTANCE = require("src.importance")

local function toBlocks(tokens)
	local blocks = {}

	local block = {}

	for i = 1, #tokens do
		local token = tokens[i]

		if token.type == TOKENS.semicolon then
			table.insert(blocks, block)
			block = {}
		else
			table.insert(block, token)
		end
	end

	return blocks
end

local function getLeastImportant(level)
	local leastImportance = -math.huge
	local leastImportant
	local leastImportantI

	for i = 1, #level do
		local token = level[i]

		local importance = IMPORTANCE[token.type]
		if importance and importance >= leastImportance then --the lower the importance the more important it is
			leastImportance = importance
			leastImportant = token
			leastImportantI = i
		end
	end

	return leastImportant, leastImportantI
end

local function getRight(level, centerI)
	local right = {}

	for i = centerI + 1, #level do
		local token = level[i]

		table.insert(right, token)
	end

	return right
end

local function getLeft(level, centerI)
	local left = {}

	for i = 1, centerI - 1 do
		local token = level[i]

		table.insert(left, token)
	end

	return left
end

local function evaluateSide(side)
	if #side == 1 then
		local type = side[1].type
		local value = side[1].value

		side = {
			type = type,
			value = value,
		}
	else
		side = evaluateLevel(side)
		side = {
			value = side,
			type = TOKENS.eval,
		}
	end

	return side
end

function evaluateLevel(level)
	local leastImportant, leastImportantI = getLeastImportant(level)
	if not leastImportant then
		return { right = level[2], left = level[1] }
	end

	local left = getLeft(level, leastImportantI)
	local right = getRight(level, leastImportantI)

	local newLevel = {
		operator = leastImportant,
		left = evaluateSide(left),
		right = evaluateSide(right),
	}

	return newLevel
end

function evaluateBlock(block)
	local left = {}
	local right = {}
	local fillRight = false
	for _, token in ipairs(block) do
		if token.type == TOKENS.arrow then
			fillRight = true
		else
			if fillRight then
				table.insert(right, token)
			else
				table.insert(left, token)
			end
		end
	end

	local level = {
		right = evaluateSide(right),
		left = evaluateSide(left),
		operator = TOKENS.arrow,
	}

	return level
end

local parser = {}

function parser.parse(tokens)
	local ast = {}

	local blocks = toBlocks(tokens)

	for i, block in ipairs(blocks) do
		local newBlock = evaluateBlock(block)
		ast[i] = newBlock
	end

	return ast
end

return parser
