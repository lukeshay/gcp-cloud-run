package com.lukeshay.scalagcs

import cats.effect.Async
import org.http4s.dsl.io.Ok
import org.http4s.HttpApp
import org.http4s.dsl.Http4sDsl
import org.http4s.server.websocket.WebSocketBuilder2
import org.http4s.HttpRoutes

object HttpServer {
  def service[F[_]: Async](wsb: WebSocketBuilder2[F]): HttpApp[F] = {
    val dsl = new Http4sDsl[F] {}
    import dsl._

    HttpRoutes
      .of[F] {
        case GET -> Root =>
          Ok("Hello, World!")

        case POST -> Root =>
          Ok("Hello, World!")
      }
      .orNotFound
  }
}
