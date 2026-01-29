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

  tags = {
    Name = "ec2-ansible-target"
  }
}
