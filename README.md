# Projeto DevOps – AWS com Terraform, Ansible, Docker, Nginx e CI/CD

Este projeto demonstra a construção de uma infraestrutura completa na AWS, utilizando **Infraestrutura como Código (IaC)**, automação de configuração, containers e **CI/CD**, seguindo práticas reais de ambientes DevOps e Cloud.

A solução provisiona automaticamente:

-  Infraestrutura de rede na AWS (VPC, Subnet, Security Group)
-  Instância EC2
-  Instalação e configuração de Docker via Ansible
-  Deploy de uma aplicação Nginx em container Docker
-  Pipeline CI/CD com GitHub Actions, build de imagem e deploy automatizado

##  Índice Visual

- [ Arquitetura AWS](#️-arquitetura-do-projeto)
- [ Pipeline CI/CD](#-pipeline-cicd-github-actions)
- [ Fluxo End-to-End](#-fluxo-completo-end-to-end)
- [ Fluxo Terraform](#️-provisionar-infraestrutura-com-terraform)
- [ Fluxo Ansible](#-nginx-container)
---

##  Tecnologias Utilizadas

### Infraestrutura e Automação
- **Terraform** – Provisionamento de infraestrutura (IaC)
- **Ansible** – Automação de configuração e deployment
- **GitHub Actions** – Pipeline CI/CD
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
- **Docker Hub** – Registry de imagens
- **Nginx** – Aplicação web de demonstração

### Sistema Operacional
- **Amazon Linux 2** (EC2)
- **Ubuntu** (GitHub Actions runner)
- **Pop!_OS / Linux** (máquina local)

### Outros
- **SSH** – Acesso remoto seguro
- **Git & GitHub** – Versionamento e CI/CD

---

##  Arquitetura do Projeto

```mermaid
graph TB
    subgraph Internet
        User[ Usuário]
        GitHub[ GitHub Actions]
    end
    
    subgraph "AWS Cloud"
        subgraph "VPC 10.0.0.0/16"
            subgraph "Public Subnet 10.0.1.0/24"
                EC2[ EC2 Instance<br/>Amazon Linux 2<br/>t3.micro]
                
                subgraph "EC2 Instance"
                    Docker[ Docker Engine]
                    Nginx[ Nginx Container<br/>Port 80]
                end
            end
            
            IGW[ Internet Gateway]
            RT[ Route Table<br/>0.0.0.0/0 → IGW]
            SG[ Security Group<br/>SSH: 22<br/>HTTP: 80]
        end
    end
    
    User -->|HTTP :80| SG
    User -->|SSH :22| SG
    SG --> EC2
    EC2 --> Docker
    Docker --> Nginx
    EC2 --> IGW
    IGW --> Internet
    RT -.->|Routes| IGW
    
    GitHub -->|Deploy via SSH| EC2
    
    style EC2 fill:#FF9900,stroke:#232F3E,stroke-width:3px,color:#fff
    style Docker fill:#2496ED,stroke:#fff,stroke-width:2px,color:#fff
    style Nginx fill:#009639,stroke:#fff,stroke-width:2px,color:#fff
    style SG fill:#DD344C,stroke:#fff,stroke-width:2px,color:#fff
    style IGW fill:#7AA116,stroke:#fff,stroke-width:2px,color:#fff
```

##  Pipeline CI/CD (GitHub Actions)

###  Fluxo Visual do Pipeline

```mermaid
graph LR
    A[ Developer] -->|git push| B[ GitHub Repository]
    B -->|Trigger| C[⚡ GitHub Actions]
    
    subgraph "Pipeline CI/CD"
        C --> D[1️⃣ Checkout Code]
        D --> E[2️⃣ Login Docker Hub]
        E --> F[3️⃣ Build Image]
        F --> G[4️⃣ Push to Registry]
        G --> H[5️⃣ SSH to EC2]
        H --> I[6️⃣ Run Ansible]
    end
    
    I --> J[ Docker Hub]
    I --> K[ AWS EC2]
    K --> L[ Deploy Success]
    
    style A fill:#28a745,stroke:#fff,stroke-width:2px,color:#fff
    style C fill:#2088FF,stroke:#fff,stroke-width:3px,color:#fff
    style J fill:#2496ED,stroke:#fff,stroke-width:2px,color:#fff
    style K fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff
    style L fill:#28a745,stroke:#fff,stroke-width:3px,color:#fff
```

### O que o pipeline faz:

1.  **Checkout** do código do repositório
2.  **Login** no Docker Hub (via Secrets)
3.  **Build** da imagem Docker
4.  **Push** da imagem para o Docker Hub
5.  **Conexão SSH** na instância EC2
6.  **Deploy automatizado** via Ansible

###  Secrets Configurados

| Secret              | Descrição                     |
|---------------------|-------------------------------|
| `DOCKERHUB_USERNAME`| Usuário do Docker Hub         |
| `DOCKERHUB_TOKEN`   | Token de acesso do Docker Hub |
| `EC2_SSH_KEY`       | Chave privada SSH da EC2      |

> ** Segurança:** Nenhuma credencial sensível está versionada no repositório. Todas as secrets são gerenciadas pelo GitHub Secrets.

###  Trigger do Pipeline

O pipeline é executado automaticamente a cada **push** na branch `main`:

```bash
git add .
git commit -m "Update application"
git push origin main
```

O GitHub Actions irá:
- Buildar a nova imagem
- Fazer push para o Docker Hub
- Conectar na EC2 via SSH
- Executar o deployment com Ansible

---

##  Estrutura de Pastas

```
.
├── terraform/
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
├── app/
│   └── Dockerfile     # Imagem Docker customizada
├── .github/
│   └── workflows/
│       └── ci-cd.yml  # Pipeline de CI/CD
└── README.md
```

##  Como Usar

### Pré-requisitos

-  AWS Account ativa
-  AWS CLI configurado
-  Terraform instalado (>= 1.0)
-  Ansible instalado (>= 2.9)
-  Git instalado
-  Conta no Docker Hub
-  Repositório GitHub configurado

### 1️⃣ Configurar AWS CLI

Configure suas credenciais AWS localmente:

```bash
aws configure
```

### 2️⃣ Provisionar Infraestrutura com Terraform

####  Fluxo de Provisionamento

```mermaid
graph TD
    Start[ Início] --> Init[terraform init<br/>Inicializa providers]
    Init --> Plan[terraform plan<br/>Valida mudanças]
    Plan --> Review{Revisar<br/>mudanças?}
    
    Review -->| OK| Apply[terraform apply<br/>Provisiona recursos]
    Review -->| Ajustar| Code[Editar .tf files]
    Code --> Plan
    
    Apply --> VPC[Cria VPC]
    VPC --> Subnet[Cria Subnet]
    Subnet --> IGW[Cria Internet Gateway]
    IGW --> RT[Configura Route Table]
    RT --> SG[Cria Security Group]
    SG --> KeyPair[Gera Key Pair]
    KeyPair --> EC2[Provisiona EC2]
    
    EC2 --> Output[ Output: IP Público]
    Output --> End[ Infraestrutura Pronta]
    
    style Start fill:#28a745,stroke:#fff,stroke-width:2px,color:#fff
    style Apply fill:#7B42BC,stroke:#fff,stroke-width:2px,color:#fff
    style End fill:#28a745,stroke:#fff,stroke-width:3px,color:#fff
    style EC2 fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#fff
```

#### Comandos:

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

### 3️⃣ Configurar Secrets no GitHub

No seu repositório GitHub, vá em **Settings → Secrets and variables → Actions** e adicione:

- `DOCKERHUB_USERNAME` – Seu usuário do Docker Hub
- `DOCKERHUB_TOKEN` – Token de acesso do Docker Hub
- `EC2_SSH_KEY` – Conteúdo da chave privada SSH (terraform-key.pem)

### 4️⃣ Deploy via CI/CD

Faça qualquer alteração e envie para o GitHub:

```bash
git add .
git commit -m "Deploy application"
git push origin main
```

O **GitHub Actions** executará automaticamente:
- Build da imagem Docker
- Push para Docker Hub
- Deploy na EC2 via Ansible

### 5️⃣ Acessar a Aplicação

```bash
# Obter o IP público (output do Terraform)
terraform output ec2_public_ip

# Acessar via SSH
ssh -i terraform-key.pem ec2-user@<IP_PUBLICO>

# Acessar via navegador
http://<IP_PUBLICO>
```

### 6️⃣ Destruir Recursos

Quando finalizar, destrua todos os recursos para evitar custos:

```bash
terraform destroy
```

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
| Porta | Protocolo | Origem    | Descrição  |
|-------|-----------|-----------|------------|
| 22    | TCP       | 0.0.0.0/0 | SSH access |
| 80    | TCP       | 0.0.0.0/0 | HTTP access|

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

####  Fluxo de Configuração Ansible

```mermaid
graph TD
    Start[ Ansible Playbook] --> Connect[SSH para EC2<br/>user: ec2-user]
    Connect --> Bootstrap[Bootstrap Python<br/>yum install python3]
    
    Bootstrap --> GatherFacts{gather_facts}
    GatherFacts --> Docker[Role: Docker]
    
    subgraph "Role Docker"
        Docker --> InstallDocker[Instala Docker]
        InstallDocker --> StartDocker[Inicia Docker service]
        StartDocker --> EnableDocker[Enable on boot]
    end
    
    EnableDocker --> Nginx[Role: Nginx]
    
    subgraph "Role Nginx"
        Nginx --> PullImage[Pull nginx:latest]
        PullImage --> StopOld[Stop container antigo]
        StopOld --> RunNew[docker run -d -p 80:80]
    end
    
    RunNew --> Verify[Verifica container<br/>docker ps]
    Verify --> Success[ Deploy Completo]
    
    style Start fill:#EE0000,stroke:#fff,stroke-width:2px,color:#fff
    style Docker fill:#2496ED,stroke:#fff,stroke-width:2px,color:#fff
    style Nginx fill:#009639,stroke:#fff,stroke-width:2px,color:#fff
    style Success fill:#28a745,stroke:#fff,stroke-width:3px,color:#fff
```

---

##  Fluxo Completo End-to-End

```mermaid
sequenceDiagram
    participant Dev as  Developer
    participant Git as  GitHub
    participant GHA as  Actions
    participant DHub as  Docker Hub
    participant AWS as  AWS EC2
    participant User as  End User
    
    Note over Dev,Git: 1. Desenvolvimento
    Dev->>Git: git push origin main
    
    Note over Git,GHA: 2. CI/CD Pipeline
    Git->>GHA: Trigger workflow
    GHA->>GHA: Checkout code
    GHA->>GHA: Build Docker image
    GHA->>DHub: Push image
    
    Note over GHA,AWS: 3. Deployment
    GHA->>AWS: SSH connection
    GHA->>AWS: Run Ansible playbook
    AWS->>AWS: Install Docker
    AWS->>DHub: Pull nginx image
    AWS->>AWS: Run container
    
    Note over AWS,User: 4. Produção
    User->>AWS: HTTP Request :80
    AWS->>User: Nginx Response
    
    Note over Dev,User:  Deploy Completo!
```

---

##  Decisões Técnicas Importantes

### 🔹 Separação de Responsabilidades

Cada ferramenta tem um propósito específico:

- **Terraform** → Cria infraestrutura (VPC, EC2, Security Groups)
- **Ansible** → Configura sistema e aplicações (instala Docker, deploy)
- **Docker** → Empacota aplicação (isolamento, portabilidade)
- **GitHub Actions** → Orquestra o fluxo de CI/CD

### 🔹 Ansible Bootstrap

Foi necessário separar o **bootstrap de Python**, pois:

**Problema:**
- Amazon Linux pode não ter Python configurado corretamente
- O Ansible depende de Python para executar seus módulos
- Erros como `ansible.legacy.setup` ocorrem quando o ambiente remoto "polui" a saída JSON

**Solução aplicada:**
```yaml
- name: Bootstrap Python
  raw: |
    if ! command -v python3 &> /dev/null; then
      sudo yum install -y python3
    fi
  changed_when: false

- name: Set Python interpreter
  set_fact:
    ansible_python_interpreter: /usr/bin/python3
```

 Instalação explícita do Python  
 Controle de `gather_facts`  
 Definição clara do `ansible_python_interpreter`

### 🔹 CI/CD com GitHub Actions

**Por que GitHub Actions?**
-  Integração nativa com GitHub
-  Runners gratuitos para projetos open source
-  Secrets management integrado
-  Sintaxe YAML simples e clara

**Fluxo:**
```
Push → GitHub → Build → Docker Hub → SSH → Ansible → Deploy
```

---

##  Troubleshooting Real (Erros Comuns)

###  Erro 1: Module result deserialization failed

**Mensagem:**
```
fatal: [ec2]: FAILED! => {"msg": "Module result deserialization failed..."}
```

**Causa:** Saída não-JSON no host remoto (Python não configurado ou poluindo stdout)

**Solução:**
```yaml
# 1. Garantir Python funcional
- name: Install Python
  raw: sudo yum install -y python3
  
# 2. Definir interpretador
- set_fact:
    ansible_python_interpreter: /usr/bin/python3
    
# 3. Evitar gather_facts antes do bootstrap
gather_facts: false
```

---

###  Erro 2: Permission denied (publickey)

**Mensagem:**
```
Permission denied (publickey,gssapi-keyex,gssapi-with-mic)
```

**Causa:** Usuário SSH incorreto

**Solução:**
```bash
#  Incorreto (Ubuntu)
ssh -i terraform-key.pem ubuntu@<IP>

#  Correto (Amazon Linux 2)
ssh -i terraform-key.pem ec2-user@<IP>

###  Erro 3: Role not found

**Mensagem:**
```
ERROR! the role 'docker' was not found
```

**Causa:** Estrutura incorreta de `roles/`

**Solução:**
```
ansible/
└── roles/
    ├── docker/
        └── tasks/
            └── main.yml  ← Arquivo obrigatório
```

---

###  Erro 4: Connection timeout

**Possíveis causas:**
1. Security Group não permite porta 22
2. Subnet não está associada ao Internet Gateway
3. Key Pair incorreta ou permissões erradas

**Solução:**
```bash
# Verificar permissões da chave
chmod 400 terraform-key.pem

# Verificar Security Group permite SSH
aws ec2 describe-security-groups --group-ids <SG_ID>

# Testar conectividade
ping <IP_PUBLICO>
```

---

###  Erro 5: Nginx não responde

**Verificações:**

1️⃣ **Container está rodando?**
```bash
ssh ec2-user@<IP> "docker ps"
```

2️⃣ **Security Group permite porta 80?**
```bash
terraform show | grep ingress
```

3️⃣ **Mapeamento de porta correto?**
```bash
docker ps --format "table {{.Ports}}"
# Deve mostrar: 0.0.0.0:80->80/tcp
```

---

###  Erro 6: GitHub Actions - SSH connection failed

**Causa:** Secret `EC2_SSH_KEY` mal configurada

**Solução:**
1. Copie TODO o conteúdo do arquivo `.pem` (incluindo `-----BEGIN` e `-----END`)
2. Cole exatamente no GitHub Secret
3. Verifique se não há espaços extras ou quebras de linha adicionais

```bash
# Visualizar o formato correto
cat terraform-key.pem
```

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

---

##  Boas Práticas Aplicadas

-  **Separação de responsabilidades** – Terraform para infraestrutura, Ansible para configuração, Docker para aplicação
-  **Infraestrutura versionada** – Todo código em Git
-  **Princípio do menor privilégio** – Security Groups restritivos
-  **Automação completa** – Zero intervenção manual via CI/CD
-  **Destruição controlada** – `terraform destroy` remove tudo limpo
-  **Validação prévia** – `terraform plan` antes de aplicar
-  **Secrets management** – Credenciais seguras via GitHub Secrets
-  **Idempotência** – Ansible garante estado desejado
-  **Containerização** – Aplicação isolada e portável
-  **Pipeline automatizado** – Deploy contínuo a cada push
-  **Documentação clara** – README detalhado com troubleshooting real

---

##  Links Úteis
- [Linkedin] (https://www.linkedin.com/in/carlos-zamboni-546086266/)

### Documentação Oficial
- [Documentação Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Documentação Ansible](https://docs.ansible.com/)
- [Docker Hub - Nginx](https://hub.docker.com/_nginx)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Free Tier](https://aws.amazon.com/free/)

### Troubleshooting
- [Ansible Common Issues](https://docs.ansible.com/ansible/latest/reference_appendices/faq.html)
- [Docker Troubleshooting Guide](https://docs.docker.com/config/daemon/troubleshoot/)
- [AWS EC2 Troubleshooting](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-troubleshoot.html)

### Tutoriais
- [Terraform Getting Started](https://developer.hashicorp.com/terraform/tutorials)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [GitHub Actions CI/CD Tutorial](https://docs.github.com/en/actions/quickstart)

---