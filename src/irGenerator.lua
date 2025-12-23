local IR_COMMANDS = require("src.irCommands")
local TOKENS = require("src.tokens")

local irGenerator = {}

function irGenerator.generate(evaluatedAst)
	local ir = {}

	for _, block in ipairs(evaluatedAst) do
		local right = block.right
		local left = block.left

		if right.value == "print" then
			if left.type == TOKENS.string then
				table.insert(ir, {
					command = IR_COMMANDS.pushString,
					value = left.value,
				})

				table.insert(ir, {
					command = IR_COMMANDS.printString,
				})
			elseif left.type == TOKENS.number then
				if math.type(tonumber(left.value)) == "integer" then
					table.insert(ir, {
						command = IR_COMMANDS.pushInt,
						value = left.value,
					})

					table.insert(ir, {
						command = IR_COMMANDS.printInt,
					})
				else
					table.insert(ir, {
						command = IR_COMMANDS.pushDouble,
						value = left.value,
					})

					table.insert(ir, {
						command = IR_COMMANDS.printDouble,
					})
				end
			else
				os.exit(1)
			end
		end
	end

	table.insert(ir, {
		command = "EXIT",
	})

	return ir
end

return irGenerator
