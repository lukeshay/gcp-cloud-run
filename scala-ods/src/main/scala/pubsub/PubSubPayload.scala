package com.lukeshay.scalagcs
package domain

import java.util.Base64

case class PubSubMessage(
    attributes: Map[String, String],
    data: String,
    publishTime: String,
    messageId: String
) {
  val parsedData: String = new String(Base64.getDecoder.decode(data))
}

case class PubSubPayload(message: PubSubMessage, subscription: String)
