variable "cidr_block" {
   type = list(string)
   default = ["172.20.0.0/16","172.20.10.0/28"]
}

variable "ports" {
    type    = list(number)
    default = ["22","443","8080","8081","3389"]
}

variable "instance" {
  type = list(string)
  default = ["ami-01aab85a5e4a5a0fe","t2.micro","EC-2","t2.medium"]
}