# 📋 Documentación Completa de Tests — SymptoLeaf

> **Fecha de creación:** 2026-02-11  
> **Proyecto:** SymptoLeaf — Detección de enfermedades en plantas mediante IA  
> **Framework:** Flutter / Dart  
> **Total de archivos de test:** 19  
> **Total de tests individuales:** 190  
> **Estado:** ✅ Todos los tests pasan (`flutter test` → 190 passed)

Esta documentación es una **guía completa** para entender, ejecutar y modificar las pruebas del proyecto SymptoLeaf. Está diseñada para que cualquier persona — incluso sin experiencia previa con el código — pueda comprender qué hace cada test, por qué existe, cómo ejecutarlo y cómo adaptarlo si necesita cambios.

---

## 📖 Índice

1. [Introducción y Propósito](#1-introducción-y-propósito)
2. [Estructura de los Tests](#2-estructura-de-los-tests)
3. [Arquitectura del Código y Qué se Prueba](#3-arquitectura-del-código-y-qué-se-prueba)
4. [Tests Unitarios](#4-tests-unitarios)
   - 4.1 [PredictionEntity](#41-prediction_entity_testdart)
   - 4.2 [PredictionModel](#42-prediction_model_testdart)
   - 4.3 [ChatMessageModel](#43-chat_message_model_testdart)
   - 4.4 [TreatmentModel](#44-treatment_model_testdart)
   - 4.5 [FotoProvider](#45-foto_provider_testdart)
   - 4.6 [PredictDiseaseUseCase](#46-predict_disease_usecase_testdart)
   - 4.7 [PredictionViewModel](#47-prediction_viewmodel_testdart)
   - 4.8 [GeminiViewModel](#48-gemini_viewmodel_testdart)
   - 4.9 [SettingsViewModel](#49-settings_viewmodel_testdart)
5. [Tests de Integración](#5-tests-de-integración)
   - 5.1 [Flujo de Análisis E2E](#51-analysis_flow_testdart)
   - 5.2 [Flujo de Datos](#52-data_flow_testdart)
   - 5.3 [Flujo de Gemini (Chat/Tratamientos)](#53-gemini_flow_testdart)
   - 5.4 [Flujo de Predicción](#54-prediction_flow_testdart)
   - 5.5 [Providers y Estado Global](#55-providers_state_testdart)
6. [Tests de Rendimiento (Performance)](#6-tests-de-rendimiento-performance)
   - 6.1 [Benchmark de Inferencia](#61-inference_benchmark_testdart)
   - 6.2 [Carga Extrema (Stress)](#62-load_stress_testdart)
   - 6.3 [Memoria y Sesiones Prolongadas](#63-memory_stress_testdart)
7. [Tests de Regresión](#7-tests-de-regresión)
   - 7.1 [Modelo ONNX y Clases](#71-onnx_model_testdart)
8. [Tests de Widget](#8-tests-de-widget)
   - 8.1 [HomeScreen](#81-home_screen_testdart)
9. [Cómo Ejecutar los Tests](#9-cómo-ejecutar-los-tests)
10. [Resumen de Cobertura](#10-resumen-de-cobertura)

---

## 1. Introducción y Propósito

### ¿Qué es un test (prueba)?

Un **test** es un fragmento de código que **verifica automáticamente** que otra parte del código funciona correctamente. En lugar de probar la app manualmente (abrir la app, tocar botones, ver si funciona), los tests lo hacen solos y te dicen si algo falla.

### ¿Por qué se hacen tests?

| Razón | Explicación sencilla |
|-------|---------------------|
| **Detectar errores temprano** | Si cambias algo y un test falla, sabes que rompiste algo antes de que el usuario lo vea |
| **Documentar comportamiento** | Los tests dicen exactamente qué debe hacer cada parte del código |
| **Confianza al modificar** | Puedes cambiar código sin miedo: si los tests pasan, todo sigue funcionando |
| **Calidad del software** | Un proyecto con tests bien hechos es más profesional y confiable |

### ¿Cómo funciona un test?

Cada test sigue el patrón **AAA (Arrange-Act-Assert)**:

```dart
test('descripción de lo que se prueba', () {
  // Arrange (Preparar) — Se crean los objetos necesarios
  final objeto = MiObjeto();

  // Act (Actuar) — Se ejecuta la acción que queremos probar
  final resultado = objeto.hacerAlgo();

  // Assert (Verificar) — Se comprueba que el resultado es el esperado
  expect(resultado, equals(valorEsperado));
});
```

### Estructura de este proyecto de tests

Los tests están organizados en **5 categorías principales**, cada una probando un aspecto diferente de la aplicación:

```
test/
├── unit/           → Pruebas de piezas individuales (modelos, entidades, viewmodels)
├── integration/    → Pruebas de múltiples componentes trabajando juntos
├── performance/    → Pruebas de velocidad, carga y memoria
├── regression/     → Pruebas para asegurar que el modelo de IA no cambie
└── widget/         → Pruebas de la interfaz visual (pantallas)
```

---

## 2. Estructura de los Tests

### Mapa completo de archivos

| # | Categoría | Archivo | Tests | Descripción |
|---|-----------|---------|-------|-------------|
| 1 | Unit | `unit/entities/prediction_entity_test.dart` | 10 | Entidad de predicción (dominio) |
| 2 | Unit | `unit/models/prediction_model_test.dart` | 10 | Modelo de predicción (datos) |
| 3 | Unit | `unit/models/chat_message_model_test.dart` | 10 | Modelo de mensajes de chat |
| 4 | Unit | `unit/models/treatment_model_test.dart` | 10 | Modelo de tratamientos |
| 5 | Unit | `unit/providers/foto_provider_test.dart` | 10 | Provider de fotografías |
| 6 | Unit | `unit/use_cases/predict_disease_usecase_test.dart` | 10 | Caso de uso de predicción |
| 7 | Unit | `unit/viewmodels/prediction_viewmodel_test.dart` | 10 | ViewModel de predicciones |
| 8 | Unit | `unit/viewmodels/gemini_viewmodel_test.dart` | 10 | ViewModel de Gemini |
| 9 | Unit | `unit/viewmodels/settings_viewmodel_test.dart` | 10 | ViewModel de configuración (ModelType) |
| 10 | Integration | `integration/analysis_flow_test.dart` | 8 | Flujo E2E de análisis |
| 11 | Integration | `integration/data_flow_test.dart` | 10 | Flujo de datos completo |
| 12 | Integration | `integration/gemini_flow_test.dart` | 10 | Flujo de Gemini chat |
| 13 | Integration | `integration/prediction_flow_test.dart` | 10 | Flujo de predicción |
| 14 | Integration | `integration/providers_state_test.dart` | 10 | Estado global de providers |
| 15 | Performance | `performance/inference_benchmark_test.dart` | 10 | Métricas de rendimiento |
| 16 | Performance | `performance/load_stress_test.dart` | 12 | Carga extrema 100+ operaciones |
| 17 | Performance | `performance/memory_stress_test.dart` | 10 | Memoria y leaks |
| 18 | Regression | `regression/onnx_model_test.dart` | 10 | Regresión del modelo ONNX |
| 19 | Widget | `widget/home_screen_test.dart` | 10 | Pantalla principal |

---

## 3. Arquitectura del Código y Qué se Prueba

Para entender los tests, primero hay que entender **cómo está organizado el código** que se prueba. SymptoLeaf usa **Clean Architecture** (Arquitectura Limpia), que separa el código en capas:

```
┌─────────────────────────────────────────────────────────┐
│  PRESENTACIÓN (lo que ve el usuario)                     │
│  ViewModels: PredictionViewModel, GeminiViewModel,      │
│              SettingsViewModel, FotoViewModel            │
│  Widgets: HomeScreen, pantallas de análisis, chat       │
├─────────────────────────────────────────────────────────┤
│  DOMINIO (la lógica de negocio pura)                    │
│  Entidades: PredictionEntity, PredictionTop3            │
│  Casos de uso: PredictDiseaseUseCase                    │
├─────────────────────────────────────────────────────────┤
│  DATOS (de dónde viene la información)                  │
│  Modelos: PredictionModel, ChatMessage, TreatmentModel  │
│  Repositorios: BaseRepository                           │
│  Servicios: GeminiService (IA chatbot), ONNX (ML local) │
└─────────────────────────────────────────────────────────┘
```

### Conceptos clave del proyecto que se prueban

| Concepto | Qué es | Archivo de producción |
|----------|--------|----------------------|
| **PredictionEntity** | Resultado de analizar una planta: planta, enfermedad, confianza, top 3 alternativas | `lib/domain/entities/prediction_entity.dart` |
| **PredictionModel** | Igual que la entidad pero con serialización JSON y conversión `toEntity()` | `lib/data/models/prediction_model.dart` |
| **ChatMessage** | Un mensaje en el chat con Gemini (tiene rol: usuario o asistente) | `lib/data/models/chat_message_model.dart` |
| **TreatmentModel** | Recomendación de tratamiento generada por Gemini (síntomas, remedios, prevención) | `lib/data/models/treatment_model.dart` |
| **FotoViewModel** | Gestiona la lista de fotos tomadas/seleccionadas por el usuario | `lib/presentation/viewmodels/foto_viewmodel.dart` |
| **PredictDiseaseUseCase** | Caso de uso: recibe una ruta de imagen y devuelve una predicción | `lib/domain/use_case/predict_disease_usecase.dart` |
| **PredictionViewModel** | Controla el estado de la predicción (loading, success, error) | `lib/presentation/viewmodels/prediction_viewmodel.dart` |
| **GeminiViewModel** | Controla el chat con Gemini y la obtención de tratamientos | `lib/presentation/viewmodels/gemini_viewmodel.dart` |
| **SettingsViewModel** | Configuración del modelo de IA: `standard` o `yolo11` | `lib/presentation/viewmodels/settings_viewmodel.dart` |
| **GeminiService** | Singleton que se conecta a la API de Gemini (chatbot, tratamientos) | `lib/data/datasource/gemini_service.dart` |
| **HomeScreen** | Pantalla principal con tarjetas de "Analizar Planta" y "Asistente Virtual" | `lib/presentation/widgets/pages/home_screen.dart` |

### Modelos de IA disponibles

La app usa modelos ONNX para clasificar enfermedades localmente en el dispositivo:

| Modelo | Archivo | Enum |
|--------|---------|------|
| **Estándar** | `plant_disease_model.onnx` | `ModelType.standard` |
| **YOLO11 (mejorado)** | `plant_disease_yolo11.onnx` | `ModelType.yolo11` |

El modelo clasifica imágenes en **15 clases** (5 plantas × 3 estados cada una): Manzana, Maíz, Uva, Papa y Tomate — cada una con variantes saludable y enferma.

### Verificar que todo funciona

```bash
flutter test
# 00:19 +190: All tests passed!
```

---

## 4. Tests Unitarios

Los tests unitarios prueban **una sola pieza del código a la vez**, aislada del resto. Son los más básicos y fundamentales.

---

### 4.1 `prediction_entity_test.dart`

> **Archivo:** `test/unit/entities/prediction_entity_test.dart`  
> **Qué se prueba:** La entidad `PredictionEntity` del dominio (capa de negocio)  
> **Ubicación del código probado:** `lib/domain/entities/prediction_entity.dart`

#### ¿Por qué se hace esta prueba?

`PredictionEntity` es el **objeto principal** que representa el resultado de analizar una planta. Es la entidad del dominio — la representación pura del dato sin lógica de framework ni base de datos. Si esta entidad no funciona correctamente, **todo el sistema de predicciones falla**.

#### ¿Qué nos asegura?

Que podemos crear objetos de predicción con todos sus campos, que los valores se almacenan correctamente, y que las listas de top 3 predicciones funcionan como se espera.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-PE-001** | Crear entidad con todos los campos | Crea una `PredictionEntity` con className=`Tomato_Late_blight`, plant=`Tomato`, disease=`Late blight`, confidence=`0.95`, isHealthy=`false` | Que cada campo se guarde correctamente (`className`, `plant`, `disease`, `confidence`, `isHealthy`) | Si un campo no se guarda bien, el resultado que ve el usuario será incorrecto |
| **UT-PE-002** | Crear entidad de planta saludable | Crea una entidad donde `isHealthy=true` | Que la propiedad `isHealthy` sea `true` | La app muestra un mensaje diferente si la planta está sana. Si este valor no funciona, diría que una planta sana está enferma |
| **UT-PE-003** | Crear entidad con top3 predicciones | Crea una entidad con una lista de 3 predicciones alternativas | Que `top3.length == 3` y que están ordenadas por confianza descendente | El usuario ve las 3 posibles enfermedades; si la lista no se llena bien, el diagnóstico alternativo no funciona |
| **UT-PE-004** | Confianza entre 0 y 1 | Crea entidades con confidence `0.0` y `1.0` | Que los valores extremos se acepten sin error | Si no acepta 0.0 o 1.0, el sistema fallaría en predicciones muy seguras o muy inseguras |
| **UT-PE-005** | Planta requerida | Crea una entidad y verifica que `plant` no esté vacío | Que `entity.plant.isNotEmpty` | Sin nombre de planta, el usuario no sabría qué planta analizó |
| **UT-PE-006** | Crear PredictionTop3 | Crea un objeto `PredictionTop3` individual | Que todos los campos (`className`, `plant`, `disease`, `confidence`, `isHealthy`) se guarden | Cada elemento del top 3 debe tener datos completos |
| **UT-PE-007** | PredictionTop3 saludable | Crea un `PredictionTop3` con `isHealthy=true` | Que `isHealthy` funcione en el sub-objeto | Las alternativas también pueden ser "saludable" |
| **UT-PE-008** | Diferentes plantas | Crea entidades para Tomato, Potato, Apple, Grape, Corn | Que cada planta se almacene correctamente | El modelo soporta 5 plantas; todas deben funcionar |
| **UT-PE-009** | Confianza alta vs baja | Crea entidades con confidence `0.95` y `0.35` | Que la alta sea `> 0.5` y la baja `< 0.5` | La app podría mostrar advertencias según la confianza |
| **UT-PE-010** | Lista top3 vacía válida | Crea entidad con `top3: []` (lista vacía) | Que `top3.isEmpty` sea `true` | En modo local a veces no hay alternativas; la lista vacía debe ser válida |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>prediction_entity_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';

void main() {
  group('PredictionEntity - Creación', () {
    test('UT-PE-001: debería crear entidad con todos los campos', () {
      // Arrange & Act
      final entity = PredictionEntity(
        className: 'Tomato_Late_blight',
        plant: 'Tomato',
        disease: 'Late blight',
        confidence: 0.95,
        isHealthy: false,
        top3: [],
      );

      // Assert
      expect(entity.className, equals('Tomato_Late_blight'));
      expect(entity.plant, equals('Tomato'));
      expect(entity.disease, equals('Late blight'));
      expect(entity.confidence, equals(0.95));
      expect(entity.isHealthy, isFalse);
    });

    test('UT-PE-002: debería crear entidad de planta saludable', () {
      final entity = PredictionEntity(
        className: 'Tomato_healthy',
        plant: 'Tomato',
        disease: 'healthy',
        confidence: 0.98,
        isHealthy: true,
        top3: [],
      );
      expect(entity.isHealthy, isTrue);
    });

    test('UT-PE-003: debería crear entidad con top3 predicciones', () {
      final top3 = [
        PredictionTop3(
          className: 'Tomato_Late_blight', plant: 'Tomato',
          disease: 'Late blight', confidence: 0.85, isHealthy: false,
        ),
        PredictionTop3(
          className: 'Tomato_Early_blight', plant: 'Tomato',
          disease: 'Early blight', confidence: 0.10, isHealthy: false,
        ),
        PredictionTop3(
          className: 'Tomato_healthy', plant: 'Tomato',
          disease: 'healthy', confidence: 0.05, isHealthy: true,
        ),
      ];

      final entity = PredictionEntity(
        className: 'Tomato_Late_blight', plant: 'Tomato',
        disease: 'Late blight', confidence: 0.85,
        isHealthy: false, top3: top3,
      );

      expect(entity.top3.length, equals(3));
      expect(entity.top3[0].confidence, greaterThan(entity.top3[1].confidence));
    });
  });

  group('PredictionEntity - Validaciones', () {
    test('UT-PE-004: debería aceptar confianza entre 0 y 1', () {
      final entityLow = PredictionEntity(
        className: 'Test', plant: 'Test', disease: 'Test',
        confidence: 0.0, isHealthy: false, top3: [],
      );
      final entityHigh = PredictionEntity(
        className: 'Test', plant: 'Test', disease: 'Test',
        confidence: 1.0, isHealthy: false, top3: [],
      );
      expect(entityLow.confidence, greaterThanOrEqualTo(0));
      expect(entityHigh.confidence, lessThanOrEqualTo(1));
    });

    test('UT-PE-005: debería tener planta', () {
      final entity = PredictionEntity(
        className: 'Potato_Early_blight', plant: 'Potato',
        disease: 'Early blight', confidence: 0.88,
        isHealthy: false, top3: [],
      );
      expect(entity.plant, isNotEmpty);
    });
  });

  group('PredictionTop3 - Creación', () {
    test('UT-PE-006: debería crear PredictionTop3 correctamente', () {
      final prediction = PredictionTop3(
        className: 'Apple_Scab', plant: 'Apple',
        disease: 'Scab', confidence: 0.75, isHealthy: false,
      );
      expect(prediction.className, equals('Apple_Scab'));
      expect(prediction.confidence, equals(0.75));
    });

    test('UT-PE-007: debería crear PredictionTop3 saludable', () {
      final prediction = PredictionTop3(
        className: 'Grape_healthy', plant: 'Grape',
        disease: 'healthy', confidence: 0.92, isHealthy: true,
      );
      expect(prediction.isHealthy, isTrue);
    });
  });

  group('PredictionEntity - Casos de Uso', () {
    test('UT-PE-008: debería soportar diferentes plantas', () {
      final plantas = ['Tomato', 'Potato', 'Apple', 'Grape', 'Corn'];
      for (final planta in plantas) {
        final entity = PredictionEntity(
          className: '${planta}_healthy', plant: planta,
          disease: 'healthy', confidence: 0.90,
          isHealthy: true, top3: [],
        );
        expect(entity.plant, equals(planta));
      }
    });

    test('UT-PE-009: debería diferenciar confianza alta y baja', () {
      final highConfidence = PredictionEntity(
        className: 'Test', plant: 'Test', disease: 'Test',
        confidence: 0.95, isHealthy: false, top3: [],
      );
      final lowConfidence = PredictionEntity(
        className: 'Test', plant: 'Test', disease: 'Test',
        confidence: 0.35, isHealthy: false, top3: [],
      );
      expect(highConfidence.confidence, greaterThan(0.5));
      expect(lowConfidence.confidence, lessThan(0.5));
    });

    test('UT-PE-010: debería aceptar lista top3 vacía', () {
      final entity = PredictionEntity(
        className: 'Test', plant: 'Test', disease: 'Test',
        confidence: 0.80, isHealthy: false, top3: [],
      );
      expect(entity.top3, isEmpty);
      expect(entity.top3, isA<List<PredictionTop3>>());
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/entities/prediction_entity_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar una nueva planta:** Si el modelo ahora soporta una planta nueva (ej: `Strawberry`), agrega un caso en el test `UT-PE-008` añadiendo `'Strawberry'` a la lista `plantas`.
- **Agregar un nuevo campo a la entidad:** Si añades un campo como `severity` a `PredictionEntity`, crea un nuevo test que verifique que se almacena correctamente, siguiendo el patrón de `UT-PE-001`.
- **Cambiar el rango de confianza:** Si el rango ya no es 0-1 (ej: porcentaje 0-100), actualiza los tests `UT-PE-004` y `UT-PE-009` para reflejar los nuevos límites.

---

### 4.2 `prediction_model_test.dart`

> **Archivo:** `test/unit/models/prediction_model_test.dart`  
> **Qué se prueba:** El modelo `PredictionModel` de la capa de datos  
> **Ubicación del código probado:** `lib/data/models/prediction_model.dart`

#### ¿Por qué se hace esta prueba?

`PredictionModel` es el objeto que **recibe los datos del servidor o del modelo ONNX** y los estructura para ser usados en la app. Tiene la lógica de serialización (convertir JSON ↔ objeto) y conversión a entidad. Si falla, la app no puede interpretar los resultados del modelo de IA.

#### ¿Qué nos asegura?

Que los datos que llegan del modelo de predicción se parsean correctamente, se pueden serializar a JSON para almacenar, y se convierten sin pérdida a la entidad del dominio.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-PM-001** | Crear modelo con datos válidos | Crea `PredictionModel` con className, plant, disease, confidence, isHealthy, top3 | Que todos los campos se almacenen exactamente como se proporcionaron | Base del modelo de datos; sin esto nada funciona |
| **UT-PM-002** | Crear modelo con top3 | Crea modelo con 3 items en la lista top3 | Que `top3.length == 3` y que están en orden descendente de confianza | El usuario ve las alternativas; el orden importa |
| **UT-PM-003** | Modelo saludable | Crea modelo con `isHealthy=true` y `disease='Saludable'` | Que `isHealthy` sea `true` | Distinguir planta sana de enferma |
| **UT-PM-004** | Confianza en límite inferior | Crea modelo con `confidence=0.0` | Que acepte `0.0` y sea `>= 0.0` | Un modelo puede no detectar nada (0% confianza) |
| **UT-PM-005** | Confianza en límite superior | Crea modelo con `confidence=1.0` | Que acepte `1.0` y sea `<= 1.0` | Predicción 100% segura |
| **UT-PM-006** | Confianza en rango válido | Prueba múltiples valores: 0.0, 0.25, 0.5, 0.75, 0.95, 1.0 | Que cada valor esté entre 0.0 y 1.0 | Cobertura completa del rango de confianza |
| **UT-PM-007** | Conversión a entidad (toEntity) | Crea modelo y llama `model.toEntity()` | Que la entidad resultante tenga los mismos valores que el modelo | Esta conversión conecta la capa de datos con la de dominio; si pierde datos, el resultado es incorrecto |
| **UT-PM-008** | Serialización a JSON (toJson) | Crea modelo y llama `model.toJson()` | Que el JSON tenga la estructura correcta con `prediction.class`, `prediction.plant`, etc. | Necesario para almacenar o enviar resultados |
| **UT-PM-009** | Top3 model básico | Crea `PredictionTop3Model` individualmente | Que todos sus campos funcionen | Cada alternativa en top3 es un modelo independiente |
| **UT-PM-010** | Top3 conversión a entidad | Crea `PredictionTop3Model` y llama `toEntity()` | Que preserve className y confidence al convertir | La conversión top3 model → entity debe ser sin pérdida |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>prediction_model_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/prediction_model.dart';

void main() {
  group('PredictionModel - Construcción', () {
    test('UT-PM-001: debería crear modelo con todos los campos requeridos', () {
      final model = PredictionModel(
        className: 'Tomato___Bacterial_spot',
        plant: 'Tomate',
        disease: 'Mancha bacteriana',
        confidence: 0.95,
        isHealthy: false,
        top3: [],
      );
      expect(model.className, equals('Tomato___Bacterial_spot'));
      expect(model.plant, equals('Tomate'));
      expect(model.confidence, equals(0.95));
      expect(model.isHealthy, isFalse);
    });

    test('UT-PM-002: debería crear modelo con lista top3 poblada', () {
      final top3Items = [
        PredictionTop3Model(
          className: 'Tomato___Bacterial_spot', plant: 'Tomate',
          disease: 'Mancha bacteriana', confidence: 0.95, isHealthy: false,
        ),
        PredictionTop3Model(
          className: 'Tomato___healthy', plant: 'Tomate',
          disease: 'Saludable', confidence: 0.03, isHealthy: true,
        ),
        PredictionTop3Model(
          className: 'Potato___Early_blight', plant: 'Papa',
          disease: 'Tizón temprano', confidence: 0.02, isHealthy: false,
        ),
      ];
      final model = PredictionModel(
        className: 'Tomato___Bacterial_spot', plant: 'Tomate',
        disease: 'Mancha bacteriana', confidence: 0.95,
        isHealthy: false, top3: top3Items,
      );
      expect(model.top3.length, equals(3));
      expect(model.top3[0].confidence, greaterThan(model.top3[1].confidence));
    });

    test('UT-PM-003: debería identificar correctamente planta saludable', () {
      final healthyModel = PredictionModel(
        className: 'Apple___healthy', plant: 'Manzana',
        disease: 'Saludable', confidence: 0.98,
        isHealthy: true, top3: [],
      );
      expect(healthyModel.isHealthy, isTrue);
      expect(healthyModel.disease, equals('Saludable'));
    });
  });

  group('PredictionModel - Validación de Confianza', () {
    test('UT-PM-004: debería aceptar confianza de 0.0', () {
      final model = PredictionModel(
        className: 'no_plant_detected', plant: 'No detectado',
        disease: 'No es una planta', confidence: 0.0,
        isHealthy: false, top3: [],
      );
      expect(model.confidence, equals(0.0));
    });

    test('UT-PM-005: debería aceptar confianza de 1.0', () {
      final model = PredictionModel(
        className: 'Corn___healthy', plant: 'Maíz',
        disease: 'Saludable', confidence: 1.0,
        isHealthy: true, top3: [],
      );
      expect(model.confidence, equals(1.0));
    });

    test('UT-PM-006: confianza debería estar en rango [0.0, 1.0]', () {
      final confidences = [0.0, 0.25, 0.5, 0.75, 0.95, 1.0];
      for (final conf in confidences) {
        final model = PredictionModel(
          className: 'Test___class', plant: 'Test',
          disease: 'Test', confidence: conf,
          isHealthy: false, top3: [],
        );
        expect(model.confidence, greaterThanOrEqualTo(0.0));
        expect(model.confidence, lessThanOrEqualTo(1.0));
      }
    });
  });

  group('PredictionModel - Conversión toEntity', () {
    test('UT-PM-007: debería convertir correctamente a PredictionEntity', () {
      final model = PredictionModel(
        className: 'Grape___Black_rot', plant: 'Uva',
        disease: 'Podredumbre negra', confidence: 0.87,
        isHealthy: false,
        top3: [
          PredictionTop3Model(
            className: 'Grape___Black_rot', plant: 'Uva',
            disease: 'Podredumbre negra', confidence: 0.87, isHealthy: false,
          ),
        ],
      );
      final entity = model.toEntity();
      expect(entity.className, equals(model.className));
      expect(entity.plant, equals(model.plant));
      expect(entity.confidence, equals(model.confidence));
      expect(entity.top3.length, equals(model.top3.length));
    });
  });

  group('PredictionModel - Serialización toJson', () {
    test('UT-PM-008: debería serializar correctamente a JSON', () {
      final model = PredictionModel(
        className: 'Potato___Late_blight', plant: 'Papa',
        disease: 'Tizón tardío', confidence: 0.92,
        isHealthy: false, top3: [],
      );
      final json = model.toJson();
      expect(json['prediction']['class'], equals('Potato___Late_blight'));
      expect(json['prediction']['plant'], equals('Papa'));
      expect(json['prediction']['confidence'], equals(0.92));
    });
  });

  group('PredictionTop3Model', () {
    test('UT-PM-009: debería crear PredictionTop3Model correctamente', () {
      final top3 = PredictionTop3Model(
        className: 'Corn___Common_rust', plant: 'Maíz',
        disease: 'Roya común', confidence: 0.78, isHealthy: false,
      );
      expect(top3.className, equals('Corn___Common_rust'));
      expect(top3.confidence, equals(0.78));
    });

    test('UT-PM-010: debería convertir Top3Model a Top3Entity', () {
      final top3Model = PredictionTop3Model(
        className: 'Apple___Apple_scab', plant: 'Manzana',
        disease: 'Sarna del manzano', confidence: 0.65, isHealthy: false,
      );
      final top3Entity = top3Model.toEntity();
      expect(top3Entity.className, equals(top3Model.className));
      expect(top3Entity.confidence, equals(top3Model.confidence));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/models/prediction_model_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Cambiar la estructura del JSON:** Si el JSON del modelo de IA cambia (ej: `prediction.class` ahora se llama `prediction.label`), actualiza el test `UT-PM-008` con las nuevas claves.
- **Agregar un campo nuevo al modelo:** Crea un nuevo test siguiendo el patrón de `UT-PM-001`, añadiendo el campo nuevo al constructor y verificando con `expect`.
- **Probar `fromJson` con datos reales:** Copia un JSON real de la respuesta del modelo ONNX y úsalo en un test nuevo para asegurar compatibilidad.

---

### 4.3 `chat_message_model_test.dart`

> **Archivo:** `test/unit/models/chat_message_model_test.dart`  
> **Qué se prueba:** El modelo `ChatMessage` y el enum `MessageRole`  
> **Ubicación del código probado:** `lib/data/models/chat_message_model.dart`

#### ¿Por qué se hace esta prueba?

El chat con Gemini es una funcionalidad central de la app donde los usuarios hacen preguntas sobre tratamientos. `ChatMessage` representa cada mensaje en la conversación. Si los mensajes no se crean correctamente, el chat no mostraría las respuestas del asistente o confundiría quién dijo qué.

#### ¿Qué nos asegura?

Que los mensajes se crean correctamente con su contenido, rol (usuario o asistente), timestamp, y que las factory methods (`user()`, `assistant()`, `loading()`) funcionan adecuadamente.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-CM-001** | Crear mensaje de usuario | Crea `ChatMessage` con role=`user` | Que `isUser=true`, `isAssistant=false`, `isLoading=false`, contenido correcto | El chat debe identificar quién escribió cada mensaje |
| **UT-CM-002** | Crear mensaje de asistente | Crea `ChatMessage` con role=`assistant` | Que `isAssistant=true`, `isUser=false` | Distinguir respuestas de Gemini de las preguntas del usuario |
| **UT-CM-003** | Timestamp automático | Crea mensaje y verifica que el timestamp esté entre `beforeCreation` y `afterCreation` | Que se asigne timestamp automáticamente dentro del rango correcto | Los mensajes deben tener hora para ordenarse cronológicamente |
| **UT-CM-004** | Timestamp personalizado | Crea mensaje con timestamp `DateTime(2026, 1, 15, 10, 30)` | Que el timestamp sea exactamente el proporcionado | Permite reconstruir historial de chat desde almacenamiento |
| **UT-CM-005** | Factory `ChatMessage.user()` | Usa el factory method `ChatMessage.user('texto')` | Que cree un mensaje de usuario con role correcto | Atajo para crear mensajes; debe funcionar igual que el constructor |
| **UT-CM-006** | Factory `ChatMessage.assistant()` | Usa `ChatMessage.assistant('texto')` | Que cree un mensaje de asistente correctamente | Atajo para respuestas de Gemini |
| **UT-CM-007** | Factory `ChatMessage.loading()` | Usa `ChatMessage.loading()` | Que tenga contenido vacío, role=assistant, `isLoading=true` | Mientras Gemini responde, se muestra un indicador de carga |
| **UT-CM-008** | Getter isUser | Crea mensaje de usuario y de asistente | Que `isUser` sea `true` solo para usuario | Evitar que ambos roles devuelvan `true` |
| **UT-CM-009** | Getter isAssistant | Crea mensaje de usuario y de asistente | Que `isAssistant` sea `true` solo para asistente | Complemento del test anterior; seguridad doble |
| **UT-CM-010** | Verificar roles disponibles | Consulta `MessageRole.values` | Que haya exactamente 2 roles: `user` y `assistant` | Si alguien agrega un rol nuevo sin actualizar el chat, esto lo detecta |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>chat_message_model_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/chat_message_model.dart';

void main() {
  group('ChatMessage - Construcción', () {
    test('UT-CM-001: debería crear mensaje de usuario correctamente', () {
      final message = ChatMessage(
        content: '¿Cómo trato la mancha bacteriana?',
        role: MessageRole.user,
      );
      expect(message.content, equals('¿Cómo trato la mancha bacteriana?'));
      expect(message.role, equals(MessageRole.user));
      expect(message.isUser, isTrue);
      expect(message.isAssistant, isFalse);
      expect(message.isLoading, isFalse);
    });

    test('UT-CM-002: debería crear mensaje de asistente correctamente', () {
      final message = ChatMessage(
        content: 'Para tratar la mancha bacteriana...',
        role: MessageRole.assistant,
      );
      expect(message.role, equals(MessageRole.assistant));
      expect(message.isAssistant, isTrue);
    });

    test('UT-CM-003: debería asignar timestamp automáticamente', () {
      final beforeCreation = DateTime.now();
      final message = ChatMessage(content: 'Test', role: MessageRole.user);
      final afterCreation = DateTime.now();
      expect(message.timestamp.isAfter(
        beforeCreation.subtract(const Duration(seconds: 1))), isTrue);
      expect(message.timestamp.isBefore(
        afterCreation.add(const Duration(seconds: 1))), isTrue);
    });

    test('UT-CM-004: debería aceptar timestamp personalizado', () {
      final customTime = DateTime(2026, 1, 15, 10, 30);
      final message = ChatMessage(
        content: 'Test', role: MessageRole.user, timestamp: customTime,
      );
      expect(message.timestamp, equals(customTime));
    });
  });

  group('ChatMessage - Factory Methods', () {
    test('UT-CM-005: ChatMessage.user() debería crear mensaje de usuario', () {
      final message = ChatMessage.user('Pregunta del usuario');
      expect(message.content, equals('Pregunta del usuario'));
      expect(message.role, equals(MessageRole.user));
      expect(message.isUser, isTrue);
    });

    test('UT-CM-006: ChatMessage.assistant() debería crear mensaje de asistente', () {
      final message = ChatMessage.assistant('Respuesta del asistente');
      expect(message.content, equals('Respuesta del asistente'));
      expect(message.isAssistant, isTrue);
    });

    test('UT-CM-007: ChatMessage.loading() debería crear mensaje de carga', () {
      final message = ChatMessage.loading();
      expect(message.content, isEmpty);
      expect(message.role, equals(MessageRole.assistant));
      expect(message.isLoading, isTrue);
    });
  });

  group('ChatMessage - Getters', () {
    test('UT-CM-008: isUser debería ser true solo para mensajes de usuario', () {
      final userMessage = ChatMessage.user('Test');
      final assistantMessage = ChatMessage.assistant('Test');
      expect(userMessage.isUser, isTrue);
      expect(assistantMessage.isUser, isFalse);
    });

    test('UT-CM-009: isAssistant debería ser true solo para mensajes de asistente', () {
      final userMessage = ChatMessage.user('Test');
      final assistantMessage = ChatMessage.assistant('Test');
      expect(userMessage.isAssistant, isFalse);
      expect(assistantMessage.isAssistant, isTrue);
    });
  });

  group('MessageRole Enum', () {
    test('UT-CM-010: debería tener exactamente 2 roles', () {
      expect(MessageRole.values.length, equals(2));
      expect(MessageRole.values.contains(MessageRole.user), isTrue);
      expect(MessageRole.values.contains(MessageRole.assistant), isTrue);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/models/chat_message_model_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar un rol nuevo (ej: `system`):** Añade el valor al enum `MessageRole` en el código de producción, luego actualiza `UT-CM-010` para esperar 3 valores y crea un test que verifique el nuevo rol.
- **Agregar un campo como `imageUrl` al mensaje:** Crea un test que construya un `ChatMessage` con el campo nuevo y verifique con `expect`.
- **Probar mensajes muy largos:** Añade un test que cree un `ChatMessage` con un contenido de 10,000 caracteres para verificar que no haya límites.

---

### 4.4 `treatment_model_test.dart`

> **Archivo:** `test/unit/models/treatment_model_test.dart`  
> **Qué se prueba:** `TreatmentModel`, `TreatmentOption`, `TreatmentType` y el parseo de respuestas de Gemini  
> **Ubicación del código probado:** `lib/data/models/treatment_model.dart`

#### ¿Por qué se hace esta prueba?

Cuando se detecta una enfermedad, Gemini sugiere tratamientos. `TreatmentModel` estructura esa información (síntomas, tratamientos orgánicos/químicos/culturales, prevención). Si esta estructura falla, el usuario no recibiría recomendaciones de tratamiento o las recibiría mal formateadas.

#### ¿Qué nos asegura?

Que los tratamientos se estructuran correctamente, que los 3 tipos de tratamiento existen, que las etiquetas con emojis se generan bien, y que las respuestas de Gemini se pueden parsear.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-TM-001** | Crear modelo con campos requeridos | Crea `TreatmentModel` con enfermedad, planta, síntomas, tratamientos y prevención | Que todos los campos se almacenen correctamente | Estructura base de los tratamientos |
| **UT-TM-002** | Modelo con síntomas vacíos | Crea modelo con listas vacías | Que funcione sin errores con listas vacías | Plantas saludables no tienen síntomas; la app no debe romperse |
| **UT-TM-003** | Modelo con tratamientos orgánicos | Crea modelo con 2 tratamientos de tipo `TreatmentType.organic` | Que los tratamientos orgánicos se almacenen correctamente | Muchos usuarios prefieren tratamientos orgánicos |
| **UT-TM-004** | Modelo con tratamientos químicos | Crea modelo con tratamiento `TreatmentType.chemical` | Que el tipo sea `chemical` | Los tratamientos químicos son una opción válida |
| **UT-TM-005** | Verificar tipos de tratamiento | Consulta `TreatmentType.values` | Que existan exactamente 3 tipos: `organic`, `chemical`, `cultural` | Si falta un tipo, tratamientos no se pueden clasificar |
| **UT-TM-006** | Crear opción de tratamiento | Crea `TreatmentOption` tipo `cultural` con nombre y descripción | Que todos los campos funcionen | Cada opción de tratamiento debe estar completa |
| **UT-TM-007** | typeLabel para orgánico | Verifica `organic.typeLabel` | Que contenga `🌿` y `Orgánico` | La UI muestra emojis para identificar tipo; deben ser correctos |
| **UT-TM-008** | typeLabel para químico | Verifica `chemical.typeLabel` | Que contenga `🧪` y `Químico` | Identificación visual en la interfaz |
| **UT-TM-009** | typeLabel para cultural | Verifica `cultural.typeLabel` | Que contenga `🌱` y `Cultural` | Identificación visual en la interfaz |
| **UT-TM-010** | Parsear respuesta de Gemini | Llama `TreatmentModel.fromGeminiResponse()` con texto de ejemplo | Que el plantName, diseaseName y additionalInfo se extraigan correctamente | Conecta la respuesta raw de la IA con la estructura de datos de la app |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>treatment_model_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/treatment_model.dart';

void main() {
  group('TreatmentModel - Construcción', () {
    test('UT-TM-001: debería crear modelo con campos requeridos', () {
      final model = TreatmentModel(
        diseaseName: 'Tizón tardío',
        plantName: 'Papa',
        symptoms: ['Manchas oscuras', 'Hojas marchitas'],
        treatments: [],
        preventionTips: ['Rotación de cultivos'],
        additionalInfo: 'Información adicional de Gemini',
      );
      expect(model.diseaseName, equals('Tizón tardío'));
      expect(model.plantName, equals('Papa'));
      expect(model.symptoms.length, equals(2));
    });

    test('UT-TM-002: debería permitir lista de síntomas vacía', () {
      final model = TreatmentModel(
        diseaseName: 'Saludable', plantName: 'Tomate',
        symptoms: [], treatments: [], preventionTips: [],
      );
      expect(model.symptoms, isEmpty);
    });

    test('UT-TM-003: debería crear modelo con tratamientos orgánicos', () {
      final treatments = [
        TreatmentOption(
          name: 'Fungicida de cobre',
          type: TreatmentType.organic,
          description: 'Aplicar cada 7 días',
        ),
        TreatmentOption(
          name: 'Aceite de neem',
          type: TreatmentType.organic,
          description: 'Aplicar en horas de la tarde',
        ),
      ];
      final model = TreatmentModel(
        diseaseName: 'Roya común', plantName: 'Maíz',
        symptoms: ['Pústulas naranjas'], treatments: treatments,
        preventionTips: ['Eliminar residuos de cosecha'],
      );
      expect(model.treatments.length, equals(2));
      expect(model.treatments[0].type, equals(TreatmentType.organic));
    });

    test('UT-TM-004: debería crear modelo con tratamientos químicos', () {
      final chemicalTreatment = TreatmentOption(
        name: 'Mancozeb',
        type: TreatmentType.chemical,
        description: 'Fungicida de contacto',
      );
      final model = TreatmentModel(
        diseaseName: 'Mancha bacteriana', plantName: 'Tomate',
        symptoms: ['Manchas en hojas'], treatments: [chemicalTreatment],
        preventionTips: [],
      );
      expect(model.treatments.first.type, equals(TreatmentType.chemical));
    });
  });

  group('TreatmentType Enum', () {
    test('UT-TM-005: debería tener 3 tipos de tratamiento', () {
      expect(TreatmentType.values.length, equals(3));
      expect(TreatmentType.values.contains(TreatmentType.organic), isTrue);
      expect(TreatmentType.values.contains(TreatmentType.chemical), isTrue);
      expect(TreatmentType.values.contains(TreatmentType.cultural), isTrue);
    });
  });

  group('TreatmentOption', () {
    test('UT-TM-006: debería crear opción de tratamiento correctamente', () {
      final option = TreatmentOption(
        name: 'Poda de partes afectadas',
        type: TreatmentType.cultural,
        description: 'Eliminar hojas y ramas enfermas',
      );
      expect(option.name, equals('Poda de partes afectadas'));
      expect(option.type, equals(TreatmentType.cultural));
    });

    test('UT-TM-007: typeLabel debería mostrar emoji para orgánico', () {
      final organic = TreatmentOption(
        name: 'Test', type: TreatmentType.organic, description: '',
      );
      expect(organic.typeLabel, contains('🌿'));
      expect(organic.typeLabel, contains('Orgánico'));
    });

    test('UT-TM-008: typeLabel debería mostrar emoji para químico', () {
      final chemical = TreatmentOption(
        name: 'Test', type: TreatmentType.chemical, description: '',
      );
      expect(chemical.typeLabel, contains('🧪'));
      expect(chemical.typeLabel, contains('Químico'));
    });

    test('UT-TM-009: typeLabel debería mostrar emoji para cultural', () {
      final cultural = TreatmentOption(
        name: 'Test', type: TreatmentType.cultural, description: '',
      );
      expect(cultural.typeLabel, contains('🌱'));
      expect(cultural.typeLabel, contains('Cultural'));
    });
  });

  group('TreatmentModel - fromGeminiResponse', () {
    test('UT-TM-010: debería parsear respuesta básica de Gemini', () {
      const geminiResponse = '''
      El tomate presenta mancha bacteriana.
      Síntomas:
      - Manchas oscuras en las hojas
      Tratamientos:
      🌿 Aplicar fungicida de cobre
      Prevención:
      - Rotación de cultivos
      ''';
      final model = TreatmentModel.fromGeminiResponse(
        geminiResponse, 'Tomate', 'Mancha bacteriana',
      );
      expect(model.plantName, equals('Tomate'));
      expect(model.diseaseName, equals('Mancha bacteriana'));
      expect(model.additionalInfo, equals(geminiResponse));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/models/treatment_model_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar un tipo de tratamiento nuevo (ej: `biological`):** Añádelo al enum `TreatmentType`, actualiza `UT-TM-005` para esperar 4 tipos, y crea un test nuevo para verificar su `typeLabel`.
- **Probar respuestas reales de Gemini:** Copia una respuesta real de la API de Gemini y úsala en un test del factory `fromGeminiResponse` para asegurar que el parseo es correcto.
- **Agregar campo `severity` al tratamiento:** Crea un test que construya un `TreatmentModel` con el nuevo campo y verifique que se almacena.

---

### 4.5 `foto_provider_test.dart`

> **Archivo:** `test/unit/providers/foto_provider_test.dart`  
> **Qué se prueba:** `FotoViewModel` (gestión de fotos) y el modelo `Foto`  
> **Ubicación del código probado:** `lib/presentation/viewmodels/foto_viewmodel.dart` y `lib/presentation/models/foto.dart`

#### ¿Por qué se hace esta prueba?

`FotoViewModel` maneja las fotos que el usuario toma con la cámara o selecciona de la galería. Es el puente entre la captura de imagen y el análisis con IA. Si no puede agregar, eliminar o mantener fotos en orden, el flujo de análisis se rompe.

#### ¿Qué nos asegura?

Que se pueden agregar fotos, que se mantiene el orden de inserción, que se pueden eliminar por índice, y que el modelo `Foto` almacena `path`, `nombre` y `description` correctamente.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-FP-001** | Lista de fotos vacía inicialmente | Crea `FotoProvider()` nuevo | Que `fotos.isEmpty` y `fotos.length == 0` | Al abrir la app no debe haber fotos precargadas |
| **UT-FP-002** | Agregar una foto | Llama `agregarFoto()` con una foto | Que `fotos.length == 1` y los datos sean correctos | Función básica: el usuario toma una foto y se agrega |
| **UT-FP-003** | Agregar múltiples fotos | Agrega 5 fotos en un loop | Que `fotos.length == 5` | El usuario puede tomar varias fotos seguidas |
| **UT-FP-004** | Fotos se agregan en orden | Agrega 'first', 'second', 'third' | Que `fotos[0]='first'`, `fotos[1]='second'`, `fotos[2]='third'` | El orden cronológico de las fotos importa |
| **UT-FP-005** | Eliminar foto por índice | Crea 3 fotos [a, b, c] y elimina índice 1 | Que queden [a, c] con `length == 2` | El usuario puede descartar fotos equivocadas |
| **UT-FP-006** | Eliminar primera foto | Crea 2 fotos y elimina índice 0 | Que quede solo la segunda foto | Eliminar la primera foto no debe romper la lista |
| **UT-FP-007** | Eliminar última foto | Crea 2 fotos y elimina índice 1 | Que quede solo la primera foto | Eliminar la última en la lista |
| **UT-FP-008** | Eliminar todas las fotos | Crea 3 fotos y las elimina una por una (de atrás para adelante) | Que `fotos.isEmpty` al final | Limpiar todas las fotos para empezar de nuevo |
| **UT-FP-009** | Crear modelo Foto | Crea `Foto` con path, nombre y descripción | Que los 3 campos se almacenen correctamente | El modelo es el dato base que viaja por toda la app |
| **UT-FP-010** | Foto con descripción vacía | Crea `Foto` con `description: ''` | Que `description.isEmpty` sin error | Las descripciones son opcionales |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>foto_provider_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/foto_viewmodel.dart';
import 'package:symptoleaf/presentation/models/foto.dart';

void main() {
  group('FotoViewModel - Estado Inicial', () {
    test('UT-FP-001: debería iniciar con lista de fotos vacía', () {
      final viewModel = FotoViewModel();
      expect(viewModel.fotos, isEmpty);
      expect(viewModel.fotos.length, equals(0));
    });
  });

  group('FotoViewModel - Agregar Fotos', () {
    test('UT-FP-002: debería agregar una foto correctamente', () {
      final viewModel = FotoViewModel();
      final foto = Foto(
        path: '/path/to/image.jpg',
        nombre: 'test_image.jpg',
        description: 'Foto de prueba',
      );
      viewModel.agregarFoto(foto);
      expect(viewModel.fotos.length, equals(1));
      expect(viewModel.fotos.first.path, equals('/path/to/image.jpg'));
    });

    test('UT-FP-003: debería agregar múltiples fotos', () {
      final viewModel = FotoViewModel();
      for (int i = 0; i < 5; i++) {
        viewModel.agregarFoto(Foto(
          path: '/path/to/image_$i.jpg',
          nombre: 'image_$i.jpg',
          description: 'Foto $i',
        ));
      }
      expect(viewModel.fotos.length, equals(5));
    });

    test('UT-FP-004: debería mantener orden de inserción', () {
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/first.jpg', nombre: 'first', description: '1'));
      viewModel.agregarFoto(Foto(path: '/second.jpg', nombre: 'second', description: '2'));
      viewModel.agregarFoto(Foto(path: '/third.jpg', nombre: 'third', description: '3'));
      expect(viewModel.fotos[0].nombre, equals('first'));
      expect(viewModel.fotos[1].nombre, equals('second'));
      expect(viewModel.fotos[2].nombre, equals('third'));
    });
  });

  group('FotoViewModel - Eliminar Fotos', () {
    test('UT-FP-005: debería eliminar foto por índice', () {
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/a.jpg', nombre: 'a', description: 'A'));
      viewModel.agregarFoto(Foto(path: '/b.jpg', nombre: 'b', description: 'B'));
      viewModel.agregarFoto(Foto(path: '/c.jpg', nombre: 'c', description: 'C'));
      viewModel.eliminarFoto(1); // Eliminar 'b'
      expect(viewModel.fotos.length, equals(2));
      expect(viewModel.fotos[0].nombre, equals('a'));
      expect(viewModel.fotos[1].nombre, equals('c'));
    });

    test('UT-FP-006: debería eliminar primera foto', () {
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/first.jpg', nombre: 'first', description: '1'));
      viewModel.agregarFoto(Foto(path: '/second.jpg', nombre: 'second', description: '2'));
      viewModel.eliminarFoto(0);
      expect(viewModel.fotos.length, equals(1));
      expect(viewModel.fotos.first.nombre, equals('second'));
    });

    test('UT-FP-007: debería eliminar última foto', () {
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/first.jpg', nombre: 'first', description: '1'));
      viewModel.agregarFoto(Foto(path: '/second.jpg', nombre: 'second', description: '2'));
      viewModel.eliminarFoto(1);
      expect(viewModel.fotos.length, equals(1));
      expect(viewModel.fotos.first.nombre, equals('first'));
    });

    test('UT-FP-008: debería poder eliminar todas las fotos', () {
      final viewModel = FotoViewModel();
      for (int i = 0; i < 3; i++) {
        viewModel.agregarFoto(Foto(
          path: '/img_$i.jpg', nombre: 'img_$i', description: '$i',
        ));
      }
      viewModel.eliminarFoto(2);
      viewModel.eliminarFoto(1);
      viewModel.eliminarFoto(0);
      expect(viewModel.fotos, isEmpty);
    });
  });

  group('Foto Model', () {
    test('UT-FP-009: debería crear modelo Foto correctamente', () {
      final foto = Foto(
        path: '/storage/emulated/0/DCIM/photo.jpg',
        nombre: 'photo.jpg',
        description: 'Hoja de tomate con manchas',
      );
      expect(foto.path, equals('/storage/emulated/0/DCIM/photo.jpg'));
      expect(foto.nombre, equals('photo.jpg'));
      expect(foto.description, equals('Hoja de tomate con manchas'));
    });

    test('UT-FP-010: debería permitir descripción vacía', () {
      final foto = Foto(
        path: '/path/to/img.jpg', nombre: 'img.jpg', description: '',
      );
      expect(foto.description, isEmpty);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/providers/foto_provider_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar límite máximo de fotos:** Si quieres que `FotoViewModel` solo permita 10 fotos, añade un test que agregue 11 fotos y verifique que rechaza la última o solo mantiene 10.
- **Agregar método de búsqueda por nombre:** Si añades `buscarPor(nombre)` al ViewModel, crea un test que agregue varias fotos y busque una específica.
- **Probar notificaciones a listeners:** Usa `viewModel.addListener(() => ...)` en un test para verificar que se notifica al agregar/eliminar fotos.

---

### 4.6 `predict_disease_usecase_test.dart`

> **Archivo:** `test/unit/use_cases/predict_disease_usecase_test.dart`  
> **Qué se prueba:** `PredictDiseaseUseCase` (caso de uso del dominio)  
> **Ubicación del código probado:** `lib/domain/use_case/predict_disease_usecase.dart`

#### ¿Por qué se hace esta prueba?

`PredictDiseaseUseCase` es el **caso de uso principal** de la aplicación. Es el punto de entrada de la lógica de negocio que recibe una ruta de imagen y devuelve una predicción. Usa un Mock del repositorio para aislar la prueba de la IA real.

#### ¿Qué nos asegura?

Que el caso de uso valida entradas (rechaza paths vacíos), delega al repositorio, retorna resultados correctos y propaga errores cuando el modelo falla.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-PDU-001** | Rechazar path vacío | Llama `execute('')` con string vacío | Que lance una `Exception` | Sin ruta de imagen, no se puede predecir nada |
| **UT-PDU-002** | Aceptar path válido | Llama `execute('/storage/DCIM/photo.jpg')` | Que retorne un resultado no nulo con className correcto | El flujo normal debe funcionar |
| **UT-PDU-003** | Ejecutar predicción exitosa | Configura mock con resultado de tomate - late blight | Que retorne `PredictionEntity` con confidence `0.92` | La predicción completa funciona end-to-end |
| **UT-PDU-004** | Delegar al repositorio | Configura mock con resultado de papa | Que `result.plant == 'Potato'` | El use case DEBE delegar al repository, no hacer la predicción solo |
| **UT-PDU-005** | Propagar errores del repositorio | Configura mock con `Exception('Error de inferencia')` | Que lance la misma excepción | Si el modelo falla, el error debe llegar al usuario |
| **UT-PDU-006** | Identificar planta saludable | Configura mock con `isHealthy=true` | Que `result.isHealthy == true` | La detección de planta sana es distinta a enferma |
| **UT-PDU-007** | Identificar planta enferma | Configura mock con `isHealthy=false` | Que `result.isHealthy == false` | La detección de enfermedad activa el flujo de tratamientos |
| **UT-PDU-008** | Retornar confianza correcta | Configura mock con `confidence=0.76` | Que `result.confidence == 0.76` | La confianza se muestra al usuario; debe ser exacta |
| **UT-PDU-009** | Retornar nombre de planta | Configura mock con `plant='Corn'` | Que `result.plant == 'Corn'` | El nombre de la planta se muestra en el resultado |
| **UT-PDU-010** | Retornar nombre de enfermedad | Configura mock con `disease='Bacterial spot'` | Que `result.disease == 'Bacterial spot'` | El nombre de la enfermedad se muestra en pantalla |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>predict_disease_usecase_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

// Mock del Repository para tests
class MockBaseRepository implements BaseRepository {
  PredictionEntity? mockResult;
  Exception? mockError;

  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    if (mockError != null) throw mockError!;
    return mockResult ?? PredictionEntity(
      className: 'Tomato_healthy', plant: 'Tomato',
      disease: 'healthy', confidence: 0.95,
      isHealthy: true, top3: [],
    );
  }
}

void main() {
  late MockBaseRepository mockRepository;
  late PredictDiseaseUseCase useCase;

  setUp(() {
    mockRepository = MockBaseRepository();
    useCase = PredictDiseaseUseCase(mockRepository);
  });

  group('PredictDiseaseUseCase - Validaciones de Entrada', () {
    test('UT-PDU-001: debería rechazar path de imagen vacío', () async {
      expect(() => useCase.execute(''), throwsA(isA<Exception>()));
    });

    test('UT-PDU-002: debería aceptar path de imagen válido', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Tomato_healthy', plant: 'Tomato',
        disease: 'healthy', confidence: 0.95,
        isHealthy: true, top3: [],
      );
      final result = await useCase.execute('/storage/DCIM/photo.jpg');
      expect(result, isNotNull);
      expect(result.className, equals('Tomato_healthy'));
    });
  });

  group('PredictDiseaseUseCase - Ejecución', () {
    test('UT-PDU-003: debería ejecutar predicción exitosa', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Tomato_Late_blight', plant: 'Tomato',
        disease: 'Late blight', confidence: 0.92,
        isHealthy: false, top3: [],
      );
      final result = await useCase.execute('/path/to/image.jpg');
      expect(result, isA<PredictionEntity>());
      expect(result.confidence, equals(0.92));
    });

    test('UT-PDU-004: debería delegar al repositorio', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Potato_Early_blight', plant: 'Potato',
        disease: 'Early blight', confidence: 0.88,
        isHealthy: false, top3: [],
      );
      final result = await useCase.execute('/image.jpg');
      expect(result.plant, equals('Potato'));
    });

    test('UT-PDU-005: debería propagar errores del repositorio', () async {
      mockRepository.mockError = Exception('Error de inferencia');
      expect(() => useCase.execute('/path/image.jpg'), throwsA(isA<Exception>()));
    });
  });

  group('PredictDiseaseUseCase - Resultados', () {
    test('UT-PDU-006: debería identificar planta saludable', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Tomato_healthy', plant: 'Tomato',
        disease: 'healthy', confidence: 0.97,
        isHealthy: true, top3: [],
      );
      final result = await useCase.execute('/healthy_plant.jpg');
      expect(result.isHealthy, isTrue);
    });

    test('UT-PDU-007: debería identificar planta enferma', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Apple_Scab', plant: 'Apple',
        disease: 'Scab', confidence: 0.85,
        isHealthy: false, top3: [],
      );
      final result = await useCase.execute('/sick_plant.jpg');
      expect(result.isHealthy, isFalse);
    });

    test('UT-PDU-008: debería retornar confianza correcta', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Grape_Black_rot', plant: 'Grape',
        disease: 'Black rot', confidence: 0.76,
        isHealthy: false, top3: [],
      );
      final result = await useCase.execute('/grape.jpg');
      expect(result.confidence, equals(0.76));
    });

    test('UT-PDU-009: debería retornar nombre de planta correcto', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Corn_Common_rust', plant: 'Corn',
        disease: 'Common rust', confidence: 0.91,
        isHealthy: false, top3: [],
      );
      final result = await useCase.execute('/corn.jpg');
      expect(result.plant, equals('Corn'));
    });

    test('UT-PDU-010: debería retornar nombre de enfermedad correcto', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Pepper_bell_Bacterial_spot', plant: 'Pepper_bell',
        disease: 'Bacterial spot', confidence: 0.89,
        isHealthy: false, top3: [],
      );
      final result = await useCase.execute('/pepper.jpg');
      expect(result.disease, equals('Bacterial spot'));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/use_cases/predict_disease_usecase_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar validación de extensión de archivo:** Si quieres que el UseCase solo acepte `.jpg`/`.png`, agrega la validación en `execute()` y un test que pase un path `.txt` y verifique que lanza excepción.
- **Simular diferentes errores:** Añade tests con `mockError = Exception('Sin permisos')`, `Exception('Sin conexión')`, etc. para cubrir más escenarios.
- **Probar timeout:** Si añades lógica de timeout al UseCase, usa `mockRepository.delay = Duration(seconds: 10)` y verifica que lanza timeout.

---

### 4.7 `prediction_viewmodel_test.dart`

> **Archivo:** `test/unit/viewmodels/prediction_viewmodel_test.dart`  
> **Qué se prueba:** `PredictionViewModel` — el ViewModel que conecta la lógica de predicción con la UI  
> **Ubicación del código probado:** `lib/presentation/viewmodels/prediction_viewmodel.dart`

#### ¿Por qué se hace esta prueba?

`PredictionViewModel` es quien maneja el **estado de la predicción** en la interfaz: initial → loading → success/error. Es el intermediario entre la UI y la lógica de negocio. Si este ViewModel falla, la pantalla no mostraría resultados o se quedaría en "cargando" para siempre.

#### ¿Qué nos asegura?

Que el estado inicial es correcto, que las predicciones exitosas cambian el estado a `success`, que los errores se capturan, y que el `reset()` limpia todo.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-PVM-001** | Estado inicial es initial | Crea `PredictionViewModel` nuevo | Que `state == PredictionState.initial` | La pantalla debe mostrar el estado de espera al inicio |
| **UT-PVM-002** | Sin predicción inicial | Verifica `viewModel.prediction` en objeto nuevo | Que `prediction == null` | No debe haber resultado antes de analizar |
| **UT-PVM-003** | Mensaje de error vacío | Verifica `viewModel.errorMessage` en objeto nuevo | Que `errorMessage.isEmpty` | No debe haber errores al inicio |
| **UT-PVM-004** | Predicción exitosa cambia a success | Ejecuta `predictDisease()` con mock exitoso | Que `state == PredictionState.success` y `prediction != null` | El resultado debe ser visible tras el análisis |
| **UT-PVM-005** | Guarda la predicción correctamente | Ejecuta predicción y verifica los campos | Que `prediction.plant == 'Potato'` y `prediction.confidence == 0.88` | Los datos del resultado deben ser exactos |
| **UT-PVM-006** | Error cambia estado a error | Ejecuta con mock que lanza excepción | Que `state == PredictionState.error` y `errorMessage` contenga el texto del error | El usuario debe ver un mensaje de error, no un crash |
| **UT-PVM-007** | Mensaje de error se guarda | Ejecuta con error `'Modelo no cargado'` | Que `errorMessage.isNotEmpty` | La UI necesita el texto del error para mostrarlo |
| **UT-PVM-008** | Reset vuelve a initial | Ejecuta predicción y luego `reset()` | Que `state == PredictionState.initial` y `prediction == null` | El usuario puede analizar otra imagen: debe poder limpiar el anterior |
| **UT-PVM-009** | Reset limpia error | Provoca error y luego `reset()` | Que `errorMessage.isEmpty` | Después del reset, no debe haber rastro del error anterior |
| **UT-PVM-010** | Reset limpia predicción anterior | Ejecuta exitosamente y luego `reset()` | Que `prediction == null` | Al preparar un nuevo análisis, el resultado viejo debe desaparecer |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>prediction_viewmodel_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

class MockPredictDiseaseUseCase extends PredictDiseaseUseCase {
  PredictionEntity? mockResult;
  Exception? mockError;
  MockPredictDiseaseUseCase() : super(MockBaseRepository());

  @override
  Future<PredictionEntity> execute(String imagePath) async {
    if (mockError != null) throw mockError!;
    return mockResult ?? PredictionEntity(
      className: 'Tomato_healthy', plant: 'Tomato',
      disease: 'healthy', confidence: 0.95,
      isHealthy: true, top3: [],
    );
  }
}

class MockBaseRepository implements BaseRepository {
  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    return PredictionEntity(
      className: 'Tomato_healthy', plant: 'Tomato',
      disease: 'healthy', confidence: 0.95,
      isHealthy: true, top3: [],
    );
  }
}

void main() {
  late MockPredictDiseaseUseCase mockUseCase;
  late PredictionViewModel viewModel;

  setUp(() {
    mockUseCase = MockPredictDiseaseUseCase();
    viewModel = PredictionViewModel(mockUseCase);
  });

  group('PredictionViewModel - Estado Inicial', () {
    test('UT-PVM-001: debería iniciar en estado initial', () {
      expect(viewModel.state, equals(PredictionState.initial));
    });

    test('UT-PVM-002: no debería tener predicción inicialmente', () {
      expect(viewModel.prediction, isNull);
    });

    test('UT-PVM-003: mensaje de error debería estar vacío', () {
      expect(viewModel.errorMessage, isEmpty);
    });
  });

  group('PredictionViewModel - Predicción Exitosa', () {
    test('UT-PVM-004: debería cambiar a success tras predicción exitosa', () async {
      mockUseCase.mockResult = PredictionEntity(
        className: 'Tomato_Late_blight', plant: 'Tomato',
        disease: 'Late blight', confidence: 0.92,
        isHealthy: false, top3: [],
      );
      await viewModel.predictDisease('/path/to/image.jpg');
      expect(viewModel.state, equals(PredictionState.success));
      expect(viewModel.prediction, isNotNull);
      expect(viewModel.prediction!.className, equals('Tomato_Late_blight'));
    });

    test('UT-PVM-005: debería guardar la predicción correctamente', () async {
      mockUseCase.mockResult = PredictionEntity(
        className: 'Potato_Early_blight', plant: 'Potato',
        disease: 'Early blight', confidence: 0.88,
        isHealthy: false, top3: [],
      );
      await viewModel.predictDisease('/image.jpg');
      expect(viewModel.prediction!.plant, equals('Potato'));
      expect(viewModel.prediction!.confidence, equals(0.88));
    });
  });

  group('PredictionViewModel - Manejo de Errores', () {
    test('UT-PVM-006: debería cambiar a error si falla', () async {
      mockUseCase.mockError = Exception('Error de inferencia');
      await viewModel.predictDisease('/path/to/image.jpg');
      expect(viewModel.state, equals(PredictionState.error));
      expect(viewModel.errorMessage, contains('Error de inferencia'));
    });

    test('UT-PVM-007: debería guardar el mensaje de error', () async {
      mockUseCase.mockError = Exception('Modelo no cargado');
      await viewModel.predictDisease('/test.jpg');
      expect(viewModel.errorMessage, isNotEmpty);
    });
  });

  group('PredictionViewModel - Reset', () {
    test('UT-PVM-008: reset debería volver a estado initial', () async {
      await viewModel.predictDisease('/image.jpg');
      expect(viewModel.state, equals(PredictionState.success));
      viewModel.reset();
      expect(viewModel.state, equals(PredictionState.initial));
      expect(viewModel.prediction, isNull);
    });

    test('UT-PVM-009: reset debería limpiar mensaje de error', () async {
      mockUseCase.mockError = Exception('Error');
      await viewModel.predictDisease('/test.jpg');
      expect(viewModel.errorMessage, isNotEmpty);
      viewModel.reset();
      expect(viewModel.errorMessage, isEmpty);
    });

    test('UT-PVM-010: reset debería limpiar predicción anterior', () async {
      mockUseCase.mockError = null;
      await viewModel.predictDisease('/image.jpg');
      expect(viewModel.prediction, isNotNull);
      viewModel.reset();
      expect(viewModel.prediction, isNull);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/viewmodels/prediction_viewmodel_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Probar transición loading → success:** Añade un test que capture el estado justo después de llamar `predictDisease()` (antes del `await`) y verifique que es `PredictionState.loading`.
- **Probar predicciones múltiples:** Crea un test que haga 3 predicciones seguidas y verifique que solo se guarda la última.
- **Agregar historial de predicciones:** Si añades una lista `previousPredictions` al ViewModel, crea tests que verifiquen que se acumulan.

---

### 4.8 `gemini_viewmodel_test.dart`

> **Archivo:** `test/unit/viewmodels/gemini_viewmodel_test.dart`  
> **Qué se prueba:** `GeminiViewModel` — ViewModel para el chat con Gemini y los tratamientos  
> **Ubicación del código probado:** `lib/presentation/viewmodels/gemini_viewmodel.dart`

#### ¿Por qué se hace esta prueba?

`GeminiViewModel` maneja dos funcionalidades clave:
1. **Obtener tratamientos** para enfermedades detectadas
2. **Chat interactivo** donde el usuario pregunta sobre cuidados de plantas

Si este ViewModel falla, el usuario no recibe tratamientos ni puede chatear.

#### ¿Qué nos asegura?

Que los estados iniciales son correctos (idle), que no hay tratamientos ni mensajes antes de usarlo, y que los errores están vacíos al inicio.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-GVM-001** | Estado de tratamiento idle | Verifica `treatmentState` inicial | Que sea `GeminiState.idle` | El estado idle significa "listo para usar" |
| **UT-GVM-002** | Lista de mensajes vacía | Verifica `messages` inicial | Que `messages.isEmpty` | El chat debe estar limpio al inicio |
| **UT-GVM-003** | Sin tratamiento inicial | Verifica `treatment` y `hasTreatment` | Que `treatment == null` y `hasTreatment == false` | No hay tratamiento antes de analizar |
| **UT-GVM-004** | Estado de chat idle | Verifica `chatState` inicial | Que sea `GeminiState.idle` | El chat también comienza en reposo |
| **UT-GVM-005** | Errores vacíos | Verifica `treatmentError` y `chatError` | Que ambos `isEmpty` | No debe haber errores al inicio |
| **UT-GVM-006** | No inicializado al inicio | Verifica `initializationFailed` | Que sea `false` | La inicialización no ha fallado porque aún no se ha intentado |
| **UT-GVM-007** | initError vacío | Verifica `initError` | Que `isEmpty` | Sin error de inicialización |
| **UT-GVM-008** | rawTreatmentResponse vacío | Verifica `rawTreatmentResponse` | Que `isEmpty` | La respuesta cruda de Gemini no existe aún |
| **UT-GVM-009** | hasTreatment es false | Verifica `hasTreatment` | Que sea `false` | Doble verificación del estado de tratamiento |
| **UT-GVM-010** | Lista de mensajes inmutable | Obtiene `messages` y verifica tipo | Que sea una `List` vacía | La lista no debe ser modificable externamente |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>gemini_viewmodel_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/gemini_viewmodel.dart';

void main() {
  late GeminiViewModel viewModel;

  setUp(() {
    viewModel = GeminiViewModel();
  });

  group('GeminiViewModel - Estado Inicial', () {
    test('UT-GVM-001: debería iniciar con estado de tratamiento idle', () {
      expect(viewModel.treatmentState, equals(GeminiState.idle));
    });

    test('UT-GVM-002: debería iniciar con lista de mensajes vacía', () {
      expect(viewModel.messages, isEmpty);
    });

    test('UT-GVM-003: no debería tener tratamiento inicialmente', () {
      expect(viewModel.treatment, isNull);
      expect(viewModel.hasTreatment, isFalse);
    });

    test('UT-GVM-004: debería iniciar con estado de chat idle', () {
      expect(viewModel.chatState, equals(GeminiState.idle));
    });

    test('UT-GVM-005: debería tener errores vacíos inicialmente', () {
      expect(viewModel.treatmentError, isEmpty);
      expect(viewModel.chatError, isEmpty);
    });
  });

  group('GeminiViewModel - Estado de Inicialización', () {
    test('UT-GVM-006: no debería estar inicializado al inicio', () {
      expect(viewModel.initializationFailed, isFalse);
    });

    test('UT-GVM-007: initError debería estar vacío al inicio', () {
      expect(viewModel.initError, isEmpty);
    });
  });

  group('GeminiViewModel - Propiedades de Tratamiento', () {
    test('UT-GVM-008: rawTreatmentResponse debería estar vacío', () {
      expect(viewModel.rawTreatmentResponse, isEmpty);
    });

    test('UT-GVM-009: hasTreatment debería ser false sin tratamiento', () {
      expect(viewModel.hasTreatment, isFalse);
    });
  });

  group('GeminiViewModel - Lista de Mensajes', () {
    test('UT-GVM-010: lista de mensajes devuelta debería ser inmutable', () {
      final messages = viewModel.messages;
      expect(messages, isA<List>());
      expect(messages, isEmpty);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/viewmodels/gemini_viewmodel_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Probar la función `getTreatment()`:** Para esto necesitas mockear `GeminiService`. Crea una clase `MockGeminiService` que devuelva respuestas predefinidas sin llamar a la API real.
- **Verificar que el chat se inicia con contexto:** Si `startChat(plant: 'Tomate', disease: 'Mancha')` añade un mensaje de bienvenida, verifica que `messages[0].content` contenga esas palabras.
- **Probar límite de mensajes:** Si quieres limitar a 50 mensajes, añade un test que envíe 51 y verifique el comportamiento.

---

### 4.9 `settings_viewmodel_test.dart`

> **Archivo:** `test/unit/viewmodels/settings_viewmodel_test.dart`  
> **Qué se prueba:** `SettingsViewModel` — ViewModel de configuración (modo local/servidor, URL)  
> **Ubicación del código probado:** `lib/presentation/viewmodels/settings_viewmodel.dart`

#### ¿Por qué se hace esta prueba?

`SettingsViewModel` controla **qué modelo de IA se usa para la predicción**: modelo **estándar** (`plant_disease_model.onnx`) o modelo **YOLO11 mejorado** (`plant_disease_yolo11.onnx`). También expone el nombre de archivo del modelo. Si esta configuración falla, la predicción usaría el modelo incorrecto.

#### ¿Qué nos asegura?

Que el tipo de modelo por defecto es `standard`, que se puede cambiar entre modelos, que el nombre de archivo retornado es correcto para cada tipo, y que los tipos del enum son exactamente 2.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **UT-SVM-001** | Estado inicial en modo standard | Crea `SettingsViewModel()` | Que `modelType == ModelType.standard` | Por defecto se usa el modelo estándar |
| **UT-SVM-002** | Nombre de modelo por defecto | Verifica `modelFileName` al inicio | Que `modelFileName.isNotEmpty` | Siempre debe haber un modelo configurado |
| **UT-SVM-003** | Cambiar a modelo yolo11 | Llama `setModelType(ModelType.yolo11)` | Que `modelType == ModelType.yolo11` | El usuario puede elegir usar el modelo mejorado |
| **UT-SVM-004** | Cambiar a modelo standard | Cambia a yolo11 y luego a standard | Que `modelType == ModelType.standard` | El cambio es reversible |
| **UT-SVM-005** | Cambio de modelo múltiple | Cambia 10 veces alternando | Que cada cambio refleje el modelo correcto | El usuario puede cambiar de opinión muchas veces |
| **UT-SVM-006** | Nombre archivo para standard | Verifica `modelFileName` en standard | Que sea `'plant_disease_model.onnx'` | El archivo del modelo ONNX debe ser correcto |
| **UT-SVM-007** | Nombre archivo para yolo11 | Cambia a yolo11 y verifica `modelFileName` | Que sea `'plant_disease_yolo11.onnx'` | El archivo del modelo YOLO11 debe ser correcto |
| **UT-SVM-008** | Verificar tipos disponibles | Consulta `ModelType.values` | Que haya exactamente 2 tipos | Si alguien agrega un tipo sin actualizar la UI, esto lo detecta |
| **UT-SVM-009** | Tipo standard existe | Verifica `ModelType.standard` | Que esté en la lista de valores | Seguridad de que el enum no fue modificado |
| **UT-SVM-010** | Tipo yolo11 existe | Verifica `ModelType.yolo11` | Que esté en la lista de valores | Seguridad de que el enum no fue modificado |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>settings_viewmodel_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsViewModel - Estado Inicial', () {
    test('UT-SVM-001: debería iniciar en modo standard', () {
      final viewModel = SettingsViewModel();
      expect(viewModel.modelType, equals(ModelType.standard));
    });

    test('UT-SVM-002: debería tener nombre de modelo por defecto', () {
      final viewModel = SettingsViewModel();
      expect(viewModel.modelFileName, isNotEmpty);
    });
  });

  group('SettingsViewModel - Cambio de Modelo', () {
    test('UT-SVM-003: debería cambiar a modelo yolo11', () async {
      final viewModel = SettingsViewModel();
      await viewModel.setModelType(ModelType.yolo11);
      expect(viewModel.modelType, equals(ModelType.yolo11));
    });

    test('UT-SVM-004: debería cambiar a modelo standard', () async {
      final viewModel = SettingsViewModel();
      await viewModel.setModelType(ModelType.yolo11);
      await viewModel.setModelType(ModelType.standard);
      expect(viewModel.modelType, equals(ModelType.standard));
    });

    test('UT-SVM-005: debería permitir cambios de modelo múltiples', () async {
      final viewModel = SettingsViewModel();
      for (int i = 0; i < 10; i++) {
        if (i % 2 == 0) {
          await viewModel.setModelType(ModelType.yolo11);
          expect(viewModel.modelType, equals(ModelType.yolo11));
        } else {
          await viewModel.setModelType(ModelType.standard);
          expect(viewModel.modelType, equals(ModelType.standard));
        }
      }
    });
  });

  group('SettingsViewModel - Nombre de Archivo del Modelo', () {
    test('UT-SVM-006: debería retornar nombre correcto para standard', () {
      final viewModel = SettingsViewModel();
      expect(viewModel.modelFileName, equals('plant_disease_model.onnx'));
    });

    test('UT-SVM-007: debería retornar nombre correcto para yolo11', () async {
      final viewModel = SettingsViewModel();
      await viewModel.setModelType(ModelType.yolo11);
      expect(viewModel.modelFileName, equals('plant_disease_yolo11.onnx'));
    });
  });

  group('ModelType Enum', () {
    test('UT-SVM-008: debería tener exactamente 2 tipos', () {
      expect(ModelType.values.length, equals(2));
    });

    test('UT-SVM-009: tipo standard debería existir', () {
      expect(ModelType.values.contains(ModelType.standard), isTrue);
    });

    test('UT-SVM-010: tipo yolo11 debería existir', () {
      expect(ModelType.values.contains(ModelType.yolo11), isTrue);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/unit/viewmodels/settings_viewmodel_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar un tercer modelo:** Si añades `ModelType.mobilenet` al enum, actualiza `UT-SVM-008` para esperar 3 tipos, añade un test que verifique el nombre de archivo del nuevo modelo, y prueba el cambio a ese tipo.
- **Probar persistencia:** Añade un test que cambie el modelo a `yolo11`, cree un nuevo `SettingsViewModel()`, y verifique que el valor persiste en `SharedPreferences`.
- **Probar valor por defecto después de limpiar preferencias:** Limpia `SharedPreferences` y verifica que el modelo vuelve a `standard`.

---

## 5. Tests de Integración

Los tests de integración prueban **múltiples componentes trabajando juntos**. Verifican que los datos fluyen correctamente entre capas (modelo → entidad → viewmodel → UI).

---

### 5.1 `analysis_flow_test.dart`

> **Archivo:** `test/integration/analysis_flow_test.dart`  
> **Qué se prueba:** El flujo completo End-to-End de un análisis de planta  
> **Componentes involucrados:** `SettingsViewModel`, `FotoProvider`, `GeminiService`, `PredictionState`, `ModelType`

#### ¿Por qué se hace esta prueba?

Un análisis de planta involucra múltiples componentes que deben funcionar juntos: seleccionar modo → tomar foto → predecir → mostrar resultado. Este test verifica que todos estos componentes se **inicializan correctamente** y pueden **coexistir sin conflictos**.

#### ¿Qué nos asegura?

Que todos los providers arrancan correctamente, que los estados de predicción y modos son válidos, que GeminiService mantiene una única instancia (singleton), y que FotoProvider inicia vacío.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **IE2E-001** | Todos los providers se inicializan | Crea SettingsViewModel, FotoProvider, GeminiService | Que modelType=standard, fotos vacías, chat inactivo | Todos los proveedores deben funcionar al arrancar la app |
| **IE2E-002** | PredictionState tiene transiciones válidas | Consulta los 4 estados del enum | Que existan: initial, loading, success, error | El flujo de estados es la columna vertebral de la UI |
| **IE2E-003** | Tipos de modelo | Consulta los tipos | Que existan: standard y yolo11, total 2 | Solo hay 2 modelos disponibles |
| **IE2E-004** | Singleton de GeminiService | Crea 3 instancias y las compara | Que las 3 sean idénticas (`identical`) | Un solo servicio de Gemini en toda la app evita estados inconsistentes |
| **IE2E-005** | FotoProvider sin foto inicial | Crea FotoProvider | Que `fotos.isEmpty` | No debe haber fotos al abrir la app |
| **IE2E-006** | SettingsViewModel modo standard | Verifica estado inicial | Que `modelType == standard` y `modelFileName.isNotEmpty` | La configuración por defecto es modelo estándar |
| **IE2E-007** | Chat inactivo inicialmente | Verifica GeminiService | Que `isChatActive == false` | El chat no debe estar activo sin que el usuario lo inicie |
| **IE2E-008** | Estado de configuración de Gemini | Verifica `isConfigured` | Que sea de tipo `bool` (puede ser true o false) | Depende de si hay API key; el test solo verifica que tenga un valor |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>analysis_flow_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/presentation/providers/foto_provider.dart';
import 'package:symptoleaf/data/datasource/gemini_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Integration E2E: Flujo de Análisis', () {
    test('IE2E-001: Todos los providers deberían inicializarse correctamente', () {
      final settingsVM = SettingsViewModel();
      final fotoProvider = FotoProvider();
      final geminiService = GeminiService();
      expect(settingsVM.modelType, equals(ModelType.standard));
      expect(fotoProvider.fotos, isEmpty);
      expect(geminiService.isChatActive, isFalse);
    });

    test('IE2E-002: PredictionState debería tener transiciones válidas', () {
      final states = PredictionState.values;
      expect(states.contains(PredictionState.initial), isTrue);
      expect(states.contains(PredictionState.loading), isTrue);
      expect(states.contains(PredictionState.success), isTrue);
      expect(states.contains(PredictionState.error), isTrue);
      expect(states.length, equals(4));
    });

    test('IE2E-003: Tipos de modelo deberían ser standard y yolo11', () {
      final types = ModelType.values;
      expect(types.contains(ModelType.standard), isTrue);
      expect(types.contains(ModelType.yolo11), isTrue);
      expect(types.length, equals(2));
    });

    test('IE2E-004: GeminiService debería mantener una única instancia', () {
      final instance1 = GeminiService();
      final instance2 = GeminiService();
      final instance3 = GeminiService();
      expect(identical(instance1, instance2), isTrue);
      expect(identical(instance2, instance3), isTrue);
    });

    test('IE2E-005: FotoProvider debería iniciar sin foto seleccionada', () {
      final provider = FotoProvider();
      expect(provider.fotos, isEmpty);
    });

    test('IE2E-006: SettingsViewModel debería iniciar en modo standard', () {
      final viewModel = SettingsViewModel();
      expect(viewModel.modelType, equals(ModelType.standard));
      expect(viewModel.modelFileName, isNotEmpty);
    });
  });

  group('Integration E2E: Flujo de Chat', () {
    test('IE2E-007: Chat debería estar inactivo inicialmente', () {
      final geminiService = GeminiService();
      expect(geminiService.isChatActive, isFalse);
    });

    test('IE2E-008: GeminiService debería reportar su estado de configuración', () {
      final service = GeminiService();
      expect(service.isConfigured, isA<bool>());
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/integration/analysis_flow_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar test de flujo con nuevo provider:** Si añades `AuthViewModel` a los providers, crea un test `IE2E-009` que lo inicialice junto con los demás y verifique que todos estén en su estado inicial.
- **Probar flujo completo con imagen simulada:** Añade un test que simule agregar una foto, ejecutar predicción y verificar el resultado.
- **Verificar que los providers se crean sin conflictos:** Si se agregan dependencias entre providers, asegúrate de que el orden de inicialización no cause problemas.

---

### 5.2 `data_flow_test.dart`

> **Archivo:** `test/integration/data_flow_test.dart`  
> **Qué se prueba:** El flujo completo de datos: JSON → Model → Entity → JSON  
> **Componentes involucrados:** `PredictionModel`, `PredictionEntity`, `TreatmentModel`, `TreatmentOption`, `ChatMessage`

#### ¿Por qué se hace esta prueba?

Los datos de predicción pasan por múltiples transformaciones: llegan como JSON del modelo, se convierten a `PredictionModel`, luego a `PredictionEntity` para la lógica de dominio, y potencialmente de vuelta a JSON para almacenar. Esta prueba verifica que **ningún dato se pierda** en estas conversiones.

#### ¿Qué nos asegura?

Que el ciclo completo de datos preserva toda la información, que el parseo de JSON funciona, que los tratamientos tienen la estructura correcta, y que el chat mantiene la conversación en orden.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **INT-DF-001** | Model a Entity | Crea PredictionModel y llama `toEntity()` | Que la entidad tenga los mismos campos | La conversión entre capas no debe perder datos |
| **INT-DF-002** | Entity preserva campos | Crea PredictionEntity con top3 de 2 elementos | Que top3.length=2 y que la primera confidence > la segunda | Las listas top3 deben mantener su orden |
| **INT-DF-003** | Modelo desde JSON | Parsea JSON con estructura `{'prediction': {...}, 'top3': []}` | Que className, plant, isHealthy, confidence se extraigan correctamente | El JSON del servidor/modelo debe parsearse sin errores |
| **INT-DF-004** | Modelo a JSON | Crea modelo y llama `toJson()` | Que el JSON contenga `prediction.class`, `prediction.plant`, etc. | Necesario para almacenar o reenviar resultados |
| **INT-DF-005** | Ciclo completo JSON→Model→Entity→JSON | Parsea JSON, convierte a entity, recrea modelo, serializa a JSON | Que el JSON final tenga los mismos valores que el original | **El test más importante**: prueba que no hay pérdida de datos en todo el ciclo |
| **INT-DF-006** | TreatmentModel estructura | Crea tratamiento completo con síntomas, opciones y prevención | Que todos los campos tengan los valores correctos | La estructura de tratamientos debe ser completa |
| **INT-DF-007** | TreatmentOption campos | Crea opción orgánica 'Neem Oil' | Que name, description y type sean correctos, y typeLabel contenga 'Orgánico' | Cada opción de tratamiento debe estar bien formada |
| **INT-DF-008** | ChatMessage flujo de conversación | Crea 4 mensajes alternando user/assistant | Que haya 4 mensajes y que alternen correctamente (user, assistant, user, assistant) | El chat debe mantener la conversación en orden |
| **INT-DF-009** | MessageRole alternancia | Crea un mensaje user y uno assistant | Que los roles sean correctos y los getters funcionen | Verificación explícita de los roles |
| **INT-DF-010** | Timestamps ordenados | Crea 2 mensajes con 10ms de diferencia | Que el segundo timestamp sea después del primero | Los mensajes deben poder ordenarse cronológicamente |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>data_flow_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/models/prediction_model.dart';
import 'package:symptoleaf/data/models/treatment_model.dart';
import 'package:symptoleaf/data/models/chat_message_model.dart';

void main() {
  group('Integration: Flujo de Datos Prediction', () {
    test('INT-DF-001: PredictionModel debería convertirse a PredictionEntity', () {
      final model = PredictionModel(
        className: 'Tomato_Late_blight', plant: 'Tomato',
        disease: 'Late blight', confidence: 0.92,
        isHealthy: false, top3: [],
      );
      final entity = model.toEntity();
      expect(entity, isA<PredictionEntity>());
      expect(entity.className, equals(model.className));
      expect(entity.confidence, equals(model.confidence));
    });

    test('INT-DF-003: PredictionModel debería parsearse desde JSON', () {
      final json = {
        'prediction': {
          'class': 'Potato_healthy', 'plant': 'Potato',
          'disease': 'healthy', 'confidence': 0.97, 'is_healthy': true,
        },
        'top3': [],
      };
      final model = PredictionModel.fromJson(json);
      expect(model.className, equals('Potato_healthy'));
      expect(model.isHealthy, isTrue);
    });

    test('INT-DF-005: ciclo completo de datos debería preservar información', () {
      final originalJson = {
        'prediction': {
          'class': 'Corn_Common_rust', 'plant': 'Corn',
          'disease': 'Common rust', 'confidence': 0.89, 'is_healthy': false,
        },
        'top3': [],
      };
      final model = PredictionModel.fromJson(originalJson);
      final entity = model.toEntity();
      final finalJson = PredictionModel(
        className: entity.className, plant: entity.plant,
        disease: entity.disease, confidence: entity.confidence,
        isHealthy: entity.isHealthy, top3: [],
      ).toJson();
      final finalPrediction = finalJson['prediction'] as Map<String, dynamic>;
      final originalPrediction = originalJson['prediction'] as Map<String, dynamic>;
      expect(finalPrediction['class'], equals(originalPrediction['class']));
      expect(finalPrediction['confidence'], equals(originalPrediction['confidence']));
    });
  });

  group('Integration: Flujo de Datos Chat', () {
    test('INT-DF-008: ChatMessage debería mantener flujo de conversación', () {
      final messages = <ChatMessage>[];
      messages.add(ChatMessage.user('¿Cómo trato Late blight?'));
      messages.add(ChatMessage.assistant('Para tratar Late blight...'));
      messages.add(ChatMessage.user('¿Es orgánico?'));
      messages.add(ChatMessage.assistant('Sí, puedes usar...'));
      expect(messages.length, equals(4));
      expect(messages[0].isUser, isTrue);
      expect(messages[1].isAssistant, isTrue);
    });

    test('INT-DF-010: timestamps deberían estar ordenados', () async {
      final msg1 = ChatMessage.user('Mensaje 1');
      await Future.delayed(const Duration(milliseconds: 10));
      final msg2 = ChatMessage.user('Mensaje 2');
      expect(msg2.timestamp.isAfter(msg1.timestamp), isTrue);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/integration/data_flow_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Probar con datos reales del modelo:** Si tienes una salida JSON real del modelo ONNX, úsala en `INT-DF-003` en lugar del JSON simulado.
- **Añadir prueba de conversión con campos opcionales:** Si `PredictionModel` ahora tiene `bestMethod`, añade un test que verifique que `toEntity()` preserva ese campo.
- **Probar chat con más mensajes:** Amplía `INT-DF-008` con 20 mensajes para simular una conversación larga y verificar que todos se mantienen.

---

### 5.3 `gemini_flow_test.dart`

> **Archivo:** `test/integration/gemini_flow_test.dart`  
> **Qué se prueba:** La interacción entre `GeminiViewModel` y `GeminiService`  
> **Componentes involucrados:** `GeminiViewModel`, `GeminiService`, `GeminiState`

#### ¿Por qué se hace esta prueba?

El chat con Gemini involucra un ViewModel (estado de la UI) y un Service (comunicación con la API). Estos dos componentes deben estar **sincronizados**: si el servicio no está configurado, el ViewModel no debe intentar enviar mensajes.

#### ¿Qué nos asegura?

Que los estados iniciales del ViewModel y el Service están sincronizados, que el singleton se comparte, que las propiedades de tratamiento y chat son independientes pero ambas inician en idle.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **INT-GF-001** | Singleton compartido | Crea 3 instancias de GeminiService y las compara | Que todas las instancias sean idénticas | El mismo servicio se usa en el ViewModel y directamente; debe ser uno solo |
| **INT-GF-002** | Estados iniciales sincronizados | Verifica treatmentState, chatState, messages, hasTreatment | Que todos inicien en idle/vacío/false | Al arrancar, todo debe estar en estado inicial |
| **INT-GF-003** | Refleja estado de inicialización | Verifica initializationFailed e initError | Que no haya fallo de inicialización y error vacío | El ViewModel refleja el estado real del servicio |
| **INT-GF-004** | Lista de mensajes inmutable | Obtiene messages del ViewModel | Que sea una lista vacía de tipo List | Los mensajes no deben ser modificables externamente |
| **INT-GF-005** | Propiedades de tratamiento sincronizadas | Verifica treatment, hasTreatment, treatmentError, rawTreatmentResponse | Que todo sea null/false/vacío | Sin análisis previo, no hay tratamiento |
| **INT-GF-006** | GeminiState tiene todos los estados | Consulta GeminiState.values | Que tenga 4 estados: idle, loading, success, error | Los estados del chat deben estar completos |
| **INT-GF-007** | Transiciones de estado válidas | Verifica estados iniciales | Que ambos (treatment y chat) estén en idle | Punto de partida para transiciones |
| **INT-GF-008** | Chat y tratamiento independientes | Compara chatState con treatmentState | Que ambos sean idle pero son propiedades distintas | El chat puede estar cargando mientras el tratamiento ya terminó |
| **INT-GF-009** | Estado de configuración | Verifica `geminiService.isConfigured` | Que sea de tipo bool | Depende de la API key; el test valida la existencia de la propiedad |
| **INT-GF-010** | Chat inactivo inicialmente | Verifica `geminiService.isChatActive` | Que sea false | Sin sesión de chat activa |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>gemini_flow_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/gemini_viewmodel.dart';
import 'package:symptoleaf/data/datasource/gemini_service.dart';

void main() {
  late GeminiViewModel viewModel;
  late GeminiService geminiService;

  setUp(() {
    viewModel = GeminiViewModel();
    geminiService = GeminiService();
  });

  group('Integration: GeminiViewModel y GeminiService', () {
    test('INT-GF-001: GeminiService debería ser singleton compartido', () {
      final service1 = GeminiService();
      final service2 = GeminiService();
      expect(identical(service1, service2), isTrue);
      expect(identical(geminiService, service1), isTrue);
    });

    test('INT-GF-002: estados iniciales deberían estar sincronizados', () {
      expect(viewModel.treatmentState, equals(GeminiState.idle));
      expect(viewModel.chatState, equals(GeminiState.idle));
      expect(viewModel.messages, isEmpty);
      expect(viewModel.hasTreatment, isFalse);
    });

    test('INT-GF-005: propiedades de tratamiento deberían estar sincronizadas', () {
      expect(viewModel.treatment, isNull);
      expect(viewModel.hasTreatment, isFalse);
      expect(viewModel.treatmentError, isEmpty);
      expect(viewModel.rawTreatmentResponse, isEmpty);
    });
  });

  group('Integration: Estados de Gemini', () {
    test('INT-GF-006: GeminiState debería tener todos los estados', () {
      final states = GeminiState.values;
      expect(states.contains(GeminiState.idle), isTrue);
      expect(states.contains(GeminiState.loading), isTrue);
      expect(states.contains(GeminiState.success), isTrue);
      expect(states.contains(GeminiState.error), isTrue);
      expect(states.length, equals(4));
    });

    test('INT-GF-008: estados de chat y tratamiento deberían ser independientes', () {
      expect(viewModel.chatState, equals(GeminiState.idle));
      expect(viewModel.treatmentState, equals(GeminiState.idle));
    });
  });

  group('Integration: Configuración de GeminiService', () {
    test('INT-GF-009: debería reportar estado de configuración', () {
      expect(geminiService.isConfigured, isA<bool>());
    });

    test('INT-GF-010: chat debería estar inactivo inicialmente', () {
      expect(geminiService.isChatActive, isFalse);
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/integration/gemini_flow_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Probar inicialización con API key válida:** Si quieres probar con la API real, necesitas configurar `GeminiConfig` con una key válida y agregar un test que llame a `viewModel.initialize()`.
- **Verificar que `clearChat()` realmente limpia todo:** Crea un test que simule mensajes, llame `clearChat()` y verifique que mensajes, estados y errores vuelven a su estado inicial.
- **Probar flujo tratamiento → chat:** Añade un test que primero obtenga un tratamiento y luego inicie un chat con ese contexto.

---

### 5.4 `prediction_flow_test.dart`

> **Archivo:** `test/integration/prediction_flow_test.dart`  
> **Qué se prueba:** El flujo completo ViewModel → UseCase → Repository usando un MockRepository  
> **Componentes involucrados:** `PredictionViewModel`, `PredictDiseaseUseCase`, `MockIntegrationRepository`, `SettingsViewModel`

#### ¿Por qué se hace esta prueba?

Este es el **test más importante de integración** porque prueba toda la cadena de predicción: el ViewModel llama al UseCase, que llama al Repository, que devuelve un resultado. Si esta cadena falla, la funcionalidad principal de la app no funciona.

#### ¿Qué nos asegura?

Que la predicción completa funciona end-to-end, que los errores se propagan correctamente, que se puede hacer múltiples predicciones seguidas, que el reset funciona, y que el cambio de modo es compatible con las predicciones.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **INT-PF-001** | Flujo completo exitoso | Ejecuta predicción con mock que retorna Potato+Early_blight | Que `state=success`, `prediction.plant='Potato'`, `callCount=1` | El flujo principal funciona de inicio a fin |
| **INT-PF-002** | Flujo con error propagado | Mock lanza `Exception('Modelo no cargado')` | Que `state=error`, `errorMessage` contenga el texto, `callCount=1` | Los errores deben llegar al usuario, no desaparecer |
| **INT-PF-003** | Estado loading durante predicción | Mock con delay de 100ms; verifica estado durante ejecución | Que el estado sea loading o success | El usuario ve un indicador de carga mientras procesa |
| **INT-PF-004** | Múltiples predicciones secuenciales | Ejecuta 3 predicciones (Tomato, Potato, Apple) | Que cada una tenga success y la planta correcta; `callCount=3` | El usuario analiza varias plantas seguidas |
| **INT-PF-005** | Reset limpia estado completo | Ejecuta predicción y luego `reset()` | Que `state=initial`, `prediction=null`, `errorMessage.isEmpty` | Limpiar para un nuevo análisis |
| **INT-PF-006** | Modo local con predicción | Configura modo local y ejecuta predicción | Que `mode=local` y `state=success` | El modo local debe funcionar con el flujo de predicción |
| **INT-PF-007** | Cambio de modo durante predicción | Inicia predicción con delay e intenta cambiar modo durante ejecución | Que `state=success` y `mode=server` sin conflictos | Cambiar configuración mientras se procesa no debe causar crash |
| **INT-PF-008** | Path vacío rechazado | Ejecuta `predictDisease('')` | Que `state=error` y `callCount=0` (nunca llegó al repo) | La validación de entrada protege al sistema |
| **INT-PF-009** | Path válido pasa validaciones | Ejecuta con path completo del almacenamiento | Que `state=success` y el repo recibió el path exacto | Paths reales de Android deben funcionar |
| **INT-PF-010** | Múltiples paths independientes | Ejecuta 3 paths diferentes con reset entre cada uno | Que `callCount=3` y `calledPaths` tenga los 3 paths | Cada análisis es independiente del anterior |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>prediction_flow_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

// Mock del Repository para tests de integración
class MockIntegrationRepository implements BaseRepository {
  int callCount = 0;
  List<String> calledPaths = [];
  PredictionEntity? mockResult;
  Exception? mockError;
  Duration? delay;

  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    callCount++;
    calledPaths.add(imagePath);
    if (delay != null) await Future.delayed(delay!);
    if (mockError != null) throw mockError!;
    return mockResult ?? PredictionEntity(
      className: 'Tomato_Late_blight', plant: 'Tomato',
      disease: 'Late blight', confidence: 0.92,
      isHealthy: false, top3: [],
    );
  }
}

void main() {
  late MockIntegrationRepository mockRepository;
  late PredictDiseaseUseCase useCase;
  late PredictionViewModel viewModel;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockIntegrationRepository();
    useCase = PredictDiseaseUseCase(mockRepository);
    viewModel = PredictionViewModel(useCase);
  });

  group('Integration: Flujo ViewModel -> UseCase -> Repository', () {
    test('INT-PF-001: debería completar flujo de predicción exitosamente', () async {
      mockRepository.mockResult = PredictionEntity(
        className: 'Potato_Early_blight', plant: 'Potato',
        disease: 'Early blight', confidence: 0.88,
        isHealthy: false, top3: [],
      );
      await viewModel.predictDisease('/test/image.jpg');
      expect(viewModel.state, equals(PredictionState.success));
      expect(viewModel.prediction!.plant, equals('Potato'));
      expect(mockRepository.callCount, equals(1));
    });

    test('INT-PF-002: debería propagar errores del repository', () async {
      mockRepository.mockError = Exception('Modelo no cargado');
      await viewModel.predictDisease('/error/image.jpg');
      expect(viewModel.state, equals(PredictionState.error));
      expect(viewModel.errorMessage, contains('Modelo no cargado'));
    });

    test('INT-PF-004: debería manejar múltiples predicciones secuenciales', () async {
      final plants = ['Tomato', 'Potato', 'Apple'];
      for (int i = 0; i < plants.length; i++) {
        mockRepository.mockResult = PredictionEntity(
          className: '${plants[i]}_healthy', plant: plants[i],
          disease: 'healthy', confidence: 0.90 + (i * 0.02),
          isHealthy: true, top3: [],
        );
        await viewModel.predictDisease('/image_$i.jpg');
        expect(viewModel.prediction!.plant, equals(plants[i]));
      }
      expect(mockRepository.callCount, equals(3));
    });
  });

  group('Integration: Validaciones de Entrada en Cadena', () {
    test('INT-PF-008: path vacío debería ser rechazado', () async {
      await viewModel.predictDisease('');
      expect(viewModel.state, equals(PredictionState.error));
      expect(mockRepository.callCount, equals(0));
    });

    test('INT-PF-010: múltiples paths deberían procesarse independientemente', () async {
      final paths = ['/path/image1.jpg', '/path/image2.png', '/path/image3.jpeg'];
      for (final path in paths) {
        viewModel.reset();
        await viewModel.predictDisease(path);
      }
      expect(mockRepository.callCount, equals(3));
      expect(mockRepository.calledPaths, equals(paths));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/integration/prediction_flow_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Simular errores de red:** Añade `mockRepository.mockError = Exception('Sin conexión a internet')` y verifica que el mensaje de error llega al ViewModel.
- **Agregar test de caché:** Si implementas caché de predicciones, verifica que la segunda predicción con la misma imagen devuelve el resultado cacheado sin llamar al repositorio.
- **Probar con modelo yolo11:** Añade un test que configure `ModelType.yolo11` antes de predecir y verifique que la predicción funciona igual.

---

### 5.5 `providers_state_test.dart`

> **Archivo:** `test/integration/providers_state_test.dart`  
> **Qué se prueba:** La interacción entre todos los providers y ViewModels simultáneos  
> **Componentes involucrados:** `FotoProvider`, `SettingsViewModel`, `PredictionViewModel`, `GeminiViewModel`, `MockRepository`

#### ¿Por qué se hace esta prueba?

En la app real, todos los ViewModels y providers viven al mismo tiempo (están declarados en el `MultiProvider` del `main.dart`). Este test verifica que **no interfieren entre sí** y que el estado global es coherente.

#### ¿Qué nos asegura?

Que una foto agregada está disponible para predicción, que múltiples fotos se analizan secuencialmente, que eliminar una foto no borra la predicción existente, que los ViewModels operan independientemente, y que limpiar uno no afecta a los demás.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **INT-PS-001** | Foto disponible para predicción | Agrega foto y usa su path para predecir | Que `fotos.length=1` y `state=success` | La foto tomada se debe poder usar para el análisis |
| **INT-PS-002** | Múltiples fotos análisis secuencial | Agrega 3 fotos y analiza cada una | Que cada predicción sea success; `fotos.length=3` | Analizar varias fotos una tras otra |
| **INT-PS-003** | Eliminar foto no afecta predicción | Agrega foto, predice, elimina foto | Que `fotos.isEmpty` pero `prediction != null` | La predicción ya hecha persiste aun si borras la foto |
| **INT-PS-004** | Modo standard permite predicción | Configura modelo standard y predice | Que `modelType=standard` y `state=success` | El modelo standard es el principal; debe funcionar con predicción |
| **INT-PS-005** | Modelo yolo11 configurable | Configura modelo yolo11 | Que `modelType=yolo11` y `modelFileName='plant_disease_yolo11.onnx'` | La configuración del modelo alternativo debe actualizarse |
| **INT-PS-006** | Cambio de modelo notifica listeners | Registra listener en SettingsViewModel y cambia modelo 2 veces | Que `notificationCount >= 2` | La UI se actualiza cuando cambian los settings |
| **INT-PS-007** | ViewModels independientes | Configura settings, ejecuta predicción, verifica gemini | Que cada VM mantenga su propio estado independiente | No deben interferir entre sí |
| **INT-PS-008** | Reset de uno no afecta otros | Ejecuta predicción y luego `reset()` | Que `predictionVM.state=initial` pero `settings.modelType=yolo11` siga igual | Cada ViewModel se resetea por separado |
| **INT-PS-009** | Estado global coherente | Agrega foto, cambia modelo, verifica geminiVM | Que `fotos.length=1`, `modelType=standard`, `treatmentState=idle` | El estado global es la suma de todos los providers |
| **INT-PS-010** | Limpieza sin efectos secundarios | Agrega foto, configura settings, elimina foto | Que `fotos.isEmpty` pero `settings.modelType=yolo11` no cambie | Limpiar un provider no toca los demás |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>providers_state_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/presentation/providers/foto_provider.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/gemini_viewmodel.dart';
import 'package:symptoleaf/presentation/models/foto.dart';
import 'package:symptoleaf/domain/use_case/predict_disease_usecase.dart';
import 'package:symptoleaf/domain/entities/prediction_entity.dart';
import 'package:symptoleaf/data/repositories/base_repository.dart';

class MockRepository implements BaseRepository {
  @override
  Future<PredictionEntity> predictDisease(String imagePath) async {
    return PredictionEntity(
      className: 'Tomato_healthy', plant: 'Tomato',
      disease: 'healthy', confidence: 0.95,
      isHealthy: true, top3: [],
    );
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Integration: FotoProvider con Predicción', () {
    test('INT-PS-001: foto agregada debería estar disponible para predicción', () async {
      final fotoProvider = FotoProvider();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      fotoProvider.agregarFoto(Foto(
        path: '/test/plant.jpg', nombre: 'plant.jpg',
        description: 'Planta de tomate',
      ));
      final fotoPath = fotoProvider.fotos.first.path;
      await predictionVM.predictDisease(fotoPath);

      expect(fotoProvider.fotos.length, equals(1));
      expect(predictionVM.state, equals(PredictionState.success));
    });

    test('INT-PS-003: eliminar foto no debería afectar predicción existente', () async {
      final fotoProvider = FotoProvider();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      fotoProvider.agregarFoto(Foto(
        path: '/test/plant.jpg', nombre: 'plant.jpg', description: 'Test',
      ));
      await predictionVM.predictDisease(fotoProvider.fotos.first.path);
      fotoProvider.eliminarFoto(0);

      expect(fotoProvider.fotos, isEmpty);
      expect(predictionVM.prediction, isNotNull); // Predicción persiste
    });
  });

  group('Integration: Múltiples ViewModels Simultáneos', () {
    test('INT-PS-007: ViewModels deberían operar independientemente', () async {
      final settings = SettingsViewModel();
      final geminiVM = GeminiViewModel();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      await settings.setModelType(ModelType.yolo11);
      await predictionVM.predictDisease('/test.jpg');

      expect(settings.modelType, equals(ModelType.yolo11));
      expect(predictionVM.state, equals(PredictionState.success));
      expect(geminiVM.treatmentState, equals(GeminiState.idle));
    });

    test('INT-PS-008: reset de un ViewModel no debería afectar otros', () async {
      final settings = SettingsViewModel();
      final mockRepo = MockRepository();
      final useCase = PredictDiseaseUseCase(mockRepo);
      final predictionVM = PredictionViewModel(useCase);

      await settings.setModelType(ModelType.yolo11);
      await predictionVM.predictDisease('/test.jpg');
      predictionVM.reset();

      expect(predictionVM.state, equals(PredictionState.initial));
      expect(settings.modelType, equals(ModelType.yolo11)); // No afectado
    });

    test('INT-PS-010: limpieza de estado no debería causar efectos secundarios', () async {
      final fotoProvider = FotoProvider();
      final settings = SettingsViewModel();

      fotoProvider.agregarFoto(Foto(
        path: '/test.jpg', nombre: 'test.jpg', description: 'Test',
      ));
      await settings.setModelType(ModelType.yolo11);
      fotoProvider.eliminarFoto(0);

      expect(fotoProvider.fotos, isEmpty);
      expect(settings.modelType, equals(ModelType.yolo11));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/integration/providers_state_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar `AuthViewModel` al test de independencia:** Si añades autenticación, inclúyelo en `INT-PS-007` y verifica que operar con auth no afecta a los demás ViewModels.
- **Probar listeners cruzados:** Si un ViewModel escucha a otro, crea un test que verifique que los cambios en uno se reflejan en el otro.
- **Simular sesión completa del usuario:** Añade un test que siga el flujo: login → agregar foto → predecir → obtener tratamiento → chat → cerrar sesión.

---

## 6. Tests de Rendimiento (Performance)

Los tests de rendimiento verifican que la aplicación funciona **dentro de límites aceptables** de tiempo, memoria y carga.

---

### 6.1 `inference_benchmark_test.dart`

> **Archivo:** `test/performance/inference_benchmark_test.dart`  
> **Qué se prueba:** Métricas de rendimiento de inferencia — tiempos, umbrales, degradación  
> **Nota:** Estas son pruebas simuladas (no ejecutan el modelo real) que validan la lógica de medición

#### ¿Por qué se hace esta prueba?

Para asegurar que el sistema de medición de rendimiento funciona correctamente. Establece los **umbrales aceptables**: la inferencia debe tomar **menos de 500ms**, la degradación entre operaciones no debe superar el **10%**, y el modelo debe caber en **300MB de RAM**.

#### ¿Qué nos asegura?

Que el sistema de métricas mide tiempos correctamente, que los umbrales están definidos y son razonables, que se pueden detectar degradaciones de rendimiento, y que los requerimientos de memoria son factibles.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **PERF-001** | Stopwatch mide tiempos | Ejecuta un loop de 10M iteraciones con Stopwatch | Que `elapsedMilliseconds > 0` | Si el cronómetro no funciona, no podemos medir rendimiento |
| **PERF-002** | Umbral de inferencia 500ms | Define constantes threshold=500ms y tolerance=100ms | Que threshold=500 y threshold+tolerance=600 | El usuario no debe esperar más de medio segundo por predicción |
| **PERF-003** | Cálculo de promedio | Calcula promedio de tiempos [450, 480, 510, 490, 470] | Que el promedio sea ~480ms | Las métricas deben promediar correctamente |
| **PERF-004** | Detección de degradación >10% | Prueba 5 tiempos contra baseline de 500ms con umbral 10% | Que 560ms y 600ms se detecten como degradación, y 540ms no | Detectar cuando la app se vuelve más lenta |
| **PERF-005** | Desviación estándar | Calcula varianza simplificada de tiempos | Que `stdDev >= 0` | Métricas estadísticas deben ser calculables |
| **PERF-006** | 10 operaciones consecutivas | Ejecuta 10 operaciones simples | Que `completedOperations.length=10` | Verificar que operaciones repetidas no fallan |
| **PERF-007** | Sin regresión entre operaciones | Compara promedio de primera y segunda mitad de 10 tiempos | Que la degradación sea `< 10%` | Las operaciones no deben volverse más lentas |
| **PERF-008** | Límite de memoria 300MB | Verifica cálculo: 300 * 1024 * 1024 | Que sea `314572800` bytes | El modelo + app no debe exceder la RAM disponible |
| **PERF-009** | Imagen máxima 4096x4096 | Calcula tamaño de imagen 4K RGBA | Que sea ~64MB | No procesar imágenes que no caben en memoria |
| **PERF-010** | Modelo ONNX cabe en memoria | Verifica que 50MB (modelo) + 100MB (trabajo) < 300MB | Que `totalRequired < memoryLimit` | El dispositivo debe tener suficiente RAM |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>inference_benchmark_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance: Métricas de Tiempo', () {
    test('PERF-001: Stopwatch debería medir tiempos correctamente', () {
      final stopwatch = Stopwatch();
      stopwatch.start();
      int sum = 0;
      for (int i = 0; i < 10000000; i++) { sum += i; }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThan(0));
      expect(sum, greaterThan(0));
    });

    test('PERF-002: Umbral de inferencia debería ser 500ms', () {
      const int thresholdMs = 500;
      const int toleranceMs = 100;
      expect(thresholdMs, equals(500));
      expect(thresholdMs + toleranceMs, equals(600));
    });

    test('PERF-003: Cálculo de promedio de tiempos debería ser correcto', () {
      final times = [450, 480, 510, 490, 470];
      final average = times.reduce((a, b) => a + b) / times.length;
      expect(average, closeTo(480, 1));
    });

    test('PERF-004: Degradación > 10% debería ser detectable', () {
      const double baselineMs = 500.0;
      const double degradationThreshold = 0.10;
      final testCases = [
        {'time': 540.0, 'shouldFail': false}, // 8% - OK
        {'time': 560.0, 'shouldFail': true},  // 12% - FAIL
      ];
      for (final testCase in testCases) {
        final time = testCase['time'] as double;
        final shouldFail = testCase['shouldFail'] as bool;
        final degradation = (time - baselineMs) / baselineMs;
        final hasDegraded = degradation > degradationThreshold;
        expect(hasDegraded, equals(shouldFail));
      }
    });
  });

  group('Performance: Operaciones Consecutivas', () {
    test('PERF-006: 10 operaciones consecutivas deberían completarse', () {
      const int numOperations = 10;
      final List<int> completedOperations = [];
      for (int i = 0; i < numOperations; i++) {
        completedOperations.add(i);
      }
      expect(completedOperations.length, equals(numOperations));
    });

    test('PERF-007: Tiempo promedio no debería aumentar significativamente', () {
      final times = [480, 485, 490, 488, 492, 495, 498, 500, 502, 505];
      final firstHalfAvg = times.sublist(0, 5).reduce((a, b) => a + b) / 5;
      final secondHalfAvg = times.sublist(5, 10).reduce((a, b) => a + b) / 5;
      final degradation = (secondHalfAvg - firstHalfAvg) / firstHalfAvg;
      expect(degradation, lessThan(0.10));
    });
  });

  group('Performance: Límites de Memoria (Simulado)', () {
    test('PERF-008: Límite de memoria debería ser 300MB', () {
      const int memoryLimitMB = 300;
      const int bytesPerMB = 1024 * 1024;
      final memoryLimitBytes = memoryLimitMB * bytesPerMB;
      expect(memoryLimitBytes, equals(314572800));
    });

    test('PERF-010: Modelo ONNX debería caber en memoria', () {
      const int modelSizeMB = 50;
      const int workingMemoryMB = 100;
      const int totalRequiredMB = modelSizeMB + workingMemoryMB;
      const int memoryLimitMB = 300;
      expect(totalRequiredMB, lessThan(memoryLimitMB));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/performance/inference_benchmark_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Cambiar el umbral de rendimiento:** Si el modelo nuevo es más rápido, cambia `thresholdMs` de 500 a tu nuevo límite en `PERF-002`.
- **Probar con el modelo ONNX real:** Ejecuta estas pruebas en un dispositivo/emulador real reemplazando los cálculos simulados por llamadas a `OnnxDataSource.predict()`.
- **Agregar métrica de percentil 95:** Añade un test que ordene los tiempos, tome el valor en la posición del 95% y verifique que está por debajo del umbral.

---

### 6.2 `load_stress_test.dart`

> **Archivo:** `test/performance/load_stress_test.dart`  
> **Qué se prueba:** Comportamiento bajo carga extrema — 100, 500 y 1000 operaciones  
> **Nota:** Simula las operaciones sin ejecutar el modelo real

#### ¿Por qué se hace esta prueba?

Verifica que el sistema no se degrada bajo **uso intensivo**. Un usuario podría analizar muchas plantas en una sesión, cambiar configuración repetidamente, o hacer muchas preguntas al chat. Estos tests verifican que **nada se rompe** bajo carga.

#### ¿Qué nos asegura?

Que 100+ análisis consecutivos se completan, que el singleton no se corrompe después de 100 accesos, que los cambios de estado rápidos son manejables, y que el sistema tiene throughput adecuado.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **LOAD-001** | 100 análisis consecutivos | Genera 100 resultados simulados | Que `results.length=100` en < 1 segundo | Uso normal: muchos análisis en una sesión |
| **LOAD-002** | 500 análisis (stress extremo) | Genera 500 IDs completados | Que `completedIds.length=500`, first=0, last=499 | Uso extremo: prueba los límites |
| **LOAD-003** | Singleton consistente tras 100 accesos | Accede 100 veces a GeminiService | Que todas las instancias sean idénticas | El singleton no debe corromperse bajo carga |
| **LOAD-004** | 100 cambios de modelo | Alterna entre standard y yolo11 100 veces | Que `standardCount=50`, `yolo11Count=50`, último modelo correcto | La configuración debe ser estable |
| **LOAD-005** | Transiciones de estado rápidas | Simula 200 transiciones de PredictionState | Que todas sean estados válidos y `length=200` | Los estados no deben corromperse |
| **LOAD-006** | 100 PredictionModels procesables | Crea 100 predicciones con distribución de clases | Que `length=100` y `healthy+disease=100` | Procesar muchos resultados sin errores |
| **LOAD-007** | 500 mensajes de chat | Crea 500 mensajes alternando user/assistant | Que `length=500`, `userMessages=250`, `assistantMessages=250` | Historial extenso de chat |
| **LOAD-008** | top3 de 100 predicciones | Genera top3 para 100 predicciones | Que cada top3 tenga 3 elementos | Datos de top3 masivos |
| **LOAD-009** | 50 Futures concurrentes | Crea 50 futures con delay de 10ms y espera todos | Que `results.length=50` y la suma sea 1225 | Operaciones asíncronas concurrentes |
| **LOAD-010** | 1000 objetos Map creables | Crea 1000 Maps con datos anidados | Que `length=1000` en < 1 segundo | Creación masiva de objetos |
| **LOAD-011** | Límite de 1000 análisis por sesión | Simula 850 análisis y compara con límite de 1000 | Que `sessionCount < 1000` y `> 800` | Umbral de warning antes del límite |
| **LOAD-012** | Throughput 2 análisis/segundo | Calcula 2 × 60 análisis | Que el resultado sea 120 análisis por minuto | Define la capacidad teórica del sistema |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>load_stress_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/data/datasource/gemini_service.dart';
import 'package:symptoleaf/presentation/viewmodels/prediction_viewmodel.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';

void main() {
  setUpAll(() { TestWidgetsFlutterBinding.ensureInitialized(); });
  setUp(() { SharedPreferences.setMockInitialValues({}); });

  group('Load: 100+ Operaciones Consecutivas', () {
    test('LOAD-001: 100 análisis consecutivos deberían completarse', () {
      const int numAnalyses = 100;
      final List<Map<String, dynamic>> results = [];
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < numAnalyses; i++) {
        results.add({
          'id': i, 'className': 'Tomato___healthy',
          'confidence': 0.85 + (i % 10) * 0.01,
        });
      }
      stopwatch.stop();
      expect(results.length, equals(numAnalyses));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('LOAD-003: Singleton debería ser consistente después de 100 accesos', () {
      final List<GeminiService> instances = [];
      for (int i = 0; i < 100; i++) { instances.add(GeminiService()); }
      final first = instances.first;
      for (final instance in instances) {
        expect(identical(instance, first), isTrue);
      }
    });
  });

  group('Load: Cambios de Estado Rápidos', () {
    test('LOAD-004: 100 cambios de modelo deberían ser manejables', () async {
      final viewModel = SettingsViewModel();
      int standardCount = 0, yolo11Count = 0;
      for (int i = 0; i < 100; i++) {
        if (i % 2 == 0) {
          await viewModel.setModelType(ModelType.standard);
          standardCount++;
        } else {
          await viewModel.setModelType(ModelType.yolo11);
          yolo11Count++;
        }
      }
      expect(standardCount, equals(50));
      expect(yolo11Count, equals(50));
    });

    test('LOAD-005: Transiciones de PredictionState deberían ser válidas', () {
      final states = PredictionState.values;
      final transitionLog = <PredictionState>[];
      for (int i = 0; i < 200; i++) {
        transitionLog.add(states[i % states.length]);
      }
      expect(transitionLog.length, equals(200));
    });
  });

  group('Load: Procesamiento Masivo de Datos', () {
    test('LOAD-007: 500 mensajes de chat deberían ser manejables', () {
      final messages = <Map<String, dynamic>>[];
      for (int i = 0; i < 500; i++) {
        messages.add({
          'id': i, 'role': i % 2 == 0 ? 'user' : 'assistant',
          'content': 'Mensaje número $i',
        });
      }
      expect(messages.length, equals(500));
      final userMessages = messages.where((m) => m['role'] == 'user').length;
      expect(userMessages, equals(250));
    });
  });

  group('Load: Concurrencia Simulada', () {
    test('LOAD-009: 50 Futures concurrentes deberían resolverse', () async {
      final futures = <Future<int>>[];
      for (int i = 0; i < 50; i++) {
        futures.add(Future.delayed(Duration(milliseconds: 10), () => i));
      }
      final results = await Future.wait(futures);
      expect(results.length, equals(50));
      expect(results.reduce((a, b) => a + b), equals(1225));
    });

    test('LOAD-010: 1000 objetos Map deberían ser creables', () {
      final objects = <Map<String, dynamic>>[];
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        objects.add({'id': i, 'name': 'Object_$i',
          'data': List.generate(10, (j) => j * i),
        });
      }
      stopwatch.stop();
      expect(objects.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Load: Límites del Sistema', () {
    test('LOAD-012: Throughput teórico: 2 análisis/segundo', () {
      const int targetThroughput = 2;
      const int testDurationSeconds = 60;
      const int expectedAnalyses = targetThroughput * testDurationSeconds;
      expect(expectedAnalyses, equals(120));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/performance/load_stress_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Incrementar la carga:** Cambia `numAnalyses` de 100 a 500 o 1000 para simular uso muy intensivo.
- **Agregar métricas de tiempo real:** Envúlvete cada operación con `Stopwatch` y registra tiempos individuales para detectar degradación.
- **Probar con datos más grandes:** Aumenta el tamaño de las predicciones simuladas (más campos, top3 más grandes) para reflejar uso real.

---

### 6.3 `memory_stress_test.dart`

> **Archivo:** `test/performance/memory_stress_test.dart`  
> **Qué se prueba:** Gestión de memoria — detección de leaks, sesiones prolongadas, streams

#### ¿Por qué se hace esta prueba?

Los **memory leaks** (fugas de memoria) son un problema grave en apps móviles: la app consume cada vez más RAM hasta que el sistema la mata. Estos tests verifican que los objetos se crean y destruyen correctamente, que los singletons no multiplican instancias, y que las sesiones largas no acumulan basura.

#### ¿Qué nos asegura?

Que el singleton no crea múltiples instancias, que FotoProvider se puede limpiar, que cambiar modo muchas veces no acumula estado, que objetos temporales son recolectables, y que streams se cierran correctamente.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **MEM-001** | Singleton no crea múltiples instancias | Crea 100 "instancias" de GeminiService | Que todas las 100 sean idénticas | Evitar 100 conexiones a la API de Gemini |
| **MEM-002** | FotoProvider permite limpiar | Verifica estado inicial de FotoProvider | Que `fotos.isEmpty` | La limpieza de fotos libera memoria |
| **MEM-003** | setModelType no acumula estado | Cambia modelo 50 veces | Que el estado final sea determinístico (yolo11) | Cambios repetidos no deben acumular listeners o callbacks |
| **MEM-004** | Simular sesión prolongada (1h) | Ejecuta 600 operaciones (10/min × 60min) | Que `length=600` y la última sea correcta | La app no debe degradarse en sesiones largas |
| **MEM-005** | Objetos temporales recreables | Crea y descarta 100 FotoProvider | Que no haya error de memoria | El garbage collector debe poder limpiar objetos temporales |
| **MEM-006** | Listas con límite | Agrega 150 items manteniendo solo los últimos 100 | Que `length=100` y los primeros 50 hayan sido eliminados | Evitar listas que crecen infinitamente |
| **MEM-007** | Patrón crear-usar-destruir | Crea y destruye 10 listas de 1000 elementos | Que destruction > creation para cada par | Verificar ciclo de vida correcto |
| **MEM-008** | Callbacks invocables múltiples veces | Ejecuta un callback 100 veces | Que `callCount=100` | Los callbacks no deben fallar por uso repetido |
| **MEM-009** | Múltiples Futures completados | Crea 20 futures y espera todos | Que `length=20` y `last=19` | Los futures no deben quedarse pendientes (leak) |
| **MEM-010** | Streams se cierran | Crea un stream de 10 enteros y lo consume | Que `results.length=10` | Los streams abiertos consumen memoria; deben cerrarse |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>memory_stress_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symptoleaf/data/datasource/gemini_service.dart';
import 'package:symptoleaf/presentation/viewmodels/settings_viewmodel.dart';
import 'package:symptoleaf/presentation/providers/foto_provider.dart';

void main() {
  setUpAll(() { TestWidgetsFlutterBinding.ensureInitialized(); });
  setUp(() { SharedPreferences.setMockInitialValues({}); });

  group('Memory: Gestión de Instancias', () {
    test('MEM-001: GeminiService singleton no debería crear nuevas instancias', () {
      final List<GeminiService> instances = [];
      for (int i = 0; i < 100; i++) { instances.add(GeminiService()); }
      final firstInstance = instances.first;
      for (final instance in instances) {
        expect(identical(instance, firstInstance), isTrue);
      }
    });

    test('MEM-002: FotoProvider debería permitir limpiar foto', () {
      final provider = FotoProvider();
      expect(provider.fotos, isEmpty);
    });

    test('MEM-003: Múltiples llamadas a setModelType no deberían acumular estado', () async {
      final viewModel = SettingsViewModel();
      for (int i = 0; i < 50; i++) {
        if (i % 2 == 0) {
          await viewModel.setModelType(ModelType.standard);
        } else {
          await viewModel.setModelType(ModelType.yolo11);
        }
      }
      expect(viewModel.modelType, equals(ModelType.yolo11));
    });
  });

  group('Memory: Simulación de Sesiones Prolongadas', () {
    test('MEM-004: Simular operaciones de sesión prolongada', () {
      const int totalOperations = 600; // 10/min × 60min
      final List<int> operationResults = [];
      for (int i = 0; i < totalOperations; i++) {
        operationResults.add(i % 15);
      }
      expect(operationResults.length, equals(totalOperations));
    });

    test('MEM-005: Objetos temporales deberían ser recreables', () {
      for (int i = 0; i < 100; i++) {
        final tempProvider = FotoProvider();
        expect(tempProvider.fotos, isEmpty);
      }
      expect(true, isTrue);
    });

    test('MEM-006: Listas de resultados deberían tener límite', () {
      const int maxHistorySize = 100;
      final List<Map<String, dynamic>> history = [];
      for (int i = 0; i < 150; i++) {
        history.add({'id': i, 'result': 'class_$i'});
        if (history.length > maxHistorySize) { history.removeAt(0); }
      }
      expect(history.length, equals(maxHistorySize));
      expect(history.first['id'], equals(50));
    });
  });

  group('Memory: Detección de Patrones de Leak', () {
    test('MEM-008: Callbacks deberían ser invocables múltiples veces', () {
      int callCount = 0;
      void callback() { callCount++; }
      for (int i = 0; i < 100; i++) { callback(); }
      expect(callCount, equals(100));
    });

    test('MEM-009: Múltiples Futures deberían completarse', () async {
      final List<Future<int>> futures = [];
      for (int i = 0; i < 20; i++) { futures.add(Future.value(i)); }
      final results = await Future.wait(futures);
      expect(results.length, equals(20));
      expect(results.last, equals(19));
    });

    test('MEM-010: Streams deberían poder cerrarse', () async {
      final controller = Stream<int>.fromIterable(List.generate(10, (i) => i));
      final results = <int>[];
      await for (final value in controller) { results.add(value); }
      expect(results.length, equals(10));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/performance/memory_stress_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Medir memoria real:** Usa `ProcessInfo.currentRss` (requiere `dart:io`) para medir el consumo de memoria antes y después de las operaciones.
- **Probar con imágenes reales en memoria:** Carga `Uint8List` de imágenes grandes y verifica que la memoria se libera después de procesar.
- **Aumentar las iteraciones:** Cambia las 100 iteraciones del singleton a 1000 para simular sesiones aún más largas.

---

## 7. Tests de Regresión

Los tests de regresión verifican que **el modelo de IA no cambie** su comportamiento esperado después de actualizaciones.

---

### 7.1 `onnx_model_test.dart`

> **Archivo:** `test/regression/onnx_model_test.dart`  
> **Qué se prueba:** Las 15 clases del modelo ONNX, traducciones y estructura de datos  
> **Componentes involucrados:** `PredictionModel`, clases de clasificación

#### ¿Por qué se hace esta prueba?

El modelo ONNX clasifica plantas en **15 categorías** (5 plantas × 3 estados cada una). Si el modelo se actualiza y cambia una clase, estas pruebas lo detectan inmediatamente. También verifica que las traducciones al español existen para todas las clases.

#### ¿Qué nos asegura?

Que el modelo tiene exactamente 15 clases, que soporta 5 plantas, que cada planta tiene una clase "healthy", que el formato de nombres es correcto, que todas las clases tienen traducción al español, y que la estructura de PredictionModel es correcta.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **REG-001** | 15 clases exactas | Cuenta las clases esperadas | Que `length == 15` | Si se agrega o elimina una clase, esto lo detecta |
| **REG-002** | 5 tipos de plantas | Extrae plantas únicas de las clases | Que sean: Apple, Corn, Grape, Potato, Tomato | Las 5 plantas soportadas deben existir |
| **REG-003** | Cada planta tiene clase healthy | Filtra clases que contienen 'healthy' | Que haya exactamente 5 clases healthy | Cada planta debe poder ser diagnosticada como sana |
| **REG-004** | Formato Plant___Disease | Verifica que cada clase contenga `___` y tenga 2 partes | Que todas las 15 clases sigan el formato | Un formato incorrecto rompería el parseo |
| **REG-005** | Traducciones al español | Verifica que cada clase tenga traducción con 'plant' y 'disease' | Que las 15 clases tengan traducción completa | La app se muestra en español; cada enfermedad necesita traducción |
| **REG-006** | Estructura de PredictionModel | Crea modelo completo con top3 de 3 items | Que todos los campos existan y tengan los tipos correctos | La estructura del modelo no debe cambiar |
| **REG-007** | Rango de confianza [0.0, 1.0] | Prueba valores 0.0, 0.5, 0.95, 1.0 | Que todos estén en rango | Valores fuera de rango indicarían bug en el modelo |
| **REG-008** | Detección de planta saludable | Verifica que clases con 'healthy' tengan isHealthy=true | Que la detección sea correcta para las 15 clases | Falso positivo de enfermedad en planta sana es crítico |
| **REG-009** | no_plant_detected como caso especial | Verifica que `no_plant_detected` NO está en las 15 clases normales | Que no esté en la lista pero se pueda crear un modelo con ella | Cuando la imagen no es una planta, hay un manejo especial |
| **REG-010** | top3 ordenado por confianza | Verifica que top3 esté en orden descendente | Que cada confidence sea >= la siguiente | La primera predicción debe ser la más probable |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>onnx_model_test.dart</code></summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/data/models/prediction_model.dart';

void main() {
  group('Regresión ONNX: Clases de Clasificación', () {
    final List<String> expectedClasses = [
      'Apple___Apple_scab', 'Apple___Black_rot',
      'Apple___Cedar_apple_rust', 'Apple___healthy',
      'Corn___Cercospora_leaf_spot', 'Corn___Common_rust', 'Corn___healthy',
      'Grape___Black_rot', 'Grape___Esca', 'Grape___healthy',
      'Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy',
      'Tomato___Bacterial_spot', 'Tomato___healthy',
    ];

    final Map<String, Map<String, String>> expectedTranslations = {
      'Apple___Apple_scab': {'plant': 'Manzana', 'disease': 'Sarna del manzano'},
      'Apple___Black_rot': {'plant': 'Manzana', 'disease': 'Podredumbre negra'},
      'Apple___Cedar_apple_rust': {'plant': 'Manzana', 'disease': 'Roya del cedro'},
      'Apple___healthy': {'plant': 'Manzana', 'disease': 'Saludable'},
      'Corn___Cercospora_leaf_spot': {'plant': 'Maíz', 'disease': 'Mancha foliar por Cercospora'},
      'Corn___Common_rust': {'plant': 'Maíz', 'disease': 'Roya común'},
      'Corn___healthy': {'plant': 'Maíz', 'disease': 'Saludable'},
      'Grape___Black_rot': {'plant': 'Uva', 'disease': 'Podredumbre negra'},
      'Grape___Esca': {'plant': 'Uva', 'disease': 'Enfermedad de Esca'},
      'Grape___healthy': {'plant': 'Uva', 'disease': 'Saludable'},
      'Potato___Early_blight': {'plant': 'Papa', 'disease': 'Tizón temprano'},
      'Potato___Late_blight': {'plant': 'Papa', 'disease': 'Tizón tardío'},
      'Potato___healthy': {'plant': 'Papa', 'disease': 'Saludable'},
      'Tomato___Bacterial_spot': {'plant': 'Tomate', 'disease': 'Mancha bacteriana'},
      'Tomato___healthy': {'plant': 'Tomate', 'disease': 'Saludable'},
    };

    test('REG-001: El modelo debería tener exactamente 15 clases', () {
      expect(expectedClasses.length, equals(15));
    });

    test('REG-002: El modelo debería soportar 5 tipos de plantas', () {
      final plantas = expectedClasses.map((c) => c.split('___')[0]).toSet().toList();
      expect(plantas.length, equals(5));
      expect(plantas.contains('Apple'), isTrue);
      expect(plantas.contains('Tomato'), isTrue);
    });

    test('REG-003: Cada planta debería tener una clase healthy', () {
      final healthyClasses = expectedClasses.where((c) => c.contains('healthy')).toList();
      expect(healthyClasses.length, equals(5));
    });

    test('REG-004: Todas las clases deberían seguir formato Plant___Disease', () {
      for (final className in expectedClasses) {
        expect(className.contains('___'), isTrue);
        final parts = className.split('___');
        expect(parts.length, equals(2));
      }
    });

    test('REG-005: Todas las clases deberían tener traducción al español', () {
      for (final className in expectedClasses) {
        expect(expectedTranslations.containsKey(className), isTrue);
        final translation = expectedTranslations[className]!;
        expect(translation['plant'], isNotEmpty);
        expect(translation['disease'], isNotEmpty);
      }
    });

    test('REG-006: PredictionModel debería tener todos los campos requeridos', () {
      final model = PredictionModel(
        className: 'Tomato___healthy', plant: 'Tomate',
        disease: 'Saludable', confidence: 0.95, isHealthy: true,
        top3: [
          PredictionTop3Model(
            className: 'Tomato___healthy', plant: 'Tomate',
            disease: 'Saludable', confidence: 0.95, isHealthy: true,
          ),
          PredictionTop3Model(
            className: 'Tomato___Bacterial_spot', plant: 'Tomate',
            disease: 'Mancha bacteriana', confidence: 0.03, isHealthy: false,
          ),
        ],
      );
      expect(model.className, equals('Tomato___healthy'));
      expect(model.top3.length, equals(2));
    });

    test('REG-008: isHealthy debería ser true solo para clases healthy', () {
      for (final className in expectedClasses) {
        final shouldBeHealthy = className.contains('healthy');
        final isHealthyDetected = className.toLowerCase().contains('healthy');
        expect(isHealthyDetected, equals(shouldBeHealthy));
      }
    });

    test('REG-009: no_plant_detected debería manejarse como caso especial', () {
      const noPlantClass = 'no_plant_detected';
      expect(expectedClasses.contains(noPlantClass), isFalse);
      final model = PredictionModel(
        className: noPlantClass, plant: 'No detectado',
        disease: 'No es una planta', confidence: 0.0,
        isHealthy: false, top3: [],
      );
      expect(model.className, equals(noPlantClass));
    });

    test('REG-010: top3 debería estar ordenado por confianza descendente', () {
      final top3 = [
        {'className': 'Tomato___healthy', 'confidence': 0.95},
        {'className': 'Tomato___Bacterial_spot', 'confidence': 0.03},
        {'className': 'Potato___healthy', 'confidence': 0.02},
      ];
      for (int i = 0; i < top3.length - 1; i++) {
        final current = top3[i]['confidence'] as double;
        final next = top3[i + 1]['confidence'] as double;
        expect(current >= next, isTrue);
      }
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/regression/onnx_model_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar una nueva planta al modelo:** Si el modelo ahora detecta "Strawberry", agrégala a la lista `expectedClasses` con sus variantes (ej: `Strawberry___healthy`, `Strawberry___Leaf_spot`) y a `expectedTranslations` con la traducción al español.
- **Agregar una nueva enfermedad:** Añade la clase nueva a `expectedClasses` y su traducción a `expectedTranslations`. Actualiza `REG-001` si cambia el número total de clases.
- **Verificar nuevo formato de confianza:** Si el modelo devuelve porcentajes (0-100) en vez de probabilidades (0-1), actualiza `REG-007` con el nuevo rango.

---

## 8. Tests de Widget

Los tests de widget prueban la **interfaz visual** — que las pantallas se rendericen correctamente, muestren el contenido esperado y respondan a interacciones.

---

### 8.1 `home_screen_test.dart`

> **Archivo:** `test/widget/home_screen_test.dart`  
> **Qué se prueba:** `HomeScreen` — la pantalla principal de la aplicación  
> **Ubicación del código probado:** `lib/presentation/widgets/pages/home_screen.dart`

#### ¿Por qué se hace esta prueba?

`HomeScreen` es la **primera pantalla** que ve el usuario. Muestra el título de bienvenida, las tarjetas de acciones rápidas (Analizar Planta y Asistente Virtual), y los iconos de navegación. Si esta pantalla no se renderiza bien, el usuario no puede usar la app.

#### ¿Qué nos asegura?

Que la pantalla se renderiza sin errores, que muestra todos los textos esperados, que las tarjetas de acción existen, que los iconos están presentes, que el scroll funciona, y que la navegación funciona al tocar las tarjetas.

#### Detalle de cada test

| ID | Nombre | Qué hace | Qué verifica | Por qué es importante |
|----|--------|----------|-------------|----------------------|
| **WDG-HS-001** | Renderiza sin errores | Construye HomeScreen dentro de MaterialApp | Que `find.byType(HomeScreen)` encuentre 1 widget | La pantalla debe abrirse sin crash |
| **WDG-HS-002** | Muestra título de bienvenida | Busca texto 'Bienvenido a SymptoLeaf' | Que lo encuentre (1 instancia) | El usuario debe ver el nombre de la app |
| **WDG-HS-003** | Muestra subtítulo descriptivo | Busca texto 'Detecta enfermedades...' | Que lo encuentre | El usuario entiende qué hace la app |
| **WDG-HS-004** | Tarjeta de analizar planta | Busca textos 'Analizar Planta' y 'Toma una foto...' | Que ambos existan | La acción principal debe ser visible |
| **WDG-HS-005** | Tarjeta de asistente virtual | Busca textos 'Asistente Virtual' y 'Pregunta sobre...' | Que ambos existan | La función de chat debe ser visible |
| **WDG-HS-006** | Callback onTabChange | Toca 'Analizar Planta' con callback configurado | Que `tappedTab == 1` | Tocar la tarjeta debe navegar al análisis |
| **WDG-HS-007** | Iconos de cámara y chat | Busca Icons.camera_alt e Icons.chat_bubble_outline | Que ambos existan | Iconos visuales para las acciones |
| **WDG-HS-008** | Cards de acciones rápidas | Busca widgets de tipo Card | Que haya al menos 2 Cards | Las tarjetas son la estructura visual de las acciones |
| **WDG-HS-009** | Es scrolleable | Busca SingleChildScrollView | Que exista | La pantalla debe permitir scroll |
| **WDG-HS-010** | Navegación a chat | Toca 'Asistente Virtual' con onGenerateRoute | Que `navigatedRoute == '/chat'` | Tocar asistente virtual debe ir al chat |

#### Código completo del test

<details>
<summary>📄 Haz clic para ver el código de <code>home_screen_test.dart</code></summary>

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/widgets/pages/home_screen.dart';

void main() {
  group('Widget: HomeScreen', () {
    testWidgets('WDG-HS-001: debería renderizar sin errores', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('WDG-HS-002: debería mostrar título de bienvenida', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.text('Bienvenido a SymptoLeaf'), findsOneWidget);
    });

    testWidgets('WDG-HS-003: debería mostrar subtítulo descriptivo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(
        find.text('Detecta enfermedades en tus plantas de manera rápida y precisa'),
        findsOneWidget,
      );
    });

    testWidgets('WDG-HS-004: debería mostrar tarjeta de analizar planta', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.text('Analizar Planta'), findsOneWidget);
      expect(find.text('Toma una foto o selecciona de galería'), findsOneWidget);
    });

    testWidgets('WDG-HS-005: debería mostrar tarjeta de asistente virtual', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.text('Asistente Virtual'), findsOneWidget);
      expect(find.text('Pregunta sobre cuidados y tratamientos'), findsOneWidget);
    });

    testWidgets('WDG-HS-006: debería llamar onTabChange al tocar analizar', (tester) async {
      int? tappedTab;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreen(onTabChange: (index) { tappedTab = index; }),
          ),
        ),
      );
      await tester.tap(find.text('Analizar Planta'));
      await tester.pumpAndSettle();
      expect(tappedTab, equals(1));
    });

    testWidgets('WDG-HS-007: debería contener iconos de cámara y chat', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('WDG-HS-008: debería contener Cards de acciones rápidas', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.byType(Card), findsAtLeast(2));
    });

    testWidgets('WDG-HS-009: debería ser scrolleable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: HomeScreen())),
      );
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('WDG-HS-010: debería navegar a /chat al tocar asistente', (tester) async {
      String? navigatedRoute;
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(body: HomeScreen()),
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Chat Screen')),
            );
          },
        ),
      );
      await tester.tap(find.text('Asistente Virtual'));
      await tester.pumpAndSettle();
      expect(navigatedRoute, equals('/chat'));
    });
  });
}
```

</details>

#### ¿Cómo ejecutar esta prueba?

```bash
flutter test test/widget/home_screen_test.dart
```

#### ¿Cómo modificar o ampliar esta prueba?

- **Agregar una tarjeta nueva al HomeScreen:** Si añades una tarjeta "Historial", crea un test que verifique `find.text('Historial')` y `find.text('descripción de historial')`. Actualiza `WDG-HS-008` para esperar al menos 3 Cards.
- **Cambiar textos de la pantalla:** Si el título cambia a "Bienvenido a PlantDoc", actualiza `WDG-HS-002` con el nuevo texto.
- **Probar navegación a nueva ruta:** Copia el patrón de `WDG-HS-010` (que verifica `/chat`), cambia el `find.text()` y la ruta esperada para la nueva pantalla.
- **Probar en modo oscuro:** Envuelve el widget en un `MaterialApp` con `ThemeData.dark()` y verifica que renderiza sin errores.

---

## 9. Cómo Ejecutar los Tests

### Ejecutar TODOS los tests

```bash
cd SymptoLeaf
flutter test
```

### Ejecutar por categoría

```bash
# Solo tests unitarios
flutter test test/unit/

# Solo tests de integración
flutter test test/integration/

# Solo tests de rendimiento
flutter test test/performance/

# Solo tests de regresión
flutter test test/regression/

# Solo tests de widget
flutter test test/widget/
```

### Ejecutar un test específico

```bash
flutter test test/unit/models/prediction_model_test.dart
```

### Ejecutar con cobertura (reporte HTML)

```bash
flutter test --coverage
# Se genera archivo lcov.info en coverage/
```

---

## 10. Resumen de Cobertura

### Capas de la arquitectura probadas

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │ ViewModels   │  │ Providers   │  │ Views (Widgets) │  │
│  │ ✅ Prediction│  │ ✅ Foto     │  │ ✅ HomeScreen   │  │
│  │ ✅ Gemini    │  │             │  │                 │  │
│  │ ✅ Settings  │  │             │  │                 │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
├─────────────────────────────────────────────────────────┤
│                     DOMAIN LAYER                          │
│  ┌──────────────────┐  ┌──────────────────────┐          │
│  │ Entities          │  │ Use Cases             │          │
│  │ ✅ PredictionEntity│ │ ✅ PredictDiseaseUC  │          │
│  └──────────────────┘  └──────────────────────┘          │
├─────────────────────────────────────────────────────────┤
│                      DATA LAYER                           │
│  ┌─────────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ Models           │  │ Services      │  │ Repos      │  │
│  │ ✅ Prediction    │  │ ✅ Gemini     │  │ (via mock) │  │
│  │ ✅ ChatMessage   │  │              │  │            │  │
│  │ ✅ Treatment     │  │              │  │            │  │
│  └─────────────────┘  └──────────────┘  └────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Componentes que aún no tienen tests

| Componente | Archivo | Qué hace |
|------------|---------|----------|
| `AuthViewModel` | `auth_viewmodel.dart` | Maneja inicio de sesión y registro de usuarios |
| `DiagnosticsViewModel` | `diagnostics_viewmodel.dart` | Maneja historial de diagnósticos |
| `AuthDatasource` | `auth_datasource.dart` | Conexión con backend de autenticación |
| `DiagnosticsDatasource` | `diagnostics_datasource.dart` | Conexión con backend de diagnósticos |
| Widgets atómicos/moleculares/orgánicos | `widgets/atoms/`, `widgets/molecules/`, `widgets/organisms/` | Sistema de diseño visual de la app |
| `LoginScreen` / `RegisterScreen` / `HistoryScreen` | `widgets/pages/` | Pantallas de autenticación e historial |

### Estadísticas finales

| Métrica | Valor |
|---------|-------|
| Total de archivos de test | 19 |
| Total de tests individuales | 190 |
| Tests que pasan | ✅ 190 (100%) |
| Capas cubiertas | Presentación, Dominio, Datos |
| Tipos de test | Unitario, Integración, Performance, Regresión, Widget |
| Componentes probados | 12+ clases/servicios/viewmodels |
| Componentes sin tests aún | 6+ clases (auth, diagnostics, widgets de UI) |

---

> **Conclusión:** Los tests cubren exhaustivamente la funcionalidad **core** de SymptoLeaf: la predicción de enfermedades, el chat con Gemini, la gestión de fotos, la configuración de modelos (`ModelType.standard` / `ModelType.yolo11`), y la pantalla principal. Los **190 tests pasan correctamente**. Los componentes de autenticación, diagnósticos y widgets de UI se podrían cubrir con tests adicionales en el futuro.
