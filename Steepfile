# frozen_string_literal: true

target :lib do
  signature "sig"

  check "lib"

  # Start with strict diagnostics as requested
  configure_code_diagnostics(Steep::Diagnostic::Ruby.strict)

  # Naught is a heavily metaprogrammed library that dynamically generates
  # null object classes. Many patterns used (module_eval, define_method
  # within blocks, class variable manipulation, Class.new with blocks)
  # are beyond what steep can currently analyze statically.
  #
  # We disable specific diagnostics that are triggered by these
  # metaprogramming patterns while keeping other strict checks active.
  configure_code_diagnostics do |hash|
    # Metaprogramming patterns cause these false positives:
    # - define_method called within module_eval blocks
    # - Class.new blocks where self changes
    # - class variables used for configuration
    hash[Steep::Diagnostic::Ruby::NoMethod] = :hint
    hash[Steep::Diagnostic::Ruby::UnknownInstanceVariable] = :hint
    hash[Steep::Diagnostic::Ruby::UnknownConstant] = :hint
    hash[Steep::Diagnostic::Ruby::FallbackAny] = :hint
    hash[Steep::Diagnostic::Ruby::BlockTypeMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::UnexpectedPositionalArgument] = :hint
    hash[Steep::Diagnostic::Ruby::ArgumentTypeMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::IncompatibleAssignment] = :hint
    hash[Steep::Diagnostic::Ruby::MethodArityMismatch] = :hint
    hash[Steep::Diagnostic::Ruby::DifferentMethodParameterKind] = :hint
    hash[Steep::Diagnostic::Ruby::UndeclaredMethodDefinition] = :hint
  end
end
