# Sobre o Sempre Deploy

O SempreDeploy é uma ferramenta desenvolvida para instalar os sistemas da Sempre Tecnologia de maneira eficiente e automatizada. Seu propósito principal é otimizar o processo interno de deploy, reduzindo o tempo necessário para a configuração e instalação dos sistemas, minimizando erros e garantindo uma maior consistência nas instalações.

Com o SempreDeploy, a equipe técnica da Sempre Tecnologia pode automatizar tarefas repetitivas e complexas, como a configuração de servidores, a cópia de arquivos, a modificação de permissões e ajustes em arquivos de configuração, garantindo que cada instalação siga um padrão definido e seja concluída com sucesso. Isso melhora a produtividade e a qualidade do trabalho realizado, além de permitir que os desenvolvedores se concentrem em tarefas mais estratégicas e criativas.

## Tecnologias Utilizadas

Shell Script (Bash): O SempreDeploy é construído usando scripts de shell com Bash, que automatizam a execução de comandos no servidor. O uso do Bash permite a criação de scripts robustos para gerenciar a instalação e configuração dos sistemas da Sempre Tecnologia.

psql: Ferramenta de linha de comando do PostgreSQL utilizada para executar comandos SQL diretamente no banco de dados. No SempreDeploy, o psql é usado para realizar consultas, atualizações e inserções de dados, garantindo que as operações no banco de dados sejam integradas ao processo de deploy.

ssh: Protocolo utilizado para estabelecer conexões seguras e criptografadas entre o SempreDeploy e os servidores remotos. Através do SSH, o SempreDeploy executa comandos remotamente e transfere arquivos de maneira segura, essencial para a automação do processo de instalação em diferentes ambientes.

rsync: Utilizado para sincronizar e copiar arquivos entre o servidor local e o servidor remoto de maneira eficiente, preservando permissões e evitando cópias redundantes.

sed/awk: Ferramentas de manipulação de texto que são utilizadas dentro dos scripts para buscar, filtrar, e alterar arquivos de configuração de forma automatizada.

scp: Para cópia segura de arquivos entre hosts, garantindo que todos os componentes necessários sejam transferidos corretamente para o ambiente de produção.