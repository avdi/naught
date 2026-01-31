# frozen_string_literal: true

target :lib do
  signature "sig"
  check "lib"

  library "singleton"
  library "forwardable"

  # Start with strict diagnostics
  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)

  # Naught is a heavily metaprogrammed library that dynamically generates
  # null object classes. Many patterns used (Module.new with blocks,
  # define_method within blocks, super in dynamic methods, Class.new blocks)
  # are beyond what Steep can statically analyze because the block bodies
  # are evaluated with a different `self` context at runtime.
  #
  # These diagnostics are demoted to hints for metaprogramming patterns:
  configure_code_diagnostics do |hash|
    # define_method/attr_reader called inside Module.new/Class.new blocks
    hash[Steep::Diagnostic::Ruby::NoMethod] = :hint
    # @ivar references inside dynamically defined methods
    hash[Steep::Diagnostic::Ruby::UnknownInstanceVariable] = :hint
    # Constants like ::Singleton, ::Forwardable accessed in blocks
    hash[Steep::Diagnostic::Ruby::UnknownConstant] = :hint
    # Proc/block type mismatches for metaprogramming patterns
    hash[Steep::Diagnostic::Ruby::BlockTypeMismatch] = :hint
    # super calls inside dynamically defined methods
    hash[Steep::Diagnostic::Ruby::UnexpectedSuper] = :hint
    # Arguments to super in dynamic methods
    hash[Steep::Diagnostic::Ruby::UnexpectedPositionalArgument] = :hint
    # Splat args in dynamic method definitions
    hash[Steep::Diagnostic::Ruby::FallbackAny] = :hint
    # Method parameter mismatches in dynamically defined methods
    hash[Steep::Diagnostic::Ruby::MethodParameterMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::MethodArityMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::DifferentMethodParameterKind] = :hint
    # Type mismatches when passing self or singleton classes
    hash[Steep::Diagnostic::Ruby::ArgumentTypeMismatch] = :hint
    # Singleton class assignment type mismatches
    hash[Steep::Diagnostic::Ruby::IncompatibleAssignment] = :hint
  end
end
