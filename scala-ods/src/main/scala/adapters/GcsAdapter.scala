package com.lukeshay.scalagcs
package adapters

import com.google.cloud.storage.Storage.BlobTargetOption
import com.google.cloud.storage.BlobInfo
import com.google.cloud.storage.Blob
import com.google.cloud.storage.Storage
import com.google.cloud.storage.StorageOptions

import scala.util.Failure
import scala.util.Success
import scala.util.Try

object GcsAdapter {
  private val storage: Storage = StorageOptions.getDefaultInstance.getService

  def create(blobInfo: BlobInfo, content: Array[Byte]): Try[Blob] = {
    try {
      Success(storage.create(blobInfo, content))
    } catch {
      case error: Throwable => Failure(error)
    }
  }
}
