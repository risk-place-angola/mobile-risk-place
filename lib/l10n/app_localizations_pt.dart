// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Risk Place';

  @override
  String get login => 'Entrar';

  @override
  String get register => 'Cadastrar';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Telefone';

  @override
  String get password => 'Senha';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get name => 'Nome';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get dontHaveAccount => 'Não tem uma conta? ';

  @override
  String get signUp => 'Cadastre-se';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get signIn => 'Entre';

  @override
  String get or => 'ou';

  @override
  String get emailOrPhone => 'Email ou Telefone';

  @override
  String get enterEmailOrPhone => 'Digite seu email ou telefone';

  @override
  String get enterEmail => 'Digite seu email';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String get enterName => 'Digite seu nome';

  @override
  String get enterPhone => 'Digite seu telefone';

  @override
  String get invalidEmail => 'Email inválido';

  @override
  String get passwordTooShort => 'Senha deve ter no mínimo 6 caracteres';

  @override
  String get passwordsDontMatch => 'Senhas não conferem';

  @override
  String get fieldRequired => 'Este campo é obrigatório';

  @override
  String get verificationCode => 'Código de Verificação';

  @override
  String verificationCodeSent(String email) {
    return 'Enviamos um código para\n$email';
  }

  @override
  String get verificationCodeMessage =>
      'Verifique seu telefone ou email pelo código de verificação';

  @override
  String get enterCode => '000000';

  @override
  String get confirm => 'Confirmar';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get accountConfirmed => 'Conta confirmada com sucesso!';

  @override
  String get errorConfirmingCode => 'Erro ao confirmar código';

  @override
  String get codeResentSuccess => 'Código reenviado com sucesso!';

  @override
  String get codeSentToEmail => 'Código enviado para o email';

  @override
  String get smsFailed => 'Falha no SMS. Verifique seu email';

  @override
  String codeSentTo(String contact) {
    return 'Código enviado para $contact';
  }

  @override
  String get errorResendingCode => 'Erro ao reenviar código';

  @override
  String get verificationCodeExpired =>
      'Código de verificação expirado. Solicite um novo.';

  @override
  String get invalidVerificationCode =>
      'Código de verificação inválido. Verifique e tente novamente.';

  @override
  String get failedToConfirmRegistration => 'Falha ao confirmar cadastro';

  @override
  String get verificationCodeTitle => 'Verificação de Código';

  @override
  String verificationAttemptsLeft(int attempts) {
    return '$attempts tentativas restantes';
  }

  @override
  String verificationAccountLocked(int minutes) {
    return 'Muitas tentativas. Aguarde $minutes minutos';
  }

  @override
  String verificationResendIn(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String verificationCodeExpiresIn(int minutes, String seconds) {
    return 'Código expira em $minutes:$seconds';
  }

  @override
  String verificationWaitBeforeResend(int seconds) {
    return 'Aguarde $seconds segundos antes de reenviar';
  }

  @override
  String get verificationTooManyAttempts =>
      'Muitas tentativas incorretas. Aguarde 15 minutos';

  @override
  String verificationCodeSentTo(String contact) {
    return 'Código enviado para $contact';
  }

  @override
  String get clear => 'Limpar';

  @override
  String get errorInvalidCredentials =>
      'Email ou senha inválidos. Verifique e tente novamente.';

  @override
  String get errorAccountNotVerified =>
      'Sua conta não está verificada. Verifique seu telefone ou email pelo código de verificação.';

  @override
  String get errorSessionExpired =>
      'Sua sessão expirou. Por favor, faça login novamente.';

  @override
  String get errorNoPermission =>
      'Você não tem permissão para realizar esta ação.';

  @override
  String get errorNotFound =>
      'As informações solicitadas não foram encontradas.';

  @override
  String get errorNoInternet =>
      'Sem conexão com a internet. Verifique sua conexão e tente novamente.';

  @override
  String get errorTimeout =>
      'A operação está demorando muito. Verifique sua conexão e tente novamente.';

  @override
  String get errorServerUnavailable =>
      'Nossos servidores estão temporariamente indisponíveis. Tente novamente em alguns instantes.';

  @override
  String get errorInvalidData =>
      'Os dados enviados são inválidos. Verifique e tente novamente.';

  @override
  String get errorUnexpected =>
      'Ocorreu um erro inesperado. Por favor, tente novamente.';

  @override
  String get errorGeneric =>
      'Algo deu errado. Por favor, tente novamente mais tarde.';

  @override
  String get forgotPasswordTitle => 'Esqueceu sua senha?';

  @override
  String get forgotPasswordSubtitle =>
      'Digite seu email ou telefone para receber\no código de recuperação';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get invalidIdentifier => 'Digite um email ou telefone válido';

  @override
  String get identifierRequired => 'Email ou telefone é obrigatório';

  @override
  String get codeSentSuccess => 'Código enviado para seu email!';

  @override
  String get errorSendingCode => 'Erro ao enviar código';

  @override
  String get newPassword => 'Nova Senha';

  @override
  String get newPasswordSubtitle =>
      'Digite o código recebido e\nsua nova senha';

  @override
  String get verificationCodeLabel => 'Código de verificação';

  @override
  String get newPasswordLabel => 'Nova senha';

  @override
  String get confirmPasswordLabel => 'Confirmar senha';

  @override
  String get resetPassword => 'Redefinir senha';

  @override
  String get passwordChangedSuccess => 'Senha alterada com sucesso!';

  @override
  String get errorResettingPassword => 'Erro ao redefinir senha';

  @override
  String get enterVerificationCode => 'Digite o código';

  @override
  String get codeMustBe6Digits => 'Código deve ter 6 dígitos';

  @override
  String get enterNewPassword => 'Digite a nova senha';

  @override
  String get profile => 'Perfil';

  @override
  String get logout => 'Sair';

  @override
  String get edit => 'Editar';

  @override
  String get personalInfo => 'Informações Pessoais';

  @override
  String get contactInfo => 'Informações de Contato';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get success => 'Sucesso';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get myLocation => 'Minha Localização';

  @override
  String get search => 'Buscar';

  @override
  String get home => 'Casa';

  @override
  String get work => 'Trabalho';

  @override
  String get safeRoute => 'Rota Segura';

  @override
  String get shareLocation => 'Compartilhar Localização';

  @override
  String get emergencyContacts => 'Contatos de Emergência';

  @override
  String get myAlerts => 'Meus Alertas';

  @override
  String get reportRisk => 'Reportar Risco';

  @override
  String get riskTypes => 'Tipos de Risco';

  @override
  String get crime => 'Crime';

  @override
  String get accident => 'Acidente';

  @override
  String get naturalDisaster => 'Desastre Natural';

  @override
  String get fire => 'Incêndio';

  @override
  String get health => 'Saúde';

  @override
  String get infrastructure => 'Infraestrutura';

  @override
  String get environment => 'Meio Ambiente';

  @override
  String get violence => 'Violência';

  @override
  String get publicSafety => 'Segurança Pública';

  @override
  String get traffic => 'Trânsito';

  @override
  String get urbanIssue => 'Problema Urbano';

  @override
  String get riskTopicRobber => 'Roubo';

  @override
  String get riskTopicAssault => 'Assalto';

  @override
  String get riskTopicTheft => 'Furtos';

  @override
  String get riskTopicVandalism => 'Vandalismo';

  @override
  String get riskTopicTrafficAccident => 'Acidente de Trânsito';

  @override
  String get riskTopicWorkAccident => 'Acidente de Trabalho';

  @override
  String get riskTopicFall => 'Queda';

  @override
  String get riskTopicFlood => 'Enchente';

  @override
  String get riskTopicLandslide => 'Deslizamento';

  @override
  String get riskTopicStorm => 'Tempestade';

  @override
  String get riskTopicForestFire => 'Incêndio Florestal';

  @override
  String get riskTopicInfectiousDisease => 'Doença Infecciosa';

  @override
  String get riskTopicMedicalEmergency => 'Emergência Médica';

  @override
  String get riskTopicBridgeCollapse => 'Queda de Ponte';

  @override
  String get riskTopicPowerOutage => 'Queda de Energia';

  @override
  String get riskTopicPollution => 'Poluição';

  @override
  String get riskTopicChemicalLeak => 'Vazamento Químico';

  @override
  String get assalto_mao_armada => 'Assalto à Mão Armada';

  @override
  String get roubo_residencia => 'Roubo em Residência';

  @override
  String get roubo_veiculo => 'Roubo de Veículo';

  @override
  String get furto_carteira => 'Furto de Carteira';

  @override
  String get furto_telemovel => 'Furto de Telemóvel';

  @override
  String get vandalismo => 'Vandalismo';

  @override
  String get sequestro => 'Sequestro';

  @override
  String get violencia_domestica => 'Violência Doméstica';

  @override
  String get agressao_fisica => 'Agressão Física';

  @override
  String get tiroteio => 'Tiroteio';

  @override
  String get acidente_viacao => 'Acidente de Viação';

  @override
  String get colisao_transito => 'Colisão';

  @override
  String get atropelamento => 'Atropelamento';

  @override
  String get capotamento => 'Capotamento';

  @override
  String get inundacao => 'Inundação';

  @override
  String get deslizamento_terra => 'Deslizamento de Terra';

  @override
  String get tempestade => 'Tempestade';

  @override
  String get raio => 'Queda de Raio';

  @override
  String get incendio_residencial => 'Incêndio Residencial';

  @override
  String get incendio_comercial => 'Incêndio Comercial';

  @override
  String get incendio_mercado => 'Incêndio em Mercado';

  @override
  String get incendio_veiculo => 'Veículo em Chamas';

  @override
  String get emergencia_medica => 'Emergência Médica';

  @override
  String get impactArea => 'Área de impacto aproximada';

  @override
  String get coordinates => 'Coordenadas';

  @override
  String get detailedViewComingSoon => 'Visualização detalhada em breve';

  @override
  String get verifications => 'Verificações';

  @override
  String get rejections => 'Rejeições';

  @override
  String get netScore => 'Pontuação Líquida';

  @override
  String get reportDetails => 'Detalhes do Report';

  @override
  String get riskType => 'Tipo de Risco';

  @override
  String get riskTopic => 'Tópico';

  @override
  String get location => 'Localização';

  @override
  String get address => 'Endereço';

  @override
  String get province => 'Província';

  @override
  String get reportedAt => 'Reportado em';

  @override
  String get relationFamily => 'Família';

  @override
  String get relationFriend => 'Amigo';

  @override
  String get relationColleague => 'Colega';

  @override
  String get relationNeighbor => 'Vizinho';

  @override
  String get relationOther => 'Outro';

  @override
  String get priority => 'Prioridade';

  @override
  String get call => 'Ligar';

  @override
  String get sendSMS => 'Enviar SMS';

  @override
  String get errorLoadingSettings => 'Erro ao Carregar Configurações';

  @override
  String get noSettingsAvailable => 'Nenhuma configuração disponível';

  @override
  String get lastUpdate => 'Última Atualização';

  @override
  String get expiresAt => 'Expira Em';

  @override
  String get surto_doenca => 'Surto de Doença';

  @override
  String get acidente_trabalho => 'Acidente de Trabalho';

  @override
  String get queda_energia => 'Falta de Energia';

  @override
  String get queda_agua => 'Falta de Água';

  @override
  String get buraco_via => 'Buraco na Via';

  @override
  String get semaforo_avariado => 'Semáforo Avariado';

  @override
  String get cabo_solto => 'Cabo Elétrico Solto';

  @override
  String get estrutura_risco => 'Estrutura em Risco';

  @override
  String get lixo_acumulado => 'Lixo Acumulado';

  @override
  String get esgoto_aberto => 'Esgoto Aberto';

  @override
  String get poluicao_ar => 'Poluição do Ar';

  @override
  String get vazamento_agua => 'Vazamento de Água';

  @override
  String get rua_escura => 'Rua Escura';

  @override
  String get zona_assalto => 'Zona de Assalto';

  @override
  String get vigilancia_necessaria => 'Vigilância Necessária';

  @override
  String get operacao_policial => 'Operação Policial';

  @override
  String get congestionamento => 'Congestionamento';

  @override
  String get via_bloqueada => 'Via Bloqueada';

  @override
  String get manifestacao => 'Manifestação';

  @override
  String get animal_solto => 'Animal Solto';

  @override
  String get obra_sinalizacao => 'Obra Sem Sinalização';

  @override
  String get assalto => 'Assalto';

  @override
  String get furtos => 'Furtos';

  @override
  String get roubo => 'Roubo';

  @override
  String get queda => 'Queda';

  @override
  String get enchente => 'Enchente';

  @override
  String get deslizamento => 'Deslizamento';

  @override
  String get incendio_florestal => 'Incêndio Florestal';

  @override
  String get doenca_infecciosa => 'Doença Infecciosa';

  @override
  String get queda_ponte => 'Queda de Ponte';

  @override
  String get poluicao => 'Poluição';

  @override
  String get vazamento_quimico => 'Vazamento Químico';

  @override
  String get acidente_transito => 'Acidente de Trânsito';

  @override
  String get searchRadius => 'Raio de Busca';

  @override
  String get searchLocation => 'Buscar Localização';

  @override
  String get recent => 'Recentes';

  @override
  String get moreOptions => 'Mais Opções';

  @override
  String get savedPlaces => 'Lugares Salvos';

  @override
  String get savedPlacesSubtitle => 'Acesso rápido às suas localizações';

  @override
  String get shareMyLocation => 'Compartilhar Minha Localização';

  @override
  String get shareMyLocationSubtitle =>
      'Enviar localização para família e amigos';

  @override
  String get checkSafeRoute => 'Verificar Rota Segura';

  @override
  String get checkSafeRouteSubtitle => 'Encontre o caminho mais seguro';

  @override
  String get emergencyContactsSubtitle =>
      'Discar manualmente números locais de emergência';

  @override
  String get editAlert => 'Editar Alerta';

  @override
  String get updateAlertMessage =>
      'Atualize a mensagem, gravidade ou raio do alerta.';

  @override
  String get message => 'Mensagem';

  @override
  String get describeTheAlert => 'Descreva o alerta';

  @override
  String get messageRequired => 'Mensagem é obrigatória';

  @override
  String get severity => 'Gravidade';

  @override
  String get radius => 'Raio';

  @override
  String get radiusMeters => 'Raio (metros)';

  @override
  String get radiusRequired => 'Raio é obrigatório';

  @override
  String get invalidValue => 'Valor inválido';

  @override
  String get radiusMustBeBetween => 'Raio deve estar entre 100 e 10.000m';

  @override
  String get changesWillBeApplied =>
      'As alterações serão aplicadas imediatamente e os inscritos serão notificados.';

  @override
  String get addContact => 'Adicionar Contato';

  @override
  String get editContact => 'Editar Contato';

  @override
  String get configureEmergencyContact =>
      'Configure um contato de emergência para ser notificado em situações críticas.';

  @override
  String get nameRequired => 'Nome é obrigatório';

  @override
  String get exampleName => 'Ex: Maria Silva';

  @override
  String get phoneRequired => 'Telefone é obrigatório';

  @override
  String get examplePhone => 'Ex: +244 923 456 789';

  @override
  String get relation => 'Relação';

  @override
  String get priorityContact => 'Contato prioritário';

  @override
  String get willReceiveEmergencyAlerts =>
      'Receberá alertas de emergência automáticos';

  @override
  String get add => 'Adicionar';

  @override
  String get reportAtMyLocation => 'Reportar na minha localização';

  @override
  String get useCurrentGpsLocation => 'Usar localização atual do GPS';

  @override
  String get chooseLocationOnMap => 'Escolher localização no mapa';

  @override
  String get adjustManuallyOnMap => 'Ajustar manualmente no mapa';

  @override
  String get report => 'Reportar';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get createdByMe => 'Criados por Mim';

  @override
  String get subscribed => 'Inscritos';

  @override
  String get confirmDeletion => 'Confirmar Exclusão';

  @override
  String get confirmCancellation => 'Confirmar Cancelamento';

  @override
  String get areYouSureDelete => 'Tem certeza que deseja excluir este alerta?';

  @override
  String get areYouSureCancelSubscription =>
      'Tem certeza que deseja cancelar a inscrição neste alerta?';

  @override
  String get unsubscribe => 'Cancelar Inscrição';

  @override
  String get alertRadius => 'Raio de Alerta';

  @override
  String get reportRadius => 'Raio de Relatório';

  @override
  String get allReports => 'Todos os Relatórios';

  @override
  String get errorLoadingReports => 'Erro ao carregar relatórios';

  @override
  String get selectDestination => 'Selecionar Destino';

  @override
  String get selectOnMap => 'Selecionar no Mapa';

  @override
  String get confirmDestination => 'Confirmar Destino';

  @override
  String get removeContact => 'Remover Contato';

  @override
  String get remove => 'Remover';

  @override
  String get safetySettings => 'Configurações de Segurança';

  @override
  String get notificationsEnabled => 'Notificações Ativadas';

  @override
  String get receiveAllNotifications => 'Receber todas as notificações';

  @override
  String get alertTypes => 'Tipos de Alerta';

  @override
  String get reportTypes => 'Tipos de Relatório';

  @override
  String get locationSharing => 'Compartilhamento de Localização';

  @override
  String get shareLocationEmergencies =>
      'Compartilhar localização em emergências';

  @override
  String get locationHistory => 'Histórico de Localizações';

  @override
  String get saveLocationHistory => 'Salvar histórico de onde você esteve';

  @override
  String get profileVisibility => 'Visibilidade do Perfil';

  @override
  String get anonymousReports => 'Relatórios Anônimos';

  @override
  String get dontShowNameReports => 'Não mostrar seu nome nos relatórios';

  @override
  String get showOnlineStatus => 'Mostrar Status Online';

  @override
  String get othersCanSeeOnline =>
      'Outros usuários podem ver se você está online';

  @override
  String get automaticAlerts => 'Alertas Automáticos';

  @override
  String get enableSmartAutomaticAlerts =>
      'Ativar alertas automáticos inteligentes';

  @override
  String get dangerZones => 'Zonas de Perigo';

  @override
  String get alertWhenEnteringRiskAreas =>
      'Alertar ao entrar em áreas de risco';

  @override
  String get timeBasedAlerts => 'Alertas por Horário';

  @override
  String get specialAlertsRiskTimes => 'Alertas especiais em horários de risco';

  @override
  String get startTime => 'Horário de Início';

  @override
  String get endTime => 'Horário de Término';

  @override
  String get automaticNightMode => 'Modo Noturno Automático';

  @override
  String get enableAutomaticallyAtNight => 'Ativar automaticamente à noite';

  @override
  String get nightModeStart => 'Início do Modo Noturno';

  @override
  String get nightModeEnd => 'Término do Modo Noturno';

  @override
  String get close => 'Fechar';

  @override
  String get moreDetails => 'Mais Detalhes';

  @override
  String get viewDetails => 'Ver Detalhes';

  @override
  String get editLocation => 'Editar Localização';

  @override
  String get deletePlace => 'Excluir Local';

  @override
  String get sharingLocation => 'Compartilhando Localização';

  @override
  String get stopSharing => 'Parar Compartilhamento';

  @override
  String get stopSharingConfirm => 'Parar';

  @override
  String get share => 'Compartilhar';

  @override
  String get copyLink => 'Copiar Link';

  @override
  String get placeName => 'Nome do Local';

  @override
  String get category => 'Categoria';

  @override
  String get describeAlert => 'Descreva o alerta';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get enterFullName => 'Digite seu nome completo';

  @override
  String get markAsPriority => 'Marcar como prioritário';

  @override
  String get receiveAutomaticEmergencyAlerts =>
      'Receberá alertas de emergência automáticos';

  @override
  String get rangeOfReach => 'Raio de Alcance';

  @override
  String get emergencyAlert => '🚨 ALERTA DE EMERGÊNCIA';

  @override
  String get reachRadius => 'Raio de Alcance';

  @override
  String get timeLabel => 'Horário';

  @override
  String get now => 'Agora';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min atrás';
  }

  @override
  String hoursAgo(Object hours) {
    return '${hours}h atrás';
  }

  @override
  String get communityReport => '📍 REPORT DA COMUNIDADE';

  @override
  String get verified => 'Verificado';

  @override
  String get resolved => 'Resolvido';

  @override
  String get reported => 'Reportado';

  @override
  String get status => 'Status';

  @override
  String get pending => 'Pendente';

  @override
  String get tracking => 'Rastreamento';

  @override
  String get privacy => 'Privacidade';

  @override
  String get automaticAlertsSettings => 'Alertas Automáticos';

  @override
  String get nightMode => 'Modo Noturno';

  @override
  String get notifications => 'Notificações';

  @override
  String get noneSelected => 'Nenhum selecionado';

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get fillDataBelow => 'Preencha os dados abaixo';

  @override
  String get fullNameLabel => 'Nome Completo';

  @override
  String get enterFullNamePlaceholder => 'Digite seu nome completo';

  @override
  String get enterEmailPlaceholder => 'Digite seu email';

  @override
  String get enterPhonePlaceholder => 'Digite seu telefone';

  @override
  String get enterPasswordPlaceholder => 'Digite sua senha';

  @override
  String get iAmRFCE => 'Sou RFCE';

  @override
  String get registerButton => 'Registrar-se';

  @override
  String get alreadyHaveAccountQuestion => 'Já tem uma conta? ';

  @override
  String sentCodeTo(Object email) {
    return 'Enviamos um código para\n$email';
  }

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get whatDoYouSee => 'O que você vê?';

  @override
  String get selectSpecificType => 'Selecione o tipo específico';

  @override
  String helloUser(Object name) {
    return 'Olá, $name!';
  }

  @override
  String get welcome => 'Bem-vindo!';

  @override
  String get loginOrRegister => 'Entrar / Registrar';

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get viewAlertsPostedOrSubscribed =>
      'Ver alertas que você publicou ou inscreveu';

  @override
  String get viewAllSystemReports => 'Ver todos os relatórios do sistema';

  @override
  String get emergencyContactsTitle => 'Contatos de Emergência';

  @override
  String get manageTrustedContacts => 'Gerenciar contatos confiáveis';

  @override
  String get safetySettingsTitle => 'Configurações de Segurança';

  @override
  String get notificationsTrackingPrivacy =>
      'Notificações, rastreamento, privacidade';

  @override
  String get communityFeedback => 'Comunidade & Feedback';

  @override
  String get sendFeedbackReadUpdates => 'Enviar feedback ou ler atualizações';

  @override
  String get myProfile => 'Meu Perfil';

  @override
  String get editPersonalInfoPreferences =>
      'Editar informações e preferências pessoais';

  @override
  String get enableNotifications => 'Ativar Notificações';

  @override
  String get receiveUrgentSafetyAlerts =>
      'Receber alertas urgentes de segurança em tempo real';

  @override
  String get turnOnNow => 'Ativar agora';

  @override
  String get notInformed => 'Não informado';

  @override
  String get voteConfirmed => 'Obrigado por confirmar!';

  @override
  String get voteFeedbackReceived => 'Feedback recebido';

  @override
  String get voteErrorTitle => 'Não foi possível votar';

  @override
  String get voteErrorMessage =>
      'Não conseguimos processar seu voto. Por favor, tente novamente.';

  @override
  String get voteErrorNetwork =>
      'Erro de conexão. Verifique sua internet e tente novamente.';

  @override
  String get voteErrorServer =>
      'Erro no servidor. Por favor, tente novamente mais tarde.';

  @override
  String get voteErrorUnauthorized => 'Você precisa estar logado para votar.';

  @override
  String get setHome => 'Configurar Casa';

  @override
  String get setWork => 'Configurar Trabalho';

  @override
  String get searchAddress => 'Buscar endereço...';

  @override
  String get errorSearchingAddress => 'Erro ao buscar endereço';

  @override
  String get pleaseSelectAddress => 'Por favor, selecione um endereço';

  @override
  String errorSavingAddress(Object error) {
    return 'Erro ao salvar endereço: $error';
  }

  @override
  String selected(Object address) {
    return 'Selecionado: $address';
  }

  @override
  String get fillAllFields => 'Preencha todos os campos!';

  @override
  String get loginSuccessful => 'Login Realizado!';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get verifiedBadge => 'Verificado';

  @override
  String get unreliableBadge => 'Não confiável';

  @override
  String confirmsBadge(Object count) {
    return '$count confirmam';
  }

  @override
  String get tryAgainButton => 'Tentar novamente';

  @override
  String get unsubscribeButton => 'Cancelar Inscrição';

  @override
  String get subscribe => 'Inscrever';

  @override
  String get confirmDestinationButton => 'Confirmar Destino';

  @override
  String get errorCalculatingRoute => 'Erro ao calcular rota';

  @override
  String errorSendingSMS(Object error) {
    return 'Erro ao enviar SMS: $error';
  }

  @override
  String get errorRegisterCheckCredentials =>
      'Erro ao registrar. Verifique suas credenciais.';

  @override
  String get locationPermissionDenied => 'Permissão de localização negada';

  @override
  String get couldNotGetLocation => 'Não foi possível obter a localização';

  @override
  String locationStreamError(Object error) {
    return 'Erro no stream de localização: $error';
  }

  @override
  String get addSafePlace => 'Adicionar Lugar Seguro';

  @override
  String get safeRouteButton => 'Rota Segura';

  @override
  String get waitingLocation => 'Aguardando localização...';

  @override
  String get waitingGPS => 'Aguardando localização GPS...';

  @override
  String get homeAddressSavedSuccess => 'Endereço de casa salvo com sucesso!';

  @override
  String get workAddressSavedSuccess =>
      'Endereço de trabalho salvo com sucesso!';

  @override
  String addedSuccessfully(Object name) {
    return '$name adicionado com sucesso!';
  }

  @override
  String get allReportsTitle => 'Todos os Relatórios';

  @override
  String get refresh => 'Atualizar';

  @override
  String get filterBy => 'Filtrar por:';

  @override
  String get all => 'Todos';

  @override
  String get noReportsFound => 'Nenhum relatório encontrado';

  @override
  String get loadingReports => 'Carregando relatórios...';

  @override
  String get loadingRiskTypes => 'Preparando opções de relatório...';

  @override
  String get loadingRiskTypesMessage =>
      'Carregando categorias de risco disponíveis, aguarde um momento.';

  @override
  String get errorLoadingRiskTypes => 'Não Foi Possível Carregar Opções';

  @override
  String get errorLoadingRiskTypesMessage =>
      'Não conseguimos carregar as categorias de relatório. Isso pode ser devido à conexão lenta ou problema no servidor.';

  @override
  String get apiSlowWarning => 'A API pode estar lenta, por favor aguarde...';

  @override
  String get timeoutError => 'Tempo Esgotado';

  @override
  String get timeoutErrorMessage =>
      'O servidor está demorando muito para responder. Isso pode ser devido à API lenta ou conexão de internet ruim.';

  @override
  String get timeoutTip =>
      'Dica: Verifique sua conexão de internet ou tente novamente em alguns instantes.';

  @override
  String totalReports(Object count) {
    return 'Total: $count relatórios';
  }

  @override
  String pageOf(Object current, Object total) {
    return 'Página $current de $total';
  }

  @override
  String daysAgo(Object days) {
    return '${days}d atrás';
  }

  @override
  String get shareLocationTitle => 'Compartilhar Localização';

  @override
  String get shareLocationQuestion => 'Por quanto tempo deseja compartilhar?';

  @override
  String get minutes15 => '15 minutos';

  @override
  String get minutes30 => '30 minutos';

  @override
  String get minutes60 => '60 minutos';

  @override
  String get shortSharing => 'Compartilhamento curto';

  @override
  String get recommended => 'Recomendado';

  @override
  String get longSharing => 'Compartilhamento longo';

  @override
  String get sharingLocationActive => 'Compartilhando Localização';

  @override
  String get activeSharing => 'Compartilhamento Ativo';

  @override
  String expiresIn(Object time) {
    return 'Expira em: $time';
  }

  @override
  String get stopSharingQuestion =>
      'Deseja realmente parar de compartilhar sua localização?';

  @override
  String get linkCopied => 'Link copiado para a área de transferência';

  @override
  String get locationUpdating =>
      'Sua localização está sendo atualizada a cada 10 segundos';

  @override
  String shareMessage(Object expires, Object link) {
    return 'Estou compartilhando minha localização em tempo real com você.\n\nAcesse: $link\n\nLink válido até: $expires\n\nRiskPlace - Cidades Mais Seguras 🛡️';
  }

  @override
  String get comingSoon => 'Em Breve';

  @override
  String get featureComingSoon =>
      'Esta funcionalidade estará disponível em breve. Fique atento às atualizações!';

  @override
  String get settingsUpdatedSuccess => 'Configuração atualizada com sucesso';

  @override
  String get visibilityPublic => 'Público';

  @override
  String get visibilityFriends => 'Amigos';

  @override
  String get visibilityPrivate => 'Privado';

  @override
  String get alertTypeLow => 'Baixo';

  @override
  String get alertTypeMedium => 'Médio';

  @override
  String get alertTypeHigh => 'Alto';

  @override
  String get alertTypeCritical => 'Crítico';

  @override
  String get reportTypeRejected => 'Rejeitado';
}
