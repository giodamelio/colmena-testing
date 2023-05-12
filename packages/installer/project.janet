(declare-project
  :name "installer"
  :description "A script to help me install NixOS easily"
  :dependencies [])

(declare-executable
  :name "installer"
  :entry "src/main.janet"
  :install true)
