class Core

  def initialize(mal)
    @mal = mal
  end

  def get
    Env.new.tap do |env|
      {
        "+": -> (a, b) { a + b },
        "-": -> (a, b) { a - b },
        "*": -> (a, b) { a * b },
        "/": -> (a, b) { a / b },
        "=": -> (a, b) { a == b },
        "<": -> (a, b) { a < b },
        ">": -> (a, b) { a > b },
        "<=": -> (a, b) { a <= b },
        ">=": -> (a, b) { a >= b },
        "list": -> (*a) { @mal.convert_to_vector(a[0..1]) },
        "list?": -> (a) { @mal.array?(a) },
        "empty?": -> (a) { a.empty? },
        "count": count
      }.each do |key, value|
        env.set(key, value)
      end
    end
  end

  private

  def count
    lambda do |a|
      return 0 if a.nil?
      a.size
    end
  end
end
