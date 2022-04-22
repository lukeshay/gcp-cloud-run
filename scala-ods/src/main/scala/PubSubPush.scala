package com.lukeshay.scalagcs

import domain.PubSubPayload
import types.Handler

import cats.effect.*
import cats.implicits.*
import com.comcast.ip4s.*
import com.typesafe.scalalogging.Logger
import io.circe.generic.auto.*
import org.http4s.*
import org.http4s.circe.*
import org.http4s.circe.CirceEntityCodec.*
import org.http4s.dsl.io.*
import org.http4s.ember.server.EmberServerBuilder

object PubSubPush {
  val handler: Handler = (payload, logger) => true

  def handle(handler: Handler): IO[ExitCode] = {
    val host = Ipv4Address.fromString("0.0.0.0").get
    val port = Port.fromString(sys.env.getOrElse("PORT", "8080")).get
    val logger = Logger("Index")

    for {
      server <-
        EmberServerBuilder
          .default[IO]
          .withHost(host)
          .withPort(port)
          .withHttpApp(
            HttpRoutes
              .of[IO] {
                case req @ GET -> Root =>
                  logger.info(s"Received request: $req")

                  Ok("Hello, World!")

                case req @ POST -> Root =>
                  logger.info(s"Received request: $req")

                  req.decode[PubSubPayload] {
                    payload =>
                       logger.info(s"Received Pub/Sub message: $payload")

                       if (handler(payload, logger))
                         Ok()
                       else
                         InternalServerError()
                  }
              }
              .orNotFound
          )
          .build
    } yield server
  }.use(
    server =>
      IO.delay(println(s"Server Has Started at ${server.address}")) >>
        IO.never.as(ExitCode.Success)
  )

}
