# Projeto DevOps – Provisionamento AWS com Terraform, Ansible, Docker e Nginx

##  Visão Geral

Este projeto demonstra a construção de uma infraestrutura completa na AWS utilizando **Infraestrutura como Código (IaC)** e automação de configuração, seguindo práticas comuns em ambientes DevOps e Cloud.

O ambiente provisionado cria uma VPC dedicada, configura rede, segurança e computação, sobe uma instância EC2, instala Docker automaticamente e executa uma aplicação Nginx acessível publicamente via HTTP.

**Objetivo:** Estudo, consolidação de conceitos e portfólio, demonstrando domínio prático dos fundamentos de Cloud, redes, containers e automação.

---

## Tecnologias Utilizadas

### Infraestrutura e Automação
- **Terraform** – Provisionamento de infraestrutura (IaC)
- **Ansible** – Automação de configuração
- **AWS CLI** – Autenticação e integração local

### AWS Services
- **VPC** – Rede virtual privada
- **Subnet** – Sub-rede pública
- **Internet Gateway** – Conectividade externa
- **Route Table** – Tabela de rotas
- **Security Group** – Firewall virtual
- **EC2** – Instância de computação
- **Key Pair** – Autenticação SSH

### Containers e Aplicação
- **Docker** – Execução de containers
- **Nginx** – Aplicação web de demonstração

### Sistema Operacional
- **Amazon Linux 2** (EC2)
- **Pop!_OS** (máquina local)

### Outros
- **SSH** – Acesso remoto seguro
- **Git & GitHub** – Versionamento de código

---

##  Arquitetura do Projeto

```
Internet
   |
   | (HTTP / SSH)
   v
+----------------------+
|   Security Group     |
|  - Port 22 (SSH)     |
|  - Port 80 (HTTP)    |
+----------+-----------+
           |
           v
+----------------------+
|    EC2 Instance      |
|  Amazon Linux 2      |
|  Docker Engine       |
|  Nginx Container     |
+----------+-----------+
           |
           v
+----------------------+
|   Public Subnet      |
|  10.0.1.0/24         |
+----------+-----------+
           |
           v
+----------------------+
|        VPC           |
|  10.0.0.0/16         |
+----------------------+
```

---

##  Estrutura de Pastas

```
.
├── provider.tf        # Configuração do provider AWS
├── network.tf         # VPC, Subnet, IGW e Route Table
├── security.tf        # Security Groups
├── compute.tf         # EC2 e Key Pair
├── outputs.tf         # IP público da EC2
├── ansible/
│   ├── inventory.ini  # Inventário com IP da EC2
│   ├── playbook.yml   # Playbook principal
│   └── roles/
│       ├── docker/    # Role para instalação do Docker
│       └── nginx/     # Role para deployment do Nginx
└── README.md
```

---

## Como Usar

### Pré-requisitos

- AWS Account ativa
- AWS CLI configurado
- Terraform instalado (>= 1.0)
- Ansible instalado (>= 2.9)
- Git instalado

### 1. Configurar AWS CLI

Configure suas credenciais AWS localmente:

```bash
aws configure
```

Isso permite que o Terraform se autentique automaticamente sem expor credenciais no código.

### 2. Provisionar Infraestrutura com Terraform

```bash
# Inicializar o Terraform
terraform init

# Formatar código (opcional)
terraform fmt

# Planejar as mudanças
terraform plan

# Aplicar a infraestrutura
terraform apply
```

O comando `terraform plan` mostra exatamente o que será criado antes de aplicar as mudanças.

### 3. Configurar com Ansible

Após o provisionamento, configure a instância:

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 4. Acessar a Aplicação

```bash
# Obter o IP público (output do Terraform)
terraform output

# Acessar via SSH
ssh -i terraform-key.pem ec2-user@<IP_PUBLICO>

# Acessar via navegador
http://<IP_PUBLICO>
```

### 5. Destruir Recursos

Quando finalizar, destrua todos os recursos para evitar custos:

```bash
terraform destroy
```

---

##  Componentes Detalhados

### VPC e Networking

**VPC (Virtual Private Cloud)**
- CIDR: `10.0.0.0/16`
- Isolamento completo dos recursos do projeto

**Subnet Pública**
- CIDR: `10.0.1.0/24`
- Associada ao Internet Gateway

**Internet Gateway**
- Permite comunicação com a internet

**Route Table**
- Rota padrão: `0.0.0.0/0` → Internet Gateway

### Security Group

Funciona como um **firewall virtual** controlando o tráfego:

**Ingress (Entrada)**
| Porta | Protocolo | Origem |  | Descrição   |
|-------|-----------|-----------|-------------|
| 22    | TCP       | 0.0.0.0/0 | SSH access  |
| 80    | TCP       | 0.0.0.0/0 | HTTP access |

**Egress (Saída)**
- Liberação total para todas as portas e destinos

### EC2 Instance

**Especificações:**
- **Tipo:** t3.micro (free tier eligible)
- **AMI:** Amazon Linux 2
- **Usuário SSH:** `ec2-user`
- **Key Pair:** Gerado via Terraform

**User Data:**
- Instalação automática do Docker durante o boot
- Configuração inicial do sistema

### Docker

Instalado automaticamente via `user_data` do Terraform ou via Ansible.

**Verificar instalação:**
```bash
docker --version
docker ps
```

### Nginx Container

Container Docker executando o servidor web Nginx.

**Deploy manual:**
```bash
docker run -d -p 80:80 nginx
```

**Deploy via Ansible:**
Automatizado através do playbook na role `nginx/`.

---

##  Troubleshooting

### Erro: Permission denied (publickey)

**Causa:** Tentativa de conexão com usuário incorreto

**Solução:** Amazon Linux 2 usa o usuário `ec2-user`, não `ubuntu`

```bash
#  Incorreto
ssh -i terraform-key.pem ubuntu@<IP>

#  Correto
ssh -i terraform-key.pem ec2-user@<IP>
```

### Erro: Connection timeout

**Possíveis causas:**
- Security Group não permite porta 22
- Subnet não está associada ao Internet Gateway
- Key Pair incorreta

### Nginx não responde

**Verificações:**
1. Container está rodando? `docker ps`
2. Security Group permite porta 80?
3. Nginx está mapeado na porta correta? `-p 80:80`

---

##  Outputs do Terraform

O arquivo `outputs.tf` exporta informações úteis:

```hcl
output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.main.public_ip
}
```

**Visualizar outputs:**
```bash
terraform output
terraform output ec2_public_ip
```


##  Links Úteis

- [Documentação Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Documentação Ansible](https://docs.ansible.com/)
- [Docker Hub - Nginx](https://hub.docker.com/_/nginx)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Linkedin ](https://www.linkedin.com/in/carlos-zamboni-546086266/)
---


