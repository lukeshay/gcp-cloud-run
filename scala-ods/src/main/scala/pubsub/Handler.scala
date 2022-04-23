package com.lukeshay.scalagcs
package types

import com.typesafe.scalalogging.Logger
import domain.PubSubPayload

type Handler = (payload: PubSubPayload, logger: Logger) => Boolean
