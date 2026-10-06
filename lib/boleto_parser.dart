class BoletoData {
  final String linhaDigitavel;
  final String codigoBarras;
  final String banco;
  final int valorCentavos;
  final DateTime? vencimento;

  const BoletoData({
    required this.linhaDigitavel,
    required this.codigoBarras,
    required this.banco,
    required this.valorCentavos,
    required this.vencimento,
  });

  bool get vencido {
    if (vencimento == null) {
      return false;
    }

    final agora = DateTime.now();

    final hoje = DateTime(
      agora.year,
      agora.month,
      agora.day,
    );

    return vencimento!.isBefore(hoje);
  }

  double get valor {
    return valorCentavos / 100;
  }
}

class BoletoParseException implements Exception {
  final String message;

  const BoletoParseException(this.message);

  @override
  String toString() {
    return message;
  }
}

class BoletoParser {
  static const Map<String, String> _bancos = {
    '001': 'Banco do Brasil',
    '003': 'Banco da Amazônia',
    '004': 'Banco do Nordeste',
    '007': 'BNDES',
    '012': 'Banco Inbursa',
    '021': 'Banestes',
    '025': 'Banco Alfa',
    '029': 'Itaú BBA',
    '033': 'Santander',
    '036': 'Bradesco BBI',
    '037': 'Banpará',
    '040': 'Banco Cargill',
    '041': 'Banrisul',
    '047': 'Banese',
    '060': 'Confidence Câmbio',
    '062': 'Hipercard',
    '063': 'Banco Bradescard',
    '064': 'Goldman Sachs',
    '065': 'Banco Andbank',
    '066': 'Banco Morgan Stanley',
    '069': 'Banco Crefisa',
    '070': 'BRB - Banco de Brasília',
    '074': 'Banco J. Safra',
    '075': 'Banco ABN AMRO',
    '076': 'Banco KDB Brasil',
    '077': 'Banco Inter',
    '078': 'Haitong Banco de Investimento',
    '079': 'Banco Original do Agronegócio',
    '080': 'BT Corretora',
    '081': 'BancoSeguro',
    '082': 'Banco Topázio',
    '083': 'Banco da China Brasil',
    '084': 'Uniprime Norte do Paraná',
    '085': 'Ailos',
    '089': 'Cresol',
    '091': 'Unicred Central',
    '092': 'Brickell',
    '093': 'Pólocred',
    '094': 'Banco Finaxis',
    '096': 'Banco B3',
    '097': 'Credisis',
    '098': 'Credialiança',
    '099': 'Uniprime Central',
    '100': 'Planner Corretora',
    '102': 'XP Investimentos',
    '104': 'Caixa Econômica Federal',
    '107': 'Banco BOCOM BBM',
    '108': 'PortoCred',
    '111': 'Oliveira Trust',
    '113': 'Magliano Corretora',
    '114': 'Central Cooperativa de Crédito',
    '117': 'Advanced Câmbio',
    '119': 'Banco Western Union',
    '120': 'Banco Rodobens',
    '121': 'Agibank',
    '122': 'Banco Bradesco BERJ',
    '124': 'Banco Woori Bank',
    '125': 'Banco Genial',
    '126': 'BR Partners',
    '127': 'Codepe',
    '128': 'MS Bank',
    '129': 'UBS Brasil',
    '130': 'Caruana',
    '131': 'Tullett Prebon',
    '132': 'ICBC do Brasil',
    '133': 'Cresol Confederação',
    '134': 'BGC Liquidez',
    '136': 'Unicred',
    '138': 'Get Money',
    '139': 'Intesa Sanpaolo Brasil',
    '140': 'Easynvest',
    '142': 'Broker Brasil',
    '143': 'Treviso Corretora',
    '144': 'Bexs Banco',
    '145': 'Levycam',
    '146': 'Guitta Corretora',
    '149': 'Facta Financeira',
    '157': 'ICAP do Brasil',
    '159': 'Casa do Crédito',
    '163': 'Commerzbank Brasil',
    '169': 'Banco Olé Bonsucesso',
    '172': 'Albatross',
    '173': 'BRL Trust',
    '174': 'Pernambucanas Financiadora',
    '177': 'Guide Investimentos',
    '180': 'CM Capital Markets',
    '183': 'Socred',
    '184': 'Banco Itaú BBA',
    '188': 'Ativa Investimentos',
    '189': 'HS Financeira',
    '190': 'Servicoop',
    '191': 'Nova Futura',
    '194': 'Parmetal',
    '196': 'Fair Corretora',
    '197': 'Stone',
    '208': 'BTG Pactual',
    '212': 'Banco Original',
    '213': 'Banco Arbi',
    '217': 'Banco John Deere',
    '218': 'Banco BS2',
    '222': 'Crédit Agricole Brasil',
    '224': 'Banco Fibra',
    '233': 'Banco Cifra',
    '237': 'Bradesco',
    '241': 'Banco Clássico',
    '243': 'Banco Máxima',
    '246': 'Banco ABC Brasil',
    '249': 'Investcred',
    '250': 'BCV',
    '253': 'Bexs',
    '254': 'Paraná Banco',
    '259': 'Moneo',
    '260': 'Nubank',
    '265': 'Banco Fator',
    '266': 'Banco Cédula',
    '269': 'Banco HSBC',
    '276': 'Senff',
    '278': 'Genial Investimentos',
    '280': 'Banco Will',
    '290': 'PagBank',
    '299': 'Banco Afinz',
    '300': 'Banco de la Nación Argentina',
    '301': 'PJBank',
    '318': 'Banco BMG',
    '320': 'Banco Industrial e Comercial',
    '323': 'Mercado Pago',
    '329': 'QI Tech',
    '330': 'Banco Bari',
    '335': 'Banco Digio',
    '336': 'C6 Bank',
    '341': 'Itaú Unibanco',
    '348': 'Banco XP',
    '349': 'Ame Digital',
    '356': 'Banco RCI Brasil',
    '366': 'Société Générale Brasil',
    '368': 'Banco CSF',
    '370': 'Banco Mizuho',
    '376': 'J.P. Morgan',
    '380': 'PicPay',
    '381': 'Banco Mercedes-Benz',
    '387': 'Banco Toyota',
    '389': 'Banco Mercantil do Brasil',
    '390': 'Banco GM',
    '393': 'Banco Volkswagen',
    '394': 'Bradesco Financiamentos',
    '399': 'HSBC Bank Brasil',
    '403': 'Cora',
    '412': 'Banco Capital',
    '413': 'Banco BV',
    '422': 'Banco Safra',
    '456': 'Banco MUFG Brasil',
    '461': 'Asaas',
    '464': 'Banco Sumitomo Mitsui',
    '473': 'Banco Caixa Geral Brasil',
    '477': 'Citibank',
    '487': 'Deutsche Bank',
    '488': 'JPMorgan Chase',
    '492': 'ING Bank',
    '495': 'Banco de la Provincia de Buenos Aires',
    '505': 'Credit Suisse Brasil',
    '545': 'Senso',
    '600': 'Banco Luso Brasileiro',
    '604': 'Banco Industrial do Brasil',
    '610': 'Banco VR',
    '611': 'Banco Paulista',
    '612': 'Banco Guanabara',
    '613': 'Omni Banco',
    '623': 'Banco PAN',
    '626': 'C6 Consignado',
    '630': 'Banco Smartbank',
    '633': 'Banco Rendimento',
    '637': 'Banco Sofisa',
    '643': 'Banco Pine',
    '652': 'Itaú Unibanco Holding',
    '653': 'Banco Indusval',
    '654': 'Banco Digimais',
    '655': 'Banco Votorantim',
    '707': 'Banco Daycoval',
    '712': 'Banco Ourinvest',
    '739': 'Banco Cetelem',
    '741': 'Banco Ribeirão Preto',
    '743': 'Banco Semear',
    '745': 'Citibank Brasil',
    '746': 'Banco Modal',
    '747': 'Rabobank Brasil',
    '748': 'Sicredi',
    '751': 'Scotiabank Brasil',
    '752': 'BNP Paribas Brasil',
    '753': 'Novo Banco Continental',
    '754': 'Banco Sistema',
    '755': 'Bank of America Merrill Lynch',
    '756': 'Sicoob',
  };

