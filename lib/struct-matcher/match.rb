require "struct-matcher/match/version"
require "struct-matcher/match/matcher"

module Match

  def self.match(value, &blk)
    (instance = MatcherContext.new).instance_eval(&blk)
    instance.eval(value)
  end

end
