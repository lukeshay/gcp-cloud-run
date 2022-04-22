package com.lukeshay.scalagcs.utils

import java.time.format.DateTimeFormatter
import java.time.temporal.TemporalAccessor

val isoDateTimeFormatter = DateTimeFormatter.ISO_DATE_TIME

object DateTimeUtil {

  def parseIsoDateTime(isoDateTime: String): TemporalAccessor =
    isoDateTimeFormatter.parse(isoDateTime)

  def formatIsoDateTime(isoDateTime: TemporalAccessor): String =
    isoDateTimeFormatter.format(isoDateTime)

}
