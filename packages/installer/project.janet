(declare-project
  :name "nixos-installer"
  :description ```Barebones NixOS installer```
  :version "0.0.0"
  :dependencies ["spork"])

(declare-executable
  :name "nixos-installer"
  :entry "src/init.janet"
  :install true)
