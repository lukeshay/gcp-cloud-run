package com.lukeshay.scalagcs

import scala.concurrent.ExecutionContext

import cats.effect._
import com.comcast.ip4s.Ipv4Address
import com.comcast.ip4s.Port
import com.typesafe.scalalogging.Logger
import org.http4s.ember.server.EmberServerBuilder
import org.http4s.implicits._
import org.http4s.server.middleware.RequestId
import org.slf4j.LoggerFactory
import com.lukeshay.scalagcs.controllers._

object Main extends IOApp {

  override def run(args: List[String]): IO[ExitCode] = {
    val host = Ipv4Address.fromString("0.0.0.0").get
    val port = Port.fromString(sys.env.get("PORT").getOrElse("8080")).get

    for {
      server <-
        EmberServerBuilder
          .default[IO]
          .withHost(host)
          .withPort(port)
          .withHttpWebSocketApp(Index.service[IO])
          .build
    } yield server
  }.use(server =>
    IO.delay(println(s"Server Has Started at ${server.address}")) >>
      IO.never.as(ExitCode.Success)
  )
}
