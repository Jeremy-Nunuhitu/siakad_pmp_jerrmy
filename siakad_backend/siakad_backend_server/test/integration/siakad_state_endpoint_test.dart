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
  });
}
