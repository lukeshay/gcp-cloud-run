package com.lukeshay.scalagcs
package pubsub

import java.util.Base64

case class PubSubMessage(
    attributes: Map[String, String],
    data: String,
    publishTime: String,
    messageId: String
) {
  val bufferData: Array[Byte] = Base64.getDecoder.decode(data)
  val parsedData: String = new String(bufferData)
}

case class PubSubPayload(message: PubSubMessage, subscription: String)
