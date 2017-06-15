class Mimir < Formula
  desc "The Mimir data-ish exploration tool (alpha version)."
  homepage "http://mimirdb.info"
  url "http://maven.mimirdb.info/info/mimirdb/mimir-core_2.11/0.2/Mimir.jar", using: :curl
  version "0.2.1"
  sha256 "030973c5d5e3c990ac73e26a882328179d2f7db07058688246d7d4883292b66a"

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
