module Planorithm
  class Node
    INDENT_SPACES = 2

    def self.string!(val)
      raise(TypeError, "val should be a String") if val and !val.is_a?(String)
      val
    end

    def self.children!(val)
      if val
        raise(TypeError, "val should be an Array of Nodes") if !val.is_a?(Array)
        val.each { |v|
          unless v.is_a?(Node)
            puts val.inspect
            raise(TypeError, format("val should contain Nodes not %ss", v.class))
          end
        }
      end
      val
    end

    attr_reader :name, :desc, :action, :iaction, :check,
                :setup, :components, :teardown

    def initialize(name: nil,
                   desc: nil,
                   action: nil,
                   iaction: nil,
                   check: nil,
                   setup: nil,
                   components: nil,
                   teardown: nil)
      @name = name
      @desc = desc
      @action = action
      @iaction = iaction
      @check = check
      @setup = setup
      @components = components
      @teardown = teardown
    end

    def load_hash(hsh)
      begin
        self.name = hsh["name"]
        self.desc = hsh["desc"]
        self.action = hsh["action"]
        self.iaction = hsh["iaction"]
        self.check = hsh["check"]
        if hsh["setup"]
          self.setup = hsh["setup"].map { |s|
            Node.new.load_hash(s)
          }
        end
        if hsh["components"]
          self.components = hsh["components"].map { |c|
            Node.new.load_hash(c)
          }
        end
        if hsh["teardown"]
          self.teardown = hsh["teardown"].map { |t|
            Node.new.load_hash(t)
          }
        end
      rescue TypeError => e
        puts hsh.inspect
        raise
      end
      self
    end

    def process(level = 0)
      puts if @name
      indent = ' ' * INDENT_SPACES * level

      # first, name
      puts format("%sName: %s", indent, @name) if @name
      puts format("%sDesc: %s", indent, @desc) if @desc

      # then setup
      if @setup and !@setup.empty?
        puts format("%sSETUP: %s", indent, @name)
        @setup.each { |n| n.process(level + 1) }
      end

      # now direct tasks
      puts format("%sIAction: %s", indent, schedule(@iaction)) if @iaction
      puts format("%sAction: %s", indent, schedule(@action)) if @action

      # then components
      if @components and !@components.empty?
        puts format("%sCOMPONENTS: %s", indent, @name)
        @components.each { |n| n.process(level + 1) }
      end

      puts format("%sCheck: %s", indent, schedule(@check)) if @check

      # finally teardown
      if @teardown and !@teardown.empty?
        puts format("%sTEARDOWN: %s", indent, @name)
        @teardown.each { |n| n.process(level + 1) }
      end
    end

    def schedule(which)
      which.to_s
    end

    def to_s
      @name || ''
    end

    def name=(val)
      @name = Node.string!(val)
    end

    def desc=(val)
      @desc = Node.string!(val)
    end

    def action=(val)
      @action = Node.string!(val)
    end

    def iaction=(val)
      @iaction = Node.string!(val)
    end

    def check=(val)
      @check = Node.string!(val)
    end

    def setup=(val)
      @setup = Node.children!(val)
    end

    def components=(val)
      @components = Node.children!(val)
    end

    def teardown=(val)
      @teardown = Node.children!(val)
    end
  end
end
