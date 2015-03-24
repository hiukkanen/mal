class Reader

  def initialize(tokens, mal)
    @tokens = tokens.reverse
    @mal = mal
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
    elsif token[0] == "["
      pop
      read_vector
    else
      read_atom(pop)
    end
  end

  def read_vector
    vector = []
    while peek != "]"
      vector << read_from
    end
    pop
    @mal.convert_to_vector(vector)
    vector
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
    return false if value == "false"
    return true if value == "true"
    return nil if value == "nil"
    value.to_sym
  end

  def self.read_str(value, mal)
    tokens = tokenizer(value)
    Reader.new(tokens, mal).read_from
  end

  def self.tokenizer(value)
    tokens = value.scan(/[\s,]*(~@|[\[\]{}()'`~^@]|"(?:\\.|[^\\"])*"|;.*|[^\s\[\]{}('"`,;)]*)/)
    tokens.flatten
  end
end
