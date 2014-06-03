Puppet::Type.type(:ex_order).provide(:ruby) do

  Puppet.warning("Setting Property Class Variables")
  # If you didn't read the previous post, these are *global*.
  @@ex_order_classvars = {
   :example => true
  }

  def initialize(*args)
    super(*args)

    Puppet.warning("Provider Initialization :name= '#{@resource[:name]}'")
    Puppet.warning("Provider Initialization :foo = '#{@resource[:foo]}'")
    Puppet.warning("Provider Initialization :bar = '#{@resource[:bar]}'")
  end

  def baz
    # This is what 'is' ends up being in insync?
    Puppet.warning("#{@resource[:name]}: In getter for :baz")
  end

  def baz=(should)
    Puppet.warning("#{@resource[:name]}: In setter for :baz")
  end

  def flush
    Puppet.warning("Time to flush #{@resource[:name]}")
  end

  def self.post_resource_eval
    Puppet.warning("WE'RE FINISHED!!!!")
  end
end
