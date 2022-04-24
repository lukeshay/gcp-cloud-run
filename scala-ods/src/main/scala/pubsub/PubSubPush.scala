package com.lukeshay.scalagcs
package pubsub

import scala.util.Failure
import scala.util.Success
import scala.util.Try

import cats.effect.ExitCode
import cats.effect.IO
import com.comcast.ip4s.Ipv4Address
import com.comcast.ip4s.Port
import com.typesafe.scalalogging.Logger
import io.circe.generic.auto._
import io.circe.syntax._
import org.http4s.HttpRoutes
import org.http4s._
import org.http4s.circe.CirceEntityCodec._
import org.http4s.circe._
import org.http4s.dsl.io._
import org.http4s.ember.server._
import org.http4s.implicits._
import scala.concurrent.duration._

object PubSubPush {
  type Handler = (PubSubPayload, Logger) => Try[Boolean]

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

                  Ok(HealthResponse(true).asJson)
                case req @ POST -> Root =>
                  logger.info(s"Received request: $req")

                  req.as[PubSubPayload].flatMap { payload =>
                     logger.info(
                       s"Received Pub/Sub message: $payload"
                     )

                     handler(payload, logger) match {
                       case Success(result) =>
                         Ok(SuccessResponse(result).asJson)
                       case Failure(error) =>
                         InternalServerError(
                           ErrorResponse(
                             error.getMessage
                           ).asJson
                         )
                     }
                  }
              }
              .orNotFound
          )
          .build
    } yield server
  }.use(server =>
    IO.delay(println(s"Server Has Started at ${server.address}")) >>
      IO.never.as(ExitCode.Success)
  )

}
