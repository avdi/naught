# Helper for creating CallLocation objects in tests
module CallLocationHelper
  # Default values for test CallLocation instances
  DEFAULT_LOCATION = {
    label: :foo,
    args: [1],
    path: "/path/to/file.rb",
    lineno: 42,
    base_label: "method"
  }.freeze

  # Create a CallLocation with default values that can be overridden
  #
  # @param overrides [Hash] attributes to override
  # @return [Naught::CallLocation]
  def make_location(overrides = {})
    Naught::CallLocation.new(**DEFAULT_LOCATION.merge(overrides))
  end
end
