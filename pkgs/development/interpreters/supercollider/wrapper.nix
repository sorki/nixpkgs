{ stdenv, symlinkJoin, supercollider, makeWrapper, plugins }:

let
puredataFlags = map (x: "-path ${x}/") plugins;
in symlinkJoin {
  name = "supercollider-with-plugins-${supercollider.version}";

  paths = [ supercollider ] ++ plugins;

  buildInputs = [ makeWrapper ];

  postBuild = ''
    ln -s $out/lib/SuperCollider/plugins/ $out/
    wrapProgram $out/bin/scide
  #    --add-flags "${toString puredataFlags}"
  '';

  #postInstall = ''
  #  mkdir $out/plugins
  #  ln -s ${sc3}/lib/* $out/plugins/
  #  ln -s ${sc3}/share/SuperCollider/Extensions/SC3plugins $out/Extensions/
  #'';
}
