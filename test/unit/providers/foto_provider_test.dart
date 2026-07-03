// =============================================================================
// TEST UNITARIO: FotoViewModel
// =============================================================================
// Pruebas unitarias para el ViewModel de fotos.
//
// Fecha: 2026-02-04
// Fase: 2 - Pruebas Unitarias
// Autor: QA Team - SymptoLeaf
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:symptoleaf/presentation/viewmodels/foto_viewmodel.dart';
import 'package:symptoleaf/presentation/models/foto.dart';

void main() {
  group('FotoViewModel - Estado Inicial', () {
    // =========================================================================
    // TEST UT-FP-001: Lista de fotos vacía inicialmente
    // =========================================================================
    test('UT-FP-001: debería iniciar con lista de fotos vacía', () {
      // Arrange & Act
      final viewModel = FotoViewModel();

      // Assert
      expect(viewModel.fotos, isEmpty);
      expect(viewModel.fotos.length, equals(0));
    });
  });

  group('FotoViewModel - Agregar Fotos', () {
    // =========================================================================
    // TEST UT-FP-002: Agregar una foto
    // =========================================================================
    test('UT-FP-002: debería agregar una foto correctamente', () {
      // Arrange
      final viewModel = FotoViewModel();
      final foto = Foto(
        path: '/path/to/image.jpg',
        nombre: 'test_image.jpg',
        description: 'Foto de prueba',
      );

      // Act
      viewModel.agregarFoto(foto);

      // Assert
      expect(viewModel.fotos.length, equals(1));
      expect(viewModel.fotos.first.path, equals('/path/to/image.jpg'));
      expect(viewModel.fotos.first.nombre, equals('test_image.jpg'));
    });

    // =========================================================================
    // TEST UT-FP-003: Agregar múltiples fotos
    // =========================================================================
    test('UT-FP-003: debería agregar múltiples fotos', () {
      // Arrange
      final viewModel = FotoViewModel();

      // Act
      for (int i = 0; i < 5; i++) {
        viewModel.agregarFoto(Foto(
          path: '/path/to/image_$i.jpg',
          nombre: 'image_$i.jpg',
          description: 'Foto $i',
        ));
      }

      // Assert
      expect(viewModel.fotos.length, equals(5));
    });

    // =========================================================================
    // TEST UT-FP-004: Fotos se agregan en orden
    // =========================================================================
    test('UT-FP-004: debería mantener orden de inserción', () {
      // Arrange
      final viewModel = FotoViewModel();

      // Act
      viewModel.agregarFoto(Foto(path: '/first.jpg', nombre: 'first', description: '1'));
      viewModel.agregarFoto(Foto(path: '/second.jpg', nombre: 'second', description: '2'));
      viewModel.agregarFoto(Foto(path: '/third.jpg', nombre: 'third', description: '3'));

      // Assert
      expect(viewModel.fotos[0].nombre, equals('first'));
      expect(viewModel.fotos[1].nombre, equals('second'));
      expect(viewModel.fotos[2].nombre, equals('third'));
    });
  });

  group('FotoViewModel - Eliminar Fotos', () {
    // =========================================================================
    // TEST UT-FP-005: Eliminar foto por índice
    // =========================================================================
    test('UT-FP-005: debería eliminar foto por índice', () {
      // Arrange
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/a.jpg', nombre: 'a', description: 'A'));
      viewModel.agregarFoto(Foto(path: '/b.jpg', nombre: 'b', description: 'B'));
      viewModel.agregarFoto(Foto(path: '/c.jpg', nombre: 'c', description: 'C'));
      expect(viewModel.fotos.length, equals(3));

      // Act
      viewModel.eliminarFoto(1); // Eliminar 'b'

      // Assert
      expect(viewModel.fotos.length, equals(2));
      expect(viewModel.fotos[0].nombre, equals('a'));
      expect(viewModel.fotos[1].nombre, equals('c'));
    });

    // =========================================================================
    // TEST UT-FP-006: Eliminar primera foto
    // =========================================================================
    test('UT-FP-006: debería eliminar primera foto', () {
      // Arrange
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/first.jpg', nombre: 'first', description: '1'));
      viewModel.agregarFoto(Foto(path: '/second.jpg', nombre: 'second', description: '2'));

      // Act
      viewModel.eliminarFoto(0);

      // Assert
      expect(viewModel.fotos.length, equals(1));
      expect(viewModel.fotos.first.nombre, equals('second'));
    });

    // =========================================================================
    // TEST UT-FP-007: Eliminar última foto
    // =========================================================================
    test('UT-FP-007: debería eliminar última foto', () {
      // Arrange
      final viewModel = FotoViewModel();
      viewModel.agregarFoto(Foto(path: '/first.jpg', nombre: 'first', description: '1'));
      viewModel.agregarFoto(Foto(path: '/second.jpg', nombre: 'second', description: '2'));

      // Act
      viewModel.eliminarFoto(1);

      // Assert
      expect(viewModel.fotos.length, equals(1));
      expect(viewModel.fotos.first.nombre, equals('first'));
    });

    // =========================================================================
    // TEST UT-FP-008: Eliminar todas las fotos
    // =========================================================================
    test('UT-FP-008: debería poder eliminar todas las fotos', () {
      // Arrange
      final viewModel = FotoViewModel();
      for (int i = 0; i < 3; i++) {
        viewModel.agregarFoto(Foto(path: '/img_$i.jpg', nombre: 'img_$i', description: '$i'));
      }
      expect(viewModel.fotos.length, equals(3));

      // Act - Eliminar de atrás hacia adelante
      viewModel.eliminarFoto(2);
      viewModel.eliminarFoto(1);
      viewModel.eliminarFoto(0);

      // Assert
      expect(viewModel.fotos, isEmpty);
    });
  });

  group('Foto Model', () {
    // =========================================================================
    // TEST UT-FP-009: Crear modelo Foto
    // =========================================================================
    test('UT-FP-009: debería crear modelo Foto correctamente', () {
      // Arrange & Act
      final foto = Foto(
        path: '/storage/emulated/0/DCIM/photo.jpg',
        nombre: 'photo.jpg',
        description: 'Hoja de tomate con manchas',
      );

      // Assert
      expect(foto.path, equals('/storage/emulated/0/DCIM/photo.jpg'));
      expect(foto.nombre, equals('photo.jpg'));
      expect(foto.description, equals('Hoja de tomate con manchas'));
    });

    // =========================================================================
    // TEST UT-FP-010: Foto con descripción vacía
    // =========================================================================
    test('UT-FP-010: debería permitir descripción vacía', () {
      // Arrange & Act
      final foto = Foto(
        path: '/path/to/img.jpg',
        nombre: 'img.jpg',
        description: '',
      );

      // Assert
      expect(foto.description, isEmpty);
    });
  });
}
