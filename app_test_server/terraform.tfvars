terragrunt = {

  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = ["../network", "../security-groups", "../keys", "../roles"]
  }

}
