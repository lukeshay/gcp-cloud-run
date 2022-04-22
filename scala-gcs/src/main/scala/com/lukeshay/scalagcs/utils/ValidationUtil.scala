package com.lukeshay.scalagcs.utils

import scala.util.Try
import scala.util.Success
import scala.util.Failure
import java.time.temporal.TemporalAccessor
import com.lukeshay.scalagcs.types.ValidationResult
import com.lukeshay.scalagcs.types.Ok
import com.lukeshay.scalagcs.types.Fail

object ValidationUtil {

  def isBase64String(str: String): ValidationResult[String, String] =
    Try(java.util.Base64.getDecoder.decode(str)) match {
      case Success(bytes) =>
        Ok(new String(bytes))
      case Failure(e) =>
        Fail("Invalid base64 string")
    }

  def isIsoDateString(str: String): ValidationResult[TemporalAccessor, String] =
    Try(DateTimeUtil.parseIsoDateTime(str)) match {
      case Success(dateTime) =>
        Ok(dateTime)
      case Failure(e) =>
        Fail("Invalid ISO date string")
    }

  def isIntegerString(str: String): ValidationResult[Int, String] =
    Try(str.toInt) match {
      case Success(int) =>
        Ok(int)
      case Failure(e) =>
        Fail("Invalid integer string")
    }

}
