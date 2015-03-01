class Printer
  def pr_str(value)
    @presentation = ""
    @was_array = true
    _pr_str(value)
    @presentation
  end

  private

  def _pr_str(value)
    if value.is_a? Array
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
        @presentation << "#{value}"
      else
        @presentation << " #{value}"
      end
      @was_array = false
    end
  end
end
