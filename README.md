# Projeto Terraform AWS – EC2 com Docker e Nginx

## Visão geral

Este projeto tem como objetivo demonstrar o uso do Terraform para provisionamento de infraestrutura na AWS, criando um ambiente funcional e reproduzível que inclui rede, segurança, computação e execução de uma aplicação containerizada.

O resultado final é uma instância EC2 acessível via SSH, executando Docker com Nginx, disponível publicamente via HTTP.

O projeto foi desenvolvido com foco em Infraestrutura como Código (IaC), clareza arquitetural e boas práticas para ambientes de estudo.

## Tecnologias utilizadas

Terraform  
AWS (VPC, EC2, Security Group, Key Pair)  
AWS CLI  
Docker  
Nginx  
Linux (Amazon Linux 2) e Linux PopOs
SSH  

## AWS CLI

O AWS CLI foi configurado previamente para autenticar a conta AWS localmente e permitir que o Terraform se comunique com a AWS sem necessidade de credenciais no código.

Após a execução do comando aws configure, o Terraform passou a utilizar automaticamente as credenciais configuradas.

## Terraform e Infraestrutura como Código

Toda a infraestrutura foi criada utilizando Terraform, permitindo versionamento e fácil destruição dos recursos.

Fluxo utilizado:
terraform init  
terraform fmt
terraform plan  
terraform apply  
terraform destroy  

O uso do terraform plan antes do apply foi essencial para validar as mudanças antes de aplicá-las.

## Arquitetura de Rede (VPC e Subnet)

Foi criada uma VPC dedicada, isolando completamente os recursos do projeto.

Dentro da VPC:
- Subnet pública
- Internet Gateway
- Route Table com rota para a internet

Essa configuração permitiu que a EC2 tivesse IP público e acesso externo.

## Key Pair e acesso SSH

Uma Key Pair foi criada via Terraform para permitir acesso SSH à EC2.

Durante o desenvolvimento, ocorreu um problema de autenticação devido ao uso incorreto do usuário SSH. A AMI utilizada foi Amazon Linux 2, cujo usuário padrão é ec2-user, e não ubuntu.

Após a correção do usuário, o acesso SSH funcionou corretamente.

## Security Group

Foi criado um Security Group com as seguintes regras:
- Porta 22 para SSH
- Porta 80 para HTTP
- Saída liberada para qualquer destino

O Security Group atuou como firewall virtual, garantindo acesso controlado à instância.

## EC2 (Compute)

Foi criada uma instância EC2 t3.micro associada à VPC, subnet pública, Security Group e Key Pair.

A EC2 é utilizada como host para execução de containers Docker.

## Docker

O Docker foi instalado automaticamente via user_data durante o boot da EC2, utilizando os comandos corretos para Amazon Linux 2.


## Nginx e aplicação

Um container Nginx foi executado utilizando Docker para demonstrar uma aplicação web funcional.

O Nginx foi escolhido por ser leve, simples e amplamente utilizado.

## Acesso via HTTP

Com a porta 80 liberada e o Nginx em execução, a aplicação ficou acessível via navegador utilizando o IP público da EC2.

Esse passo validou toda a infraestrutura criada.

## Output do Terraform

Foi utilizado um output simples para exibir o IP público da EC2, facilitando acesso SSH e HTTP.

## Versionamento no GitHub

Todo o projeto foi versionado no GitHub, incluindo arquivos Terraform e este README.

Arquivos de estado não devem ser versionados em projetos reais.

## Considerações finais


