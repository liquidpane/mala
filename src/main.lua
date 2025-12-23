local lexer = require("src.lexer")
local parser = require("src.parser")
local astEvaluator = require("src.astEvaluator")
local irGenerator = require("src.irGenerator")

local function readFile()
	if not arg[1] then
		print("Incorrect usage")
		os.exit(1)
	end

	local fileName = arg[1]

	local file, err = io.open(fileName, "r")
	if not file then
		print("Error opening file:", err)
		os.exit(1)
	end

	local content = file:read("*a")
	file:close()

	return content
end

local content = readFile()
local tokens = lexer.tokenize(content)
local ast = parser.parse(tokens)
local evaluatedAst = astEvaluator.evaluate(ast)
local ir = irGenerator.generate(evaluatedAst)

local debug = arg[2] and arg[2] == "--debug"

local generator = require("src.fileGenerators.x86_64_linux")
generator.generate(ir, arg[1], debug)
