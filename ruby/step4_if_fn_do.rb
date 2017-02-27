require 'readline'
require_relative 'reader'
require_relative 'printer'
require_relative 'env'
require_relative 'repl_exception'
require_relative 'core'

class Mal
  def prompt
    "mal-user> "
  end

  def array?(value)
    return false unless value.is_a? Array
    !value.instance_variable_get(:@mal_vector)
  end

  def vector?
    return false unless value.is_a? Array
    value.instance_variable_get(:@mal_vector)
  end

  def convert_to_vector(array)
    array.instance_variable_set(:@mal_vector, true)
    array
  end

  def READ(value)
    Reader.read_str(value, self)
  end

  def eval_ast(ast, env)
    return env.get(ast) if ast.is_a? Symbol
    return ast.map { |value| EVAL(value, env) } if array?(ast)
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
      if array?(ast)
        EVAL(ast, env)
      else
        ast
      end
    end
  end

  def make_function(ast, env)
    lambda do |*args|
      vector = EVAL(ast[1], env)
      new_env = Env.new(env, vector, args)
      EVAL(ast[2], new_env)
    end
  end

  def EVAL(ast, env)
    return eval_ast(ast, env) unless array?(ast)

    return env.set(ast[1], EVAL(ast[2], env)) if ast[0] == :def!
    return new_env(ast, env) if ast[0] == :"let*"
    return make_function(ast, env) if ast[0] == :"fn*"

    evaluation = eval_ast(ast, env)
    f = evaluation.first
    raise ReplException.new("#{f} not a function") unless f.is_a?(Proc)
    post_eval = post_eval(evaluation[1..-1], env)
    f.call(*post_eval)
  end

  def PRINT(ast)
    Printer.new(self).pr_str(ast)
  end

  def rep(value)
    PRINT(EVAL(READ(value), repl_env))
  rescue ReplException => e
    puts e.message
  end

  def repl_env
    core = Core.new(self)
    @env ||= core.get
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
