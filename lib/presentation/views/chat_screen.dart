import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gemini_viewmodel.dart';
import '../../data/models/chat_message_model.dart';
import '../temas/esquema_color.dart';
import '../temas/tipografia.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      final geminiViewModel = Provider.of<GeminiViewModel>(context, listen: false);
      
      geminiViewModel.startChat(
        plant: args?['plant'],
        disease: args?['disease'],
      );
    });
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

    final geminiViewModel = Provider.of<GeminiViewModel>(context, listen: false);
    geminiViewModel.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: EsquemaColor.backgroundGradient,
        ),
        child: Consumer<GeminiViewModel>(
          builder: (context, viewModel, child) {
            if (!viewModel.isConfigured) {
              return _buildNotConfigured();
            }
            
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
                ),
                _buildInputArea(viewModel),
              ],
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
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    if (message.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 60),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: EsquemaColor.primaryGreen,
                ),
              ),
              SizedBox(width: 12),
              Text('Escribiendo...', style: Tipografia.caption),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12,
          left: isUser ? 60 : 0,
          right: isUser ? 0 : 60,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? EsquemaColor.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: Tipografia.cuerpo.copyWith(
            color: isUser ? Colors.white : EsquemaColor.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(GeminiViewModel viewModel) {
    final isLoading = viewModel.chatState == GeminiState.loading;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: EsquemaColor.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              onPressed: isLoading ? null : _sendMessage,
              mini: true,
              backgroundColor: isLoading 
                  ? Colors.grey 
                  : EsquemaColor.primaryGreen,
              child: Icon(
                isLoading ? Icons.hourglass_empty : Icons.send,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
