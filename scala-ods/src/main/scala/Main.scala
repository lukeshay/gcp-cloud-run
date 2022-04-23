package com.lukeshay.scalagcs

import cats.effect.ExitCode
import cats.effect.IO
import cats.effect.IOApp

object Main extends IOApp {
  override def run(args: List[String]): IO[ExitCode] = PubSubPush
    .handle((payload, logger) => false)

}
