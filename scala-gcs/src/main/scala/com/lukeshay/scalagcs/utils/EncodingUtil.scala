package com.lukeshay.scalagcs.utils

import java.util.Base64

object EncodingUtil {
  def base64Decode(str: String): String =
    new String(Base64.getDecoder.decode(str))

}
