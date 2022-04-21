package com.lukeshay.scalagcs.controllers

import scala.concurrent.duration._

import cats.effect._
import cats.implicits._
import com.comcast.ip4s._
import com.typesafe.scalalogging.Logger
import io.circe.generic.auto._
import io.circe.syntax._
import org.http4s._
import org.http4s.circe.CirceEntityCodec._
import org.http4s.circe._
import org.http4s.dsl.Http4sDsl
import org.http4s.dsl.io._
import org.http4s.ember.server._
import org.http4s.server.websocket.WebSocketBuilder2
import com.lukeshay.scalagcs.domain._

object Index {
  private val logger = Logger("Index")

  def service[F[_]: Async](wsb: WebSocketBuilder2[F]): HttpApp[F] = {
    val dsl = new Http4sDsl[F] {}
    import dsl._

    HttpRoutes
      .of[F] {
        case req @ GET -> Root =>
          logger.info(s"Received request: $req")

          Ok("Hello, World!")

        case req @ POST -> Root =>
          logger.info(s"Received request: $req")

          for {
            user <- req.as[User]
            resp <- Ok(Hello(user.name))
          } yield (resp)
      }
      .orNotFound
  }
}
