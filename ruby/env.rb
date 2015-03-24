require_relative 'repl_exception'
class Env

  def initialize(outer = nil, binds = [], exprs = [])
    @outer = outer
    @map = {}

    binds.zip(exprs).each do |key, value|
      set(key, value)
    end
  end

  def find(key)
    candidate = @map[key]
    return @map if candidate
    return @outer.find(key) if @outer
    nil
  end

  def get(key)
    map = find(key)
    return map[key] if map
    raise ReplException.new "#{key} not found"
  end

  def set(key, value)
    @map[key] = value
    value
  end
end
