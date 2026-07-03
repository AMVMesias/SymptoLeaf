import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/diagnostics_viewmodel.dart';
import '../../temas/esquema_color.dart';
import '../../temas/tipografia.dart';
import '../atoms/gradient_container.dart';
import '../../../data/datasource/diagnostics_datasource.dart';

/// Pantalla para ver el historial de diagnósticos
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar diagnósticos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiagnosticsViewModel>().loadDiagnostics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Diagnósticos'),
        backgroundColor: EsquemaColor.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientContainer(
        child: Consumer<DiagnosticsViewModel>(
          builder: (context, diagnosticsVm, child) {
            if (diagnosticsVm.state == DiagnosticsState.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: EsquemaColor.primaryGreen,
                ),
              );
            }

            if (diagnosticsVm.state == DiagnosticsState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: EsquemaColor.diseaseRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      diagnosticsVm.errorMessage,
                      style: Tipografia.cuerpo,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => diagnosticsVm.loadDiagnostics(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (!diagnosticsVm.hasDiagnostics) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: EsquemaColor.primaryGreen.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No hay diagnósticos guardados',
                      style: Tipografia.titulo3.copyWith(
                        color: EsquemaColor.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los diagnósticos que guardes aparecerán aquí',
                      style: Tipografia.cuerpo.copyWith(
                        color: EsquemaColor.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => diagnosticsVm.loadDiagnostics(),
              color: EsquemaColor.primaryGreen,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: diagnosticsVm.diagnostics.length,
                itemBuilder: (context, index) {
                  final diagnostic = diagnosticsVm.diagnostics[index];
                  return _buildDiagnosticCard(context, diagnostic, diagnosticsVm);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiagnosticCard(
    BuildContext context,
    DiagnosticModel diagnostic,
    DiagnosticsViewModel diagnosticsVm,
  ) {
    final isHealthy = diagnostic.diseaseName.toLowerCase().contains('healthy') ||
        diagnostic.diseaseName.toLowerCase().contains('saludable');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDiagnosticDetail(context, diagnostic),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen en miniatura
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildThumbnail(diagnostic),
              ),
              const SizedBox(width: 16),
              
              // Información del diagnóstico
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isHealthy ? Icons.check_circle : Icons.warning,
                          size: 18,
                          color: isHealthy
                              ? EsquemaColor.healthyGreen
                              : EsquemaColor.diseaseRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            diagnostic.plantName,
                            style: Tipografia.titulo3.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diagnostic.diseaseName,
                      style: Tipografia.cuerpo.copyWith(
                        color: isHealthy
                            ? EsquemaColor.healthyGreen
                            : EsquemaColor.diseaseRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (diagnostic.confidence != null)
                      Text(
                        'Confianza: ${(diagnostic.confidence! * 100).toStringAsFixed(1)}%',
                        style: Tipografia.caption.copyWith(
                          color: EsquemaColor.textSecondary,
                        ),
                      ),
                    if (diagnostic.createdAt != null)
                      Text(
                        _formatDate(diagnostic.createdAt!),
                        style: Tipografia.caption.copyWith(
                          color: EsquemaColor.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade400,
                onPressed: () => _confirmDelete(context, diagnostic, diagnosticsVm),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(DiagnosticModel diagnostic) {
    if (diagnostic.imageBase64 != null && diagnostic.imageBase64!.isNotEmpty) {
      try {
        final bytes = _decodeImageBase64(diagnostic.imageBase64!);
        return Image.memory(
          bytes,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderThumbnail(),
        );
      } catch (e) {
        return _buildPlaceholderThumbnail();
      }
    }
    if (diagnostic.imageUrl != null && diagnostic.imageUrl!.isNotEmpty) {
      return Image.network(
        diagnostic.imageUrl!,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderThumbnail(),
      );
    }
    return _buildPlaceholderThumbnail();
  }

  Widget _buildPlaceholderThumbnail() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: EsquemaColor.lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.eco,
        size: 35,
        color: EsquemaColor.primaryGreen,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _confirmDelete(
    BuildContext context,
    DiagnosticModel diagnostic,
    DiagnosticsViewModel diagnosticsVm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar diagnóstico'),
        content: Text(
          '¿Estás seguro de eliminar el diagnóstico de ${diagnostic.plantName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (diagnostic.id != null) {
                final deleted = await diagnosticsVm.deleteDiagnostic(diagnostic.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        deleted
                            ? 'Diagnóstico eliminado'
                            : 'Error al eliminar',
                      ),
                      backgroundColor: deleted
                          ? EsquemaColor.healthyGreen
                          : EsquemaColor.diseaseRed,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showDiagnosticDetail(BuildContext context, DiagnosticModel diagnostic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Imagen completa
                    if ((diagnostic.imageBase64 != null &&
                            diagnostic.imageBase64!.isNotEmpty) ||
                        (diagnostic.imageUrl != null &&
                            diagnostic.imageUrl!.isNotEmpty))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildFullImage(diagnostic),
                      ),
                    const SizedBox(height: 24),
                    
                    // Título
                    Text(
                      diagnostic.plantName,
                      style: Tipografia.titulo1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: EsquemaColor.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Estado
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: diagnostic.diseaseName.toLowerCase().contains('healthy')
                            ? EsquemaColor.healthyGreen.withOpacity(0.1)
                            : EsquemaColor.diseaseRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        diagnostic.diseaseName,
                        style: Tipografia.subtitulo.copyWith(
                          color: diagnostic.diseaseName.toLowerCase().contains('healthy')
                              ? EsquemaColor.healthyGreen
                              : EsquemaColor.diseaseRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Confianza
                    if (diagnostic.confidence != null) ...[
                      Text(
                        'Confianza: ${(diagnostic.confidence! * 100).toStringAsFixed(2)}%',
                        style: Tipografia.cuerpo,
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Fecha
                    if (diagnostic.createdAt != null)
                      Text(
                        'Fecha: ${_formatDate(diagnostic.createdAt!)}',
                        style: Tipografia.caption.copyWith(
                          color: EsquemaColor.textSecondary,
                        ),
                      ),
                    
                    // Tratamiento
                    if (diagnostic.treatment != null &&
                        diagnostic.treatment!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Tratamiento Recomendado',
                        style: Tipografia.titulo3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: EsquemaColor.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          diagnostic.treatment!,
                          style: Tipografia.cuerpo,
                        ),
                      ),
                    ],
                    
                    // Botón para ver historial de chat
                    if (diagnostic.id != null) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showChatHistory(context, diagnostic.id!),
                          icon: const Icon(Icons.chat),
                          label: const Text('Ver Historial de Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: EsquemaColor.darkGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullImage(DiagnosticModel diagnostic) {
    if (diagnostic.imageBase64 != null && diagnostic.imageBase64!.isNotEmpty) {
      try {
        final bytes = _decodeImageBase64(diagnostic.imageBase64!);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        );
      } catch (e) {
        return _buildPlaceholderImage();
      }
    }
    if (diagnostic.imageUrl != null && diagnostic.imageUrl!.isNotEmpty) {
      return Image.network(
        diagnostic.imageUrl!,
        width: double.infinity,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  dynamic _decodeImageBase64(String value) {
    final normalized = value
        .replaceFirst(RegExp(r'^data:image/[^;]+;base64,'), '')
        .replaceAll(RegExp(r'\s'), '');
    return base64Decode(normalized);
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: EsquemaColor.lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.image_not_supported,
        size: 80,
        color: EsquemaColor.primaryGreen,
      ),
    );
  }

  Future<void> _showChatHistory(BuildContext context, String diagnosticId) async {
    final diagnosticsVm = Provider.of<DiagnosticsViewModel>(context, listen: false);
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final messages = await diagnosticsVm.getChatHistory(diagnosticId);
    
    if (!context.mounted) return;
    
    // Cerrar loading
    Navigator.pop(context);

    if (messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay historial de chat para este diagnóstico'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mostrar chat en un bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat,
                      color: EsquemaColor.primaryGreen,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Historial de Chat',
                      style: Tipografia.titulo2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Messages
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildChatMessage(message);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessageModel message) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? EsquemaColor.primaryGreen
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: Tipografia.cuerpo.copyWith(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
