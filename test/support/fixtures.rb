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

  # Simulates Stripe-style objects that define methods dynamically based on data
  # These objects expose a `keys` method to discover available attributes
  class StripeStyleObject
    def initialize(values = {})
      @values = values
    end

    def keys
      @values.keys
    end

    def regular_method
      "regular"
    end

    def method_missing(name, *)
      if @values.key?(name)
        @values[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @values.key?(name) || super
    end
  end

  # Simulates ActiveRecord-style objects with attribute_names
  class ActiveRecordStyleObject
    def initialize(attributes = {})
      @attributes = attributes
    end

    def attribute_names
      @attributes.keys.map(&:to_s)
    end

    def regular_method
      "regular"
    end

    def method_missing(name, *)
      if @attributes.key?(name)
        @attributes[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @attributes.key?(name) || super
    end
  end

  # Simulates OpenStruct-style objects with to_h
  class OpenStructStyleObject
    def initialize(values = {})
      @values = values
    end

    def to_h
      @values.dup
    end

    def regular_method
      "regular"
    end

    def method_missing(name, *)
      if @values.key?(name)
        @values[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @values.key?(name) || super
    end
  end

  # Object whose to_h raises an error
  class BrokenToHObject
    def initialize(values = {})
      @values = values
    end

    def to_h
      raise "broken!"
    end

    def regular_method
      "regular"
    end

    def method_missing(name, *)
      if @values.key?(name)
        @values[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @values.key?(name) || super
    end
  end

  # Object whose to_h returns a non-Hash value
  class NonHashToHObject
    def initialize(values = {})
      @values = values
    end

    def to_h
      # Returns an Array instead of a Hash
      @values.to_a
    end

    def regular_method
      "regular"
    end

    def method_missing(name, *)
      if @values.key?(name)
        @values[name]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @values.key?(name) || super
    end
  end
end
