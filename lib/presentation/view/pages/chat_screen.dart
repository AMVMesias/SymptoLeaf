import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/gemini_viewmodel.dart';
import '../../viewmodels/diagnostics_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/gradient_container.dart';
import '../atoms/app_button.dart';
import '../organisms/chat_area.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _chatInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeChatIfNeeded(BuildContext context) {
    if (_chatInitialized) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final geminiViewModel =
        Provider.of<GeminiViewModel>(context, listen: false);

    geminiViewModel.startChat(
      plant: args?['plant'],
      disease: args?['disease'],
    );

    _chatInitialized = true;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final geminiViewModel =
        Provider.of<GeminiViewModel>(context, listen: false);
    geminiViewModel.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  Future<void> _saveChatHistory() async {
    final geminiViewModel =
        Provider.of<GeminiViewModel>(context, listen: false);
    final diagnosticsVm =
        Provider.of<DiagnosticsViewModel>(context, listen: false);
    final authVm = Provider.of<AuthViewModel>(context, listen: false);

    if (geminiViewModel.messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay conversación para guardar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final messagesJson = geminiViewModel.messages
        .where((msg) => !msg.isLoading)
        .map((msg) => {
              'content': msg.content,
              'isUser': msg.isUser,
              'timestamp': msg.timestamp.toIso8601String(),
            })
        .toList();

    try {
      final saved = await diagnosticsVm.saveChatHistory(
        userId: (authVm.user?.id ?? 0).toString(),
        diagnosticId: diagnosticsVm.lastSavedId,
        messages: messagesJson,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved
                  ? '✅ Conversación guardada exitosamente'
                  : '❌ Error al guardar conversación',
            ),
            backgroundColor:
                saved ? EsquemaColor.healthyGreen : EsquemaColor.diseaseRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: EsquemaColor.diseaseRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, size: 28),
            SizedBox(width: 8),
            Text('Asistente Agrícola'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Guardar conversación',
            onPressed: _saveChatHistory,
          ),
        ],
      ),
      body: GradientContainer(
        child: Consumer<GeminiViewModel>(
          builder: (context, viewModel, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeChatIfNeeded(context);
            });

            if (!viewModel.isConfigured) {
              return _buildNotConfigured();
            }

            WidgetsBinding.instance
                .addPostFrameCallback((_) => _scrollToBottom());

            // Atomic Design: ChatArea organism
            return ChatArea(
              messages: viewModel.messages,
              messageController: _messageController,
              scrollController: _scrollController,
              focusNode: _focusNode,
              onSendMessage: _sendMessage,
              isLoading: viewModel.chatState == GeminiState.loading,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotConfigured() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.key_off,
              size: 80,
              color: EsquemaColor.warningOrange,
            ),
            const SizedBox(height: 24),
            Text(
              'API Key no configurada',
              style: Tipografia.titulo2.copyWith(
                color: EsquemaColor.warningOrange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Para usar el asistente, necesitas configurar tu API Key de Gemini.\n\n'
              '1. Ve a aistudio.google.com\n'
              '2. Crea una API Key\n'
              '3. Pégala en lib/config/gemini_config.dart',
              style: Tipografia.cuerpo,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'Volver',
              icon: Icons.arrow_back,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
