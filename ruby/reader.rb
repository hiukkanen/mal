class Reader

  def initialize(tokens)
    @tokens = tokens.reverse
  end

  def pop
    @tokens.pop
  end

  def peek
    @tokens.last
  end

  def read_from
    token = peek
    if token[0] == "("
      pop
      read_list([])
    else
      read_atom(pop)
    end
  end

  def read_list(list)
    while true do
      token = peek
      raise "noo fast end" unless token
      if token[0] == ")"
        pop
        return list
      end
      data = read_from
      list << data
    end
  end

  def read_atom(value)
    return value if value.is_a? Array
    return value if value.start_with?("\"")
    return value.to_i if value.to_i.to_s == value.to_s
    value.to_sym
  end

  def self.read_str(value)
    tokens = tokenizer(value)
    Reader.new(tokens).read_from
  end

  def self.tokenizer(value)
    tokens = value.scan(/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/)
    tokens.flatten
  end
end
