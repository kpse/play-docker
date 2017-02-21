name := """play-docker"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.7"

libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,
  "org.scalatestplus.play" %% "scalatestplus-play" % "1.5.1" % Test
)

lazy val dockerSettings = Seq(
  // things the docker file generation depends on are listed here
  dockerfile in docker := {
    // any vals to be declared here
    new sbtdocker.mutable.Dockerfile {
//      env("APPLICATION_SECRET", s"123745")
    }
  }
)