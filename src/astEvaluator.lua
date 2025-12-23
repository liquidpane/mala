local tokens = require("src.tokens")

local evalFunctions = {
	[tokens.plus] = function(left, right)
		local sum = left.value + right.value
		sum = math.tointeger(sum) or sum

		return sum, tokens.number
	end,

	[tokens.minus] = function(left, right)
		local product = left.value - right.value
		product = math.tointeger(product) or product

		return product, tokens.number
	end,

	[tokens.snowflake] = function(left, right)
		local product = left.value * right.value
		product = math.tointeger(product) or product

		return product, tokens.number
	end,

	[tokens.slash] = function(left, right)
		local product = left.value / right.value
		product = math.tointeger(product) or product

		return product, tokens.number
	end,
}

function evaluateSide(side)
	if side.type ~= tokens.eval then
		return side
	end

	local left = evaluateSide(side.value.left)
	local right = evaluateSide(side.value.right)
	local operator = side.value.operator

	local value, type = evalFunctions[operator.type](left, right)

	return {
		type = type,
		value = value,
	}
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

		evaluatedAst[i] = evaluatedBlock
	end

	return evaluatedAst
end

return astEvaluator
