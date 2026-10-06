import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'boleto_parser.dart';
import 'pdf_service.dart';

void main() {
  runApp(const BoletoApp());
}

class BoletoApp extends StatelessWidget {
  const BoletoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Boleto PDF',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3158D4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  bool editing = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    focusNode.addListener(() {
      if (!mounted) {
        return;
      }

      setState(() {
        editing = focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> pasteCode() async {
    try {
      final clipboard = await Clipboard.getData(
        Clipboard.kTextPlain,
      );

      final text = clipboard?.text?.trim() ?? '';

      if (text.isEmpty) {
        showMessage(
          'Não há nenhum texto copiado.',
        );
        return;
      }

      controller.text = text;

      controller.selection = TextSelection.collapsed(
        offset: text.length,
      );

      setState(() {});
    } catch (_) {
      showMessage(
        'Não foi possível acessar a área de transferência. Cole o código manualmente.',
      );
    }
  }

  Future<void> generateBoleto() async {
    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final boleto = BoletoParser.parse(
        controller.text,
      );

      if (!mounted) {
        return;
      }

      if (boleto.vencido) {
        final continuar = await mostrarAvisoVencido(
          boleto,
        );

        if (continuar != true) {
          return;
        }
      }

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BoletoScreen(
            boleto: boleto,
          ),
        ),
      );
    } on BoletoParseException catch (erro) {
      showMessage(
        erro.message,
      );
    } catch (_) {
      showMessage(
        'Não foi possível processar esse boleto. Confira o código e tente novamente.',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<bool?> mostrarAvisoVencido(
    BoletoData boleto,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Boleto vencido',
          ),
          content: Text(
            'Este boleto venceu em ${formatDate(boleto.vencimento)}. Deseja continuar mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Continuar',
              ),
            ),
          ],
        );
      },
    );
  }

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final padding =
                constraints.maxWidth < 360 ? 14.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 680,
                ),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    28,
                    padding,
                    30,
                  ),
                  children: [
                    Text(
                      'Gerar boleto em PDF',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Cole a linha digitável do boleto bancário para gerar o PDF.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: const Color(
                              0xFF626775,
                            ),
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        10,
                        10,
                        12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          16,
                        ),
                        border: Border.all(
                          color: const Color(
                            0xFFDCE0E8,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Código copia e cola',
                                  style: TextStyle(
                                    color: Color(
                                      0xFF626775,
                                    ),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: pasteCode,
                                child: const Text(
                                  'Colar',
                                ),
                              ),
                            ],
                          ),
                          if (editing)
                            TextField(
                              controller: controller,
                              focusNode: focusNode,
                              keyboardType:
                                  TextInputType.number,
                              maxLines: 1,
                              decoration:
                                  const InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    'Cole o código do boleto',
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              onChanged: (_) {
                                setState(() {});
                              },
                            )
                          else
                            InkWell(
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                              onTap: () {
                                setState(() {
                                  editing = true;
                                });

                                Future.delayed(
                                  const Duration(
                                    milliseconds: 100,
                                  ),
                                  () {
                                    focusNode.requestFocus();
                                  },
                                );
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    controller.text
                                            .trim()
                                            .isEmpty
                                        ? 'Cole o código do boleto'
                                        : controller.text,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: controller.text
                                              .trim()
                                              .isEmpty
                                          ? const Color(
                                              0xFF9BA1AD,
                                            )
                                          : const Color(
                                              0xFF22252D,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed:
                            loading
                                ? null
                                : generateBoleto,
                        child:
                            loading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Gerar boleto',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BoletoScreen extends StatefulWidget {
  const BoletoScreen({
    super.key,
    required this.boleto,
  });

  final BoletoData boleto;

  @override
  State<BoletoScreen> createState() =>
      _BoletoScreenState();
}

class _BoletoScreenState extends State<BoletoScreen> {
  late final Future<Uint8List> pdfFuture;

  bool salvando = false;
  bool encaminhando = false;

  @override
  void initState() {
    super.initState();

    pdfFuture = PdfService.generate(
      widget.boleto,
    );
  }

  Future<void> salvarPdf() async {
    if (salvando) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final bytes = await pdfFuture;

      await Printing.layoutPdf(
        name: 'boleto.pdf',
        onLayout: (_) async {
          return bytes;
        },
      );
    } catch (_) {
      if (mounted) {
        showMessage(
          'Não foi possível salvar o PDF.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  Future<void> encaminharPdf() async {
    if (encaminhando) {
      return;
    }

    setState(() {
      encaminhando = true;
    });

    try {
      final bytes = await pdfFuture;

      final arquivo = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: 'boleto.pdf',
      );

      await Share.shareXFiles(
        [
          arquivo,
        ],
        fileNameOverrides: const [
          'boleto.pdf',
        ],
      );
    } catch (_) {
      if (mounted) {
        showMessage(
          'Não foi possível encaminhar o PDF.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          encaminhando = false;
        });
      }
    }
  }

  void showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Boleto gerado',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<Uint8List>(
          future: pdfFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  child: Text(
                    'Não foi possível gerar o PDF.\n\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return PdfPreview(
              build: (_) async {
                return snapshot.data!;
              },
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              allowPrinting: false,
              allowSharing: false,
              pdfFileName: 'boleto.pdf',
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          14,
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        salvando
                            ? null
                            : salvarPdf,
                    child:
                        salvando
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Salvar',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed:
                        encaminhando
                            ? null
                            : encaminharPdf,
                    child:
                        encaminhando
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Encaminhar',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatDate(
  DateTime? data,
) {
  if (data == null) {
    return 'Não informado';
  }

  final dia = data.day.toString().padLeft(
    2,
    '0',
  );

  final mes = data.month.toString().padLeft(
    2,
    '0',
  );

  return '$dia/$mes/${data.year}';
}