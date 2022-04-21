package com.lukeshay.scalagcs.domain

case class PubSubMessage(
    attributes: Map[String, String],
    data: String,
    messageId: String,
    publishTime: String
)
