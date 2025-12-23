local IR_COMMANDS = require("src.irCommands")

local generator = {}

function generator.generate(ir, fileName, debug)
	local data = {}

	table.insert(data, "section .data")
	table.insert(data, 'intFormat db "%d", 10, 0')
	table.insert(data, 'doubleFormat db "%lf", 10, 0')
	table.insert(data, 'stringFormat db "%s", 10, 0')

	local text = {}

	table.insert(text, "section .text")
	table.insert(text, "global main")
	table.insert(text, "extern printf") --getting printf from libc
	table.insert(text, "main:")
	table.insert(text, "sub rsp, 8") --align stack

	local lastStringValueIndex = 1
	local lastDoubleValueIndex = 1

	for _, token in ipairs(ir) do
		if token.command == IR_COMMANDS.pushInt then
			table.insert(text, "mov rsi, " .. token.value)
		elseif token.command == IR_COMMANDS.printInt then
			table.insert(text, "mov rdi, intFormat")
			table.insert(text, "xor rax, rax")
			table.insert(text, "call printf")
		elseif token.command == IR_COMMANDS.pushDouble then
			table.insert(data, "doubleValue" .. lastDoubleValueIndex .. " dq " .. token.value)
			table.insert(text, "movsd xmm0, [doubleValue" .. lastDoubleValueIndex .. "]")
			lastDoubleValueIndex = lastDoubleValueIndex + 1
		elseif token.command == IR_COMMANDS.printDouble then
			table.insert(text, "movsd qword [rsp], xmm0") --move value stored in xmm0 to stack
			table.insert(text, "mov rdi, doubleFormat")
			table.insert(text, "call printf")
		elseif token.command == IR_COMMANDS.pushString then
			table.insert(data, "stringValue" .. lastStringValueIndex .. ' db "' .. token.value .. '", 0')
			table.insert(text, "mov rsi, stringValue" .. lastStringValueIndex)
			lastStringValueIndex = lastStringValueIndex + 1
		elseif token.command == IR_COMMANDS.printString then
			table.insert(text, "mov rdi, stringFormat")
			table.insert(text, "xor eax, eax")
			table.insert(text, "call printf")
		elseif token.command == IR_COMMANDS.exit then
			table.insert(text, "add rsp, 8") --reset stack
			table.insert(text, "mov eax, 0")
			table.insert(text, "ret")
		else
			print("Unrecognised IR command: " .. token.command)
			os.exit(1)
		end
	end

	local eof = {}

	table.insert(eof, "section .note.GNU-stack noalloc noexec nowrite progbits")

	local assembly = table.concat(data, "\n") .. "\n\n" .. table.concat(text, "\n") .. "\n\n" .. table.concat(eof, "\n")

	--turning it into a file
	local fileTag = fileName:match("(.+)%.[^.]+$")

	local f = assert(io.open(fileTag .. ".asm", "w"))
	f:write(assembly)
	f:close()

	os.execute("nasm -f elf64 " .. fileTag .. ".asm -o " .. fileTag .. ".o")
	os.execute("gcc " .. fileTag .. ".o -no-pie -o " .. fileTag)

	if not debug then
		os.remove(fileTag .. ".asm")
		os.remove(fileTag .. ".o")
	else
		--put the ir into a file so you can debug it without having to pretty print the ir table
		local irText = {}
		for _, token in ipairs(ir) do
			if token.value then
				table.insert(irText, "command = " .. token.command .. ", value = " .. token.value)
			else
				table.insert(irText, "command = " .. token.command)
			end
		end
		local f = assert(io.open(fileTag .. ".malair", "w"))
		f:write(table.concat(irText, "\n"))
		f:close()
	end
end

return generator
