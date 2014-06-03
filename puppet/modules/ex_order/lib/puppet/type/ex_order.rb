module Puppet
  newtype(:ex_order) do
    @doc = <<-EOM
      A type demonstrating execution order on the Puppet server.
    EOM

    def initialize(args)
      # Do this *first* since you want the type to set up properly
      # before you start messing about with it.
      super(args)

      # Now, you can do a lot of things here but, be warned, the
      # catalog is not completely compiled yet. However, you *can* get
      # to the class parameters.
      Puppet.warning("#{self[:name]}: Type Initializing")

      # You can also dig through the currently compiled catalog.
      num_ex_orders = @catalog.resources.find_all { |r|
        r.is_a?(Puppet::Type.type(:ex_order))
      }.count
      Puppet.warning("Ex_order's in the catalog: '#{num_ex_orders+1}'")

      # Notice, here, we have to use 'self[:name]' while, in the
      # parameters and properties, we have to use 'resource[:name]'.
    end

    def finish
      # Stuff to do at the end of your type run.
      Puppet.warning("#{self[:name]}: Type Finishing")
      
      # Don't forget to call this *at the end*
      super
    end

    newparam(:name) do
      desc "An arbitrary, but unique, name for the resource."

      isnamevar

      munge do |value|
        Puppet.warning("#{value}: In the name parameter.")
        value
      end
    end

    newparam(:foo) do
      desc <<-EOM
        Hey, foo!
      EOM

      # Y U Do Nothing?!!!?
      # Though supported, isrequired just doesn't do anything.
      # See https://projects.puppetlabs.com/issues/4049 for more
      # information
      isrequired 

      # Can't get to resource[:name] here!
      Puppet.warning("Param :foo -> Starting")

      validate do |value|
        Puppet.warning("#{resource[:name]}: Param :foo -> Validating")
      end

      munge do |value|
        Puppet.warning("#{resource[:name]}: Param :foo -> Munging")
        # Order matters!!
        Puppet.warning("Where's Param :bar? Bar is '#{resource[:bar]}'")

        value
      end
    end

    newproperty(:baz) do
      desc <<-EOM
        Have to have a property to do some work.
      EOM
      # Can't get to resource[:name] here!
      Puppet.warning("Property :baz -> Starting")

      validate do |value|
        Puppet.warning("#{resource[:name]}: Property :baz -> Validating")
        Puppet.warning("#{resource[:name]}: Property :baz -> Foo is '#{resource[:foo]}'")
      end

      def insync?(is)
        # This is simply what the native provider code would do.
        is == @should
        
        # Note, you have to use @resource, not resource here since
        # you're not in the property any more, you're in the provider.
        Puppet.warning("#{@resource[:name]}: In 'insync?' for :baz")
        # We're returning false just to see the rest of the components
        # fire off.
        false
      end
    end

    newparam(:bar) do
      desc <<-EOM
        And, bar!
      EOM

      isrequired

      # Can't get to resource[:name] here!
      Puppet.warning("Param :bar -> Starting")

      validate do |value|
        Puppet.warning("#{resource[:name]}: Param :bar -> Validating")
      end

      munge do |value|
        Puppet.warning("#{resource[:name]}: Param :bar -> Munging")
        # Order matters!!
        Puppet.warning("#{resource[:name]}: Where's Param :foo? Foo is '#{resource[:foo]}'")

        value
      end
    end

    # Ok, since 'isrequired' doesn't do anything (but it does set a
    # value) we get to do it this way!
    validate do
      required_params = [:foo, :bar, :baz]
      Puppet.warning("#{self[:name]}: Validating")
      required_params.each do |param|
        if not self[param] then
          # Note how we show the user *where* the error is.
          raise Puppet::ParseError,"Hey, I need :#{param} in #{self.ref} at line #{self.file}:#{self.line}"
        end
      end
    end

    autorequire(:file) do
      Puppet.warning("#{self[:name]}: Autorequring")
      ["/tmp/foo"]
    end
  end
end
