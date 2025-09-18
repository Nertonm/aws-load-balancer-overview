# aws-lb-asg-overview

Este projeto demonstra a criação de uma infraestrutura web escalável, resiliente e de alta disponibilidade na AWS usando Terraform. A arquitetura é composta por um Application Load Balancer (ALB) que distribui o tráfego para um grupo de instâncias EC2 gerenciadas por um Auto Scaling Group (ASG), que por sua vez ajusta a quantidade de servidores com base na demanda de CPU.

## Componentes Principais

### 1. Application Load Balancer (ALB)

#### O que é?
O Load Balancer atua como o ponto de entrada principal para todo o tráfego de usuários. Ele recebe as requisições e as distribui de forma inteligente entre as instâncias EC2 que estão saudáveis, garantindo que nenhuma delas fique sobrecarregada.

#### O que aprendi:
* **Alta Disponibilidade:** Se uma instância EC2 falhar, o Load Balancer para de enviar tráfego para ela automaticamente, evitando que o usuário final perceba o erro.
* **Gerenciamento de Tráfego:** Ele distribui a carga de trabalho, melhorando o desempenho e o tempo de resposta do site.
* **Segurança:** Ao ser posicionado nas subnets públicas e se comunicar com as instâncias nas subnets privadas, ele protege os servidores de aplicação do acesso direto da internet.

#### Passo a Passo no Código:
1.  **Criação do Load Balancer:** O arquivo `modules/aws-lb-asg-overview/alb.tf` define o recurso `aws_lb`. Ele é configurado para ser do tipo "application" e voltado para a internet (`internal = false`), sendo associado às subnets públicas e a um Security Group específico (`lb_sg`).

2.  **Criação do Target Group:** O recurso `aws_alb_target_group` no mesmo arquivo agrupa as instâncias EC2 que receberão o tráfego.

3.  **Configuração do Health Check:** Dentro do Target Group, a seção `health_check` define como o ALB irá verificar se uma instância está saudável. Neste caso, ele faz uma requisição HTTP (`protocol = "HTTP"`) no caminho `/` (`path = "/"`), local padrão para o nginx de teste, e espera um código de resposta `200-399` para considerar a instância apta a receber tráfego.

4.  **Criação do Listener:** O `aws_lb_listener` é a "porta" do Load Balancer. Ele fica "ouvindo" na porta 80 (`port = 80`) e, quando recebe uma requisição, a encaminha (`type = "forward"`) para o Target Group criado anteriormente.

### 2. Auto Scaling Group (ASG)

#### O que é?
O Auto Scaling Group é o componente responsável pela escalabilidade da aplicação. Ele garante que tenhamos sempre o número ideal de instâncias EC2 rodando para atender à demanda atual, adicionando servidores quando o tráfego aumenta e removendo-os quando diminui para economizar custos.

#### O que aprendi:
* **Elasticidade e Economia:** O ASG ajusta a quantidade de servidores com base em regras predefinidas, evitando o desperdício de recursos em momentos de baixa demanda e garantindo a performance em picos de acesso.
* **Resiliência (Self-Healing):** O ASG monitora a saúde das instâncias. Se uma delas for marcada como "não saudável" pelo Load Balancer, o ASG a termina automaticamente e cria uma nova para substituí-la, sem intervenção manual.
* **Automação:** A criação e remoção de servidores é totalmente automatizada, baseada em um modelo pré-configurado.

#### Passo a Passo no Código:
1.  **Criação do Launch Template:** O arquivo `modules/aws-lb-asg-overview/compute.tf` define o `aws_launch_template`. Este recurso é o "molde" de como cada nova instância EC2 deve ser criada, especificando a AMI (`image_id`), o tipo de instância (`instance_type`), a IAM Role (`iam_instance_profile`) e o script de inicialização (`user_data`).

2.  **Criação do Auto Scaling Group:** O recurso `aws_autoscaling_group` utiliza o Launch Template para criar as instâncias.
    * As variáveis `min_size`, `max_size` e `desired_capacity` definem os limites mínimo, máximo e a quantidade inicial de servidores.
    * A linha `target_group_arns` associa o ASG ao Target Group do Load Balancer, garantindo que toda nova instância seja automaticamente registrada para receber tráfego.

### 3. Regras de Scaling (Scaling Up e Down)

#### O que são?
São as regras que dizem ao Auto Scaling Group **quando** ele deve adicionar (Scale Up) ou remover (Scale Down) instâncias. Elas são acionadas por alarmes que monitoram métricas de desempenho, como o uso de CPU.

#### O que aprendi:
* **Escalabilidade Proativa:** A infraestrutura reage automaticamente às mudanças na carga de trabalho. Em vez de esperar o site ficar lento, o ASG adiciona recursos quando a CPU atinge um certo limite.
* **Controle de Custos Automatizado:** Da mesma forma, ele remove recursos desnecessários quando a carga diminui, garantindo que você pague apenas pelo que realmente precisa.

#### Passo a Passo no Código:
1.  **Criação das Políticas de Scaling:** No arquivo `compute.tf`, os recursos `aws_autoscaling_policy` (`scale_up_step_policy` e `scale_down_step_policy`) definem **o que fazer**.
    * A política de `scale_up` tem um `scaling_adjustment = 1`, que significa "adicione 1 instância".
    * A política de `scale_down` tem um `scaling_adjustment = -1`, que significa "remova 1 instância".

2.  **Criação dos Alarmes do CloudWatch:** Os recursos `aws_cloudwatch_metric_alarm` definem **quando acionar** as políticas.
    * **Alarme de Alta CPU (`high_cpu_alarm`):** Este alarme monitora a métrica `CPUUtilization`. Se a média de CPU for maior ou igual (`GreaterThanOrEqualToThreshold`) a `50%` (`threshold = 50`) por um período contínuo, ele aciona a política de `scale_up`.
    * **Alarme de Baixa CPU (`low_cpu_alarm`):** Este alarme faz o oposto. Se a média de CPU for menor ou igual (`LessThanOrEqualToThreshold`) a `30%` (`threshold = 30`), ele aciona a política de `scale_down` para remover uma instância e economizar custos.i, otimizando os gastos.

### Como fazer o deploy do Projeto?
1.  Navegue para o diretório do ambiente que deseja subir:

    ```bash
    cd environments/learning
    ```

2.  Inicialize o Terraform para instalar os providers necessários.

    ```bash
    terraform init
    ```

3.  Gere um plano de execução para verificar os recursos que serão criados:

    ```bash
    terraform plan -var-file="var.tfvars"
    ```

4.  Se concordar com o plano apresentado, execute o comando seguinte para criar a infraestrutura:

    ```bash
    terraform apply -var-file="var.tfvars"
    ```

    O Terraform irá pedir uma confirmação final.

## Conclusão
Com essa configuração, tem-se uma infraestrutura AWS robusta, capaz de lidar com variações de tráfego de forma eficiente e automática. O uso combinado do Application Load Balancer e do Auto Scaling Group garante que a aplicação esteja sempre disponível, performática e econômica.

