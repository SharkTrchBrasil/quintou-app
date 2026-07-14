import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  final int initialTab;

  const LegalScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text('Legal', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFFB7F65E),
            indicatorWeight: 3,
            labelColor: const Color(0xFF171E0E),
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Termos de Uso'),
              Tab(text: 'Privacidade'),
              Tab(text: 'Anfitrião'),
              Tab(text: 'Hóspede'),
              Tab(text: 'Cancelamento'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTermosDeUso(),
            _buildPrivacidade(),
            _buildTermosAnfitriao(),
            _buildTermosHospede(),
            _buildPoliticaCancelamento(),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF171E0E), height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 48),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Quintou Tecnologia Ltda — CNPJ: XX.XXX.XXX/0001-XX',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Dúvidas? contato@quintou.com.br',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: TERMOS DE USO ──────────────────────────────

  Widget _buildTermosDeUso() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('Última atualização: 12 de julho de 2026'),

        _buildSection(
          '1. Aceitação dos Termos',
          'Ao acessar, navegar ou utilizar o aplicativo Quintou, você declara ter lido, compreendido e aceito integralmente estes Termos de Uso. Caso não concorde com qualquer disposição, você deve cessar imediatamente o uso da plataforma.',
        ),

        _buildSection(
          '2. Definições',
          '• Plataforma: O aplicativo Quintou e todos os seus serviços associados.\n'
          '• Anfitrião: Pessoa física ou jurídica que lista espaços ou equipamentos para locação.\n'
          '• Hóspede: Pessoa física que realiza reservas e utiliza os espaços ou equipamentos.\n'
          '• Listing (Anúncio): Publicação de um espaço ou equipamento disponível para reserva.\n'
          '• Reserva (Booking): Agendamento confirmado entre Anfitrião e Hóspede.',
        ),

        _buildSection(
          '3. Natureza do Serviço',
          'O Quintou é uma plataforma tecnológica de intermediação que conecta Anfitriões e Hóspedes para a locação temporária de espaços e equipamentos.\n\n'
          'O Quintou NÃO é proprietário, operador, gestor ou responsável pelos espaços e equipamentos anunciados na plataforma.\n\n'
          'O Quintou NÃO presta serviços de lazer, hospedagem, locação direta ou qualquer outro serviço além da intermediação tecnológica.\n\n'
          'A relação contratual de locação é estabelecida exclusivamente entre o Anfitrião e o Hóspede, sem qualquer vínculo empregatício, societário ou de representação com o Quintou.',
        ),

        _buildSection(
          '4. Elegibilidade',
          'Para utilizar a plataforma, o usuário deve:\n\n'
          'a) Ter no mínimo 18 (dezoito) anos de idade;\n'
          'b) Possuir CPF válido e regular junto à Receita Federal;\n'
          'c) Fornecer informações cadastrais verdadeiras e atualizadas;\n'
          'd) Possuir capacidade civil plena.\n\n'
          'A conta é pessoal e intransferível.',
        ),

        _buildSection(
          '5. Cadastro e Conta',
          'O usuário é responsável por manter a confidencialidade de suas credenciais de acesso. Qualquer atividade realizada através da conta será de responsabilidade exclusiva do titular. O Quintou poderá solicitar documentos adicionais para verificação de identidade a qualquer momento.',
        ),

        _buildSection(
          '6. Regras para Anfitriões',
          'Ao listar um espaço ou equipamento, o Anfitrião declara e garante que:\n\n'
          'a) É o legítimo proprietário ou possui autorização expressa do proprietário para realizar a locação;\n'
          'b) O espaço está em condições seguras e adequadas para uso;\n'
          'c) Possui seguro residencial ou patrimonial vigente;\n'
          'd) A locação está em conformidade com a legislação municipal, estadual e federal aplicável;\n'
          'e) A locação é permitida pela convenção condominial, quando aplicável;\n'
          'f) As informações e fotos do anúncio são verdadeiras e representam fielmente o espaço;\n'
          'g) Manterá o calendário de disponibilidade atualizado;\n'
          'h) É o único responsável civil e criminalmente por quaisquer eventos ocorridos em seu espaço.',
        ),

        _buildSection(
          '7. Regras para Hóspedes',
          'Ao realizar uma reserva, o Hóspede concorda em:\n\n'
          'a) Respeitar integralmente as regras da casa definidas pelo Anfitrião;\n'
          'b) Não exceder o número máximo de convidados informado na reserva;\n'
          'c) Devolver o espaço nas mesmas condições em que foi encontrado;\n'
          'd) Não realizar atividades ilegais, perigosas ou que perturbem a vizinhança;\n'
          'e) Supervisionar diretamente todos os menores de idade presentes;\n'
          'f) Comunicar imediatamente ao Anfitrião qualquer dano ou problema.',
        ),

        _buildSection(
          '8. Reservas e Pagamentos',
          'As reservas são processadas através da plataforma. O Quintou cobra:\n\n'
          'a) Taxa de serviço do Hóspede (service fee): percentual sobre o valor da reserva;\n'
          'b) Taxa do Anfitrião (host fee): percentual deduzido do repasse ao Anfitrião.\n\n'
          'As políticas de cancelamento (Flexível, Moderada ou Rigorosa) são definidas individualmente por cada Anfitrião.\n\n'
          'O depósito de segurança (caução), quando aplicável, será retido temporariamente e devolvido após verificação do espaço.',
        ),

        _buildSection(
          '9. Isenção de Responsabilidade',
          'O Quintou NÃO se responsabiliza por:\n\n'
          'a) Qualidade, segurança, legalidade ou adequação dos espaços e equipamentos listados;\n'
          'b) Veracidade ou precisão das informações fornecidas por Anfitriões ou Hóspedes;\n'
          'c) Acidentes, lesões corporais, afogamentos ou danos pessoais ocorridos durante o uso dos espaços;\n'
          'd) Danos materiais, furtos ou perdas ocorridos nos espaços;\n'
          'e) Danos causados por caso fortuito ou força maior;\n'
          'f) Ações, omissões ou condutas de Anfitriões, Hóspedes ou terceiros;\n'
          'g) Interrupções temporárias ou indisponibilidade da plataforma;\n'
          'h) Prejuízos decorrentes de cancelamentos.',
        ),

        _buildSection(
          '10. Assunção de Risco',
          'O Hóspede reconhece expressamente que atividades em piscinas, áreas de lazer, quadras esportivas, brinquedos infláveis e demais espaços e equipamentos envolvem RISCOS INERENTES, incluindo, mas não se limitando a: lesões corporais, afogamento, insolação, quedas e contusões.\n\n'
          'Ao realizar uma reserva, o Hóspede ASSUME INTEGRAL RESPONSABILIDADE pela sua segurança e pela segurança de todos os seus convidados, incluindo menores de idade sob sua supervisão.',
        ),

        _buildSection(
          '11. Indenização',
          'O usuário concorda em indenizar, defender e isentar o Quintou, seus sócios, diretores, funcionários e parceiros de quaisquer reclamações, perdas, danos, responsabilidades e despesas (incluindo honorários advocatícios) decorrentes de:\n\n'
          'a) Violação destes Termos;\n'
          'b) Uso indevido da plataforma;\n'
          'c) Violação de direitos de terceiros;\n'
          'd) Informações falsas fornecidas.',
        ),

        _buildSection(
          '12. Propriedade Intelectual',
          'Todo o conteúdo da plataforma, incluindo marca, logotipo, interface, código-fonte, textos e imagens, é de propriedade exclusiva do Quintou e protegido pela legislação de propriedade intelectual.',
        ),

        _buildSection(
          '13. Suspensão e Encerramento de Conta',
          'O Quintou reserva-se o direito de suspender ou encerrar contas que:\n\n'
          'a) Violem estes Termos;\n'
          'b) Apresentem comportamento fraudulento;\n'
          'c) Recebam múltiplas denúncias;\n'
          'd) Causem danos à reputação da plataforma.\n\n'
          'Valores devidos serão processados antes do encerramento.',
        ),

        _buildSection(
          '14. Comunicações',
          'Ao se cadastrar, o usuário consente em receber comunicações por e-mail, notificações push e SMS relacionadas ao uso da plataforma, incluindo confirmações de reserva, atualizações de conta e comunicados de segurança.',
        ),

        _buildSection(
          '15. Alterações nos Termos',
          'O Quintou poderá modificar estes Termos a qualquer momento, mediante notificação prévia de 15 (quinze) dias através do aplicativo ou e-mail. O uso continuado após o período de notificação constitui aceitação das alterações.',
        ),

        _buildSection(
          '16. Legislação Aplicável',
          'Estes Termos são regidos pelas leis da República Federativa do Brasil, em especial o Código Civil, o Código de Defesa do Consumidor e o Marco Civil da Internet.',
        ),

        _buildSection(
          '17. Foro',
          'Fica eleito o foro da comarca da sede da empresa para dirimir quaisquer litígios, com renúncia a qualquer outro, por mais privilegiado que seja.',
        ),

        _buildSection(
          '18. Disposições Gerais',
          'Caso qualquer cláusula destes Termos seja considerada inválida ou inexequível, as demais disposições permanecerão em pleno vigor. A tolerância quanto ao descumprimento de qualquer condição não constituirá renúncia ao direito de exigi-la.',
        ),

        _buildFooter(),
      ],
    );
  }

  // ─── TAB 2: POLÍTICA DE PRIVACIDADE ────────────────────

  Widget _buildPrivacidade() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('Em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018)'),

        _buildSection(
          '1. Dados Coletados',
          'Coletamos os seguintes dados pessoais:\n\n'
          '• Nome completo\n'
          '• CPF\n'
          '• Endereço de e-mail\n'
          '• Número de telefone\n'
          '• Endereço residencial (para Anfitriões)\n'
          '• Foto de perfil\n'
          '• Dados de pagamento (processados pelo Stripe)\n'
          '• Localização geográfica (com consentimento)\n'
          '• Dados de uso do aplicativo (páginas visitadas, tempo de uso, ações realizadas)\n'
          '• Endereço IP e informações do dispositivo',
        ),

        _buildSection(
          '2. Finalidade do Tratamento',
          'Seus dados são utilizados para:\n\n'
          'a) Criação e gerenciamento da conta;\n'
          'b) Verificação de identidade e prevenção de fraudes;\n'
          'c) Processamento de pagamentos e repasses;\n'
          'd) Comunicação sobre reservas e atualizações;\n'
          'e) Melhoria contínua da plataforma e experiência do usuário;\n'
          'f) Personalização de conteúdo e recomendações;\n'
          'g) Cumprimento de obrigações legais e regulatórias;\n'
          'h) Resolução de disputas entre usuários.',
        ),

        _buildSection(
          '3. Base Legal',
          'O tratamento de dados é fundamentado em:\n\n'
          'a) Execução de contrato (Art. 7º, V da LGPD);\n'
          'b) Consentimento do titular (Art. 7º, I);\n'
          'c) Legítimo interesse do controlador (Art. 7º, IX);\n'
          'd) Cumprimento de obrigação legal (Art. 7º, II).',
        ),

        _buildSection(
          '4. Compartilhamento de Dados',
          'Seus dados podem ser compartilhados com:\n\n'
          'a) Stripe Inc. — para processamento de pagamentos;\n'
          'b) Serviços de verificação de CPF — para validação cadastral;\n'
          'c) Firebase/Google — para analytics e notificações;\n'
          'd) Autoridades governamentais — quando exigido por lei ou ordem judicial.\n\n'
          'O Quintou NÃO vende, aluga ou comercializa dados pessoais de seus usuários a terceiros.',
        ),

        _buildSection(
          '5. Armazenamento e Segurança',
          'Seus dados são armazenados em servidores seguros com criptografia em trânsito (TLS/SSL) e em repouso. Adotamos medidas técnicas e administrativas para proteger seus dados contra acesso não autorizado, destruição, perda ou alteração.',
        ),

        _buildSection(
          '6. Direitos do Titular',
          'Você tem direito a:\n\n'
          'a) Confirmar a existência de tratamento;\n'
          'b) Acessar seus dados;\n'
          'c) Corrigir dados incompletos ou desatualizados;\n'
          'd) Solicitar a anonimização ou exclusão de dados desnecessários;\n'
          'e) Solicitar a portabilidade dos dados;\n'
          'f) Revogar o consentimento a qualquer momento;\n'
          'g) Solicitar informações sobre compartilhamento;\n'
          'h) Opor-se ao tratamento quando em desconformidade com a LGPD.',
        ),

        _buildSection(
          '7. Cookies e Tecnologias de Rastreamento',
          'Utilizamos Firebase Analytics para métricas de uso e Firebase Cloud Messaging para notificações push. Estas tecnologias nos ajudam a melhorar a experiência do usuário e garantir o funcionamento adequado da plataforma.',
        ),

        _buildSection(
          '8. Retenção de Dados',
          'Seus dados são mantidos enquanto sua conta estiver ativa. Após o encerramento da conta, os dados serão mantidos por 5 (cinco) anos para cumprimento de obrigações fiscais e legais, após os quais serão anonimizados ou excluídos.',
        ),

        _buildSection(
          '9. Encarregado de Dados (DPO)',
          'Para exercer seus direitos ou esclarecer dúvidas sobre o tratamento de dados, entre em contato com nosso Encarregado de Proteção de Dados:\n\nprivacidade@quintou.com.br',
        ),

        _buildSection(
          '10. Alterações',
          'Esta Política poderá ser atualizada periodicamente. Notificaremos sobre alterações significativas com antecedência mínima de 15 dias.',
        ),

        _buildFooter(),
      ],
    );
  }

  // ─── TAB 3: TERMOS DO ANFITRIÃO ───────────────────────

  Widget _buildTermosAnfitriao() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('Termos e Condições Específicos para Anfitriões'),

        _buildSection(
          '1. Declaração de Propriedade ou Autorização',
          'Ao listar um espaço ou equipamento no Quintou, o Anfitrião declara, sob as penas da lei, que é o legítimo proprietário do bem ou que possui autorização expressa, por escrito, do proprietário para realizar a locação. O Quintou poderá solicitar comprovação documental a qualquer momento.',
        ),

        _buildSection(
          '2. Conformidade Legal',
          'O Anfitrião é integralmente responsável por verificar e garantir que a locação está em conformidade com:\n\n'
          'a) A convenção e o regulamento interno do condomínio, quando aplicável;\n'
          'b) A legislação municipal (zoneamento, alvarás, licenças);\n'
          'c) A legislação estadual e federal aplicável;\n'
          'd) Normas de segurança e acessibilidade.\n\n'
          'O Quintou não verifica a conformidade legal dos espaços listados.',
        ),

        _buildSection(
          '3. Segurança do Espaço',
          'O Anfitrião declara e garante que:\n\n'
          'a) O espaço está em condições seguras e adequadas para o uso proposto;\n'
          'b) Todos os equipamentos disponibilizados estão em bom estado de conservação e funcionamento;\n'
          'c) Possui seguro residencial ou patrimonial vigente que cubra o imóvel;\n'
          'd) Áreas de piscina atendem às normas técnicas de segurança aplicáveis (ABNT NBR 10339, quando aplicável);\n'
          'e) Instalações elétricas e hidráulicas estão em conformidade;\n'
          'f) Possui itens de segurança quando exigidos por lei (extintores, saídas de emergência).',
        ),

        _buildSection(
          '4. Responsabilidade Civil e Criminal',
          'O Anfitrião é o ÚNICO responsável civil e criminalmente por quaisquer acidentes, danos pessoais, materiais ou morais ocorridos em seu espaço durante ou em decorrência de uma reserva realizada através do Quintou.\n\n'
          'O Quintou, na qualidade de mero intermediador tecnológico, NÃO assume qualquer responsabilidade por eventos ocorridos nos espaços listados.',
        ),

        _buildSection(
          '5. Obrigações Fiscais',
          'Os rendimentos obtidos através da plataforma constituem renda tributável. O Anfitrião é exclusivamente responsável pela declaração e pagamento de tributos incidentes sobre os valores recebidos, conforme legislação fiscal vigente.',
        ),

        _buildSection(
          '6. Veracidade das Informações',
          'As fotos, descrições e informações do anúncio devem ser verdadeiras, atuais e representar fielmente o espaço. Anúncios com informações falsas ou enganosas serão removidos e poderão resultar na suspensão da conta.',
        ),

        _buildSection(
          '7. Disponibilidade e Calendário',
          'O Anfitrião deve manter seu calendário de disponibilidade atualizado. A não confirmação de reservas ou cancelamentos recorrentes pelo Anfitrião podem resultar em penalidades, incluindo redução de visibilidade, suspensão temporária ou encerramento da conta.',
        ),

        _buildSection(
          '8. Cancelamentos pelo Anfitrião',
          'Cancelamentos realizados pelo Anfitrião após a confirmação podem resultar em:\n\n'
          'a) Aplicação de multa;\n'
          'b) Avaliação negativa automática;\n'
          'c) Redução no ranking de busca;\n'
          'd) Suspensão temporária ou permanente em caso de reincidência.',
        ),

        _buildSection(
          '9. Recebimentos',
          'Os pagamentos são processados via Stripe Connect. O repasse ao Anfitrião será realizado conforme os prazos estabelecidos pelo processador de pagamentos, deduzida a taxa do Anfitrião (host fee). O Anfitrião é responsável por manter seus dados bancários atualizados.',
        ),

        _buildSection(
          '10. Remoção de Anúncios',
          'O Quintou reserva-se o direito de remover anúncios que:\n\n'
          'a) Violem estes termos;\n'
          'b) Recebam denúncias de segurança;\n'
          'c) Apresentem informações falsas;\n'
          'd) Recebam avaliações consistentemente negativas;\n'
          'e) Não atendam aos padrões mínimos de qualidade da plataforma.',
        ),

        _buildFooter(),
      ],
    );
  }

  // ─── TAB 4: TERMOS DO HÓSPEDE ─────────────────────────

  Widget _buildTermosHospede() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('Termos e Condições Específicos para Hóspedes'),

        _buildSection(
          '1. Assunção de Risco',
          'O Hóspede reconhece e aceita que o uso de piscinas, áreas de lazer, quadras esportivas, brinquedos infláveis, churrasqueiras e demais espaços e equipamentos listados no Quintou envolve RISCOS INERENTES, incluindo, mas não se limitando a: lesões corporais, afogamento, quedas, queimaduras, insolação, reações alérgicas e contusões.\n\n'
          'O Hóspede ASSUME INTEGRAL RESPONSABILIDADE pela sua segurança e pela segurança de todos os convidados presentes durante a reserva.',
        ),

        _buildSection(
          '2. Supervisão de Menores',
          'Menores de 18 (dezoito) anos devem estar SEMPRE acompanhados e sob supervisão direta e ininterrupta de um adulto responsável.\n\n'
          'O Hóspede é integralmente responsável pela segurança de todas as crianças e adolescentes presentes durante toda a duração da reserva.\n\n'
          'Atividades aquáticas com menores requerem atenção redobrada e supervisão constante.',
        ),

        _buildSection(
          '3. Regras da Casa',
          'O Hóspede deve respeitar integralmente todas as regras definidas pelo Anfitrião, incluindo:\n\n'
          'a) Número máximo de convidados;\n'
          'b) Nível de ruído permitido;\n'
          'c) Horários de início e término;\n'
          'd) Permissão ou proibição de bebidas alcoólicas;\n'
          'e) Proibição de fumar;\n'
          'f) Regras sobre animais de estimação;\n'
          'g) Áreas de acesso permitido;\n'
          'h) Regras específicas de cada espaço.',
        ),

        _buildSection(
          '4. Danos e Prejuízos',
          'O Hóspede é responsável por quaisquer danos causados ao espaço, equipamentos ou mobiliário durante a reserva.\n\n'
          'O depósito de segurança (caução), quando aplicável, poderá ser retido parcial ou integralmente para cobrir danos. Caso os danos excedam o valor do depósito, o Hóspede será responsável pelo pagamento da diferença.',
        ),

        _buildSection(
          '5. Conduta',
          'É expressamente proibido:\n\n'
          'a) Realizar atividades ilegais no espaço;\n'
          'b) Perturbar a paz e o sossego da vizinhança;\n'
          'c) Sublocar ou ceder o espaço a terceiros;\n'
          'd) Utilizar o espaço para fins comerciais sem autorização expressa do Anfitrião;\n'
          'e) Exceder o número de convidados informado na reserva;\n'
          'f) Permanecer no espaço além do horário reservado;\n'
          'g) Consumir substâncias ilícitas;\n'
          'h) Causar danos intencionais ao espaço ou equipamentos.',
        ),

        _buildSection(
          '6. Política de Cancelamento',
          'As políticas de cancelamento são definidas individualmente por cada Anfitrião:\n\n'
          '• Flexível: Reembolso integral se cancelado até 24 horas antes do início.\n\n'
          '• Moderada: Reembolso de 50% se cancelado até 48 horas antes do início.\n\n'
          '• Rigorosa: Sem reembolso para cancelamentos com menos de 7 dias de antecedência. Reembolso de 50% para cancelamentos entre 7 e 14 dias antes.\n\n'
          'Em todos os casos, a taxa de serviço do Quintou não é reembolsável.',
        ),

        _buildSection(
          '7. Avaliações',
          'As avaliações devem ser honestas, respeitosas e baseadas na experiência real. O Quintou reserva-se o direito de remover avaliações que contenham: linguagem ofensiva, informações falsas, conteúdo discriminatório ou que violem estes termos.',
        ),

        _buildSection(
          '8. Reclamações e Disputas',
          'Em caso de problemas com uma reserva, o Hóspede deve:\n\n'
          'a) Comunicar o Anfitrião imediatamente através do chat da plataforma;\n'
          'b) Registrar evidências (fotos, mensagens);\n'
          'c) Acionar o suporte do Quintou caso a situação não seja resolvida diretamente.\n\n'
          'O Quintou atuará como mediador, mas a decisão final sobre disputas de danos é baseada nas evidências apresentadas por ambas as partes.',
        ),

        _buildFooter(),
      ],
    );
  }

  // ─── TAB 5: POLÍTICA DE CANCELAMENTO ────────────────────

  Widget _buildPoliticaCancelamento() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildHeader('Política de Cancelamento de Reservas'),

        _buildSection(
          '1. Visão Geral',
          'O Quintou oferece três opções de política de cancelamento para os Anfitriões. A política escolhida pelo Anfitrião será claramente informada na página do anúncio e aplicada a todas as reservas confirmadas naquele espaço.',
        ),

        _buildSection(
          '2. Política Flexível',
          '• Cancelamento pelo Hóspede até 24 horas antes do início da reserva: Reembolso de 100% do valor da reserva (exceto a taxa de serviço).\n\n'
          '• Cancelamento pelo Hóspede com menos de 24 horas de antecedência: Reembolso de 50% do valor da reserva (exceto a taxa de serviço).',
        ),

        _buildSection(
          '3. Política Moderada',
          '• Cancelamento pelo Hóspede até 5 dias (120 horas) antes do início da reserva: Reembolso de 100% do valor da reserva (exceto a taxa de serviço).\n\n'
          '• Cancelamento pelo Hóspede com menos de 5 dias de antecedência: Reembolso de 50% do valor da reserva (exceto a taxa de serviço).',
        ),

        _buildSection(
          '4. Política Rigorosa',
          '• Cancelamento pelo Hóspede até 14 dias (336 horas) antes do início da reserva: Reembolso de 100% do valor da reserva (exceto a taxa de serviço).\n\n'
          '• Cancelamento pelo Hóspede entre 7 e 14 dias antes do início da reserva: Reembolso de 50% do valor da reserva (exceto a taxa de serviço).\n\n'
          '• Cancelamento pelo Hóspede com menos de 7 dias de antecedência: Não há reembolso do valor da reserva.',
        ),

        _buildSection(
          '5. Taxa de Serviço',
          'A taxa de serviço (service fee) cobrada pelo Quintou no momento da reserva não é reembolsável em caso de cancelamento pelo Hóspede, independentemente da política aplicável, pois cobre os custos de processamento financeiro e de plataforma já incorridos.',
        ),

        _buildSection(
          '6. Cancelamento pelo Anfitrião',
          'Caso o Anfitrião cancele uma reserva confirmada, o Hóspede receberá o reembolso integral (100%) do valor pago, incluindo a taxa de serviço.\n\n'
          'O Anfitrião estará sujeito a multas e penalidades conforme os Termos do Anfitrião.',
        ),

        _buildSection(
          '7. Eventos de Força Maior',
          'Em casos extremos e documentados de força maior (como desastres naturais que impeçam o acesso ao local ou emergências de saúde pública), o Quintou poderá intervir e sobrepor a política de cancelamento do Anfitrião, garantindo um reembolso adequado ao Hóspede.',
        ),

        _buildFooter(),
      ],
    );
  }
}
