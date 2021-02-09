# Node:
#   Empty object or dict
#     Has 8 reserved words:
#       name: string
#       desc: string
#       setup: array of Node (children)
#       components: array of Node (children)
#       teardown: array of Node (children)
#       action: string
#       iaction: string
#       test: string
#
#    All keys are optional
#      Suggested usage:
#        name: put something useful, particularly for high level concepts
#        desc: description, notes, etc. - very optional
#        setup: steps to run before components
#        components: the meat for actions, iactions, and tests
#        teardown: undo any prior setup or actions, after components
#        action: perform this action (sequential)
#        iaction: perform this independent action (concurrent)
#        test: check a condition, possible failure
#


# Node processing sequence (all keys are optional):
#   1. Read and display name
#   2. Read and display notes
#   3. Visit setup nodes
#   4. Schedule iaction
#   5. Schedule action
#   6. Schedule test once any action or iaction completes
#   7. Visit components nodes
#   8. Visit teardown nodes

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

    attr_reader :name, :desc, :action, :iaction, :test,
                :setup, :components, :teardown

    def initialize(name: nil,
                   desc: nil,
                   action: nil,
                   iaction: nil,
                   test: nil,
                   setup: nil,
                   components: nil,
                   teardown: nil)
      @name = name
      @desc = desc
      @action = action
      @iaction = iaction
      @test = test
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
        self.test = hsh["test"]
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
      puts format("%sTest: %s", indent, schedule(@test)) if @test

      # then components
      if @components and !@components.empty?
        puts format("%sCOMPONENTS: %s", indent, @name)
        @components.each { |n| n.process(level + 1) }
      end

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

    def test=(val)
      @test = Node.string!(val)
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