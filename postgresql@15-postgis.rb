class PostgresqlAT15Postgis < Formula
  desc ""
  homepage ""
  url "https://download.osgeo.org/postgis/source/postgis-3.3.4.tar.gz"
  sha256 "9d41eaef70e811a4fe2f4a431d144c0c57ce17c2c1a3c938ddaf4e5a3813b0d8"
  license ""
  keg_only "conflicts with the `postgis` formula"

  depends_on "gpp" => :build
  depends_on "pkg-config" => :build
  depends_on "gdal"
  depends_on "geos"
  depends_on "icu4c"
  depends_on "json-c"
  depends_on "pcre2"
  depends_on "postgresql@15"
  depends_on "proj"
  depends_on "protobuf-c"
  depends_on "sfcgal"

  fails_with gcc: "5" # C++17

  def postgresql
    Formula["postgresql@15"]
  end

  def install
    ENV.deparallelize

    ENV.append "CXXFLAGS", "-std=c++17"

    ENV["PG_CONFIG"] = postgresql.opt_bin/"pg_config"

    args = [
      "--with-projdir=#{Formula["proj"].opt_prefix}",
      "--with-jsondir=#{Formula["json-c"].opt_prefix}",
      "--with-pgconfig=#{postgresql.opt_bin}/pg_config",
      "--with-protobufdir=#{Formula["protobuf-c"].opt_bin}",
      "--disable-nls",
    ]

    system "./configure", *args

    system "make"

    system "make", "install", "DESTDIR=#{buildpath}/stage"

    postgresql_prefix = postgresql.prefix.realpath
    postgresql_stage_path = File.join("stage", postgresql_prefix)
    bin.install (buildpath/postgresql_stage_path/"bin").children
    doc.install (buildpath/postgresql_stage_path/"share/doc").children

    stage_path = File.join("stage", HOMEBREW_PREFIX, "opt/postgresql@15")
    lib.install (buildpath/stage_path/"lib").children
    share.install (buildpath/stage_path/"share").children


    bin.install %w[
      utils/create_undef.pl
      utils/create_upgrade.pl
      utils/postgis_restore.pl
      utils/profile_intersects.pl
      utils/test_estimation.pl
      utils/test_geography_estimation.pl
      utils/test_geography_joinestimation.pl
      utils/test_joinestimation.pl
    ]
  end
end
