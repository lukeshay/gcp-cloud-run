package com.lukeshay.scalagcs
package domain

case class PubSubMessage(
    attributes: Map[String, String],
    data: String,
    publishTime: String,
    messageId: String
)
