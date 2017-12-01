{
  gli = {
    source = {
      remotes = ["https://rubygems.vpsfree.cz"];
      sha256 = "0g7g3lxhh2b4h4im58zywj9vcfixfgndfsvp84cr3x67b5zm4kaq";
      type = "gem";
    };
    version = "2.17.1";
  };
  json = {
    source = {
      remotes = ["https://rubygems.vpsfree.cz"];
      sha256 = "01v6jjpvh3gnq6sgllpfqahlgxzj50ailwhj9b3cd20hi2dx0vxp";
      type = "gem";
    };
    version = "2.1.0";
  };
  osctl = {
    dependencies = ["gli" "json"];
    source = {
      remotes = ["https://rubygems.vpsfree.cz"];
      sha256 = "0cqp89cm6021ngxy6bsjab9vixqkly3dq554fc6nrzmgcddwciyn";
      type = "gem";
    };
    version = "0.1.0.build20171201182704";
  };
}