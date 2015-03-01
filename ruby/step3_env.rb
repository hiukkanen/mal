require 'readline'
require_relative 'reader'
require_relative 'printer'
require_relative 'env'
require_relative 'repl_exception'

class Mal
  def prompt
    "mal-user> "
  end

  def READ(value)
    Reader.read_str(value)
  end

  def eval_ast(ast, env)
    return env.get(ast) if ast.is_a? Symbol
    return ast.map { |value| EVAL(value, env) } if ast.is_a? Array
    ast
  end

  def new_env(ast, env)
    lets = ast[1]
    new_env = Env.new(env)
    lets.each_slice(2).each do |symbol, value|
      new_env.set(symbol, value)
    end
    EVAL(ast[2], new_env)
  end

  def post_eval(asts, env)
    asts.map do |ast|
      if ast.is_a? Array
        EVAL(ast, env)
      else
        ast
      end
    end
  end

  def EVAL(ast, env)
    return env.set(ast[1], EVAL(ast[2], env)) if ast[0] == :def!
    return new_env(ast, env) if ast[0] == :"let*"
    return eval_ast(ast, env) unless ast.is_a? Array
    evaluation = eval_ast(ast, env)
    evaluation.first.call(*(post_eval(evaluation[1..-1], env)))
  end

  def PRINT(ast)
    Printer.new.pr_str(ast)
  end

  def rep(value)
    PRINT(EVAL(READ(value), repl_env))
  rescue ReplException => e
    puts e.message
  end

  def repl_env
    @env ||= Env.new.tap do |env|
      {
        "+": -> (a, b) { a + b },
        "-": -> (a, b) { a - b },
        "*": -> (a, b) { a * b },
        "/": -> (a, b) { a / b }
      }.each do |key, value|
        env.set(key, value)
      end
    end
  end
end

trap('INT') do
  system("stty", %x(stty -g).chomp)
  puts
  exit
end

mal = Mal.new

while line = Readline.readline(mal.prompt, true) do
  puts (mal.rep line)
end
puts ""
