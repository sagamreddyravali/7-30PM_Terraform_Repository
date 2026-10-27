variable "nit" {
  type = list(string)
  #default = ["dev", "test", "prod"]
  default = ["dev", "prod"]
}



resource "aws_instance" "name" {
    ami = "ami-0d27e0fb3bac4d724"
    instance_type = "t2.medium"
    count=length(var.nit)
    tags = {
        Name = var.nit[count.index]
    }

  
}




#here i want to remove test server here how to remove from this to {default = ["dev", "test", "prod"] change liks this default = ["dev", "prod"] } like this remove from the variable block and then run terraform apply command then see which server is going to delete
#now go and check aws console here count we can't manage to remove from the exsting list whatever you want count follow the index
#so if you remove this test server it two become one i.e prod terminated and test renamed as a prod bcoz count following the series process
# in this case we have to use for_each instead of count so that we can manage the existing servers and we can remove any server from the list and then run terraform apply command then see which server is going to delete