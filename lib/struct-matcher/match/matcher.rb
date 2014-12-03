module Match

##
# A binder matches and binds the match to a variable so that the matching block
# can use them as regular Ruby variables.

class Binder < Struct.new(:index, :binder, :value)

  ##
  # Just make sure we get symbols for variables we want to bind and keep track
  # of the index because that is how we get the component of the struct we are
  # interested in.

  def initialize(index, binder, value)
    if !(Symbol === binder)
      raise StandardError, "Must supply symbol for capturing matches."
    end
    super(index, binder, value)
  end

  ##
  # Do the matching and if successful save the results into the context.
  # Success is indicated by returning a non-nil updated context object.

  def match(value, context)
    if (self.value === (v = value[index]) ||
     (Matcher === self.value && self.value.match(v, context)))
      context[binder] = v; return context
    else
      return nil
    end
  end

end

##
# Container for type matcher and value binders.

class Matcher < Struct.new(:type_matcher, :binders)

  ##
  # Need access to the block because we want to evaluate it when we have
  # a successful match.

  attr_reader :block

  ##
  # Do some basic validation and create the binders that will do the bulk of the matching
  # and context creation for block evaluation.

  def initialize(type_matcher, binders)
    if !(Struct == type_matcher.superclass.superclass)
      raise StandardError, "Type matcher must be a struct."
    end
    binder_instances = binders.each_with_index.map do |(binder, value), index|
      Binder.new(index, binder, value)
    end
    super(type_matcher, binder_instances)
  end

  ##
  # Attach a block of code that should be executed if the match is successful.

  def >>(blk)
    @block = blk
  end

  ##
  # The driver for passing the relevant pieces to the binders for doing the
  # matching. The binders themselves can have matchers so the process is
  # recursive. See the Example directory for how to use nested matchers.

  def match(value, context = {})
    if !(type_matcher === value)
      return nil
    end
    binders.each do |binder|
      return nil unless binder.match(value, context)
    end
    return context
  end

end

##
# The context we use to evaluate matches. Simply delegates all method calls
# to the variables that were captured during the matching process.

class BlockEvalContext < BasicObject

  def initialize(variables)
    @variables = variables
  end

  def method_missing(variable, *args)
    @variables[variable] || ::Kernel.raise(StandardError, "Missing variable.")
  end

end

##
# Manages the creation of matchers with convenience methods and also sets up the proper
# evaluation context for executing the matching code block.

class MatcherContext

  ##
  # Just need to keep track of the matchers as they are initialized.

  def initialize
    @matchers = []
  end

  ##
  # Convenience method for generating a matcher instance.

  def m(type, *binders)
    Matcher.new(type, binders)
  end

  ##
  # Convenience method for appending to the list of matchers.

  def with(matcher)
    @matchers << matcher; matcher
  end

  ##
  # Run through the matchers and return the result of evaluating the block for the first
  # successful match.

  def eval(value)
    @matchers.each do |m|
      if (context = m.match(value))
        return BlockEvalContext.new(context).instance_eval(&m.block)
      end
    end
  end

end

end
