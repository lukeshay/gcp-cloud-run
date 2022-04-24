package com.lukeshay.scalagcs

import cats.effect.ExitCode
import cats.effect.IO
import cats.effect.IOApp
import pubsub.PubSubPush

import com.google.cloud.storage.BlobId
import com.google.cloud.storage.BlobInfo
import com.google.cloud.storage.Storage
import com.lukeshay.scalagcs.adapters.GcsAdapter

import scala.util.Success
import scala.util.Failure

object Main extends IOApp {
  override def run(args: List[String]): IO[ExitCode] = PubSubPush
    .handle((payload, logger) => {
      val blobInfo = BlobInfo
        .newBuilder("scala-ods", s"messages/${payload.message.messageId}.json")
        .setContentType("application/json")
        .setContentEncoding("UTF-8")
        .build()

      GcsAdapter.create(
        blobInfo,
        payload.message.bufferData
      ) match {
        case Success(_) => Success(true)
        case Failure(exception) => Failure(exception)
      }
    })

}
