{
  coderay = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15vav4bhcc2x3jmi3izb11l4d9f3xv8hp2fszb7iqmpsccv1pz4y";
      type = "gem";
    };
    version = "1.1.2";
  };
  daemons = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15smbsg0gxb7nf0nrlnplc68y0cdy13dm6fviavpmw7c630sring";
      type = "gem";
    };
    version = "1.2.5";
  };
  eventmachine = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "075hdw0fgzldgss3xaqm2dk545736khcvv1fmzbf1sgdlkyh1v8z";
      type = "gem";
    };
    version = "1.2.5";
  };
  json = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01v6jjpvh3gnq6sgllpfqahlgxzj50ailwhj9b3cd20hi2dx0vxp";
      type = "gem";
    };
    version = "2.1.0";
  };
  mail = {
    dependencies = ["mini_mime"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10dyifazss9mgdzdv08p47p344wmphp5pkh5i73s7c04ra8y6ahz";
      type = "gem";
    };
    version = "2.7.0";
  };
  method_source = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xqj21j3vfq4ldia6i2akhn2qd84m0iqcnsl49kfpq3xk6x0dzgn";
      type = "gem";
    };
    version = "0.9.0";
  };
  mini_mime = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lwhlvjqaqfm6k3ms4v29sby9y7m518ylsqz2j74i740715yl5c8";
      type = "gem";
    };
    version = "1.0.0";
  };
  mysql = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y2b5rnspa0lllvqd6694hbkjhdn45389nrm3xfx6xxx6gf35p36";
      type = "gem";
    };
    version = "2.9.1";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yayisnfsr8zrs5nj6hj4f0yval09p2c0qsp2d4jx0s35b0w3zlj";
      type = "gem";
    };
    version = "0.11.2";
  };
  pry-remote = {
    dependencies = ["pry" "slop"];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10g1wrkcy5v5qyg9fpw1cag6g5rlcl1i66kn00r7kwqkzrdhd7nm";
      type = "gem";
    };
    version = "0.1.8";
  };
  require_all = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ga1g3hyi623b8da881hrcd6xqzvxflk1k46ivdfxk47rqc4rxvv";
      type = "gem";
    };
    version = "1.4.0";
  };
  slop = {
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00w8g3j7k7kl8ri2cf1m58ckxk8rn350gp4chfscmgv6pq1spk3n";
      type = "gem";
    };
    version = "3.6.0";
  };
  vpsadmind = {
    dependencies = ["daemons" "eventmachine" "json" "mail" "mysql" "pry-remote" "require_all"];
    source = {
      fetchSubmodules = false;
      rev = "1d5c2f43cde99f9e8c682ae7305a8f5b2f1b79f8";
      sha256 = "0a9gs6kckxpgghy9h7gjr2k5fsr8wrxvp8mypkv60zdffam5sig3";
      type = "git";
      url = "https://github.com/sorki/vpsadmin/";
    };
    version = "2.9.0";
  };
}
