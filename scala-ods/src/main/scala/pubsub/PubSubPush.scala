package com.lukeshay.scalagcs.pubsub;object PubSubPush {
		val handler: Handler = (payload, logger) => true

		def handle(handler: Handler): IO[ExitCode] = {
				val host = Ipv4Address.fromString("0.0.0.0").get
				val port = Port.fromString(sys.env.getOrElse("PORT", "8080")).get
				val logger = Logger("Index")

				for {
						server <-
								EmberServerBuilder
										.default[IO]
										.withHost(host)
										.withPort(port)
										.withHttpApp(
										HttpRoutes
												.of[IO] {
												case req @ GET -> Root =>
														logger.info(s"Received request: $req")

																Ok("Hello, World!")

														case req @ POST -> Root =>
																logger.info(s"Received request: $req")

																		req.decode[PubSubPayload] {
																				payload =>
																						logger.info(s"Received Pub/Sub message: $payload")

																								if (handler(payload, logger))
																										Ok()
																										else
																										InternalServerError()
																				}
												}
												.orNotFound
										)
										.build
						} yield server
				}.use(
				server =>
						IO.delay(println(s"Server Has Started at ${server.address}")) >>
								IO.never.as(ExitCode.Success)
				)

		}
