{ mkShell, ... }: mkShell {
  name = "example";
  shellHook = ''
    echo "Example DevShell"
  '';
}
