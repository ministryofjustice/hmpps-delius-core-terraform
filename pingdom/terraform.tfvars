terragrunt = {

  include {
    path = "${find_in_parent_folders()}"
  }

  dependencies {
    paths = ["../application/ndelius"]
  }

}
