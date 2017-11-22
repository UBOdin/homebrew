
require 'net/http'

class Mimir < Formula

  desc "The Mimir data-ish exploration tool (alpha version)."
  homepage "http://mimirdb.info"
  head "https://github.com/UBOdin/mimir.git"

  depends_on "sbt" => :build
  depends_on :java => "1.6+"

  def install
    system "sbt package"

    puts "Getting Classpath"
    dependencies =
      IO.popen("sbt 'export runtime:fullClasspath'") { |sbt| sbt.readlines[-1].chomp }

    puts "Loading Build Config"
    config = {}
    File.open("build.sbt") do |f|
      f.each do |l|
        case l.chomp
        when /(\w+) *:= "([^"]+)"/ then config[$1.to_sym] = $2
        end
      end
    end

    scala_major_version = config[:scalaVersion].split(/\./)[0..1].join(".")
    jar_name = "#{config[:name].downcase}_#{scala_major_version}-#{config[:version]}.jar"
    file_path = "target/scala-#{scala_major_version}/#{jar_name}"
    libexec.install file_path

    puts "Building Wrapper Script"
    File.open("mimir", "w+") do |f| 
      f.puts("#!/bin/bash")

      dep_install_paths = dependencies
        .split(/:/)
        .map do |dep|
          if File.extname(dep) == ".jar"
            case dep
            when /\/lib\/(.*)\.jar/ then 
              install_name = "mimir-lib-#{File.basename(dep)}"
              libexec.install(dep => install_name)
              "#{libexec}/#{install_name}"
            when /java_cache/ then 
              dep
            else
              raise "Unhandled Dependency: #{dep}"
            end
          end
        end
        .compact
      f.puts("JAR=#{libexec}/#{jar_name}")
      f.puts("CLASSPATH=#{dep_install_paths.join(":")}")
      f.puts("MAIN_CLASS=mimir.Mimir")
      f.puts("java -cp $JAR:$CLASSPATH $MAIN_CLASS $*") 
    end
    system "chmod +x mimir"
    bin.install "mimir"
  end

  test do
    File.open("test.sql", "w+") do |f|
      f.puts("CREATE TABLE R(a int, b int);")
      f.puts("INSERT INTO R(a, b) VALUES (1, 2);")
      f.puts("SELECT * FROM R;")
    end
    system "#{bin}/mimir --db test.db test.sql"
    system "rm test.db test.sql"
  end

end
