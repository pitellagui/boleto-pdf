# Código do Boleto para PDF

Aplicativo simples desenvolvido em Flutter para transformar a linha digitável de um boleto bancário em um arquivo PDF com código de barras para Android.

## Finalidade do projeto

Criei este aplicativo principalmente para resolver um problema que minha avó estava tendo.

Ela prefere pagar alguns boletos em dinheiro e, para isso, costuma imprimir os boletos. Porém, alguns bancos não disponibilizam o PDF do boleto diretamente com o código de barras, o que acaba tornando o processo de encontrar, baixar e encaminhar o arquivo para impressão mais complicado para ela, principalmente por não ter tanta familiaridade com tecnologia.

A ideia foi criar algo extremamente simples e no fim, o projeto acabou se tornando uma ferramenta simples que também pode facilitar a vida de outras pessoas que tenham a mesma necessidade.

## Funcionalidades

- Colar a linha digitável do boleto
- Validar o código informado
- Identificar o banco
- Identificar o valor do boleto
- Identificar a data de vencimento
- Avisar quando o boleto estiver vencido
- Converter a linha digitável para o código de barras de 44 dígitos
- Gerar o código de barras no padrão ITF
- Gerar o boleto em PDF
- Visualizar o PDF dentro do aplicativo
- Salvar o PDF
- Compartilhar o PDF com outros aplicativos

## Sobre o Projeto

O projeto foi desenvolvido utilizando:

- Flutter
- Dart
- Material 3
- `barcode` para geração do código de barras
- `pdf` para criação do arquivo PDF
- `printing` para visualização, salvamento e compartilhamento do PDF
- `flutter_launcher_icons` para geração do ícone do aplicativo

### Funcionamento

O aplicativo recebe uma linha digitável de boleto bancário com 47 dígitos.

A partir dela, o aplicativo:

1. Remove espaços e caracteres de formatação
2. Valida os dígitos verificadores
3. Reconstrói o código de barras de 44 dígitos
4. Obtém o banco, o valor e a data de vencimento
5. Gera o código de barras
6. Cria o arquivo PDF

Todo esse processo é realizado localmente no aparelho.

### Como usar

Para usar o aplicativo:

1. Baixe o arquivo `.apk`
2. Instale no celular Android
3. Abra o aplicativo
4. Cole a linha digitável do boleto
5. Toque em **Gerar boleto**
6. Salve ou compartilhe o PDF

Se quiser acessar o código-fonte, basta clonar este repositório e executar o projeto com Flutter.

Obs.: O aplicativo não consulta bancos nem verifica se o boleto está pago, cancelado ou registrado. Ele apenas utiliza os dados da linha digitável para gerar o PDF com código de barras.