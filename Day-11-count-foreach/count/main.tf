resource "aws_instance" "name" {
    ami = "ami-0d27e0fb3bac4d724"
    instance_type = "t2.medium"
    count = 3
    tags = {
        Name = "veera"
    }
  
}

#here count is creating different different names 0,1,2 for the same resource and creating 3 instances with same name
# we can cretae different different names also but in this case we have to create a variable and use that variable in the name tag to create different diffrent name 
#for example instead of creating all servers with same name i want to create 3 servers with different names like veera1, veera2, veera3 so for that we have to create the variable and use that variable in the name tag to create different different names for the servers
# here i write the variable block in count-variable-practice/ directory main.tf file and then use that variable in the name tag to create different different names for the servers
# go to count-variable-practice/ directory and create a variable block in main.tf file and then use that variable in the name tag to create different different names for the servers