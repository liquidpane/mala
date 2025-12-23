local TOKENS = require("src.TOKENS")

local constants = {}

local evalFunctions = {
	[TOKENS.plus] = function(left, right)
		local sum = left.value + right.value
		sum = math.tointeger(sum) or sum

		return sum, TOKENS.number
	end,

	[TOKENS.minus] = function(left, right)
		local product = left.value - right.value
		product = math.tointeger(product) or product

		return product, TOKENS.number
	end,

	[TOKENS.snowflake] = function(left, right)
		local product = left.value * right.value
		product = math.tointeger(product) or product

		return product, TOKENS.number
	end,

	[TOKENS.slash] = function(left, right)
		local product = left.value / right.value
		product = math.tointeger(product) or product

		return product, TOKENS.number
	end,

	[TOKENS.createConst] = function(left, right)
		return right.value, TOKENS.initializedConst
	end,
}

function evaluateSide(side)
	if side.type ~= TOKENS.eval then
		if side.type == TOKENS.identifier and constants[side.value] then
			return {
				type = constants[side.value].type,
				value = constants[side.value].value,
			}
		end

		return side
	end

	if not side.value.left or not side.value.right then
		return side
	end

	local left = evaluateSide(side.value.left)
	local right = evaluateSide(side.value.right)
	local operator = side.value.operator or { type = TOKENS.createConst }

	local value, type = evalFunctions[operator.type](left, right)

	return {
		type = type,
		value = value,
	}
end

local function evaluateBlockForConstants(block)
	if block.right.type == TOKENS.initializedConst then
		constants[block.right.value] = { value = block.left.value, type = block.left.type }
		return nil
	end

	return block
end

local astEvaluator = {}

function astEvaluator.evaluate(ast)
	local evaluatedAst = {}

	for i, block in ipairs(ast) do
		local evaluatedBlock = {
			left = evaluateSide(block.left),
			right = evaluateSide(block.right),
			operator = block.operator,
		}

		evaluatedBlock = evaluateBlockForConstants(evaluatedBlock)

		table.insert(evaluatedAst, evaluatedBlock)
	end

	return evaluatedAst
end

return astEvaluator
