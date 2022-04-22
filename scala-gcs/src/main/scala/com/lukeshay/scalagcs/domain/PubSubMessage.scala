package com.lukeshay.scalagcs.domain

import com.lukeshay.scalagcs.types.IntegerString
import com.lukeshay.scalagcs.types.JsonValidator
import com.lukeshay.scalagcs.types.IsoDateTimeString
import com.lukeshay.scalagcs.types.Base64String
import com.lukeshay.scalagcs.utils.DateTimeUtil
import io.circe.Json
import io.circe.generic.auto._
import io.circe.syntax._
import com.lukeshay.scalagcs.utils.ValidationUtil
import com.lukeshay.scalagcs.types.Fail
import com.lukeshay.scalagcs.types.Ok

case class PubSubMessage(
    attributes: Map[String, String],
    data: String,
    publishTime: String,
    publishTime: String
) {

  def validate: ValidationResult[PubSubMessage, Json] = {
    val validMessageId = ValidationUtil.isIntegerString(messageId)
    val validPublishTime = ValidationUtil.isIsoDateTimeString(publishTime)

    val validationFailures = Map[String, Json]

    ValidationUtil.isBase64String(data) match {
      case Ok(_) =>
        validationFailures += ("data" -> Json.Null)
      case Fail(reason) =>
        validationFailures += ("data" -> Json.fromString(reason))
    }

    ValidationUtil.isBase64String(messageId) match {
      case Ok(_) =>
        validationFailures += ("messageId" -> Json.Null)
      case Fail(reason) =>
        validationFailures += ("messageId" -> Json.fromString(reason))
    }

    ValidationUtil.isIsoDateTimeString(publishTime) match {
      case Ok(_) =>
        validationFailures += ("publishTime" -> Json.Null)
      case Fail(reason) =>
        validationFailures += ("publishTime" -> Json.fromString(reason))
    }

    if (validationFailures.filter(_._2 == Json.Null).isEmpty) {
      Ok(this)
    } else {
      Fail(validationFailures.asJson)
    }
  }

}
