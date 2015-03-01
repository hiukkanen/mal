require 'readline'
require_relative 'reader'
require_relative 'printer'

def prompt
  "mal-user> "
end

def READ(value)
  Reader.read_str(value)
end

def EVAL(value)
  value
end

def PRINT(value)
  Printer.new.pr_str(value)
end

def rep(value)
  [method(:READ), method(:EVAL), method(:PRINT)]. each do |method|
    value = method.call value
  end
  value
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
