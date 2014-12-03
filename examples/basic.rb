require 'struct-matcher/match'

class List < Struct.new(:head, :tail)

end

# syntax for matchers: m(Constructor, [:variable, matcher], ...) >> Proc.new { code }

matcher = ->(value) do

  Match.match(value) do

    with(m(List, [:x, 1], [:y, 2])) >> Proc.new do
      ::Kernel.puts x + y
    end

    # :_ is supposed to be a wildcard but is not really treated any differently
    with(m(List, [:a, 1], [:_, m(List, [:b, 2], [:c, 3])])) >> Proc.new do
      ::Kernel.puts a + b + c
    end

  end

end

matcher[List.new(1, 2)] # match
matcher[List.new(1, 0)] # no match
matcher[List.new(1, List.new(2, 3))] # match
matcher[List.new(1, List.new(2, 0))] # no match
