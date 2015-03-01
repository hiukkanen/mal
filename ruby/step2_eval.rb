require 'readline'
require_relative 'reader'
require_relative 'printer'

def prompt
  "mal-user> "
end

def READ(value)
  Reader.read_str(value)
end

def find_symbol(ast, env)
  symbol = env[ast]
  raise "'#{ast}' not found" unless symbol
  symbol
end

def eval_ast(ast, env)
  return find_symbol(ast, env) if ast.is_a? Symbol
  return ast.map { |value| EVAL(value, env) } if ast.is_a? Array
  ast
end

def EVAL(ast, env)
  return eval_ast(ast, env) unless ast.is_a? Array
  evaluation = eval_ast(ast, env)
  evaluation.first.call(*(evaluation[1..-1]))
end

def PRINT(ast)
  Printer.new.pr_str(ast)
end

def rep(value)
  PRINT(EVAL(READ(value), repl_env))
rescue => e
  puts e.message
end

def repl_env
  {
    "+": -> (a, b) { a + b },
    "-": -> (a, b) { a - b },
    "*": -> (a, b) { a * b },
    "/": -> (a, b) { a / b }
  }
end

trap('INT') do
  system("stty", %x(stty -g).chomp)
  puts
  exit
end

while line = Readline.readline(prompt, true) do
  puts (rep line)
end
puts ""
