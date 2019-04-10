aE = 0

def e_1(e)
  p 2
  p 4
  p 5
  p 5
  p 5
  p 5
  p 5
  p 5
  p 5
  p 5
  p 5
  :true
end

class A
  # rubocop example
  def bake(pie: pie)
    pie.heat_up
  end

  # rubocop example
  def initialize
    @x ||= 1
  end

  # rubocop example
  def get_attribute
    p 2
  end
end

# rubocop example
BEGIN { test }