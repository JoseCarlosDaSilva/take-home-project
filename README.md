# USPS Label Generator

Sistema de geração e armazenamento de etiquetas de envio USPS usando a API EasyPost.

## Sobre o Projeto

Aplicação web desenvolvida para permitir que usuários gerem, visualizem e armazenem etiquetas de envio USPS. O sistema utiliza autenticação via email/senha ou OAuth Google, com verificação de email obrigatória para contas não-Google.

## Stack Tecnológico

- **Backend**: Laravel 12.x (PHP 8.2+)
- **Frontend**: Vue.js 3 + Inertia.js + TailwindCSS
- **Database**: MySQL 8.0+
- **Autenticação**: Laravel Breeze + Laravel Socialite (OAuth Google)
- **API Externa**: EasyPost (geração de etiquetas)

## Requisitos

- PHP >= 8.2
- Composer
- Node.js >= 18.x
- MySQL >= 8.0
- NPM ou Yarn

## Instalação

1. Clone o repositório:
```bash
git clone <repository-url>
cd take-home-project
```

2. Instale as dependências do PHP:
```bash
composer install
```

3. Instale as dependências do Node:
```bash
npm install --legacy-peer-deps
```

4. Configure o ambiente:
```bash
cp .env.sample .env
php artisan key:generate
```

5. Configure o arquivo `.env` com suas credenciais:
   - Conexão MySQL remota
   - Credenciais OAuth Google (veja `INSTRUCOES_GOOGLE_OAUTH.md`)
   - API Key EasyPost
   - Configurações de email

6. Execute as migrações:
```bash
php artisan migrate
```

7. Compile os assets:
```bash
npm run build
```

8. Inicie o servidor de desenvolvimento:
```bash
php artisan serve
npm run dev
```

## Progresso de Desenvolvimento

### ✅ Fase 1: Setup e Configuração Inicial (CONCLUÍDA)

- ✅ Laravel 12 instalado e configurado
- ✅ Laravel Breeze com Vue.js instalado (Inertia.js)
- ✅ Laravel Socialite instalado para OAuth Google
- ✅ Dependências npm instaladas
- ✅ Arquivo `.env.sample` criado com todas as configurações necessárias
- ✅ Documentação de configuração OAuth Google criada (`INSTRUCOES_GOOGLE_OAUTH.md`)

### ⏳ Próximas Fases

- ⏳ Fase 2: Sistema de Autenticação Completo
  - Implementar verificação de email
  - Implementar OAuth Google
  - Implementar recuperação de senha
  
- ⏳ Fase 3: Interface de Criação de Etiquetas
  - Formulários de endereços (origem e destino)
  - Formulário de atributos do pacote
  
- ⏳ Fase 4: Integração EasyPost API
  - Service class para EasyPost
  - Endpoints de criação de etiquetas
  - Modelagem de dados
  
- ⏳ Fase 5: Visualização e Histórico
  - Visualização de etiquetas
  - Histórico por usuário

## Configuração

### Credenciais Google OAuth

Consulte o arquivo `INSTRUCOES_GOOGLE_OAUTH.md` para instruções detalhadas sobre como obter as credenciais OAuth do Google.

### API EasyPost

1. Acesse https://www.easypost.com/
2. Crie uma conta (ou use as credenciais fornecidas)
3. Obtenha sua API Key (use a chave de teste durante desenvolvimento)
4. Adicione no `.env`:
   ```
   EASYPOST_API_KEY=sua_chave_aqui
   ```

## Estrutura do Projeto

```
take-home-project/
├── app/
│   ├── Http/Controllers/
│   ├── Models/
│   └── Services/
├── database/migrations/
├── resources/
│   ├── js/
│   │   ├── components/
│   │   └── Pages/
│   └── views/
├── routes/
└── tests/
```

## Licença

Este projeto é open-source e está disponível sob a licença MIT.
