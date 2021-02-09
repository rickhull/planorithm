require 'yaml'
require 'json'
# require 'commonmarker'
require 'planorithm/node'

PROCS = {
  json: {
    to: proc { |data| data.to_json },
    from: proc { |json| JSON.parse json },
    pretty: proc { |data| JSON.pretty_generate data },
  },
  yaml: {
    to: proc { |data| data.to_yaml },
    from: proc { |yaml| YAML.load yaml },
    pretty: proc { |data| data.to_yaml },
  },

  # NO-OPs below, for now
  markdown: {
    to: proc { |data| data },
    from: proc { |md| md },
    pretty: proc { |data| data },
  },
}

module Planorithm
  module YAML
  end

  module JSON
  end

  module Markdown
  end
end
