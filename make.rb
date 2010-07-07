#!/usr/bin/env ruby 
require 'yaml'
require 'fileutils'
require 'erb'

CONTENT = 'content/'
FORMATS = 'formats/'
TRANS = 'translations/'
LESSONS = 'lessons/'
SCRIPT = 'script.yaml'
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
    translation = @@languages[languagecode][:from][text] rescue text
    translation ||= text
  end

  def self.translate_to(text, languagecode = DEFAULT_LANGUAGE)
    text = text.to_s
    return text if languagecode == DEFAULT_LANGUAGE
    read if @@languages.empty?
    translation = @@languages[languagecode][:to][text] rescue text
    translation ||= text
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
    translate_keys
  end

  def [](key)
    value key
  end

  def translated_value(key)
    Languages.translate_from(normalized(value(key)), @languagecode)
  end

  def value(key)
    v = @specification[key.to_s]
  end
  
  def symbol(key)
    normkey = normalized key
    @specification[normkey].to_sym rescue @specification[normkey.capitalize].to_sym rescue nil
  end

  def normalized(key)
    key = key.to_s.downcase
  end

  def translate_keys
    translated_spec = {}
    @specification.each { |key,value|
      translated_spec[Languages.translate_from(normalized(key), @languagecode)] = value
    }
    @specification = translated_spec
  end

  def bind(context)
    @specification.each { |key,value|
      eval "#{key} = '#{value}'", context
    }
    context
  end
end

class Build

  @specification

  def initialize(lesson_id)
    if not lesson_id or lesson_id.empty?
      puts 'No lesson id specified, skipping this lesson!'
      return
    end
    puts "Make lesson package '#{lesson_id}':"

    contentdir = CONTENT+lesson_id

    @specification = Specification.new contentdir+'/'+SCRIPT
    format = @specification.translated_value(:form)
    if not format or format.empty?
      puts 'No format specified, skipping this lesson!'
      return
    end
    puts "Using lesson format'#{format}'"
    
    formatdir = FORMATS+format
    lessondir = LESSONS+lesson_id
    
    puts "Starting with an empty destination directory '#{lessondir}'"
    FileUtils.rm_r lessondir if File.directory? lessondir

    context = @specification.bind binding
    traverse formatdir, lessondir, context
    traverse contentdir, lessondir, context
  end

  def traverse sourcedir, targetdir, context = nil
    puts "Reading from '#{sourcedir}'"
    puts "Creating '#{targetdir}'"
    FileUtils.makedirs targetdir
    list = Dir[sourcedir+'/*']
    list.each { |path|
      localpath = path.split('/').last
      next if localpath == SCRIPT
      next if ['.', '..'].include? localpath
      if File.directory? path
        traverse path, targetdir+'/'+localpath, context
      else
        if path.split('.')[-1] == 'erb'
          target = targetdir+'/'+localpath.split('.')[0..-2].join('.')
          puts "Parsing template '#{path}', writing output to '#{target}'"
          template = ERB.new File.new(path).read, nil, "%"
          result = template.result(context)
          File.open(target, 'w') {|f| f.write(result) }
        else
          puts "Copying '#{path}' to '#{targetdir}'"
          FileUtils.copy path, targetdir
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

