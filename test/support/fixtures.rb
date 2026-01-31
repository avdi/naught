# Shared test fixtures for Naught tests
#
# This module provides reusable fixture classes for testing
# null object behavior across different test files.
module NaughtTestFixtures
  # Simple 2D point with x and y coordinates
  class Point
    attr_reader :x, :y
  end

  # A user with login credentials
  class User
    attr_reader :login
  end

  # Authorization capability mixin
  module Authorizable
    def authorized_for?(_)
    end
  end

  # A library patron with borrowed book tracking
  class LibraryPatron < User
    include Authorizable

    attr_reader :name

    def member?
    end

    def notify_of_overdue_books(_)
    end
  end

  # BasicObject subclass for testing mimic with BasicObject
  class BasicWidget < BasicObject
    def widget_method
    end
  end

  # A class with method_missing, similar to ActiveRecord
  class DynamicClass
    def regular_method
      "regular"
    end

    def active?
      true
    end

    def method_missing(method_name, *)
      if method_name.to_s.start_with?("dynamic_")
        "dynamic: #{method_name}"
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?("dynamic_") || super
    end
  end

  # Coffee class for predicate testing
  class Coffee
    attr_reader :origin
    def black? = nil
  end

  # Caller class for pebble testing
  class Caller
    def call_method(thing) = thing.info
    def call_method_inside_block(thing) = 2.times { thing.info }
    def call_method_inside_nested_block(thing) = 2.times { 2.times { thing.info } }
  end
end
