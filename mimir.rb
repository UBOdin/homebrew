class Mimir < Formula
  desc ""
  homepage "http://mimirdb.info"
  url "http://maven.mimirdb.info/info/mimirdb/mimir-core_2.10/0.2-SNAPSHOT/Mimir.jar", using: :curl
  version "0.2-SNAPSHOT"
  sha256 ""

  depends_on "sbt" => :build

  def install
    File.open("mimir", "w+") do |f| 
      f.puts("#!/bin/bash")
      f.puts("java -jar #{libexec}/Mimir.jar $*") 
    end
    system "chmod +x mimir"
    libexec.install "Mimir.jar"
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
