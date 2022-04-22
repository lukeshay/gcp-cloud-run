package com.lukeshay.scalagcs.types

sealed trait ValidationResult[+T, +U]

case class Ok[+T, +U](result: T) extends ValidationResult[T, U]
case class Fail[+T, +U](reason: U) extends ValidationResult[T, U]
