# Plano de Trabalho - Sistema de Etiquetas de Envio USPS

## Análise das Especificações

### Requisitos Funcionais Principais
1. **Autenticação e Autorização**
   - Login com email/senha
   - Login com OAuth Google
   - Registro de novos usuários
   - Verificação de email obrigatória (exceto OAuth Google)
   - Recuperação de senha ("Esqueci minha senha")

2. **Geração de Etiquetas de Envio**
   - Integração com EasyPost API (backend apenas)
   - Captura de endereços de origem e destino (apenas EUA)
   - Captura de atributos do pacote (peso, dimensões)
   - Geração de etiqueta USPS pronta para impressão
   - Armazenamento persistente das etiquetas

3. **Histórico e Visualização**
   - Visualização de etiquetas criadas
   - Histórico por usuário (isolamento de dados)
   - Impressão de etiquetas

### Decisões de Arquitetura

#### Stack Tecnológico
- **Backend**: Laravel 12.x (lançado em fevereiro/2025, suporta PHP 8.2-8.4)
  - ✅ **Compatibilidade PHP**: PHP 8.2.29 é totalmente compatível
  - ✅ **Laravel 11** também é compatível (requer PHP 8.2+), mas Laravel 12 é mais recente
- **PHP**: 8.2.29 (requisito de produção atendido)
- **Frontend**: Vue.js 3 + Vite (melhor integração com Laravel, mais rápido para desenvolver)
- **Database**: MySQL 8.0+
- **Autenticação**: Laravel Sanctum (API) + Laravel Breeze ou Fortify (autenticação completa)
- **OAuth**: Laravel Socialite (Google)

#### Estrutura do Projeto
- API RESTful no backend (Laravel)
- SPA (Single Page Application) com Vue.js no frontend
- Comunicação via API JSON entre frontend e backend

## Plano de Implementação (Dividido em Etapas)

### ✅ Fase 1: Setup e Configuração Inicial (COMPLETED)

#### 1.1 Instalação do Laravel
- [x] Criar projeto Laravel 12 (compatível com PHP 8.2.29)
- [x] Configurar banco de dados MySQL (.env.sample criado com todas as configurações)
- [x] Instalar dependências do backend

#### 1.2 Configuração do Frontend
- [x] Instalar Laravel Breeze com Vue.js (inclui autenticação básica)
- [x] Configurar Vite para Vue 3
- [x] Instalar bibliotecas UI (ex: TailwindCSS já vem com Breeze)

#### 1.3 Configuração de Autenticação
- [x] Instalar Laravel Socialite para OAuth Google
- [x] Configurar Laravel Breeze + Socialite
- [x] Configurar credenciais Google OAuth no .env.sample (com instruções em docs/INSTRUCOES_GOOGLE_OAUTH.md)

#### 1.4 Configuração de Email
- [x] Configurar driver de email (Mailtrap para desenvolvimento no .env.sample)
- [x] Templates de email para verificação e reset de senha (incluídos no Laravel Breeze)

**Decisão**: Usar Laravel Breeze com Vue.js porque:
- Fornece autenticação completa pronta
- Facilita integração com Socialite
- Inclui TailwindCSS para design moderno
- Suporta verificação de email nativamente

---

### ✅ Fase 2: Sistema de Autenticação Completo (COMPLETED)

#### 2.1 Autenticação Email/Senha
- [x] Implementar registro de usuário (Laravel Breeze)
- [x] Implementar login (Laravel Breeze)
- [x] Validação de formulários (frontend e backend)
- [x] Mensagens de erro/sucesso

#### 2.2 Verificação de Email
- [x] Envio de email de verificação após registro (User model implements MustVerifyEmail)
- [x] Endpoint para verificar email (incluído no Breeze)
- [x] Middleware para bloquear usuários não verificados (middleware 'verified')
- [x] **Exceção**: Usuários OAuth Google são automaticamente verificados

#### 2.3 OAuth Google
- [x] Configurar rotas OAuth (redirect e callback em routes/auth.php)
- [x] Implementar lógica de autenticação Google (SocialAuthController)
- [x] Criar/atualizar usuário ao fazer login com Google
- [x] Marcar usuários Google como verificados automaticamente
- [x] Tratar casos de email já cadastrado (account linking)

#### 2.4 Recuperação de Senha
- [x] Página "Esqueci minha senha" (incluída no Breeze)
- [x] Envio de email com token de reset (Laravel Breeze)
- [x] Página de redefinição de senha (incluída no Breeze)
- [x] Validação e atualização de senha

