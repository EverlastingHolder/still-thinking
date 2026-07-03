//
//  ThoughtRepository.swift
//  StillThinking
//
//  Created by roman.moshkovcev on 03.07.2026.
//

import Foundation

@MainActor
protocol ThoughtRepository {
    func createThought(_ thought: Thought, schedule: ReturnSchedule?) async throws
    func thought(id: UUID) async throws -> Thought?
    func thoughts(with status: ThoughtStatus) async throws -> [Thought]
    func updateThought(_ thought: Thought) async throws
    func deleteThought(id: UUID) async throws
    func addReflection(_ reflection: Reflection) async throws
    func reflections(for thoughtID: UUID) async throws -> [Reflection]
    func recordReflection(
        _ reflection: Reflection,
        updatedThought: Thought,
        nextSchedule: ReturnSchedule?
    ) async throws
    func updateSchedule(_ schedule: ReturnSchedule) async throws
    func schedules(for thoughtID: UUID) async throws -> [ReturnSchedule]
    func schedules(state: ReturnScheduleState, dueOnOrBefore date: Date) async throws -> [ReturnSchedule]
}
