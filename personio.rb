#!/bin/env ruby
require 'pathname'
require 'date'
require 'fileutils'

module Argos
  class Personio
    DATA_DIR = Pathname.new(__dir__).join('data')
    COME_TIME_PATH = DATA_DIR.join('kommen.time').freeze

    def initialize(action)
      @action = action
      FileUtils.mkpath DATA_DIR
      @come = DateTime.parse IO.read(COME_TIME_PATH) if COME_TIME_PATH.exist?
    end

    def actions
      @actions_hash ||= {
          'come' => method(:come),
          'help' => method(:print_help)
      }.freeze
    end

    def perform_action
      action = actions[@action] || Proc.new {}

      action.call
    end

    def come
      @come = DateTime.now
      File.write COME_TIME_PATH, @come
    end

    def print_help
      puts "Available actions: #{actions.keys.join ', '}"
    end

    def print_ui
      if @come
        now = DateTime.now
        seconds = ((now - @come) * 24 * 60 * 60).to_i
        duration = Time.at seconds, in: "+00:00"
      end

      puts duration&.strftime('%H:%M:%S') || 'Personio'
      puts "---"
      puts "Kommen | bash='ruby #{__FILE__} come' terminal=false refresh=true"
      puts "Refresh | refresh=true"
    end

    def main
      perform_action
      print_ui
    end
  end
end

action = ARGV[0]
personio = Argos::Personio.new action
personio.main
