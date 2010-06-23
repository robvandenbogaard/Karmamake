#!/usr/bin/env ruby 
require 'yaml'
require 'fileutils'

CONTENT = 'content/'
FORMATS = 'formats/'
TRANS = 'translations/'
LESSONS = 'lessons/'
DEFAULT_LANGUAGE = :en

class Languages

  @@languages = {}

  def self.each
    read if @@languages.empty?
    @@languages.each { |translations|
      yield translations
    }
  end

  def self.default
    DEFAULT_LANGUAGE
  end

  def self.translate_from(text, languagecode = DEFAULT_LANGUAGE)
    text = text.to_s
    return text if languagecode == DEFAULT_LANGUAGE
    read if @@languages.empty?
    @@languages[languagecode][:from][text] rescue text
  end

  def self.translate_to(text, languagecode = DEFAULT_LANGUAGE)
    text = text.to_s
    return text if languagecode == DEFAULT_LANGUAGE
    read if @@languages.empty?
    @@languages[languagecode][:to][text] rescue text
  end

private

  def self.read
    @@languages = {}
    Dir[TRANS+'*.yaml'].each { |file|
      code = file[/\/([^\.]+)/][1..-1].to_sym
      @@languages[code] = {:to => YAML.load_file(file)}
      @@languages[code][:from] = @@languages[code][:to].invert
    }
  end

end

class Specification

  @specification
  @languagecode

  def initialize(specfilename)
    @specification = YAML.load_file specfilename
    @languagecode = symbol(:lingua)
    @languagecode ||= Languages.default
  end

  def [](key)
    value translated normalized key
  end

  def translated_value(key)
    Languages.translate_from(normalized(value(translated(normalized(key)))), @languagecode)
  end

  def value(key)
    v = @specification[key]
    v = @specification[key.capitalize] unless v
  end
  
  def symbol(key)
    normkey = normalized key
    @specification[normkey].to_sym rescue @specification[normkey.capitalize].to_sym rescue nil
  end

  def normalized(key)
    key = key.to_s.downcase
  end

  def translated(key)
    Languages.translate_to key, @languagecode
  end

end

class Build

  @lesson_id
  @specification

  def initialize(lesson_id)
    @lesson_id = lesson_id
    puts 'Make lesson package ' + lesson_id + ':'
    @specification = Specification.new CONTENT+lesson_id+'/script.yaml'
    formatdir = FORMATS+@specification.translated_value(:form)
    # make dir for lesson
    lessondir = LESSONS+lesson_id
    FileUtils.rm_r lessondir if File.directory? lessondir
    traverse formatdir, lessondir
  end

  def traverse sourcedir, targetdir
    #FileUtils.makedirs targetdir
    p sourcedir
    p targetdir
    list = Dir[sourcedir+'/*']
    list.each { |path|
      next if ['.', '..'].include? path
      if File.directory? path
        traverse path, targetdir+'/'+path.split('/')[2..-1].join('/')
      else
        if path.split('.')[-1] == 'erb'
          target = path.split('.')[1..-2].join('.')
          target = targetdir+'/'+path.split('/')[2..-1].join('/')
          puts "parse template '#{path}' and output to #{target}"
        else
          puts "copy '#{path}' to '#{targetdir}'"
        end
      end
    }
  end

end

# param: lesson id(s) (subfolder of 'content/')
lesson_ids = ARGV.empty? ? Dir[CONTENT+'*'].map{|path| path[/\/(.+)/][1..-1]} : ARGV
p lesson_ids
lesson_ids.each do |lesson_id|
  Build.new lesson_id
end

