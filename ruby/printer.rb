class Printer
  def initialize(mal)
    @mal = mal
  end

  def pr_str(value)
    @presentation = ""
    @was_array = true
    _pr_str(value)
    @presentation
  end

  private

  def _pr_str(value)
    if @mal.array?(value)
      if @was_array
        @presentation << "("
      else
        @presentation << " ("
      end
      @was_array = true
      value.each(&method(:_pr_str))
      @presentation << ")"
    else
      if @was_array
        @presentation << "#{plain value}"
      else
        @presentation << " #{plain value}"
      end
      @was_array = false
    end
  end

  def plain(value)
    return "nil" if value.nil?
    return "#<function>" if value.is_a?(Proc)
    value
  end
end