  static BoletoData parse(String texto) {
    final codigo = texto.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (codigo.isEmpty) {
      throw const BoletoParseException(
        'Cole o código do boleto.',
      );
    }

    if (codigo.length != 47) {
      throw const BoletoParseException(
        'Código inválido. O boleto bancário deve conter 47 números.',
      );
    }

    _validarCampos(codigo);

    final codigoBarras = _linhaParaCodigoBarras(
      codigo,
    );

    _validarDvGeral(
      codigoBarras,
    );

    final bancoCodigo = codigo.substring(
      0,
      3,
    );

    final fator = int.parse(
      codigo.substring(
        33,
        37,
      ),
    );

    final valorCentavos = int.parse(
      codigo.substring(
        37,
        47,
      ),
    );

    final vencimento = _calcularVencimento(
      fator,
    );

    return BoletoData(
      linhaDigitavel: _formatarLinha(
        codigo,
      ),
      codigoBarras: codigoBarras,
      banco: _nomeBanco(
        bancoCodigo,
      ),
      valorCentavos: valorCentavos,
      vencimento: vencimento,
    );
  }

  static void _validarCampos(
    String codigo,
  ) {
    final campo1 = codigo.substring(
      0,
      9,
    );

    final dv1 = int.parse(
      codigo[9],
    );

    final campo2 = codigo.substring(
      10,
      20,
    );

    final dv2 = int.parse(
      codigo[20],
    );

    final campo3 = codigo.substring(
      21,
      31,
    );

    final dv3 = int.parse(
      codigo[31],
    );

    if (_modulo10(campo1) != dv1 ||
        _modulo10(campo2) != dv2 ||
        _modulo10(campo3) != dv3) {
      throw const BoletoParseException(
        'Código inválido. Confira a linha digitável e tente novamente.',
      );
    }
  }

