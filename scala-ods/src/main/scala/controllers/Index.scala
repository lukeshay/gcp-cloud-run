package com.lukeshay.scalagcs
package controllers

import domain.PubSubPayload

import cats.effect.*
import cats.implicits.*
import com.comcast.ip4s.*
import com.typesafe.scalalogging.Logger
import io.circe.generic.auto.*
import io.circe.syntax.*
import org.http4s.*
import org.http4s.circe.*
import org.http4s.circe.CirceEntityCodec.*
import org.http4s.dsl.Http4sDsl
import org.http4s.dsl.io.*
import org.http4s.ember.server.*
import org.http4s.server.websocket.WebSocketBuilder2

import scala.concurrent.duration.*

class Index[F[_]](implicit F: Async[F]) extends Http4sDsl[F] {
  private val logger = Logger("Index")

  def routes: HttpRoutes[F] =
    HttpRoutes
      .of[F] {
        case req@GET -> Root =>
          logger.info(s"Received request: $req")

          Ok("Hello, World!")

        case req@POST -> Root =>
          logger.info(s"Received request: $req")

          req.decode[PubSubPayload] {
            payload =>
              logger.info(s"Received Pub/Sub message: $payload")

              Ok(payload)
          }
      }
}
