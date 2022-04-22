val Http4sVersion = "0.23.11"
val CirceVersion = "0.14.1"

ThisBuild / version := "0.1.0-SNAPSHOT"

ThisBuild / scalaVersion := "3.1.2"

enablePlugins(JavaServerAppPackaging)

dockerBaseImage := "openjdk:17.0.2"

lazy val root = (project in file("."))
  .settings(
    name := "scalaods",
    idePackagePrefix := Some("com.lukeshay.scalagcs"),
    libraryDependencies ++=
      Seq(
        "org.http4s" %% "http4s-core" % Http4sVersion,
        "org.http4s" %% "http4s-ember-server" % Http4sVersion,
        "org.http4s" %% "http4s-circe" % Http4sVersion,
        "org.http4s" %% "http4s-dsl" % Http4sVersion,
        "io.circe" %% "circe-core" % CirceVersion,
        "io.circe" %% "circe-generic" % CirceVersion,
        "com.typesafe.scala-logging" %% "scala-logging" % "3.9.4",
        "ch.qos.logback" % "logback-classic" % "1.2.11",
        "com.google.cloud" % "google-cloud-storage" % "2.6.1"
      )
  )
