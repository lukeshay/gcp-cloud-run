package com.lukeshay.scalagcs.domain

import io.circe.Json
import io.circe.generic.auto._
import io.circe.syntax._
import com.lukeshay.scalagcs.types.JsonValidator
import com.lukeshay.scalagcs.types.Ok
import com.lukeshay.scalagcs.types.Fail
import com.lukeshay.scalagcs.types.ValidationResult

case class PubSubPayload(message: PubSubMessage, subscription: String) {

  def validate: ValidationResult[PubSubPayload, Json] = {

    val validationFailures = Map[String, Json]("subscription" -> Json.Null)

    message.validate match {
      case Ok(_) =>
        validationFailures += ("message" -> Json.Null)
      case Fail(reason) =>
        validationFailures += ("message" -> reason)
    }

    if (validationFailures.filter(_._2 == Json.Null).isEmpty) {
      Ok(this)
    } else {
      Fail(validationFailures.asJson)
    }
  }

}
