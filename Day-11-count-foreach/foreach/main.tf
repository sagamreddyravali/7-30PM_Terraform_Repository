variable "nit" {
  type = list(string)
  #default = ["dev", "test", "prod"]
  default = ["dev", "prod"]
}



resource "aws_instance" "name" {
    ami = "ami-0d27e0fb3bac4d724"
    instance_type = "t2.medium"
    for_each=toset(var.nit)
    tags = {
        Name = each.key
    }

  
}

# remove test sevrer from the list and then run terraform apply command then see which server is going to delete
#here test server is deleted 
# count we use for only condition base process example i want to create only dev server not prod server