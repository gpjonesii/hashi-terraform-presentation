variable "location" {
    description = "Azure Region all resources will be deployed to"
    default = "eastus2"
}

variable "environment" {
    description = "Deployment Environment for Tags"
    default = "development"
}

variable "key_data" {
  description = "The SSH public key that will be added to SSH authorized_users on the consul instances"
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+6GRn1V0LaepPJiqu18RtAUeSi/Oz4EfocS17cgthvXZKhqelPR0E1tlEN1RXlPrUnXivOxgePXjoJOau7lKi/244xCtrMLXsIjA7Yfl4bop0EgCndHo7EBW9t2ouyrQuIp3LN+YPx6j8aLMLVlbs88A8aytAJC/QuuSXa5nTU8ptWHP/y5eb4OfHFXLks655LLWTX1L9fmNyqtQEBM2posVric1m/rfc5kya7EW9bGNuAjXGtUUhGkAAs2m/hzA3X3LomsVz4bpaAozBH5plMKWy8TB1On2bBYAvH7FL4C8dG9liRv2Xh10yw4mR8r7jIUYdeiDs+opfRE3PRFkJ"
}