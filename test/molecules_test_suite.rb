$:.unshift File.join(File.dirname(__FILE__), '../lib')

Dir.glob("./**/*_test.rb").each {|test| require test}