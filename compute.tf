resource "aws_key_pair" "main" {
  key_name   = "terraform-key"
  public_key = file("/home/carlos/.ssh/terraform-key.pub")
}



resource "aws_instance" "server" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = aws_key_pair.main.key_name

  user_data = <<-EOF
           
            #!/bin/bash
            yum update -y
            amazon-linux-extras install docker -y
            systemctl start docker
            systemctl enable docker
            usermod -aG docker ec2-user

            docker run -d -p 80:80 --name web nginx
            EOF

  tags = {
    Name = "ec2-docker"
  }
}
