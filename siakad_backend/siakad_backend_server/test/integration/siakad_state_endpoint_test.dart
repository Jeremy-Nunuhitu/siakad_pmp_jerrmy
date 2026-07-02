import 'dart:convert';

import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given SiakadState endpoint', (sessionBuilder, endpoints) {
    test('when saving state then it can be loaded again', () async {
      const stateJson = '{"users":[],"fakultas":[]}';

      await endpoints.siakadState.saveState(sessionBuilder, stateJson);
      final loaded = await endpoints.siakadState.getState(sessionBuilder);

      expect(loaded, stateJson);
    });

    test(
      'when saving state then domain tables are upserted incrementally',
      () async {
        const firstState =
            '{"users":[],"fakultas":[{"id":"f-01","nama":"Teknik"},{"id":"f-02","nama":"Ekonomi"}]}';
        const secondState =
            '{"users":[],"fakultas":[{"id":"f-01","nama":"Teknik Informatika"}]}';

        await endpoints.siakadState.saveState(sessionBuilder, firstState);
        await endpoints.siakadState.saveState(sessionBuilder, secondState);

        final rowsJson = await endpoints.siakadState.listRows(
          sessionBuilder,
          'fakultas',
          limit: 10,
          offset: 0,
        );
        final rows = jsonDecode(rowsJson) as List<dynamic>;

        expect(rows, hasLength(1));
        expect(rows.single, containsPair('id', 'f-01'));
        expect(rows.single, containsPair('nama', 'Teknik Informatika'));
      },
    );

    test('when using row CRUD endpoint then one domain row changes', () async {
      await endpoints.siakadState.upsertRow(
        sessionBuilder,
        'fakultas',
        '{"id":"f-03","nama":"Kedokteran"}',
      );

      final rowJson = await endpoints.siakadState.getRow(
        sessionBuilder,
        'fakultas',
        'f-03',
      );
      expect(jsonDecode(rowJson!), containsPair('nama', 'Kedokteran'));
      expect(
        jsonDecode(
          (await endpoints.siakadState.getState(sessionBuilder))!,
        )['fakultas'],
        contains(containsPair('id', 'f-03')),
      );

      await endpoints.siakadState.deleteRow(
        sessionBuilder,
        'fakultas',
        'f-03',
      );

      final deleted = await endpoints.siakadState.getRow(
        sessionBuilder,
        'fakultas',
        'f-03',
      );
      expect(deleted, isNull);
      expect(
        jsonDecode(
          (await endpoints.siakadState.getState(sessionBuilder))!,
        )['fakultas'],
        isNot(contains(containsPair('id', 'f-03'))),
      );
    });

    test('when applying row changes then a batch is persisted', () async {
      await endpoints.siakadState.saveState(
        sessionBuilder,
        '{"users":[],"fakultas":[{"id":"f-10","nama":"Lama"}]}',
      );

      await endpoints.siakadState.applyRowChanges(
        sessionBuilder,
        jsonEncode([
          {
            'tableName': 'fakultas',
            'row': {'id': 'f-11', 'nama': 'Baru'},
          },
        ]),
        jsonEncode([
          {'tableName': 'fakultas', 'id': 'f-10'},
        ]),
      );

      final rows =
          jsonDecode(
                await endpoints.siakadState.listRows(
                  sessionBuilder,
                  'fakultas',
                  limit: 10,
                  offset: 0,
                ),
              )
              as List<dynamic>;

      expect(rows, hasLength(1));
      expect(rows.single, containsPair('id', 'f-11'));
      expect(
        jsonDecode(
          (await endpoints.siakadState.getState(sessionBuilder))!,
        )['fakultas'],
        contains(containsPair('nama', 'Baru')),
      );
    });
  });
}
