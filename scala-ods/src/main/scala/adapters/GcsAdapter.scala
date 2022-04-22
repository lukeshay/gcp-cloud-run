package com.lukeshay.scalagcs
package adapters

import com.google.cloud.storage.Storage
import com.google.cloud.storage.StorageOptions

object GcsAdapter {
  val storage: Storage = StorageOptions.getDefaultInstance.getService
}
