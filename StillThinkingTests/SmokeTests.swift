import Testing

@Suite("Базовая конфигурация проекта")
struct SmokeTests {
    @Test("Тестовый target запускается через Swift Testing")
    func testTargetRuns() {
        #expect(true)
    }
}