**Decisão**: Laravel Breeze + Socialite foi usado (mais rápido e adequado para o projeto).

---

### ✅ Fase 3: Interface de Criação de Etiquetas (COMPLETED)

#### 3.1 Formulário de Endereços
- [x] Componente Vue para endereço de origem (Create.vue)
- [x] Componente Vue para endereço de destino (Create.vue)
- [x] Validação de endereços (apenas EUA - dropdown de estados)
- [x] Validação de campos obrigatórios (frontend e backend)
- [x] Design responsivo e moderno (TailwindCSS)

#### 3.2 Formulário de Atributos do Pacote
- [x] Campos: peso (lbs), comprimento, largura, altura (inches)
- [x] Validação numérica
- [x] Design consistente com formulário de endereços

#### 3.3 Layout da Página Principal
- [x] Header com navegação (logout, histórico em AuthenticatedLayout.vue)
- [x] Dashboard após login (Dashboard.vue com quick access cards)
- [x] Formulário completo de criação de etiqueta (Create.vue)
- [x] Feedback visual (loading, sucesso, erro)

---

### ✅ Fase 4: Integração com EasyPost API (COMPLETED)

#### 4.1 Configuração EasyPost
- [x] Instalar SDK EasyPost PHP (composer require easypost/easypost-php)
- [x] Configurar API key no .env.sample
- [x] Criar service class para EasyPost (EasyPostService.php)

#### 4.2 Backend - Endpoint de Criação de Etiqueta
- [x] Controller para receber dados do frontend (ShippingLabelController)
- [x] Validação de dados (endereços EUA, atributos)
- [x] Integração com EasyPost API:
  - Criar Address (origem e destino)
  - Criar Parcel (dimensões e peso)
  - Criar Shipment
  - Comprar label (buy)
  - Obter URL da etiqueta e dados

#### 4.3 Modelagem de Dados
- [x] Migration: tabela `shipping_labels` (2025_12_15_184621_create_shipping_labels_table.php)
  - id, user_id, from_address (JSON), to_address (JSON)
  - parcel_info (JSON), easypost_shipment_id
  - label_url, tracking_number, carrier, service, rate, created_at, updated_at
- [x] Model: ShippingLabel com relacionamento User
- [x] Isolamento por usuário via middleware 'auth' e query scopes

#### 4.4 Armazenamento e Resposta
- [x] Salvar etiqueta no banco de dados
- [x] Retornar dados da etiqueta para frontend (incluindo URL da imagem via Inertia.js)

---

### ✅ Fase 5: Visualização e Histórico (COMPLETED)

#### 5.1 Visualização da Etiqueta
- [x] Componente Vue para exibir etiqueta (Show.vue com imagem)
- [x] Botão de impressão (window.print())
- [x] Layout responsivo da visualização

#### 5.2 Histórico de Etiquetas
- [x] Endpoint: listar etiquetas do usuário autenticado (ShippingLabelController@index)
- [x] Página Vue com lista de etiquetas (Index.vue)
- [x] Paginação implementada (Laravel pagination)
- [x] Design de cards/listagem moderna (TailwindCSS)

---

### Fase 6: Refinamento e Design (30-45 min)

#### 6.1 Design System
- [ ] Padronizar cores e espaçamentos
- [ ] Melhorar tipografia
- [ ] Adicionar animações sutis
- [ ] Responsividade completa (mobile, tablet, desktop)

#### 6.2 UX Improvements
- [ ] Loading states
- [ ] Mensagens de erro amigáveis
- [ ] Confirmações de ações importantes
- [ ] Feedback visual consistente

#### 6.3 Testes Básicos
- [ ] Testar fluxo completo: registro → login → criar etiqueta → visualizar
- [ ] Testar OAuth Google
- [ ] Testar recuperação de senha
- [ ] Testar verificação de email

---

### Fase 7: Documentação (15-20 min)

#### 7.1 README
- [ ] Instruções de instalação
- [ ] Configuração do banco de dados
- [ ] Variáveis de ambiente necessárias
- [ ] Como executar o projeto
- [ ] Assumptions e decisões de design
- [ ] Próximos passos e melhorias

---

## Assumptions e Decisões de Design

