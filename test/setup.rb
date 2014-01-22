require 'rubygems'
require 'pry'
require 'active_record'
require 'sqlite3'
ActiveRecord::Base.establish_connection(:adapter  => 'sqlite3',
                                        :database => 'test.db')
require_relative '../export'