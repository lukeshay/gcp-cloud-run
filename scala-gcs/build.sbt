val Http4sVersion  = "0.23.11"
val CirceVersion   = "0.14.1"

inThisBuild(
  List(
    scalaVersion := "3.1.2",
    scalacOptions ++= List(
      "-deprecation",
      "-Ywarn-unused"
    ),
    semanticdbEnabled := true,
    semanticdbIncludeInJar := true,
    semanticdbVersion := scalafixSemanticdb.revision,
    scalafixDependencies += "com.github.liancheng" %% "organize-imports" % "0.5.0",
    useSuperShell := false
  )
)

enablePlugins(JavaServerAppPackaging)

dockerBaseImage := "openjdk:8u292"

lazy val root = (project in file("."))
  .settings(
    organization := "com.lukeshay",
    name         := "scala-gcs",
    version      := "0.0.1-SNAPSHOT",
    scalaVersion := "3.1.2",
    libraryDependencies ++= Seq(
      "org.http4s"         %% "http4s-core"         % Http4sVersion,
      "org.http4s"         %% "http4s-ember-server" % Http4sVersion,
      "org.http4s"         %% "http4s-circe"        % Http4sVersion,
      "org.http4s"         %% "http4s-dsl"          % Http4sVersion,
      "io.circe"           %% "circe-generic"       % CirceVersion,
    )
  )
