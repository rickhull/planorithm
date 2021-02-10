require 'yaml'
require 'json'
# require 'commonmarker'
require 'planorithm/node'

module Planorithm
  # convert to/from hash/dict/assoc format
  PROCS = {
    json: {
      to: proc { |hsh| hsh.to_json },
      from: proc { |json| JSON.parse json },
      pretty: proc { |hsh| JSON.pretty_generate hsh },
      from_file: proc { |filename| JSON.load_file filename },
    },
    yaml: {
      to: proc { |hsh| hsh.to_yaml },
      from: proc { |yaml| YAML.load yaml },
      pretty: proc { |hsh| hsh.to_yaml },
      from_file: proc { |filename| YAML.load_file filename },
    },

    # NO-OPs below, for now
    markdown: {
      to: proc { |hsh| hsh },
      from: proc { |md| md },
      pretty: proc { |hsh| hsh },
      from_file: proc { |filename| filename },
    },
  }
end
