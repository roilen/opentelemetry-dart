// Copyright 2021-2022 Workiva Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//     http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm')
import 'package:mockito/mockito.dart';
import 'package:opentelemetry/src/api/span_processors/span_processor.dart';
import 'package:opentelemetry/src/sdk/trace/tracer_provider.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  test('getTracer stores tracers by name', () {
    final provider = TracerProviderBase();
    final fooTracer = provider.getTracer('foo');
    final barTracer = provider.getTracer('bar');
    final fooWithVersionTracer = provider.getTracer('foo', version: '1.0');

    expect(
        fooTracer,
        allOf([
          isNot(barTracer),
          isNot(fooWithVersionTracer),
          same(provider.getTracer('foo'))
        ]));

    expect(provider.spanProcessors, isA<List<SpanProcessor>>());
  });

  test('tracerProvider custom span processors', () {
    final mockProcessor1 = MockSpanProcessor();
    final mockProcessor2 = MockSpanProcessor();
    final provider =
        TracerProviderBase(processors: [mockProcessor1, mockProcessor2]);

    expect(provider.spanProcessors, [mockProcessor1, mockProcessor2]);
  });

  test('tracerProvider force flushes all processors', () {
    final mockProcessor1 = MockSpanProcessor();
    final mockProcessor2 = MockSpanProcessor();
    TracerProviderBase(processors: [mockProcessor1, mockProcessor2])
        .forceFlush();

    verify(mockProcessor1.forceFlush()).called(1);
    verify(mockProcessor2.forceFlush()).called(1);
  });

  test('tracerProvider shuts down all processors', () {
    final mockProcessor1 = MockSpanProcessor();
    final mockProcessor2 = MockSpanProcessor();
    TracerProviderBase(processors: [mockProcessor1, mockProcessor2]).shutdown();

    verify(mockProcessor1.shutdown()).called(1);
    verify(mockProcessor2.shutdown()).called(1);
  });
}