  static String _linhaParaCodigoBarras(
    String codigo,
  ) {
    return codigo.substring(0, 4) +
        codigo[32] +
        codigo.substring(33, 47) +
        codigo.substring(4, 9) +
        codigo.substring(10, 20) +
        codigo.substring(21, 31);
  }

  static void _validarDvGeral(
    String codigoBarras,
  ) {
    final dvInformado = int.parse(
      codigoBarras[4],
    );

    final dvCalculado = _modulo11(
      codigoBarras,
    );

    if (dvInformado != dvCalculado) {
      throw const BoletoParseException(
        'Código inválido. O dígito verificador do boleto está incorreto.',
      );
    }
  }

  static int _modulo10(
    String numero,
  ) {
    int soma = 0;
    int peso = 2;

    for (int i = numero.length - 1; i >= 0; i--) {
      int resultado = int.parse(
            numero[i],
          ) *
          peso;

      if (resultado > 9) {
        resultado = (resultado ~/ 10) + (resultado % 10);
      }

      soma += resultado;

      peso = peso == 2 ? 1 : 2;
    }

    final resto = soma % 10;

    if (resto == 0) {
      return 0;
    }

    return 10 - resto;
  }

  static int _modulo11(
    String codigoBarras,
  ) {
    final codigoSemDv =
        codigoBarras.substring(0, 4) + codigoBarras.substring(5);

    int soma = 0;
    int peso = 2;

    for (int i = codigoSemDv.length - 1; i >= 0; i--) {
      soma += int.parse(
            codigoSemDv[i],
          ) *
          peso;

      peso++;

      if (peso > 9) {
        peso = 2;
      }
    }

    final resto = soma % 11;
    final resultado = 11 - resto;

    if (resultado == 0 || resultado == 10 || resultado == 11) {
      return 1;
    }

    return resultado;
  }

  static DateTime? _calcularVencimento(
    int fator,
  ) {
    if (fator == 0) {
      return null;
    }

    if (fator >= 1000) {
      final baseNova = DateTime(
        2025,
        2,
        22,
      );

      return baseNova.add(
        Duration(
          days: fator - 1000,
        ),
      );
    }

    final baseAntiga = DateTime(
      1997,
      10,
      7,
    );

    return baseAntiga.add(
      Duration(
        days: fator,
      ),
    );
  }

  static String _formatarLinha(
    String codigo,
  ) {
    return '${codigo.substring(0, 5)}.'
        '${codigo.substring(5, 10)} '
        '${codigo.substring(10, 15)}.'
        '${codigo.substring(15, 21)} '
        '${codigo.substring(21, 26)}.'
        '${codigo.substring(26, 32)} '
        '${codigo.substring(32, 33)} '
        '${codigo.substring(33, 47)}';
  }

  static String _nomeBanco(
    String codigo,
  ) {
    return _bancos[codigo] ?? 'Banco $codigo';
  }
}
