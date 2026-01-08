# 🌿 SymptoLeaf

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![ONNX](https://img.shields.io/badge/ONNX-Runtime-005CED?style=for-the-badge&logo=onnx&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Aplicación móvil inteligente para la detección de enfermedades en plantas usando Machine Learning**

[Características](#-características) •
[Tecnologías](#-tecnologías) •
[Instalación](#-instalación) •
[Uso](#-uso) •
[Arquitectura](#-arquitectura)

</div>

---

## 📱 Descripción

**SymptoLeaf** es una aplicación Flutter que utiliza inteligencia artificial para identificar enfermedades en plantas a través del análisis de imágenes. Simplemente toma una foto de la hoja afectada y obtén un diagnóstico instantáneo directamente en tu dispositivo, sin necesidad de conexión a internet.

## ✨ Características

- 🔍 **Detección en tiempo real** - Análisis instantáneo de enfermedades en plantas
- 📷 **Captura de cámara** - Toma fotos directamente desde la app
- 🖼️ **Galería de imágenes** - Analiza fotos existentes de tu dispositivo
- 🤖 **ML On-Device** - Inferencia local usando ONNX Runtime (sin internet)
- 🎨 **UI Moderna** - Interfaz limpia e intuitiva con animaciones Lottie
- 📊 **Resultados detallados** - Información sobre la enfermedad detectada

## 🛠️ Tecnologías

| Categoría | Tecnología |
|-----------|------------|
| **Framework** | Flutter 3.9+ |
| **Lenguaje** | Dart |
| **ML Runtime** | ONNX Runtime |
| **Estado** | Provider |
| **Cámara** | camera, image_picker |
| **Almacenamiento** | shared_preferences |
| **Animaciones** | Lottie |

## 📁 Arquitectura

El proyecto sigue los principios de **Clean Architecture**:

```
lib/
├── config/          # Configuración de la app
├── data/            # Capa de datos (repositorios, modelos)
├── domain/          # Capa de dominio (entidades, casos de uso)
├── presentation/    # Capa de presentación (UI, widgets)
└── main.dart        # Punto de entrada
```

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK 3.9+
- Android Studio / VS Code
- Dispositivo Android (API 21+) o iOS

### Pasos

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/AMVMesias/SymptoLeaf.git
   cd SymptoLeaf
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📖 Uso

1. **Abre la aplicación** en tu dispositivo
2. **Selecciona una opción**:
   - 📷 Tomar foto con la cámara
   - 🖼️ Seleccionar imagen de la galería
3. **Espera el análisis** - El modelo procesará la imagen
4. **Revisa el resultado** - Obtén el diagnóstico de la enfermedad

## 🧠 Modelo de Machine Learning

- **Arquitectura**: ResNet50
- **Formato**: ONNX
- **Dataset**: PlantVillage
- **Clases**: Múltiples enfermedades de plantas

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**AMVMesias**

- GitHub: [@AMVMesias](https://github.com/AMVMesias)

---

<div align="center">

Hecho con 💚 y Flutter

</div>
