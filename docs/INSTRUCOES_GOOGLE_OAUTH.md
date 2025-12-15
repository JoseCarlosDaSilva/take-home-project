# Instruções para Obter Credenciais OAuth do Google

## Passo a Passo Completo

### 1. Acessar o Google Cloud Console

1. Acesse: https://console.cloud.google.com/
2. Faça login com sua conta Google
3. Se você não tiver um projeto, será necessário criar um primeiro

### 2. Criar um Novo Projeto (se necessário)

1. No topo da página, clique no seletor de projetos (ao lado do logo do Google Cloud)
2. Clique em **"Novo Projeto"**
3. Preencha:
   - **Nome do projeto**: `usps-label-generator` (ou qualquer nome de sua escolha)
   - **Organização**: (opcional)
4. Clique em **"Criar"**
5. Aguarde alguns segundos e selecione o projeto recém-criado

### 3. Habilitar a API do Google+

1. No menu lateral esquerdo, vá em **"APIs e Serviços"** > **"Biblioteca"**
2. Na barra de pesquisa, digite: `Google+ API` ou `Google Identity`
3. Procure por: **"Google+ API"** ou **"Google Identity Services API"**
4. Clique na API e depois em **"ATIVAR"**

**Alternativa (mais moderna)**: O Google recomenda usar a API mais recente:
- Procure por: **"Identity Toolkit API"** ou **"Google Identity Services"**
- Ative essa API também

### 4. Configurar Tela de Consentimento OAuth

1. No menu lateral, vá em **"APIs e Serviços"** > **"Tela de consentimento OAuth"**
2. Selecione o tipo de usuário:
   - **Externo** (para usuários finais)
   - **Interno** (apenas para contas do Google Workspace)
3. Preencha as informações obrigatórias:
   - **Nome do aplicativo**: `USPS Label Generator`
   - **Email de suporte do usuário**: seu email
   - **Email de contato do desenvolvedor**: seu email
4. Clique em **"Salvar e Continuar"**
5. Na tela de **"Escopos"**, clique em **"Salvar e Continuar"** (sem adicionar escopos extras)
6. Na tela de **"Usuários de teste"**, adicione seu email para testes (opcional)
7. Clique em **"Salvar e Continuar"**
8. Revise e conclua

### 5. Criar Credenciais OAuth 2.0

1. No menu lateral, vá em **"APIs e Serviços"** > **"Credenciais"**
2. Clique em **"+ CRIAR CREDENCIAIS"** no topo
3. Selecione **"ID do cliente OAuth"**

### 6. Configurar o ID do Cliente OAuth

1. **Tipo de aplicativo**: Selecione **"Aplicativo da Web"**
2. **Nome**: `USPS Label Generator Web Client`
3. **URIs de redirecionamento autorizados**:
   
   Para desenvolvimento local:
   ```
   http://localhost:8000/auth/google/callback
   http://127.0.0.1:8000/auth/google/callback
   ```
   
   Para produção (quando disponível):
   ```
   https://seudominio.com/auth/google/callback
   ```
   
   **Importante**: Adicione todas as URLs que você vai usar. Você pode adicionar múltiplas URLs clicando em **"+ ADICIONAR URI"**
   
4. Clique em **"CRIAR"**

### 7. Copiar as Credenciais

Após criar, uma janela pop-up aparecerá com:
- **ID do cliente**: `123456789-abc123def456.apps.googleusercontent.com`
- **Secret do cliente**: `GOCSPX-abc123def456xyz`

**⚠️ IMPORTANTE**: Copie essas informações imediatamente! O Secret só é mostrado uma vez.

### 8. Adicionar ao arquivo .env

Abra o arquivo `.env` e adicione as credenciais:

```env
GOOGLE_CLIENT_ID=123456789-abc123def456.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-abc123def456xyz
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback
```

### 9. Verificar Configurações (Opcional)

Se precisar recuperar as credenciais depois:
1. Vá em **"APIs e Serviços"** > **"Credenciais"**
2. Clique no ID do cliente que você criou
3. Você poderá ver o **Client ID** novamente
4. Para ver/regenerar o **Client Secret**, clique em **"Regenerar chave secreta"** (mas isso invalidará a chave anterior)

---

## Resumo Rápido

1. ✅ Acesse: https://console.cloud.google.com/
2. ✅ Crie/selecione um projeto
3. ✅ Ative a API: "Google+ API" ou "Identity Toolkit API"
4. ✅ Configure a Tela de Consentimento OAuth
5. ✅ Crie Credenciais OAuth 2.0 (Tipo: Aplicativo da Web)
6. ✅ Adicione URIs de redirecionamento:
   - `http://localhost:8000/auth/google/callback`
   - `https://seudominio.com/auth/google/callback` (produção)
7. ✅ Copie Client ID e Client Secret
8. ✅ Adicione ao arquivo `.env`

---

## Dicas Importantes

- 🔒 **Segurança**: Nunca commite o Client Secret no repositório
- 🔄 **Desenvolvimento vs Produção**: Crie credenciais separadas para dev e produção, ou use URLs diferentes no mesmo cliente
- ⏱️ **Limites**: Durante desenvolvimento, você pode ter limites de usuários na tela de consentimento (modo de teste)
- 🌐 **Domínios**: Para produção, certifique-se de que o domínio está verificado no Google Cloud Console

---

## Troubleshooting

**Erro: "redirect_uri_mismatch"**
- Verifique se a URL de callback no `.env` corresponde exatamente à URL configurada no Google Cloud Console
- URLs são case-sensitive e devem incluir a porta (se usar localhost)

**Erro: "access_denied"**
- Verifique se o usuário foi adicionado como "Usuário de teste" na tela de consentimento (modo de teste)

**Não consigo ver o Client Secret**
- O secret só é mostrado uma vez. Se você perdeu, precisa regenerar no console.

---

**Precisa de ajuda?** Consulte a documentação oficial: https://developers.google.com/identity/protocols/oauth2/web-server
