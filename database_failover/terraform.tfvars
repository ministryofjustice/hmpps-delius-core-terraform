terragrunt = {

  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = ["../security-groups", "../key_profile"]
  }

}
