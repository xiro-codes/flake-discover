# lib/discovery.nix (or a similar location in your flake)
let
  # Internal recursive directory crawler
  crawl = path: type:
    if type == "directory" then
      let
        content = builtins.readDir path;
      in
      builtins.listToAttrs (builtins.concatLists (builtins.map
        (name:
          let
            subPath = path + "/${name}";
            subType = content.${name};
          in
          if name == "default.nix" then [ ] # Avoid self-import loops
          else if subType == "directory" then
            [{ name = name; value = crawl subPath subType; }]
          else if builtins.hasSuffix ".nix" name then
            [{ name = builtins.replaceStrings [ ".nix" ] [ "" ] name; value = import subPath; }]
          else [ ]
        )
        (builtins.attrNames content)))
    else { };

in
{
  # The main entry point for your new system
  discover = { root, collectors ? [ ] }:
    builtins.listToAttrs (builtins.map
      (c: {
        name = c.name;
        value =
          let
            basePath = root + "/${c.path}";
            files = if builtins.pathExists basePath then builtins.readDir basePath else { };
          in
          builtins.listToAttrs (builtins.concatLists (builtins.map
            (name:
              let
                fullPath = basePath + "/${name}";
                type = files.${name};
              in
              if c.filter name type then
                [{ name = builtins.replaceStrings [ ".nix" ] [ "" ] name; value = c.transform fullPath; }]
              else [ ]
            )
            (builtins.attrNames files)));
      })
      collectors);
}
