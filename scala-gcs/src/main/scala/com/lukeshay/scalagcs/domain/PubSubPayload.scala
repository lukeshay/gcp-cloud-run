package com.lukeshay.scalagcs.domain

case class PubSubPayload(message: PubSubMessage, subscription: String)
