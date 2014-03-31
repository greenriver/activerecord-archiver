require 'rubygems'
require 'active_record'
require 'sqlite3'
ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3',
                                        :database => File.join(File.dirname(__FILE__),
                                                               'test.db'))
require_relative '../lib/activerecord-archiver'
