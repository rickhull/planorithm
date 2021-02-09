require 'pp'
require 'planorithm/conversion'

filename = ARGV.first || raise("provide a yaml file as an arg")
raise "#{filename} does not exist" unless File.exist? filename

hsh = YAML.load_file(filename)
pp hsh

puts
puts
puts

include Planorithm

n = Node.new.load_hash(hsh)

puts
puts
puts

n.process
