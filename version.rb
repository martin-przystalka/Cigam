# frozen_string_literal: true

require 'json'
require 'optparse'

class PropertiesManager
  attr_reader :file, :properties

  # Takes a file and loads the properties in that file
  def initialize(file)
    @file = file
    @properties = {}
    File.open(file).each_line do |line|
      @properties[Regexp.last_match(1).strip] = Regexp.last_match(2) if line =~ %r{([^=]*)=(.*)//(.*)} || line =~ /([^=]*)=(.*)/
    end
  end

  # Save the properties back to file
  def save
    file = File.new(@file, 'w+')
    @properties.each { |key, value| file.puts "#{key}=#{value}\n" }
  end
end

def update_react_app_version(version)
  file = File.read('package.json')
  hash = JSON.parse file
  hash['version'] = version
  file_write = File.open('package.json', 'w')
  pretty_json = JSON.pretty_generate(hash)
  file_write.puts pretty_json
  file_write.close
end

def update_android_version(version)
  file_path = 'android/app/version.properties'
  props = PropertiesManager.new(file_path)
  part = version.partition('.')
  props.properties['VERSION_NAME_MAJOR'] = part.first
  props.properties['VERSION_NAME_MINOR'] = part.last.partition('.').first
  props.properties['VERSION_NAME_PATCH'] = version.rpartition('.').last
  props.properties['VERSION_CODE'] = props.properties['VERSION_CODE'].to_i + 1
  props.save
end

def update_ios_version(version)
  Dir.chdir('./ios') do
    `xcrun agvtool next-version -all`
    `xcrun agvtool new-marketing-version #{version}`
  end
end

def increment_patch
  file = File.read('package.json')
  hash = JSON.parse file
  current_version = hash['version']
  rpartition = current_version.rpartition('.')
  current_patch = rpartition.last
  new_patch = current_patch.to_i + 1
  new_version = "#{rpartition[0]}.#{new_patch}"
  upgrade_to_version(new_version)
end

def upgrade_to_version(version)
  update_ios_version(version)
  update_react_app_version(version)
  update_android_version(version)
end

def check_precondition(path)
  unless File.exist?(path)
    puts "Could not find #{path}"
    exit
  end
end

def upgrade_build_number
  # ANDROID
  file_path = 'android/app/version.properties'
  props = PropertiesManager.new(file_path)
  props.properties['VERSION_CODE'] = props.properties['VERSION_CODE'].to_i + 1
  props.save
  # IOS
  Dir.chdir('./ios') do
    `xcrun agvtool next-version -all`
  end
  up_build_number_rn(props.properties['VERSION_CODE'].to_i)
end

def up_build_number_rn(build_number)
  # REACT NATIVE
  file = File.read('package.json')
  hash = JSON.parse file
  hash['build'] = build_number
  file_write = File.open('package.json', 'w')
  pretty_json = JSON.pretty_generate(hash)
  file_write.puts pretty_json
  file_write.close
end

check_precondition('./ios')
check_precondition('android/app/version.properties')
check_precondition('package.json')

OptionParser.new do |opts|
  opts.banner = "✨ Cigam ✨ is a 🔢 versioning script. Use one of following commands:\n\n"
  opts.on('--increment-version [ARG]', 'Increment project version') do |v|
    if v
      puts "updating to version: #{v}"
      upgrade_to_version(v)
      puts 'version updated'
    else
      increment_patch
      puts 'patch increased'
    end
    exit
  end
  opts.on('--increment-build', 'Increment project build number') do |v|
    upgrade_build_number
    puts 'build number increased'
    exit
  end
  opts.on('-h', '--help', 'Display this help') do
    puts opts
    exit
  end
  opts.on('', 'Display this help') do
    puts opts
    exit
  end
end.parse!
