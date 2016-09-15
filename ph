#!/usr/bin/env ruby

# ph - Parallel Heroku
#
# Quick and dirty way to run an heroku command against several apps in
# parallel. For example, if you want to see what version of ruby is being used
# on every app you currently have deployed on Heroku:
#
# hp run 'ruby --version'
#
# Use at your own risk.

require 'optparse'
require 'thread'

options = {
  debug: false,
  regexp: /\A[^= ]+/,
  workers: 5,
}

OptionParser.new { |opts|
  opts.banner = 'usage: ph [options] cmd [args ...]'

  opts.on '-d', '--debug', 'Show debugging output' do
    options[:debug] = true
  end

  opts.on '-j NUM', 'Number of threads to run in parallel (default: 5)' do |n|
    options[:workers] = Integer(n)
  end

  opts.on '-r REGEX', '--re=REGEX', 'Only run on applications whose name match REGEX' do |re|
    options[:regexp] = Regexp.new(re)
  end

  opts.on '-h', '--help', 'Prints this help message.' do
    puts opts
    exit
  end
}.parse!

threads = []
queue   = Queue.new
width   = 0
cmd     = ARGV

puts "<<DEBUG>> #{options.inspect}" if options[:debug]

%x{ heroku apps }.split(/\n/).each do |line|
  if options[:debug]
    puts "<<DEBUG>> #{line.inspect}.match(/#{options[:regexp]}/)"
    puts "<<DEBUG>> # => #{line.match /#{options[:regexp]}/}"
  end

  line.match /(?<app>[[:graph:]]*#{options[:regexp]}[[:graph:]]*)/ do |m|
    width = [m[:app].length, width].max
    queue << m[:app]
  end
end

options[:workers].times do |n|
  threads << Thread.new do
    until queue.empty?
      app = queue.pop(true) rescue nil
      if app
        puts "<<DEBUG>> `heroku #{cmd.join ' '} -a #{app}`" if options[:debug]

        IO.popen ['heroku', *cmd, '-a', app] do |p|
          p.each do |output|
            puts "%-#{width}s => %s" % [app, output]
          end
        end
      end
    end
  end
end

threads.each(&:join)
