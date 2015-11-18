//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
// C Primitive Types
//===----------------------------------------------------------------------===//

/// The C 'char' type.
///
/// This will be the same as either `CSignedChar` (in the common
/// case) or `CUnsignedChar`, depending on the platform.
public typealias CChar = Int8

/// The C 'unsigned char' type.
public typealias CUnsignedChar = UInt8

/// The C 'unsigned short' type.
public typealias CUnsignedShort = UInt16

/// The C 'unsigned int' type.
public typealias CUnsignedInt = UInt32

/// The C 'unsigned long' type.
public typealias CUnsignedLong = UInt

/// The C 'unsigned long long' type.
public typealias CUnsignedLongLong = UInt64

/// The C 'signed char' type.
public typealias CSignedChar = Int8

/// The C 'short' type.
public typealias CShort = Int16

/// The C 'int' type.
public typealias CInt = Int32

/// The C 'long' type.
public typealias CLong = Int

/// The C 'long long' type.
public typealias CLongLong = Int64

/// The C 'float' type.
public typealias CFloat = Float

/// The C 'double' type.
public typealias CDouble = Double

// FIXME: long double

// FIXME: Is it actually UTF-32 on Darwin?
//
/// The C++ 'wchar_t' type.
public typealias CWideChar = UnicodeScalar

// FIXME: Swift should probably have a UTF-16 type other than UInt16.
//
/// The C++11 'char16_t' type, which has UTF-16 encoding.
public typealias CChar16 = UInt16

/// The C++11 'char32_t' type, which has UTF-32 encoding.
public typealias CChar32 = UnicodeScalar

/// The C '_Bool' and C++ 'bool' type.
public typealias CBool = Bool

/// A wrapper around an opaque C pointer.
///
/// Opaque pointers are used to represent C pointers to types that
/// cannot be represented in Swift, such as incomplete struct types.
public struct OpaquePointer : Equatable, Hashable, NilLiteralConvertible {
  internal var _rawValue: Builtin.RawPointer

  /// Create an instance initialized with `nil`.
  @_transparent
  public init(nilLiteral: ()) {
    self._rawValue = _nilRawPointer
  }

  @_transparent
  internal init(_ v: Builtin.RawPointer) {
    self._rawValue = v
  }

  /// Construct an `OpaquePointer` from a given address in memory.
  @_transparent
  public init(bitPattern: Int) {
    self._rawValue = Builtin.inttoptr_Word(bitPattern._builtinWordValue)
  }

  /// Construct an `OpaquePointer` from a given address in memory.
  @_transparent
  public init(bitPattern: UInt) {
    self._rawValue = Builtin.inttoptr_Word(bitPattern._builtinWordValue)
  }

  /// Convert a typed `UnsafePointer` to an opaque C pointer.
  @_transparent
  public init<T>(_ source: UnsafePointer<T>) {
    self._rawValue = source._rawValue
  }

  /// Convert a typed `UnsafeMutablePointer` to an opaque C pointer.
  @_transparent
  public init<T>(_ source: UnsafeMutablePointer<T>) {
    self._rawValue = source._rawValue
  }

  /// Unsafely convert an unmanaged class reference to an opaque
  /// C pointer.
  ///
  /// This operation does not change reference counts.
  ///
  ///     let str: CFString = Unmanaged.fromOpaque(ptr).takeUnretainedValue()
  // FIXME: example code does not use the commented initializer
  @transparent
  public init<T>(_ source: Unmanaged<T>) {
    self = unsafeBitCast(source._value, OpaquePointer.self)
  }

  /// Determine whether the given pointer is null.
  @_transparent
  var _isNull : Bool {
    return self == nil
  }

  /// The hash value.
  ///
  /// **Axiom:** `x == y` implies `x.hashValue == y.hashValue`.
  ///
  /// - Note: The hash value is not guaranteed to be stable across
  ///   different invocations of the same program.  Do not persist the
  ///   hash value across program runs.
  public var hashValue: Int {
    return Int(Builtin.ptrtoint_Word(_rawValue))
  }
}

extension OpaquePointer : CustomDebugStringConvertible {
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return _rawPointerToString(_rawValue)
  }
}

@warn_unused_result
public func ==(lhs: OpaquePointer, rhs: OpaquePointer) -> Bool {
  return Bool(Builtin.cmp_eq_RawPointer(lhs._rawValue, rhs._rawValue))
}

/// The corresponding Swift type to `va_list` in imported C APIs.
public struct CVaListPointer {
  var value: UnsafeMutablePointer<Void>

  public // @testable
  init(_fromUnsafeMutablePointer from: UnsafeMutablePointer<Void>) {
    value = from
  }
}

extension CVaListPointer : CustomDebugStringConvertible {
  /// A textual representation of `self`, suitable for debugging.
  public var debugDescription: String {
    return value.debugDescription
  }
}

func _memcpy(
  dest destination: UnsafeMutablePointer<Void>,
  src: UnsafeMutablePointer<Void>,
  size: UInt
) {
  let dest = destination._rawValue
  let src = src._rawValue
  let size = UInt64(size)._value
  Builtin.int_memcpy_RawPointer_RawPointer_Int64(
    dest, src, size,
    /*alignment:*/ Int32()._value,
    /*volatile:*/ false._value)
}
