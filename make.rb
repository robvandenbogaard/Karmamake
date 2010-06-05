#!/usr/bin/env ruby 
require 'yaml'

CONTENT = 'content/'

# param: lesson id(s) (subfolder of 'content/')
lesson_ids = ARGV.empty? ? Dir[CONTENT+'*'].map{|path| path.delete CONTENT} : ARGV

lesson_ids.each do |lesson_id|
  puts 'Make lesson package ' + lesson_id + ':'
  specification = YAML.load_file( CONTENT+lesson_id+'/script.yaml' )
  p specification
end
