import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class PrinterInfo {
  final String name;
  final String portName;
  final String driverName;
  final int status;

  PrinterInfo({
    required this.name,
    required this.portName,
    required this.driverName,
    required this.status,
  });
}

class PrinterNames {
  final int _flags;

  PrinterNames(this._flags);

  List<PrinterInfo> getPrinters() {
    final printers = <PrinterInfo>[];
    final pBuffSize = calloc<DWORD>();
    final bPrinterLen = calloc<DWORD>();

    try {
      EnumPrinters(_flags, nullptr, 2, nullptr, 0, pBuffSize, bPrinterLen);

      if (pBuffSize.value == 0) {
        throw 'Failed to read printer buffer size.';
      }

      final rawBuffer = malloc.allocate<BYTE>(pBuffSize.value);
      try {
        if (EnumPrinters(_flags, nullptr, 2, rawBuffer, pBuffSize.value,
                pBuffSize, bPrinterLen) ==
            0) {
          throw 'Failed to read printer raw buffer.';
        }

        for (var i = 0; i < bPrinterLen.value; i++) {
          final printer = rawBuffer.cast<PRINTER_INFO_2>() + i;
          final name = _safeToDartString(printer.ref.pPrinterName);
          final portName = _safeToDartString(printer.ref.pPortName);
          final driverName = _safeToDartString(printer.ref.pDriverName);
          final status = printer.ref.Status;

          printers.add(PrinterInfo(
            name: name,
            portName: portName,
            driverName: driverName,
            status: status,
          ));
        }
      } finally {
        malloc.free(rawBuffer);
      }
    } finally {
      malloc.free(pBuffSize);
      malloc.free(bPrinterLen);
    }

    return printers;
  }

  String _safeToDartString(Pointer<Utf16>? pointer) {
    return pointer == nullptr ? '' : pointer!.toDartString();
  }
}

void main() {
  runApp(PrinterApp());
}

class PrinterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Printer Info',
      home: PrinterListScreen(),
    );
  }
}

class PrinterListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final printerNames = PrinterNames(PRINTER_ENUM_LOCAL);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printers'),
      ),
      body: FutureBuilder<List<PrinterInfo>>(
        future: Future(() => printerNames.getPrinters()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: const CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No printers found.'));
          }

          final printers = snapshot.data!;
          return ListView.builder(
            itemCount: printers.length,
            itemBuilder: (context, index) {
              final printer = printers[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(printer.name),
                  subtitle: Text(
                      'Port: ${printer.portName}\nDriver: ${printer.driverName}\nStatus: ${printer.status}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
