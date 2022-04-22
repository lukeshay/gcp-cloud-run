package com.lukeshay.scalagcs

import controllers.Index

import cats.effect.{ExitCode, IO, IOApp}
import com.comcast.ip4s.{Ipv4Address, Port}
import org.http4s.ember.server.EmberServerBuilder

object Main extends IOApp {

  override def run(args: List[String]): IO[ExitCode] = {
    val host = Ipv4Address.fromString("0.0.0.0").get
    val port = Port.fromString(sys.env.getOrElse("PORT", "8080")).get

    for {
      server <-
        EmberServerBuilder
          .default[IO]
          .withHost(host)
          .withPort(port)
          .withHttpApp(new Index[IO].routes.orNotFound)
          .build
    } yield server
  }.use(
    server =>
      IO.delay(println(s"Server Has Started at ${server.address}")) >>
        IO.never.as(ExitCode.Success)
  )

}
