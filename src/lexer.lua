local TOKENS = require("src.tokens")
local BUILT_IN_FUNCTION_LIST = require("src.builtInFunctionList")

local lexer = {}

function lexer.tokenize(content)
	local len = content:len()

	local tokens = {}

	local i = 1
	while i <= content:len() do
		local char = content:sub(i, i)

		if char:match("%s") then --whitespace
			i = i + 1
		elseif content:sub(i, i + 1) == "->" then --arrow
			table.insert(tokens, {
				type = TOKENS.arrow,
			})

			i = i + 2
		elseif char == ";" then --semicolon
			table.insert(tokens, {
				type = TOKENS.semicolon,
			})

			i = i + 1
		elseif char:match("%a") then --word
			local start = i

			while i <= len and content:sub(i + 1, i + 1):match("%a") do
				i = i + 1
			end

			local word = content:sub(start, i)

			if word == "const" then
				table.insert(tokens, {
					type = TOKENS.const,
				})
			elseif BUILT_IN_FUNCTION_LIST[word] then
				table.insert(tokens, {
					type = TOKENS.func,
					value = word,
				})
			else
				table.insert(tokens, {
					type = TOKENS.identifier,
					value = word,
				})
			end

			i = i + 1
		elseif char:match("%d") then --number
			local start = i
			while i <= len and (content:sub(i + 1, i + 1):match("%d") or content:sub(i + 1, i + 1) == ".") do
				i = i + 1
			end

			local num = content:sub(start, i)

			table.insert(tokens, {
				type = TOKENS.number,
				value = num,
			})

			i = i + 1
		elseif char == '"' then --string
			local start = i

			while i <= len and content:sub(i + 1, i + 1) ~= '"' do
				i = i + 1
			end

			local str = content:sub(start + 1, i)

			table.insert(tokens, {
				type = TOKENS.string,
				value = str,
			})

			i = i + 2 --go past the closing "
		elseif char == "*" then
			table.insert(tokens, {
				type = TOKENS.snowflake,
			})

			i = i + 1
		elseif char == "/" then
			table.insert(tokens, {
				type = TOKENS.slash,
			})

			i = i + 1
		elseif char == "+" then
			table.insert(tokens, {
				type = TOKENS.plus,
			})

			i = i + 1
		elseif char == "-" then
			table.insert(tokens, {
				type = TOKENS.minus,
			})

			i = i + 1
		else
			print("Unexpected character: " .. char)
			os.exit(1)
		end
	end

	table.insert(tokens, {
		type = TOKENS.eof,
	})

	return tokens
end

return lexer
