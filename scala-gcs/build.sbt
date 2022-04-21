val Http4sVersion = "0.23.11"
val CirceVersion  = "0.14.1"

inThisBuild(
  List(
    scalaVersion := "3.1.2",
    scalacOptions ++= List(
      "-deprecation",
      "-Ywarn-unused"
    ),
    javacOptions ++= List(
      "-source",
      "17.0.2",
      "-target",
      "17.0.2"
    ),
    semanticdbEnabled                              := true,
    semanticdbIncludeInJar                         := true,
    semanticdbVersion                              := scalafixSemanticdb.revision,
    scalafixDependencies += "com.github.liancheng" %% "organize-imports" % "0.5.0",
    useSuperShell                                  := false
  )
)

enablePlugins(JavaServerAppPackaging)

dockerBaseImage := "openjdk:17.0.2"

lazy val root = (project in file("."))
  .settings(
    organization := "com.lukeshay",
    name         := "scala-gcs",
    version      := "0.0.1-SNAPSHOT",
    scalaVersion := "3.1.2",
    libraryDependencies ++= Seq(
      "org.http4s"                 %% "http4s-core"         % Http4sVersion,
      "org.http4s"                 %% "http4s-ember-server" % Http4sVersion,
      "org.http4s"                 %% "http4s-circe"        % Http4sVersion,
      "org.http4s"                 %% "http4s-dsl"          % Http4sVersion,
      "io.circe"                   %% "circe-core"          % CirceVersion,
      "io.circe"                   %% "circe-generic"       % CirceVersion,
      "com.typesafe.scala-logging" %% "scala-logging"       % "3.9.4",
      "ch.qos.logback"              % "logback-classic"     % "1.2.10"
      // "io.circe"   %% "circe-literal"       % CirceVersion
    )
  )

// addCompilerPlugin("org.scalamacros" % "paradise" % "2.1.0" cross CrossVersion.full)
