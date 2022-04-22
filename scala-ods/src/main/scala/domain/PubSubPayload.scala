package com.lukeshay.scalagcs
package domain

case class PubSubPayload(message: PubSubMessage, subscription: String)