### Assumptions de Negócio
1. **Endereços apenas EUA**: Validação será feita no frontend e backend, mas não integração com APIs de validação de endereço (economiza tempo)
2. **Etiquetas de Teste**: Usar API key de teste do EasyPost para não gerar custos
3. **Formato de Etiqueta**: USPS será o carrier padrão, mas EasyPost pode sugerir outros - vamos aceitar o recomendado
4. **Armazenamento de Imagens**: Armazenar apenas URL da etiqueta fornecida pelo EasyPost (não fazer download)

### Decisões Técnicas
1. **Laravel 12**: Versão mais recente (fev/2025), totalmente compatível com PHP 8.2.29 do servidor de produção
2. **Vue.js sobre React**: Melhor integração com Laravel Breeze, setup mais rápido
3. **Laravel Breeze**: Fornece toda estrutura de autenticação, economiza tempo
4. **JSON para endereços**: Armazenar endereços como JSON na tabela para flexibilidade
5. **Single Page Application**: Melhor UX, mais moderno
6. **TailwindCSS**: Já incluído no Breeze, design rápido e moderno

### Melhorias Futuras (não no escopo de 5h)
1. Download de etiquetas em PDF
2. Validação de endereços via API (USPS Address Validation)
3. Múltiplos carriers (FedEx, UPS)
4. Exportação de histórico (CSV)
5. Notificações de tracking
6. Múltiplos pacotes por envio
7. Taxa estimada antes de comprar
8. Salvar endereços favoritos
9. Testes automatizados (PHPUnit, Jest)

---

## Timeline Estimada

| Fase | Tempo Estimado | Acumulado |
|------|---------------|-----------|
| Fase 1: Setup | 30-40 min | 40 min |
| Fase 2: Autenticação | 60-75 min | 115-155 min |
| Fase 3: Interface | 60-75 min | 175-230 min |
| Fase 4: EasyPost | 45-60 min | 220-290 min |
| Fase 5: Histórico | 45-60 min | 265-350 min |
| Fase 6: Refinamento | 30-45 min | 295-395 min |
| Fase 7: Documentação | 15-20 min | 310-415 min |

**Total**: ~5-7 horas (com margem de segurança)

### Estratégia de Otimização
- Se o tempo estiver apertado, priorizar funcionalidades core:
  1. Autenticação básica (email/senha) + OAuth Google
  2. Criação de etiqueta (funcionalidade principal)
  3. Visualização básica (sem histórico detalhado inicialmente)
  4. Design mínimo mas funcional

---

## Checklist de Variáveis de Ambiente

```
APP_NAME="USPS Label Generator"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=shipping_labels
DB_USERNAME=root
DB_PASSWORD=

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="noreply@example.com"

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=

EASYPOST_API_KEY=
```

---

## Estrutura de Diretórios Esperada

```
take-home-project/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Auth/
│   │   │   ├── ShippingLabelController.php
│   │   │   └── SocialAuthController.php
│   │   └── Middleware/
│   ├── Models/
│   │   ├── User.php
│   │   └── ShippingLabel.php
│   └── Services/
│       └── EasyPostService.php
├── database/
│   └── migrations/
├── resources/
│   ├── js/
│   │   ├── components/
│   │   │   ├── AddressForm.vue
│   │   │   ├── ParcelForm.vue
│   │   │   ├── LabelViewer.vue
│   │   │   └── LabelHistory.vue
│   │   └── Pages/
│   └── views/
├── routes/
│   └── api.php
└── tests/
```

---

## Próximos Passos Imediatos

1. ✅ Análise e planejamento (CONCLUÍDO)
2. ✅ Criação do arquivo .env.sample (CONCLUÍDO)
3. ⏭️ Instalação e configuração inicial
4. ⏭️ Desenvolvimento incremental seguindo as fases

---

## Decisões Confirmadas e Registradas

### ✅ Compatibilidade PHP e Laravel
- **PHP de Produção**: 8.2.29
- **Framework**: Laravel 12.x (lançado fev/2025)
- **Status**: ✅ Totalmente compatível - Laravel 12 suporta PHP 8.2 a 8.4

### ✅ Configuração de Ambiente
- **Banco de Dados**: MySQL remoto (configuração no .env)
- **Arquivo de Referência**: `.env.sample` criado com todos os parâmetros necessários
- **Segurança**: `.env` está no `.gitignore` (nunca será commitado)

### ✅ Variáveis de Ambiente Documentadas
- Conexão MySQL remota
- API EasyPost (teste e produção)
- OAuth Google (Client ID, Secret, Redirect URI)
- Configurações de email (SMTP)
- Todas as configurações padrão do Laravel 12

---

**Status**: Pronto para iniciar desenvolvimento após aprovação do plano.
